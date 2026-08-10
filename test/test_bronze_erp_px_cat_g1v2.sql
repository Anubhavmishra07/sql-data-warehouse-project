/*
===============================================================================
Quality Checks: Bronze ERP Product Category Information
===============================================================================
Purpose:
    Validate the raw ERP product category data for unwanted spaces,
    inconsistent values, and hidden characters before loading it into
    the Silver layer.
===============================================================================
*/

USE datawarehouse;


-- ============================================================================
-- Check 1: Review Raw Product Category Data
-- ============================================================================

SELECT *
FROM bronze_erp_px_cat_g1v2;


-- ============================================================================
-- Check 2: Detect Leading or Trailing Spaces
-- ============================================================================
-- Identify records where text columns contain unwanted spaces.
-- ============================================================================

SELECT *
FROM bronze_erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);


-- ============================================================================
-- Check 3: Review Category Values
-- ============================================================================
-- Review distinct category values to identify inconsistencies.
-- ============================================================================

SELECT DISTINCT
    cat
FROM bronze_erp_px_cat_g1v2
ORDER BY cat;


-- ============================================================================
-- Check 4: Review Subcategory Values
-- ============================================================================

SELECT DISTINCT
    subcat
FROM bronze_erp_px_cat_g1v2
ORDER BY subcat;


-- ============================================================================
-- Check 5: Review Maintenance Values
-- ============================================================================

SELECT DISTINCT
    maintenance
FROM bronze_erp_px_cat_g1v2
ORDER BY maintenance;


-- ============================================================================
-- Check 6: Detect Hidden or Unwanted Characters in Maintenance
-- ============================================================================
-- Compare the original and trimmed lengths to identify potential hidden
-- whitespace characters that may not be visible in the result.
-- ============================================================================

SELECT DISTINCT
    maintenance,
    LENGTH(maintenance) AS length,
    LENGTH(TRIM(maintenance)) AS trimmed_length,
    HEX(maintenance) AS hex_value
FROM bronze_erp_px_cat_g1v2
ORDER BY maintenance;
