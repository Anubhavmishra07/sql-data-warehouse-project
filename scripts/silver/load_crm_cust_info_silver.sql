-- ============================================================================
-- Load CRM Customer Information
-- ============================================================================
-- Transformations:
--   • Remove records with NULL or invalid customer IDs.
--   • Remove records with invalid creation dates.
--   • Retain only the most recent record for each customer.
--   • Trim leading and trailing spaces.
--   • Standardize marital status and gender values.
-- ============================================================================
TRUNCATE TABLE silver_crm_cust_info; -- for full load

INSERT INTO silver_crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)

SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,

    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'Unknown'
    END AS cst_marital_status,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'Unknown'
    END AS cst_gndr,

    cst_create_date

FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS row_num
    FROM bronze_crm_cust_info
    WHERE cst_id IS NOT NULL
      AND cst_id > 0
      AND CAST(cst_create_date AS CHAR) <> '0000-00-00'
) AS ranked_customers

WHERE row_num = 1;
