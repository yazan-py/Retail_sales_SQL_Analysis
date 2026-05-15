-- Create the database
CREATE DATABASE TechHealthDb;
GO

-- Use the newly created database
USE TechHealthDb;
GO

-- Verify creation by checking system databases
SELECT * FROM sys.databases 
WHERE name = 'TechHealthDb';
GO
-- Create the tables in this order, 1-9. 
-- 1. GeoLocation
CREATE TABLE [dbo].[GeoLocation] (
    [location_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [city] VARCHAR(100) NOT NULL,
    [state] VARCHAR(50) NULL,
    [country] VARCHAR(50) NOT NULL,
    CONSTRAINT UQ_GeoLocation_Location UNIQUE ([city], [state], [country])
);
GO

-- 2. Coaches
CREATE TABLE [dbo].[Coaches] (
    [coach_id] VARCHAR(10) NOT NULL PRIMARY KEY,
    [first_name] VARCHAR(50) NULL,
    [last_name] VARCHAR(50) NULL,
    [specialization] VARCHAR(100) NULL,
    [experience_years] INT NULL,
    [certification] VARCHAR(100) NULL,
    [region] VARCHAR(50) NULL,
    [contact_email] VARCHAR(100) NULL,
    [contact_number] VARCHAR(20) NULL
);
GO

-- 3. Customers 
CREATE TABLE [dbo].[Customers] (
    [user_id] VARCHAR(10) NOT NULL PRIMARY KEY,
    [age] INT NOT NULL CHECK ([age] BETWEEN 0 AND 120),
    [gender] CHAR(1) NOT NULL CHECK ([gender] IN ('F', 'M')),
    [occupation] VARCHAR(100) NULL,
    [income_bracket] VARCHAR(20) NULL,
    [registration_date] DATE NOT NULL DEFAULT (GETDATE()),
    [subscription_type] VARCHAR(50) NOT NULL CHECK ([subscription_type] IN ('Enterprise', 'Premium', 'Basic')),
    [location_id] INT NULL,
    CONSTRAINT FK_Customers_GeoLocation FOREIGN KEY ([location_id]) REFERENCES [dbo].[GeoLocation] ([location_id])
);
GO

-- 4. Products
CREATE TABLE [dbo].[Products] (
    [product_key] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [product_id] VARCHAR(20) NOT NULL,
    [product_name] VARCHAR(100) NOT NULL,
    [product_category] VARCHAR(50) NOT NULL,
    CONSTRAINT UQ_Products_ProductID UNIQUE ([product_id])
);
GO

-- 5. Devices
CREATE TABLE [dbo].[Devices] (
    [device_id] VARCHAR(10) NOT NULL PRIMARY KEY,
    [user_id] VARCHAR(10) NOT NULL,
    [device_type] VARCHAR(100) NOT NULL,
    [purchase_date] DATE NOT NULL DEFAULT (GETDATE()),
    [last_sync_date] DATE NOT NULL,
    [firmware_version] VARCHAR(10) NOT NULL DEFAULT ('v3.1.0'),
    [battery_life_days] DECIMAL(3,1) NOT NULL CHECK (battery_life_days >= 0),
    [sync_frequency_daily] INT NOT NULL CHECK (sync_frequency_daily >= 0),
    [active_hours_daily] DECIMAL(3,1) NOT NULL CHECK (active_hours_daily BETWEEN 0 AND 24),
    [total_steps_recorded] BIGINT NOT NULL CHECK (total_steps_recorded >= 0),
    [total_workouts_recorded] INT NOT NULL CHECK (total_workouts_recorded >= 0),
    [sleep_tracking_enabled] BIT NOT NULL DEFAULT (0),
    [heart_rate_monitoring_enabled] BIT NOT NULL DEFAULT (0),
    [gps_enabled] BIT NOT NULL DEFAULT (0),
    [notification_enabled] BIT NOT NULL DEFAULT (0),
    [device_status] VARCHAR(50) NOT NULL CHECK (device_status IN ('Retired', 'Inactive', 'Active')),
    CONSTRAINT FK_Devices_Customers FOREIGN KEY ([user_id])
        REFERENCES [dbo].[Customers] ([user_id])
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
GO

-- 6. HealthMetrics
CREATE TABLE [dbo].[HealthMetrics] (
    [record_id] VARCHAR(10) NOT NULL PRIMARY KEY,
    [user_id] VARCHAR(10) NOT NULL,
    [month_date] DATE NOT NULL,
    [avg_heart_rate] INT NOT NULL CHECK ([avg_heart_rate] BETWEEN 30 AND 200),
    [avg_resting_heart_rate] INT NOT NULL CHECK ([avg_resting_heart_rate] BETWEEN 30 AND 100),
    [avg_daily_steps] INT NOT NULL CHECK ([avg_daily_steps] >= 0),
    [avg_sleep_hours] DECIMAL(3,1) NOT NULL CHECK ([avg_sleep_hours] BETWEEN 0 AND 24),
    [avg_deep_sleep_hours] DECIMAL(3,1) NOT NULL CHECK ([avg_deep_sleep_hours] BETWEEN 0 AND 12),
    [avg_daily_calories] INT NOT NULL CHECK ([avg_daily_calories] >= 0),
    [avg_exercise_minutes] INT NOT NULL CHECK ([avg_exercise_minutes] >= 0),
    [avg_stress_level] DECIMAL(3,1) NULL CHECK ([avg_stress_level] BETWEEN 0 AND 10),
    [avg_blood_oxygen] DECIMAL(4,1) NOT NULL CHECK ([avg_blood_oxygen] BETWEEN 80 AND 100),
    [total_active_days] INT NOT NULL CHECK ([total_active_days] BETWEEN 0 AND 31),
    [workout_frequency] INT NOT NULL CHECK ([workout_frequency] BETWEEN 0 AND 7),
    [achievement_rate] DECIMAL(3,2) NULL CHECK ([achievement_rate] BETWEEN 0 AND 1),
    CONSTRAINT FK_HealthMetrics_Customers FOREIGN KEY ([user_id])
        REFERENCES [dbo].[Customers]([user_id])
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
GO


-- 7. Coach_Customer
CREATE TABLE [dbo].[Coach_Customer] (
    [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [coach_id] VARCHAR(10) NULL,
    [user_id] VARCHAR(10) NULL,
    [start_date] DATE NULL,
    [end_date] DATE NULL,
    FOREIGN KEY ([coach_id]) REFERENCES [dbo].[Coaches]([coach_id]),
    FOREIGN KEY ([user_id]) REFERENCES [dbo].[Customers]([user_id])
);
GO

-- 8. Sales
CREATE TABLE [dbo].[Sales] (
    [sale_id] VARCHAR(10) NOT NULL PRIMARY KEY,
    [user_id] VARCHAR(10) NOT NULL,
    [sale_date] DATE NOT NULL DEFAULT (GETDATE()),
    [product_id] VARCHAR(20) NOT NULL,
    [unit_price] DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    [quantity] INT NOT NULL CHECK (quantity > 0),
    [discount_applied] DECIMAL(5,2) NULL CHECK (discount_applied BETWEEN 0 AND 100),
    [total_amount] DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    [payment_method] VARCHAR(50) NOT NULL CHECK (payment_method IN ('Bank Transfer', 'PayPal', 'Credit Card')),
    [subscription_plan] VARCHAR(50) NULL,
    [sales_channel] VARCHAR(50) NOT NULL CHECK (sales_channel IN ('Direct Sales', 'Retail', 'Online')),
    [region] VARCHAR(50) NOT NULL,
    [sales_rep_id] VARCHAR(10) NOT NULL,
    CONSTRAINT FK_Sales_Customers FOREIGN KEY ([user_id])
        REFERENCES [dbo].[Customers]([user_id])
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_Sales_Products FOREIGN KEY ([product_id])
        REFERENCES [dbo].[Products]([product_id])
);
GO


