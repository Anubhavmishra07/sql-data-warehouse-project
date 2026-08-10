/*
===============================================================================
Pre-Checks Before Building the Gold Layer
===============================================================================
Purpose:
    Validate the combined Silver-layer customer data before creating the
    Gold-layer customer dimension.
===============================================================================
*/


-- ============================================================================
-- Check 1: Identify Duplicate Customer Records
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
) AS t

GROUP BY
    cst_id

HAVING COUNT(*) > 1;


-- ============================================================================
-- Check 2: Validate Gender Consistency
-- ============================================================================
-- Compare gender values from the CRM and ERP customer sources to identify
-- inconsistencies before building the Gold layer.
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
