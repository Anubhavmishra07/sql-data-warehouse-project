/*
=============================================================
Create Data Warehouse Database
=============================================================
Script Purpose:
    This script creates a new database named 'datawarehouse'.
    If the database already exists, it is dropped and recreated.

    Since MySQL treats SCHEMA as an alias for DATABASE,
    the Bronze, Silver, and Gold layers are represented
    using table naming conventions rather than separate schemas.

    Examples:
        bronze_crm_sales_details
        silver_crm_sales_details
        gold_dim_customers

WARNING:
    Running this script will permanently delete the existing
    'datawarehouse' database and all of its contents.
    Ensure proper backups before executing.
=============================================================
*/

-- Drop the database if it already exists
DROP DATABASE IF EXISTS datawarehouse;

-- Create the database
CREATE DATABASE datawarehouse;

-- Use the database
USE datawarehouse;
