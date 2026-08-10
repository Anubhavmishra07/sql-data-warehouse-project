/*
===============================================================================
Quality Checks: Gold Product Dimension
===============================================================================
Purpose:
    Validate the final Gold product dimension after combining and transforming
    the CRM product and ERP product category data.
===============================================================================
*/


-- ============================================================================
-- Check 1: Review Gold Product Dimension
-- ============================================================================

SELECT *
FROM gold_dim_products;


-- ============================================================================
-- Check 2: Check for Duplicate Product Numbers
-- ============================================================================
-- Each current product should have only one record in the Gold dimension.
-- ============================================================================

SELECT
    product_number,
    COUNT(*) AS record_count

FROM gold_dim_products

GROUP BY
    product_number

HAVING COUNT(*) > 1;


-- ============================================================================
-- Check 3: Review Product Line Values
-- ============================================================================
-- Verify that product line values are standardized correctly.
-- ============================================================================

SELECT DISTINCT
    product_line
FROM gold_dim_products
ORDER BY product_line;