/*
===============================================================================
Gold Layer: Dimension and Fact Views
===============================================================================
Purpose:
    Create the Gold-layer Customer Dimension, Product Dimension, and Sales
    Fact views from the Silver layer.

Views Created:
    1. gold_dim_customers
    2. gold_dim_products
    3. gold_fact_sale
===============================================================================
*/


/*
===============================================================================
1. GOLD CUSTOMER DIMENSION
===============================================================================
Purpose:
    Combine CRM customer information with ERP customer and location data.

Transformations:
    - Generate a surrogate customer key.
    - Apply business-friendly column names.
    - Combine customer, birthdate, gender, and country information.
    - Use CRM gender as the master source.
    - Use ERP gender as a fallback when CRM gender is Unknown.
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


/*
===============================================================================
2. GOLD PRODUCT DIMENSION
===============================================================================
Purpose:
    Combine current CRM product information with ERP product category data.

    Historical product records are excluded by keeping only records where
    prd_end_dt is NULL.
===============================================================================
*/

CREATE OR REPLACE VIEW gold_dim_products AS

SELECT
    -- Generate a surrogate key for the Product dimension
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


/*
===============================================================================
3. GOLD SALES FACT
===============================================================================
Purpose:
    Create the Gold sales fact view by combining CRM sales transactions with
    the Customer and Product dimensions.

    Dimension surrogate keys are used instead of source IDs so that the fact
    table can be properly connected to the dimension tables.
===============================================================================
*/

CREATE OR REPLACE VIEW gold_fact_sale AS

SELECT
    -- Sales transaction identifier
    sd.sls_ord_num AS order_number,

    -- Product dimension surrogate key
    pr.product_key,

    -- Customer dimension surrogate key
    cu.customer_key,

    -- Sales dates
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,

    -- Sales measures
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price

FROM silver_crm_sales_details AS sd

-- Connect sales transactions to the Product dimension
LEFT JOIN gold_dim_products AS pr
    ON sd.sls_prd_key = pr.product_number

-- Connect sales transactions to the Customer dimension
LEFT JOIN gold_dim_customers AS cu
    ON sd.sls_cust_id = cu.customer_id;
