/*
===============================================================================
Gold Layer: Product Dimension
===============================================================================
Purpose:
    Create the Gold product dimension by combining current CRM product
    information with ERP product category information.

    Historical product records are excluded by keeping only records where
    prd_end_dt is NULL.
===============================================================================
*/

CREATE OR REPLACE VIEW gold_dim_products AS

SELECT
    -- Generate a surrogate key for the product dimension
    ROW_NUMBER() OVER (
        ORDER BY pn.prd_start_dt, pn.prd_key
    ) AS product_key,

    -- Product identifiers
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,

    -- Product information
    pn.prd_nm AS product_name,

    -- Category information
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,

    -- Product attributes
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date

FROM silver_crm_prd_info AS pn

LEFT JOIN silver_erp_px_cat_g1v2 AS pc
    ON pn.cat_id = pc.id

-- Keep only the current version of each product
WHERE pn.prd_end_dt IS NULL;