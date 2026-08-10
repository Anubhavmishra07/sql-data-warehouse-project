/*
===============================================================================
Gold Layer: Sales Fact
===============================================================================
Purpose:
    Create the Gold sales fact view by combining CRM sales transactions with
    the Product and Customer dimensions.

    Dimension surrogate keys are used instead of source IDs so that the fact
    table can be properly connected to the Gold dimension tables.
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

-- Connect sales to the Product dimension
LEFT JOIN gold_dim_products AS pr
    ON sd.sls_prd_key = pr.product_number

-- Connect sales to the Customer dimension
LEFT JOIN gold_dim_customers AS cu
    ON sd.sls_cust_id = cu.customer_id;