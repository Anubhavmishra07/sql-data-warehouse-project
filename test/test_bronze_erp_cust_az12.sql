/*
===============================================================================
Quality Checks: Bronze ERP Customer Information
===============================================================================
Purpose:
    Validate the raw ERP customer data for data quality, consistency,
    referential integrity, and formatting issues before loading it into
    the Silver layer.
===============================================================================
*/

USE datawarehouse;


-- ============================================================================
-- Check 1: Review Raw ERP Customer Data
-- ============================================================================

SELECT *
FROM bronze_erp_cust_az12;


-- ============================================================================
-- Check 2: Identify Customer IDs Containing "AW"
-- ============================================================================
-- Review customer IDs containing "AW" to identify unexpected patterns
-- in the source identifiers.
-- ============================================================================

SELECT cid
FROM bronze_erp_cust_az12
WHERE cid LIKE '%AW%';


-- ============================================================================
-- Check 3: Validate Customer IDs Against CRM Customer Data
-- ============================================================================
-- ERP customer IDs should match the customer keys in the CRM customer table.
-- The 'NAS' prefix is removed before comparison where applicable.
-- ============================================================================

SELECT cid
FROM bronze_erp_cust_az12
WHERE
    CASE
        WHEN cid LIKE 'NAS%'
        THEN SUBSTRING(cid, 4)
        ELSE cid
    END NOT IN (
        SELECT DISTINCT cst_key
        FROM silver_crm_cust_info
    );


-- ============================================================================
-- Check 4: Validate Birth Dates
-- ============================================================================
-- Customer birth dates should not be in the future.
-- ============================================================================

SELECT bdate
FROM bronze_erp_cust_az12
WHERE bdate >= CURRENT_DATE();


-- ============================================================================
-- Check 5: Review Gender Values
-- ============================================================================
-- Review distinct source values to identify inconsistent or unexpected
-- gender representations.
-- ============================================================================

SELECT DISTINCT
    gen
FROM bronze_erp_cust_az12
ORDER BY gen;


-- ============================================================================
-- Check 6: Detect Hidden or Unwanted Characters in Gender Values
-- ============================================================================
-- Compare the original and trimmed values and inspect their lengths to
-- identify invisible characters such as carriage returns or line breaks.
-- ============================================================================

SELECT DISTINCT
    gen,
    LENGTH(gen) AS length,
    LENGTH(TRIM(gen)) AS trimmed_length,
    UPPER(TRIM(gen)) AS cleaned_gen
FROM bronze_erp_cust_az12
ORDER BY gen;
