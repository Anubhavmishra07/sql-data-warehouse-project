# **Naming Conventions**

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse.

## **Table of Contents**

1. [General Principles](#general-principles)
2. [Table Naming Conventions](#table-naming-conventions)
   - [Bronze Rules](#bronze-rules)
   - [Silver Rules](#silver-rules)
   - [Gold Rules](#gold-rules)
3. [Column Naming Conventions](#column-naming-conventions)
   - [General Column Rules](#general-column-rules)
   - [Primary Keys](#primary-keys)
   - [Surrogate Keys](#surrogate-keys)
   - [Technical Columns](#technical-columns)
4. [Stored Procedure Naming Conventions](#stored-procedure-naming-conventions)

---

## **General Principles**

- **Naming Conventions**: Use snake_case, with lowercase letters and underscores (`_`) to separate words.
- **Language**: Use English for all names.
- **Avoid Reserved Words**: Do not use SQL reserved words as object names.
- **Clarity**: Names should be clear, descriptive, and meaningful.
- **Consistency**: Maintain a consistent naming structure across all data warehouse layers.
- **Abbreviations**: Avoid unnecessary abbreviations unless they are commonly understood within the project.
- **Layer Identification**: Table names must clearly identify the data warehouse layer and, where applicable, the source system.

---

## **Table Naming Conventions**

### **Bronze Rules**

The Bronze layer contains raw data loaded from source systems with minimal or no transformation.

- All names must start with the Bronze layer prefix and source system name.
- Table names must match their original source table names without renaming.
- **`bronze_<sourcesystem>_<entity>`**
  - `bronze`: Identifies the Bronze layer.
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`).
  - `<entity>`: Exact table name from the source system.
- Example:
  - `bronze_crm_cust_info` → Customer information from the CRM system.
  - `bronze_erp_cust_az12` → Customer information from the ERP system.

### **Bronze Rules**

- The source system must be included in the table name.
- The original source table/entity name should be preserved.
- Do not rename source entities in the Bronze layer.
- Do not apply business-oriented naming to Bronze tables.
- Keep transformations to a minimum.

---

### **Silver Rules**

The Silver layer contains cleaned, standardized, and transformed data while retaining a close relationship with the source systems.

- All names must start with the Silver layer prefix and source system name.
- Table names should maintain consistency with the corresponding Bronze tables.
- **`silver_<sourcesystem>_<entity>`**
  - `silver`: Identifies the Silver layer.
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`).
  - `<entity>`: Represents the business entity derived from the source.
- Example:
  - `silver_crm_cust_info` → Cleaned and standardized customer information from the CRM system.
  - `silver_erp_cust_az12` → Cleaned and standardized customer information from the ERP system.

### **Silver Rules**

- The source system must remain identifiable.
- Table names should maintain consistency with the corresponding Bronze tables.
- Data may be cleaned, standardized, deduplicated, and transformed.
- Column names may be standardized where required.
- Business logic and data quality transformations are allowed.

---

### **Gold Rules**

The Gold layer contains business-ready data designed for analytics, reporting, and consumption by end users.

- All names must use meaningful, business-aligned names for tables.
- Gold table names must start with the Gold layer prefix followed by a category prefix.
- **`gold_<category>_<entity>`**
  - `gold`: Identifies the Gold layer.
  - `<category>`: Describes the role of the table, such as `dim` (dimension), `fact` (fact table), or `agg` (aggregated table).
  - `<entity>`: Descriptive name of the table, aligned with the business domain (e.g., `customers`, `products`, `sales`).
- Examples:
  - `gold_dim_customers` → Dimension table for customer data.
  - `gold_dim_products` → Dimension table for product data.
  - `gold_fact_sales` → Fact table containing sales transactions.
  - `gold_agg_sales_monthly` → Aggregated table containing monthly sales data.

### **Gold Rules**

- Gold tables should use meaningful, business-oriented names.
- Source-system prefixes are generally not required.
- Table names should describe the business entity rather than the original source structure.
- Dimension tables should use the `dim_` prefix.
- Fact tables should use the `fact_` prefix.
- Aggregated tables should use the `agg_` prefix.

#### **Glossary of Category Patterns**

| Pattern | Meaning | Example(s) |
| ------- | ------- | ---------- |
| `dim_`  | Dimension table | `gold_dim_customers`, `gold_dim_products` |
| `fact_` | Fact table | `gold_fact_sales` |
| `agg_`  | Aggregated table | `gold_agg_customers`, `gold_agg_sales_monthly` |

---

## **Column Naming Conventions**

### **General Column Rules**

- All column names must use snake_case.
- Use lowercase letters with underscores (`_`) to separate words.
- Column names should be descriptive and business-friendly.
- Avoid unnecessary abbreviations.
- Avoid spaces and special characters.
- Avoid SQL reserved words.

Examples:

```text
customer_id
customer_key
first_name
last_name
product_name
sales_amount
order_date
