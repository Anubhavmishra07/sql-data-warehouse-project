/*
===============================================================================
Quality Checks: Silver ERP Location Information
===============================================================================
Purpose:
    Validate the cleaned ERP location data in the Silver layer after
    transformation from the Bronze layer.
===============================================================================
*/

USE datawarehouse;


-- ============================================================================
-- Check 1: Review Silver ERP Location Data
-- ============================================================================

SELECT *
FROM silver_erp_loc_a101;


-- ============================================================================
-- Check 2: Validate Customer IDs
-- ============================================================================
-- Verify that every cleaned ERP customer ID exists in the CRM customer table.
-- The '-' characters should already have been removed in the Silver layer.
-- ============================================================================

SELECT cid
FROM silver_erp_loc_a101
WHERE cid NOT IN (
    SELECT DISTINCT cst_key
    FROM silver_crm_cust_info
);


-- ============================================================================
-- Check 3: Review Country Values
-- ============================================================================
-- Review distinct country values to verify that the data has been
-- standardized correctly.
-- ============================================================================

SELECT DISTINCT
    cntry
FROM silver_erp_loc_a101
ORDER BY cntry;


-- ============================================================================
-- Check 4: Check for Hidden or Unwanted Characters
-- ============================================================================
-- Verify that no unwanted whitespace or invisible characters remain
-- after the Silver transformation.
-- ============================================================================

SELECT DISTINCT
    cntry,
    LENGTH(cntry) AS length,
    LENGTH(TRIM(cntry)) AS trimmed_length
FROM silver_erp_loc_a101
ORDER BY cntry;

