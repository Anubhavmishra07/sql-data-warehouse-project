/*
===============================================================================
Load Silver: CRM Sales Details
===============================================================================
Purpose:
    Clean and transform CRM sales data from the Bronze layer before loading
    it into the Silver layer.

Business Rules:
    1. Sales = Quantity × Price.
    2. Sales, Quantity, and Price must be positive.
    3. If Sales is NULL, zero, negative, or inconsistent, recalculate it.
    4. If Price is NULL or zero, derive it using Sales / Quantity.
    5. If Price is negative, convert it to a positive value.
    6. Invalid dates are converted to NULL.
===============================================================================
*/

TRUNCATE TABLE silver_crm_sales_details;

INSERT INTO silver_crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_price,
    sls_quantity
)

WITH cleaned_data AS (

    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,

        -- Clean and derive Price
        CASE
            WHEN sls_price IS NULL
                 OR sls_price = 0
            THEN sls_sales / NULLIF(sls_quantity, 0)

            WHEN sls_price < 0
            THEN ABS(sls_price)

            ELSE sls_price
        END AS sls_price

    FROM bronze_crm_sales_details
)

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    -- Convert valid YYYYMMDD values to DATE; invalid values become NULL
    CASE
        WHEN sls_order_dt = 0
             OR LENGTH(sls_order_dt) <> 8
        THEN NULL
        ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
    END AS sls_order_dt,

    CASE
        WHEN sls_ship_dt = 0
             OR LENGTH(sls_ship_dt) <> 8
        THEN NULL
        ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt = 0
             OR LENGTH(sls_due_dt) <> 8
        THEN NULL
        ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
    END AS sls_due_dt,

    -- Recalculate Sales using the cleaned Price
    CASE
        WHEN sls_sales IS NULL
             OR sls_sales <= 0
             OR sls_sales <> sls_quantity * sls_price
        THEN sls_quantity * sls_price

        ELSE sls_sales
    END AS sls_sales,

    sls_price,
    sls_quantity

FROM cleaned_data;
