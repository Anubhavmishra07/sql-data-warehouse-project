/*
===============================================================================
Quality Checks: Gold Sales Fact
===============================================================================
Purpose:
    Validate the final Gold sales fact view and verify that all sales
    transactions are correctly connected to the Customer and Product
    dimensions.
===============================================================================
*/


-- ============================================================================
-- Check 1: Review Gold Sales Fact
-- ============================================================================

SELECT *
FROM gold_fact_sale;


-- ============================================================================
-- Check 2: Validate Product and Customer Dimension Relationships
-- ============================================================================
-- Every fact record should have a matching Product and Customer dimension
-- record through their respective surrogate keys.
--
-- If this query returns any rows, the corresponding dimension key is missing.
-- ============================================================================

SELECT
    f.order_number,
    f.product_key,
    f.customer_key

FROM gold_fact_sale AS f

LEFT JOIN gold_dim_customers AS c
    ON c.customer_key = f.customer_key

LEFT JOIN gold_dim_products AS p
    ON p.product_key = f.product_key

WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;