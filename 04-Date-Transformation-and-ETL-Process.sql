-- First, populate the dimension tables

-- Populate DimDate with a simple date range 
-- This will create over 2,000 non-duplicate dates 
WITH DateSequence AS (
    SELECT CAST('2020-01-01' AS DATE) AS [date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [date])
    FROM DateSequence
    WHERE [date] < '2025-12-31'
)
INSERT INTO [dbo].[DimDate] (
    date_key, date, day, month, year, quarter, is_weekend, month_name
)
SELECT 
    CONVERT(INT, FORMAT([date], 'yyyyMMdd')) AS date_key,
    [date],
    DATEPART(DAY, [date]),
    DATEPART(MONTH, [date]),
    DATEPART(YEAR, [date]),
    DATEPART(QUARTER, [date]),
    CASE WHEN DATEPART(WEEKDAY, [date]) IN (6, 7) THEN 1 ELSE 0 END,
    DATENAME(MONTH, [date])
FROM DateSequence
-- MAXRECURSION 0 is required to generate more than 100 rows.
OPTION (MAXRECURSION 0);
GO

-- Populate DimCustomer
INSERT INTO [dbo].[DimCustomer] (user_id, age, gender, occupation, income_bracket, subscription_type, registration_date)
SELECT
    user_id,
    age,
    gender,
    occupation,
    income_bracket,
    subscription_type,
    registration_date
FROM TechHealthDb.dbo.Customers;
GO

-- Populate DimLocation
INSERT INTO [dbo].[DimLocation] (location_id, city, state, country, region)
SELECT
    gl.location_id,
    gl.city,
    gl.state,
    gl.country,
    s.region
FROM TechHealthDb.dbo.GeoLocation gl
LEFT JOIN (SELECT DISTINCT region, user_id FROM TechHealthDb.dbo.Sales) s
ON gl.location_id = (SELECT location_id FROM TechHealthDb.dbo.Customers WHERE user_id = s.user_id);
GO

-- Populate DimDevice
INSERT INTO [dbo].[DimDevice] (device_id, device_type, firmware_version, battery_life_days, 
                     sleep_tracking_enabled, heart_rate_monitoring_enabled, gps_enabled)
SELECT
    device_id,
    device_type,
    firmware_version,
    battery_life_days,
    sleep_tracking_enabled,
    heart_rate_monitoring_enabled,
    gps_enabled
FROM TechHealthDb.dbo.Devices;
GO

-- Populate DimCoach
INSERT INTO [dbo].[DimCoach] (coach_id, first_name, last_name, specialization, experience_years, region)
SELECT
    coach_id,
    first_name,
    last_name,
    specialization,
    experience_years,
    region
FROM TechHealthDb.dbo.Coaches;
GO

-- Populate DimProduct
INSERT INTO [dbo].[DimProduct] (product_id, product_name, product_category)
SELECT
    product_id,
    product_name,
    product_category
FROM TechHealthDb.dbo.Products;
GO

-- Next, populate the fact tables.
-- Populate FactSales with INT-formatted date_key
INSERT INTO [dbo].[FactSales] (sale_id, date_key, customer_key, product_key, location_key, 
                     unit_price, quantity, discount_applied, total_amount, 
                     payment_method, sales_channel)
SELECT
    s.sale_id,
    CONVERT(INT, FORMAT(s.sale_date, 'yyyyMMdd')) AS date_key,  -- fixed here
    dc.customer_key,
    dp.product_key,
    dl.location_key,
    s.unit_price,
    s.quantity,
    s.discount_applied,
    s.total_amount,
    s.payment_method,
    s.sales_channel
FROM TechHealthDb.dbo.Sales s
JOIN [dbo].[DimCustomer] dc ON s.user_id = dc.user_id
JOIN [dbo].[DimProduct] dp ON s.product_id = dp.product_id
JOIN TechHealthDb.dbo.Customers c ON s.user_id = c.user_id
JOIN [dbo].[DimLocation] dl ON c.location_id = dl.location_id;
GO


-- Populate FactHealthMetrics with properly formatted date_key
INSERT INTO [dbo].[FactHealthMetrics] (
    record_id, date_key, customer_key, avg_heart_rate, avg_daily_steps, 
    avg_sleep_hours, avg_deep_sleep_hours, avg_daily_calories, 
    avg_exercise_minutes, avg_stress_level, avg_blood_oxygen, 
    total_active_days, workout_frequency)
SELECT
    hm.record_id,
    CONVERT(INT, FORMAT(hm.month_date, 'yyyyMMdd')) AS date_key,  -- fix applied here
    dc.customer_key,
    hm.avg_heart_rate,
    hm.avg_daily_steps,
    hm.avg_sleep_hours,
    hm.avg_deep_sleep_hours,
    hm.avg_daily_calories,
    hm.avg_exercise_minutes,
    hm.avg_stress_level,
    hm.avg_blood_oxygen,
    hm.total_active_days,
    hm.workout_frequency
FROM TechHealthDb.dbo.HealthMetrics hm
JOIN [dbo].[DimCustomer] dc ON hm.user_id = dc.user_id;
GO

-- Populate FactCoach_Assignment
INSERT INTO [dbo].[FactCoach_Assignment] (
    coach_key,
    customer_key,
    start_date_key,
    end_date_key
)
SELECT 
    dc.coach_key,
    dcu.customer_key,
    ds.date_key AS start_date_key,
    de.date_key AS end_date_key
FROM TechHealthDb.dbo.Coach_Customer cc
JOIN [dbo].[DimCoach] dc ON cc.coach_id = dc.coach_id
JOIN [dbo].[DimCustomer] dcu ON cc.user_id = dcu.user_id
JOIN [dbo].[DimDate] ds ON cc.start_date = ds.date
JOIN [dbo].[DimDate] de ON cc.end_date = de.date;
GO

-- Populate FactDevices
INSERT INTO [dbo].[FactDevices] (date_key, customer_key, device_key, last_sync_date, 
                      sync_frequency_daily, active_hours_daily, total_steps_recorded, 
                      total_workouts_recorded, device_status)
SELECT
    CONVERT(INT, FORMAT(d.purchase_date, 'yyyyMMdd')) AS date_key,
    dc.customer_key,
    dd.device_key,
    d.last_sync_date,
    d.sync_frequency_daily,
    d.active_hours_daily,
    d.total_steps_recorded,
    d.total_workouts_recorded,
    d.device_status
FROM TechHealthDb.dbo.Devices d
JOIN [dbo].[DimCustomer]  dc ON d.user_id = dc.user_id
JOIN [dbo].[DimDevice] dd ON d.device_id = dd.device_id;
GO
