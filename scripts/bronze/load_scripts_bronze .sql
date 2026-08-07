/*==============================================================================
Load Bronze Layer
==============================================================================
Script Purpose:
    Loads raw CSV files into the Bronze layer tables.

    Existing data is removed before loading the latest files.

    Data is loaded exactly as received from the source systems without any
    transformations.

NOTE:
    Ensure LOCAL INFILE is enabled before executing this script.
==============================================================================*/
-- Start Time to load the bronze layer
SET @start_time = NOW();

USE datawarehouse;

-- ============================================================================
-- CRM Customer Information
-- ============================================================================

TRUNCATE TABLE bronze_crm_cust_info;

LOAD DATA LOCAL INFILE
'C:/Users/BIT/Desktop/sql/sql with barra/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================================
-- CRM Product Information
-- ============================================================================

TRUNCATE TABLE bronze_crm_prd_info;

LOAD DATA LOCAL INFILE
'C:/Users/BIT/Desktop/sql/sql with barra/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE bronze_crm_prd_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================================
-- CRM Sales Details
-- ============================================================================

TRUNCATE TABLE bronze_crm_sales_details;

LOAD DATA LOCAL INFILE
'C:/Users/BIT/Desktop/sql/sql with barra/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================================
-- ERP Customer Information
-- ============================================================================

TRUNCATE TABLE bronze_erp_cust_az12;

LOAD DATA LOCAL INFILE
'C:/Users/BIT/Desktop/sql/sql with barra/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================================
-- ERP Customer Location
-- ============================================================================

TRUNCATE TABLE bronze_erp_loc_a101;

LOAD DATA LOCAL INFILE
'C:/Users/BIT/Desktop/sql/sql with barra/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================================
-- ERP Product Categories
-- ============================================================================

TRUNCATE TABLE bronze_erp_px_cat_g1v2;

LOAD DATA LOCAL INFILE
'C:/Users/BIT/Desktop/sql/sql with barra/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- End Time
SET @end_time = NOW();

SELECT
'Bronze Layer Load Completed Successfully' AS Status,
@start_time AS Started_At,
@end_time AS Finished_At,
ROUND(
TIMESTAMPDIFF(MICROSECOND,@start_time,@end_time)/1000000,
2
) AS Total_Time_Seconds;
