/*
===============================================================================
QUALITY CHECKS: SILVER LAYER
===============================================================================
Purpose:
    Validate the quality, consistency, and integrity of all Silver-layer
    tables before building the Gold layer.

Sources Covered:
    1. Silver CRM Customer Information
    2. Silver CRM Product Information
    3. Silver CRM Sales Details
    4. Silver ERP Customer Information
    5. Silver ERP Location Information
    6. Silver ERP Product Category Information
===============================================================================
*/

USE datawarehouse;


/*
===============================================================================
1. SILVER CRM CUSTOMER INFORMATION
===============================================================================
*/


-- ============================================================================
-- Check 1: Review Silver CRM Customer Data
-- ============================================================================

SELECT *
FROM silver_crm_cust_info;


-- ============================================================================
-- Check 2: Identify NULL or Duplicate Customer IDs
-- ============================================================================
-- Each customer ID should be unique and should not be NULL.
-- ============================================================================

SELECT
    cst_id,
    COUNT(*) AS record_count

FROM silver_crm_cust_info

GROUP BY
    cst_id

HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- ============================================================================
-- Check 3: Detect Leading or Trailing Spaces
-- ============================================================================
-- Check all relevant string columns for unwanted leading or trailing spaces.
-- ============================================================================

SELECT
    SUM(cst_firstname <> TRIM(cst_firstname)) AS firstname_spaces,
    SUM(cst_lastname <> TRIM(cst_lastname)) AS lastname_spaces,
    SUM(cst_gndr <> TRIM(cst_gndr)) AS gender_spaces,
    SUM(cst_marital_status <> TRIM(cst_marital_status))
        AS marital_status_spaces

FROM silver_crm_cust_info;


-- ============================================================================
-- Check 4: Review Standardized Gender Values
-- ============================================================================

SELECT
    cst_gndr,
    COUNT(*) AS record_count

FROM silver_crm_cust_info

GROUP BY
    cst_gndr;


-- ============================================================================
-- Check 5: Review Standardized Marital Status Values
-- ============================================================================

SELECT
    cst_marital_status,
    COUNT(*) AS record_count

FROM silver_crm_cust_info

GROUP BY
    cst_marital_status;


-- ============================================================================
-- Check 6: Identify Invalid Customer Creation Dates
-- ============================================================================

SELECT *
FROM silver_crm_cust_info
WHERE CAST(cst_create_date AS CHAR) = '0000-00-00';


/*
===============================================================================
2. SILVER CRM PRODUCT INFORMATION
===============================================================================
*/


-- ============================================================================
-- Check 7: Review Silver CRM Product Data
-- ============================================================================

SELECT *
FROM silver_crm_prd_info;


-- ============================================================================
-- Check 8: Identify NULL or Duplicate Product IDs
-- ============================================================================

SELECT
    prd_id,
    COUNT(*) AS record_count

FROM silver_crm_prd_info

GROUP BY
    prd_id

HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- ============================================================================
-- Check 9: Validate Product Category Keys
-- ============================================================================
-- Verify that every category ID in the Silver CRM product table exists
-- in the ERP product category table.
-- ============================================================================

SELECT
    cat_id

FROM silver_crm_prd_info

WHERE cat_id NOT IN (
    SELECT id
    FROM bronze_erp_px_cat_g1v2
);


-- ============================================================================
-- Check 10: Validate Product Key Consistency
-- ============================================================================
-- Verify that every product key exists in the CRM sales details.
-- ============================================================================

SELECT
    prd_key

FROM silver_crm_prd_info

WHERE prd_key NOT IN (
    SELECT sls_prd_key
    FROM bronze_crm_sales_details
);


-- ============================================================================
-- Check 11: Count Products with Missing Sales References
-- ============================================================================

SELECT
    COUNT(*) AS missing_product_key_count

FROM silver_crm_prd_info

WHERE prd_key NOT IN (
    SELECT sls_prd_key
    FROM bronze_crm_sales_details
);


-- ============================================================================
-- Check 12: Detect Leading or Trailing Spaces
-- ============================================================================

SELECT
    SUM(prd_key <> TRIM(prd_key)) AS prd_key_spaces,
    SUM(prd_nm <> TRIM(prd_nm)) AS prd_nm_spaces,
    SUM(prd_line <> TRIM(prd_line)) AS prd_line_spaces

FROM silver_crm_prd_info;


-- ============================================================================
-- Check 13: Identify NULL or Negative Product Costs
-- ============================================================================

SELECT
    prd_cost

FROM silver_crm_prd_info

WHERE prd_cost < 0
   OR prd_cost IS NULL;


-- ============================================================================
-- Check 14: Review Product Line Values
-- ============================================================================

SELECT DISTINCT
    prd_line

FROM silver_crm_prd_info

ORDER BY
    prd_line;


-- ============================================================================
-- Check 15: Validate Product Date Ranges
-- ============================================================================
-- The product end date should not be earlier than the start date.
-- ============================================================================

SELECT
    prd_start_dt,
    prd_end_dt

FROM silver_crm_prd_info

WHERE prd_end_dt < prd_start_dt;


/*
===============================================================================
3. SILVER CRM SALES DETAILS
===============================================================================
*/


-- ============================================================================
-- Check 16: Detect Leading or Trailing Spaces in Order Numbers
-- ============================================================================

SELECT *
FROM silver_crm_sales_details

WHERE sls_ord_num <> TRIM(sls_ord_num);


-- ============================================================================
-- Check 17: Validate Product Keys
-- ============================================================================
-- Every product key in the sales data should exist in the Silver product
-- dimension.
-- ============================================================================

SELECT
    s.sls_prd_key

FROM silver_crm_sales_details AS s

WHERE NOT EXISTS (
    SELECT 1
    FROM silver_crm_prd_info AS p
    WHERE p.prd_key = s.sls_prd_key
);


-- ============================================================================
-- Check 18: Validate Customer IDs
-- ============================================================================
-- Every customer ID in the sales data should exist in the Silver customer
-- dimension.
-- ============================================================================

SELECT
    s.sls_cust_id

FROM silver_crm_sales_details AS s

WHERE NOT EXISTS (
    SELECT 1
    FROM silver_crm_cust_info AS c
    WHERE c.cst_id = s.sls_cust_id
);


-- ============================================================================
-- Check 19: Validate Order Dates
-- ============================================================================
-- Check the stored date values for invalid or unexpected formats.
-- ============================================================================

SELECT
    sls_order_dt

FROM silver_crm_sales_details

WHERE sls_order_dt <= 0
   OR LENGTH(sls_order_dt) <> 10;


-- ============================================================================
-- Check 20: Validate Ship Dates
-- ============================================================================

SELECT
    sls_ship_dt

FROM silver_crm_sales_details

WHERE sls_ship_dt <= 0
   OR LENGTH(sls_ship_dt) <> 10;


-- ============================================================================
-- Check 21: Validate Due Dates
-- ============================================================================

SELECT
    sls_due_dt

FROM silver_crm_sales_details

WHERE sls_due_dt <= 0
   OR LENGTH(sls_due_dt) <> 10;


-- ============================================================================
-- Check 22: Validate Sales Date Sequence
-- ============================================================================
-- The order date should not be later than the shipping date or due date.
-- ============================================================================

SELECT
    sls_ord_num,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt

FROM silver_crm_sales_details

WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- ============================================================================
-- Check 23: Validate Sales, Quantity, and Price
-- ============================================================================
-- Business rule:
--     Sales = Quantity × Price
--
-- Sales, quantity, and price should all contain valid positive values.
-- ============================================================================

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price

FROM silver_crm_sales_details

WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0

ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;


/*
===============================================================================
4. SILVER ERP CUSTOMER INFORMATION
===============================================================================
*/


-- ============================================================================
-- Check 24: Review Silver ERP Customer Data
-- ============================================================================

SELECT *
FROM silver_erp_cust_az12;


-- ============================================================================
-- Check 25: Check for Unexpected Customer IDs
-- ============================================================================
-- Review customer IDs containing 'AW' to verify that no unexpected patterns
-- remain after transformation.
-- ============================================================================

SELECT
    cid

FROM silver_erp_cust_az12

WHERE cid LIKE '%AW%';


-- ============================================================================
-- Check 26: Validate Customer Key Integration
-- ============================================================================
-- Every ERP customer ID should correspond to a CRM customer key.
-- ============================================================================

SELECT
    cid

FROM silver_erp_cust_az12

WHERE cid NOT IN (
    SELECT DISTINCT
        cst_key
    FROM silver_crm_cust_info
);


-- ============================================================================
-- Check 27: Validate Birth Dates
-- ============================================================================
-- Birth dates should not contain future dates.
-- ============================================================================

SELECT
    bdate

FROM silver_erp_cust_az12

WHERE bdate >= CURRENT_DATE();


-- ============================================================================
-- Check 28: Review Standardized Gender Values
-- ============================================================================

SELECT DISTINCT
    gen

FROM silver_erp_cust_az12

ORDER BY
    gen;


-- ============================================================================
-- Check 29: Check for Hidden or Unwanted Characters
-- ============================================================================
-- Compare the original and trimmed lengths and review the cleaned value.
-- ============================================================================

SELECT DISTINCT
    gen,
    LENGTH(gen) AS length,
    LENGTH(TRIM(gen)) AS trimmed_length,
    UPPER(TRIM(gen)) AS cleaned_gen

FROM silver_erp_cust_az12

ORDER BY
    gen;


/*
===============================================================================
5. SILVER ERP LOCATION INFORMATION
===============================================================================
*/


-- ============================================================================
-- Check 30: Review Silver ERP Location Data
-- ============================================================================

SELECT *
FROM silver_erp_loc_a101;


-- ============================================================================
-- Check 31: Validate Customer IDs
-- ============================================================================
-- Verify that every cleaned ERP customer ID exists in the CRM customer table.
-- ============================================================================

SELECT
    cid

FROM silver_erp_loc_a101

WHERE cid NOT IN (
    SELECT DISTINCT
        cst_key
    FROM silver_crm_cust_info
);


-- ============================================================================
-- Check 32: Review Country Values
-- ============================================================================
-- Review distinct country values to verify that they have been standardized.
-- ============================================================================

SELECT DISTINCT
    cntry

FROM silver_erp_loc_a101

ORDER BY
    cntry;


-- ============================================================================
-- Check 33: Check for Hidden or Unwanted Characters
-- ============================================================================
-- Compare original and trimmed lengths to identify unwanted whitespace.
-- ============================================================================

SELECT DISTINCT
    cntry,
    LENGTH(cntry) AS length,
    LENGTH(TRIM(cntry)) AS trimmed_length

FROM silver_erp_loc_a101

ORDER BY
    cntry;


/*
===============================================================================
6. SILVER ERP PRODUCT CATEGORY INFORMATION
===============================================================================
*/


-- ============================================================================
-- Check 34: Review Silver Product Category Data
-- ============================================================================

SELECT *
FROM silver_erp_px_cat_g1v2;


-- ============================================================================
-- Check 35: Detect Leading or Trailing Spaces
-- ============================================================================
-- Verify that no unwanted spaces remain in the text columns.
-- ============================================================================

SELECT *

FROM silver_erp_px_cat_g1v2

WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);


-- ============================================================================
-- Check 36: Review Category Values
-- ============================================================================

SELECT DISTINCT
    cat

FROM silver_erp_px_cat_g1v2

ORDER BY
    cat;


-- ============================================================================
-- Check 37: Review Subcategory Values
-- ============================================================================

SELECT DISTINCT
    subcat

FROM silver_erp_px_cat_g1v2

ORDER BY
    subcat;


-- ============================================================================
-- Check 38: Review Maintenance Values
-- ============================================================================

SELECT DISTINCT
    maintenance

FROM silver_erp_px_cat_g1v2

ORDER BY
    maintenance;


-- ============================================================================
-- Check 39: Check for Hidden or Unwanted Characters in Maintenance
-- ============================================================================
-- Compare the original and trimmed lengths and inspect the hexadecimal
-- representation to identify any remaining invisible characters.
-- ============================================================================

SELECT DISTINCT
    maintenance,
    LENGTH(maintenance) AS length,
    LENGTH(TRIM(maintenance)) AS trimmed_length,
    HEX(maintenance) AS hex_value

FROM silver_erp_px_cat_g1v2

ORDER BY
    maintenance;