/*
===============================================================================
Pre-Checks Before Building the Gold Layer
===============================================================================
Purpose:
    Validate the Silver-layer customer and product data before creating the
    Gold-layer dimension tables.
===============================================================================
*/


/*
===============================================================================
CUSTOMER DIMENSION PRE-CHECKS
===============================================================================
*/


-- ============================================================================
-- Customer Check 1: Identify Duplicate Customer Records
-- ============================================================================
-- Each customer should have only one record after joining the CRM customer
-- data with the ERP customer and location data.
-- ============================================================================

SELECT
    cst_id,
    COUNT(*) AS record_count

FROM (
    SELECT
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry

    FROM silver_crm_cust_info AS ci

    LEFT JOIN silver_erp_cust_az12 AS ca
        ON ci.cst_key = ca.cid

    LEFT JOIN silver_erp_loc_a101 AS la
        ON ci.cst_key = la.cid
) AS customer_data

GROUP BY
    cst_id

HAVING COUNT(*) > 1;


-- ============================================================================
-- Customer Check 2: Validate Gender Consistency
-- ============================================================================
-- Compare gender values from the CRM and ERP customer sources to identify
-- inconsistencies before building the Gold customer dimension.
-- ============================================================================

SELECT DISTINCT
    ci.cst_gndr AS crm_gender,
    ca.gen AS erp_gender

FROM silver_crm_cust_info AS ci

LEFT JOIN silver_erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid

ORDER BY
    crm_gender,
    erp_gender;


/*
===============================================================================
PRODUCT DIMENSION PRE-CHECKS
===============================================================================
*/


-- ============================================================================
-- Product Check 1: Filter Current Product Records
-- ============================================================================
-- Exclude historical product records and keep only the current version
-- where the end date is NULL.
-- ============================================================================

SELECT
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pn.prd_start_dt,
    pn.prd_end_dt

FROM silver_crm_prd_info AS pn

WHERE pn.prd_end_dt IS NULL;


-- ============================================================================
-- Product Check 2: Enrich Current Products with Category Information
-- ============================================================================
-- Join current CRM product records with the ERP product category table
-- using the category ID.
-- ============================================================================

SELECT
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pn.prd_start_dt,
    pn.prd_end_dt,
    pc.cat,
    pc.subcat,
    pc.maintenance

FROM silver_crm_prd_info AS pn

LEFT JOIN silver_erp_px_cat_g1v2 AS pc
    ON pn.cat_id = pc.id

WHERE pn.prd_end_dt IS NULL;


-- ============================================================================
-- Product Check 3: Identify Duplicate Current Product Keys
-- ============================================================================
-- Each current product should have only one record for a given product key.
-- An empty result indicates that there are no duplicate current product keys.
-- ============================================================================

SELECT
    prd_key,
    COUNT(*) AS record_count

FROM (
    SELECT
        pn.prd_id,
        pn.cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pn.prd_end_dt

    FROM silver_crm_prd_info AS pn

    WHERE pn.prd_end_dt IS NULL
) AS current_products

GROUP BY
    prd_key

HAVING COUNT(*) > 1;
