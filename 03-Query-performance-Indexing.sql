-- Add indexes to improve query performance
CREATE INDEX IDX_FactSales_DateKey ON FactSales(date_key);
GO
CREATE INDEX IDX_FactSales_CustomerKey ON FactSales(customer_key);
GO
CREATE INDEX IDX_FactSales_ProductKey ON FactSales(product_key);
GO

CREATE INDEX IDX_FactHealthMetrics_DateKey ON FactHealthMetrics(date_key);
GO
CREATE INDEX IDX_FactHealthMetrics_CustomerKey ON FactHealthMetrics(customer_key);
GO
CREATE INDEX IDX_FactDevices_DateKey ON FactDevices(date_key);
GO
CREATE INDEX IDX_FactDevices_CustomerKey ON FactDevices(customer_key);
GO
CREATE INDEX IDX_FactDevices_DeviceKey ON FactDevices(device_key);
GO

-- Index for date-based filtering or grouping (e.g., active assignments over time)
CREATE INDEX IDX_FactCoachAssignment_StartDateKey ON FactCoach_Assignment(start_date_key);
GO
CREATE INDEX IDX_FactCoachAssignment_EndDateKey ON FactCoach_Assignment(end_date_key);
GO

-- Index for coach-based analysis (e.g., coach workload, customer count per coach)
CREATE INDEX IDX_FactCoachAssignment_CoachKey ON FactCoach_Assignment(coach_key);
GO

-- Index for customer-based filtering (e.g., who was coached, repeat assignments)
CREATE INDEX IDX_FactCoachAssignment_CustomerKey ON FactCoach_Assignment(customer_key);
GO
