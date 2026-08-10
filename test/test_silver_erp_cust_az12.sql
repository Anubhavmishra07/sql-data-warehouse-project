/*
===============================================================================
Quality Checks: Silver ERP Customer Information
===============================================================================
Purpose:
    Validate the cleaned ERP customer data in the Silver layer after
    transformation from the Bronze layer.
===============================================================================
*/

USE datawarehouse;


-- ============================================================================
-- Check 1: Review Silver ERP Customer Data
-- ============================================================================

SELECT *
FROM silver_erp_cust_az12;


-- ============================================================================
-- Check 2: Check for Unexpected Customer IDs
-- ============================================================================
-- Review customer IDs containing 'AW' to verify that no unexpected patterns
-- remain after transformation.
-- ============================================================================

SELECT cid
FROM silver_erp_cust_az12
WHERE cid LIKE '%AW%';


-- ============================================================================
-- Check 3: Validate Customer Key Integration
-- ============================================================================
-- Every ERP customer ID should correspond to a CRM customer key.
-- ============================================================================

SELECT cid
FROM silver_erp_cust_az12
WHERE cid NOT IN (
    SELECT DISTINCT cst_key
    FROM silver_crm_cust_info
);


-- ============================================================================
-- Check 4: Validate Birth Dates
-- ============================================================================
-- Birth dates should not contain future dates.
-- ============================================================================

SELECT bdate
FROM silver_erp_cust_az12
WHERE bdate >= CURRENT_DATE();


-- ============================================================================
-- Check 5: Review Standardized Gender Values
-- ============================================================================
-- Verify that gender values have been standardized correctly.
-- ============================================================================

SELECT DISTINCT
    gen
FROM silver_erp_cust_az12
ORDER BY gen;


-- ============================================================================
-- Check 6: Check for Hidden or Unwanted Characters
-- ============================================================================
-- Verify that no unexpected whitespace or invisible characters remain
-- after cleaning the gender values.
-- ============================================================================

SELECT DISTINCT
    gen,
    LENGTH(gen) AS length,
    LENGTH(TRIM(gen)) AS trimmed_length,
    UPPER(TRIM(gen)) AS cleaned_gen
FROM silver_erp_cust_az12
ORDER BY gen;
