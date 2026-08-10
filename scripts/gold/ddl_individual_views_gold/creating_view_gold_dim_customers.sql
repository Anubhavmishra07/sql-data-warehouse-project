/*
===============================================================================
Gold Layer: Customer Dimension
===============================================================================
Purpose:
    Create the Gold customer dimension by combining CRM customer information
    with ERP customer and location data.

Transformations:
    1. Generate a surrogate customer key.
    2. Apply consistent and business-friendly column names.
    3. Combine customer, birthdate, gender, and country information.
    4. Use CRM gender as the master source when available.
    5. Use ERP gender as a fallback when CRM gender is Unknown.
===============================================================================
*/

CREATE OR REPLACE VIEW gold_dim_customers AS

SELECT
    -- Generate a surrogate key for the Gold dimension
    ROW_NUMBER() OVER (
        ORDER BY ci.cst_id
    ) AS customer_key,

    -- Customer identifiers
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,

    -- Customer personal information
    ci.cst_firstname AS firstname,
    ci.cst_lastname AS lastname,

    -- Location information
    la.cntry AS country,

    -- Customer attributes
    ci.cst_marital_status AS marital_status,

    -- CRM is the master source for gender; ERP is used as fallback
    CASE
        WHEN ci.cst_gndr <> 'Unknown'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'Unknown')
    END AS gender,

    -- ERP customer birthdate
    ca.bdate AS birthdate,

    -- Customer creation date
    ci.cst_create_date AS create_date

FROM silver_crm_cust_info AS ci

LEFT JOIN silver_erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver_erp_loc_a101 AS la
    ON ci.cst_key = la.cid;
