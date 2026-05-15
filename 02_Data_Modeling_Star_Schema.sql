-- Create the TechHealthDW database
CREATE DATABASE TechHealthDW;
GO

-- Use the newly created database
USE TechHealthDW;
GO

-- Create dimension tables
-- DimDate dimension table
CREATE TABLE [dbo].[DimDate] (
    date_key INT PRIMARY KEY,  -- was DATE
    date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
        year INT NOT NULL,
    quarter INT NOT NULL,
    is_weekend BIT NOT NULL,
    month_name VARCHAR(10) NOT NULL
);
GO

-- DimCustomer dimension table
CREATE TABLE [dbo].[DimCustomer] (
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    user_id VARCHAR(10) NOT NULL,  -- Original key from source
    age INT NOT NULL,
    gender CHAR(1) NOT NULL,
    occupation VARCHAR(100) NULL,
    income_bracket VARCHAR(20) NULL,
    subscription_type VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL
);
GO

-- DimLocation dimension table
CREATE TABLE [dbo].[DimLocation] (
    location_key INT IDENTITY(1,1) PRIMARY KEY,
    location_id INT NULL, -- Original key from source
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NULL,
    country VARCHAR(50) NOT NULL,
    region VARCHAR(50) NULL
);
GO

-- DimDevice dimension table
CREATE TABLE [dbo].[DimDevice] (
    device_key INT IDENTITY(1,1) PRIMARY KEY,
    device_id VARCHAR(10) NOT NULL, -- Original key from source
    device_type VARCHAR(100) NOT NULL,
    firmware_version VARCHAR(10) NOT NULL,
    battery_life_days DECIMAL(3,1) NOT NULL,
    sleep_tracking_enabled BIT NOT NULL,
    heart_rate_monitoring_enabled BIT NOT NULL,
    gps_enabled BIT NOT NULL
);
GO

-- DimCoach dimension table
CREATE TABLE [dbo].[DimCoach] (
    coach_key INT IDENTITY(1,1) PRIMARY KEY,
    coach_id VARCHAR(10) NOT NULL, -- Original key from source
    first_name VARCHAR(50) NULL,
    last_name VARCHAR(50) NULL,
    specialization VARCHAR(100) NULL,
    experience_years INT NULL,
    region VARCHAR(50) NULL
);
GO

-- DimProduct dimension table
CREATE TABLE [dbo].[DimProduct] (
    product_key INT IDENTITY(1,1) PRIMARY KEY,
    product_id VARCHAR(20) NOT NULL, -- Original key from source
    product_name VARCHAR(100) NOT NULL,
    product_category VARCHAR(50) NOT NULL
);
GO

-- Create fact tables
-- FactSales fact table
CREATE TABLE [dbo].[FactSales] (
    sale_key INT IDENTITY(1,1) PRIMARY KEY,
    sale_id VARCHAR(10) NOT NULL, -- Original key from source
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    location_key INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    discount_applied DECIMAL(5,2) NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    sales_channel VARCHAR(50) NOT NULL,
    CONSTRAINT FK_FactSales_DimDate FOREIGN KEY (date_key) REFERENCES DimDate(date_key),
    CONSTRAINT FK_FactSales_DimCustomer FOREIGN KEY (customer_key) REFERENCES DimCustomer(customer_key),
    CONSTRAINT FK_FactSales_DimProduct FOREIGN KEY (product_key) REFERENCES DimProduct(product_key),
    CONSTRAINT FK_FactSales_DimLocation FOREIGN KEY (location_key) REFERENCES DimLocation(location_key)
);
GO

-- FactHealthMetrics fact table
CREATE TABLE [dbo].[FactHealthMetrics] (
    health_metric_key INT IDENTITY(1,1) PRIMARY KEY,
    record_id VARCHAR(10) NOT NULL, -- Original key from source
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    avg_heart_rate INT NOT NULL,
    avg_daily_steps INT NOT NULL,
    avg_sleep_hours DECIMAL(3,1) NOT NULL,
    avg_deep_sleep_hours DECIMAL(3,1) NOT NULL,
    avg_daily_calories INT NOT NULL,
    avg_exercise_minutes INT NOT NULL,
    avg_stress_level DECIMAL(3,1) NULL,
    avg_blood_oxygen DECIMAL(4,1) NOT NULL,
    total_active_days INT NOT NULL,
    workout_frequency INT NOT NULL,
    CONSTRAINT FK_FactHealthMetrics_DimDate FOREIGN KEY (date_key) REFERENCES DimDate(date_key),
    CONSTRAINT FK_FactHealthMetrics_DimCustomer FOREIGN KEY (customer_key) REFERENCES DimCustomer(customer_key)
);
GO

-- FactDevices fact table
CREATE TABLE [dbo].[FactDevices](
    device_usage_key INT IDENTITY(1,1) PRIMARY KEY,
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    device_key INT NOT NULL,
    last_sync_date DATE NOT NULL,
    sync_frequency_daily INT NOT NULL,
    active_hours_daily DECIMAL(3,1) NOT NULL,
    total_steps_recorded BIGINT NOT NULL,
    total_workouts_recorded INT NOT NULL,
    device_status VARCHAR(50) NOT NULL,
    CONSTRAINT FK_FactDevices_DimDate FOREIGN KEY (date_key) REFERENCES DimDate(date_key),
    CONSTRAINT FK_FactDevices_DimCustomer FOREIGN KEY (customer_key) REFERENCES DimCustomer(customer_key),
    CONSTRAINT FK_FactDevices_DimDevice FOREIGN KEY (device_key) REFERENCES DimDevice(device_key)
);
GO
-- Create FactCoach_Assignment fact table
CREATE TABLE [dbo].[FactCoach_Assignment] (
    coach_assignment_key INT IDENTITY(1,1) PRIMARY KEY,
    coach_key INT NOT NULL,
    customer_key INT NOT NULL,
    start_date_key INT NOT NULL,
    end_date_key INT NOT NULL,
    CONSTRAINT FK_FactCoachAssignment_DimCoach FOREIGN KEY (coach_key) REFERENCES DimCoach(coach_key),
    CONSTRAINT FK_FactCoachAssignment_DimCustomer FOREIGN KEY (customer_key) REFERENCES DimCustomer(customer_key),
    CONSTRAINT FK_FactCoachAssignment_StartDate FOREIGN KEY (start_date_key) REFERENCES DimDate(date_key),
    CONSTRAINT FK_FactCoachAssignment_EndDate FOREIGN KEY (end_date_key) REFERENCES DimDate(date_key)
);
GO
