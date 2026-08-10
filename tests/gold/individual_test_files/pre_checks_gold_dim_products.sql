/*
===============================================================================
Pre-Checks Before Building the Gold Layer
===============================================================================
Purpose:
    Validate the current CRM product data and its integration with the ERP
    product category information before building the Gold product dimension.
===============================================================================
*/


-- ============================================================================
-- Check 1: Filter Current Product Records
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
-- Check 2: Enrich Current Products with Category Information
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
-- Check 3: Identify Duplicate Current Product Keys
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
