/*
===============================================================================
Load Silver: CRM Product Information
===============================================================================
Transformations:
    • Generate category ID from the product key.
    • Keep only products with valid category IDs.
    • Trim product names and product line values.
    • Standardize product line descriptions.
    • Replace NULL product costs with 0.
    • Generate product end dates using the next product start date.
===============================================================================
*/
TRUNCATE TABLE silver_crm_prd_info; -- for full load

INSERT INTO silver_crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,

    -- Extract category ID from the first 5 characters of the product key and separate it from cat_id
    
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    substring(prd_key,7) as prd_key,
    
    prd_nm,
      TRIM(prd_nm) AS prd_nm,

        -- Replace NULL product cost with 0
        COALESCE(prd_cost, 0) AS prd_cost,

    -- Standardize product line values
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'Unknown'
    END AS prd_line,

    -- Convert product start date to DATE
    CAST(prd_start_dt AS DATE) AS prd_start_dt,

    -- End date is one day before the next start date
    DATE_SUB(
        CAST( LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE ),
        INTERVAL 1 DAY ) AS prd_end_dt
FROM bronze_crm_prd_info ;
