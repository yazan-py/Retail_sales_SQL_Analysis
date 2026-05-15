SELECT 'Source FactSales Count' AS Description, COUNT(*) AS RecordCount 
FROM [dbo].[FactSales]
UNION ALL
SELECT 'Target Sales Fact Count', COUNT(*) 
FROM [dbo].[FactSales];

SELECT 'Source FactHealthMetrics Count' AS Description, COUNT(*) AS RecordCount 
FROM [dbo].[FactHealthMetrics]
UNION ALL
SELECT 'Target HealthMetrics Fact Count', COUNT(*) 
FROM [dbo].[FactHealthMetrics];

SELECT 'Source FactDevices Count' AS Description, COUNT(*) AS RecordCount 
FROM [dbo].[FactDevices]
UNION ALL
SELECT 'Target Devices Fact Count', COUNT(*) 
FROM [dbo].[FactDevices];

-- Analytical query 1: Calculate average health metrics by subscription type
SELECT 
    c.subscription_type,
    AVG(h.avg_heart_rate) AS average_heart_rate,
    AVG(h.avg_sleep_hours) AS average_sleep_hours,
    AVG(h.avg_daily_steps) AS average_daily_steps
FROM [dbo].[FactHealthMetrics] h
JOIN [dbo].[DimCustomer] c ON h.customer_key = c.customer_key
GROUP BY c.subscription_type
ORDER BY c.subscription_type;

-- Analytical query 2: Calculate sales by product category and region
SELECT 
    p.product_category,
    l.region,
    SUM(s.total_amount) AS total_sales,
    COUNT(distinct s.customer_key) AS customer_count
FROM [dbo].[FactSales] s
JOIN [dbo].[DimProduct] p ON s.product_key = p.product_key
JOIN [dbo].[DimLocation] l ON s.location_key = l.location_key
GROUP BY p.product_category, l.region
ORDER BY p.product_category, total_sales DESC;

-- Analytical query 3: Track device usage trends by device type
SELECT 
    d.device_type,
    AVG(f.active_hours_daily) AS avg_active_hours,
    AVG(f.sync_frequency_daily) AS avg_sync_frequency,
    SUM(f.total_steps_recorded) AS total_steps,
    COUNT(*) AS device_count
FROM [dbo].[FactDevices] f
JOIN [dbo].[DimDevice] d ON f.device_key = d.device_key
GROUP BY d.device_type
ORDER BY avg_active_hours DESC;

-- Query that analyzes correlation between device usage and health metrics
SELECT 
    c.subscription_type,
    d.device_type,
    AVG(fd.active_hours_daily) AS avg_device_hours,
    AVG(fhm.avg_sleep_hours) AS avg_sleep_hours,
    AVG(fhm.avg_heart_rate) AS avg_heart_rate,
    COUNT(DISTINCT c.customer_key) AS customer_count
FROM [dbo].[DimCustomer] c
JOIN [dbo].[FactDevices] fd ON c.customer_key = fd.customer_key
JOIN [dbo].[DimDevice] d ON fd.device_key = d.device_key
JOIN [dbo].[FactHealthMetrics] fhm ON c.customer_key = fhm.customer_key
GROUP BY c.subscription_type, d.device_type
ORDER BY c.subscription_type, avg_device_hours DESC;

-----------------------------------------------

SELECT dd.year, dd.month, SUM(fs.total_amount) AS MonthlySales
FROM FactSales fs
JOIN DimDate dd ON fs.date_key = dd.date_key
GROUP BY dd.year, dd.month;
-----------------------------------------------

SELECT dp.product_name, SUM(fs.total_amount) AS TotalRevenue
FROM [dbo].[FactSales] fs
JOIN [dbo].[DimProduct] dp ON fs.product_id = dp.product_id
GROUP BY dp.product_name;
-----------------------------------------------

SELECT dd.year, SUM(fs.total_amount) AS YearlySales
FROM [dbo].[FactSales] fs
JOIN [dbo].[DimDate] dd ON fs.date_key = dd.date_key
WHERE dd.year = 2025
GROUP BY dd.year
HAVING SUM(fs.total_amount) > 10000;

-- Sample query to analyze total sales by product category
SELECT 
    dp.product_category,
    SUM(fs.total_amount) AS total_revenue,
    SUM(fs.quantity) AS total_units_sold
FROM [dbo].[FactSales] fs
JOIN [dbo].[DimProduct] dp ON fs.product_key = dp.product_key
GROUP BY dp.product_category
ORDER BY total_revenue DESC;

-- Query for monthly sales trends
SELECT 
    dd.year,
    dd.month,
    dd.month_name,
    SUM(fs.total_amount) AS monthly_sales
FROM [dbo].[FactSales] fs
JOIN [dbo].[DimDate] dd ON fs.date_key = dd.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;

-- Partial query to identify high-value customers
SELECT
    dc.customer_key,
    dc.subscription_type,
    SUM(fs.total_amount) AS total_spent
FROM [dbo].[FactSales] fs
JOIN [dbo].[DimCustomer] dc ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.subscription_type
-- Complete the query with filters and ordering

-- Query template for device usage analysis
SELECT
    dd.device_type,
    AVG(fd.active_hours_daily) AS avg_daily_active_hours,
    AVG(fd.total_steps_recorded) AS avg_steps_recorded,
    COUNT(fd.device_usage_key) AS device_count
FROM [dbo].[FactDevices] fd
JOIN [dbo].[DimDevice] dd ON fd.device_key = dd.device_key
-- Your additional joins and WHERE/HAVING clauses here
GROUP BY dd.device_type;

-- Individual products with average price per unit
SELECT 
    dp.product_name,
    dp.product_category,
    SUM(fs.total_amount) AS total_revenue,
    SUM(fs.quantity) AS total_units_sold,
    CASE 
        WHEN SUM(fs.quantity) > 0 THEN SUM(fs.total_amount) / SUM(fs.quantity) 
        ELSE 0 
    END AS avg_price_per_unit
FROM [dbo].[FactSales] fs
JOIN [dbo].[DimProduct] dp ON fs.product_key = dp.product_key
GROUP BY dp.product_name, dp.product_category
ORDER BY total_revenue DESC;

-- Weekend vs. Weekday Sales
SELECT 
    CASE WHEN dd.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(*) AS number_of_sales,
    SUM(fs.total_amount) AS total_revenue,
    AVG(fs.total_amount) AS avg_order_value
FROM [dbo].[FactSales] fs
JOIN [dbo].[DimDate] dd ON fs.date_key = dd.date_key
GROUP BY CASE WHEN dd.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END
ORDER BY day_type;

-- Weekend vs. Weekday Sales
SELECT 
    CASE WHEN dd.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(*) AS number_of_sales,
    SUM(fs.total_amount) AS total_revenue,
    AVG(fs.total_amount) AS avg_order_value
FROM [dbo].[FactSales] fs
JOIN [dbo].[DimDate] dd ON fs.date_key = dd.date_key
GROUP BY CASE WHEN dd.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END
ORDER BY day_type;

-- Quarterly Sales
SELECT 
    dd.year,
    dd.quarter,
    SUM(fs.total_amount) AS quarterly_sales,
    COUNT(*) AS number_of_sales
FROM [dbo].[FactSales] fs
JOIN [dbo].[DimDate] dd ON fs.date_key = dd.date_key
GROUP BY dd.year, dd.quarter
ORDER BY dd.year, dd.quarter;

-- Top 10 Highest-Spending Customers
SELECT TOP 10
    dc.customer_key,
    dc.subscription_type,
    dc.age,
    SUM(fs.total_amount) AS total_spent
FROM [dbo].[FactSales] fs
JOIN [dbo].[DimCustomer] dc ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.subscription_type, dc.age
ORDER BY total_spent DESC;

-- Customer Spending and Health Metrics by Gender
SELECT 
    dc.gender,
    COUNT(DISTINCT dc.customer_key) AS customer_count,
    AVG(fs.total_amount) AS avg_customer_spend,
    AVG(fhm.avg_daily_steps) AS avg_daily_steps,
    AVG(fhm.avg_sleep_hours) AS avg_sleep_hours
FROM [dbo].[DimCustomer] dc
JOIN [dbo].[FactSales] fs ON dc.customer_key = fs.customer_key
JOIN [dbo].[FactHealthMetrics] fhm ON dc.customer_key = fhm.customer_key
GROUP BY dc.gender;

-- Active Devices Analysis
SELECT
    dd.device_type,
    AVG(fd.active_hours_daily) AS avg_daily_active_hours,
    AVG(fd.total_steps_recorded) AS avg_steps_recorded,
    COUNT(fd.device_usage_key) AS device_count
FROM [dbo].[FactDevices] fd
JOIN [dbo].[DimDevice] dd ON fd.device_key = dd.device_key
WHERE fd.device_status = 'Active'
GROUP BY dd.device_type;

-- Device Usage and Health Metrics Correlation
SELECT
    dd.device_type,
    AVG(fd.active_hours_daily) AS avg_daily_active_hours,
    AVG(fd.total_steps_recorded) AS avg_steps_recorded,
    AVG(fhm.avg_heart_rate) AS avg_heart_rate,
    AVG(fhm.avg_sleep_hours) AS avg_sleep_hours
FROM [dbo].[FactDevices] fd
JOIN [dbo].[DimDevice] dd ON fd.device_key = dd.device_key
JOIN [dbo].[DimCustomer] dc ON fd.customer_key = dc.customer_key
JOIN [dbo].[FactHealthMetrics] fhm ON dc.customer_key = fhm.customer_key
WHERE fd.device_status = 'Active'
GROUP BY dd.device_type
HAVING AVG(fd.active_hours_daily) > 4 AND AVG(fd.total_steps_recorded) > 8000;

