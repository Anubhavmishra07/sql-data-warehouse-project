/*
===============================================================================
Load Silver: ERP Customer Information
===============================================================================
Purpose:
    Clean and transform ERP customer data from the Bronze layer before
    loading it into the Silver layer.

Transformations:
    1. Remove the 'NAS' prefix from customer IDs.
    2. Convert future birth dates to NULL.
    3. Standardize gender values.
    4. Remove hidden whitespace characters from gender values.
===============================================================================
*/
TRUNCATE TABLE silver_erp_cust_az12;
INSERT INTO silver_erp_cust_az12 (
    cid,
    bdate,
    gen
)

WITH cleaned_data AS (

    SELECT
        -- Remove the 'NAS' prefix from customer IDs
        CASE
            WHEN cid LIKE 'NAS%'
            THEN SUBSTRING(cid, 4)
            ELSE cid
        END AS cid,

        -- Convert future birth dates to NULL
        CASE
            WHEN bdate > CURRENT_DATE()
            THEN NULL
            ELSE bdate
        END AS bdate,

        -- Remove hidden whitespace characters
        UPPER(
            REGEXP_REPLACE(gen, '[[:space:]]+', '')
        ) AS cleaned_gen

    FROM bronze_erp_cust_az12
)

SELECT
    cid,
    bdate,

    -- Standardize gender values
    CASE
        WHEN cleaned_gen IN ('F', 'FEMALE')
            THEN 'Female'

        WHEN cleaned_gen IN ('M', 'MALE')
            THEN 'Male'

        ELSE 'Unknown'
    END AS gen

FROM cleaned_data;
