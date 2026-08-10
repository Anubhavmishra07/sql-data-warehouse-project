/*
===============================================================================
Quality Checks: Bronze ERP Location Information
===============================================================================
Purpose:
    Validate the raw ERP location data for customer key consistency and
    country standardization issues before loading it into the Silver layer.
===============================================================================
*/

USE datawarehouse;


-- ============================================================================
-- Check 1: Review Raw ERP Location Data
-- ============================================================================

SELECT *
FROM bronze_erp_loc_a101;


-- ============================================================================
-- Check 2: Validate Customer IDs
-- ============================================================================
-- Remove '-' from the ERP customer ID and verify that it exists in the
-- CRM customer table.
-- ============================================================================

SELECT
    REPLACE(cid, '-', '') AS cid
FROM bronze_erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (
    SELECT cst_key
    FROM silver_crm_cust_info
);


-- ============================================================================
-- Check 3: Review Country Values
-- ============================================================================
-- Identify distinct country values to detect inconsistent representations.
-- ============================================================================

SELECT DISTINCT
    cntry
FROM bronze_erp_loc_a101
ORDER BY cntry;

-- ============================================================================
-- Check 4: Detect Leading, Trailing, or Hidden Characters
-- ============================================================================
-- Compare the original country value with its trimmed value and inspect
-- the length to identify unwanted spaces or invisible characters such as
-- carriage returns (\r) or line breaks (\n).
-- ============================================================================

SELECT DISTINCT
    cntry,
    LENGTH(cntry) AS length,
    LENGTH(TRIM(cntry)) AS trimmed_length
FROM bronze_erp_loc_a101
ORDER BY cntry;
