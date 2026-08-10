/*
===============================================================================
Quality Checks: silver CRM Customer Information
===============================================================================
Purpose:
    Validate the quality of raw customer data before loading it into the
    gold layer.
===============================================================================
*/
select * from silver_crm_cust_info;
-- ============================================================================
-- Check 1: Identify NULL or Duplicate Customer IDs
-- ============================================================================

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- ============================================================================
-- Check 2: Detect Leading or Trailing Spaces in any column, <> means !=
-- ============================================================================
-- checking all string columns at once
SELECT
    SUM(cst_firstname != TRIM(cst_firstname)) AS firstname_spaces,
    SUM(cst_lastname != TRIM(cst_lastname)) AS lastname_spaces,
    SUM(cst_gndr != TRIM(cst_gndr)) AS gender_spaces,
    SUM(cst_marital_status != TRIM(cst_marital_status)) AS marital_status_spaces
FROM silver_crm_cust_info;
-- OR checking all string columns individually
SELECT
    cst_firstname
FROM silver_crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);

SELECT
    cst_lastname
FROM silver_crm_cust_info
WHERE cst_lastname <> TRIM(cst_lastname);

SELECT
    cst_gndr
FROM silver_crm_cust_info
WHERE cst_gndr <> TRIM(cst_gndr);

SELECT
    cst_marital_status
FROM silver_crm_cust_info
WHERE cst_marital_status <> TRIM(cst_marital_status);
-- ============================================================================
-- Check 3: Verify Data Standardization & Consistency
-- ============================================================================

-- Review all distinct gender values
SELECT
    cst_gndr,
    COUNT(*) AS record_count
FROM silver_crm_cust_info
GROUP BY cst_gndr;

-- Review all distinct marital status values
SELECT
    cst_marital_status,
    COUNT(*) AS record_count
FROM silver_crm_cust_info
GROUP BY cst_marital_status;


-- ============================================================================
-- Check 4: Identify Invalid Creation Dates
-- ============================================================================

SELECT *
FROM silver_crm_cust_info
WHERE CAST(cst_create_date AS CHAR) = '0000-00-00';
