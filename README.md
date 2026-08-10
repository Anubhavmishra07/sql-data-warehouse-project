# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀

This project demonstrates an end-to-end **Data Warehouse** built using **MySQL 8.0**, following the **Medallion Architecture (Bronze, Silver, and Gold)**. It covers the complete data engineering workflow—from ingesting raw data to creating a business-ready analytical model.

Designed as a portfolio project, it showcases industry best practices in **ETL development**, **data modeling**, **data quality**, and **SQL-based analytics**.

---

# 🏗️ Data Architecture

The project follows the **Medallion Architecture**, consisting of **Bronze**, **Silver**, and **Gold** layers.

![Data Architecture](docs/data_architecture.png)

### Bronze Layer
Stores raw data exactly as received from the source systems. Data is imported from CSV files into MySQL using `LOAD DATA INFILE`.

### Silver Layer
Applies data cleansing, standardization, normalization, and integration to produce clean, reliable datasets.

### Gold Layer
Creates business-ready analytical views using a **Star Schema**, consisting of fact and dimension tables optimized for reporting and analytics.

---

# 📖 Project Overview

- Design a modern Data Warehouse using the Medallion Architecture.
- Build ETL pipelines to ingest, clean, transform, and integrate data.
- Model analytical data using Fact and Dimension tables.
- Perform SQL-based analytics on business-ready datasets.
- Implement data quality validation across warehouse layers.

---

# 🎯 Skills Demonstrated

- MySQL 8.0
- Data Warehousing
- Data Engineering
- ETL Pipeline Development
- Data Modeling
- Star Schema Design
- SQL Development
- Data Cleansing
- Data Integration
- Data Quality Validation
- Analytics & Reporting

---

# 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| Database | MySQL 8.0 |
| SQL IDE | MySQL Workbench |
| Source Data | CSV Files |
| Data Loading | LOAD DATA INFILE |
| Documentation | Markdown |
| Diagrams | Draw.io |
| Version Control | Git & GitHub |

---

# 📂 Repository Structure

```text
sql-data-warehouse-project/
├── datasets/
├── docs/
├── scripts/
│   ├── init_database.sql
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   └── quality_checks/
├── README.md
├── LICENSE
└── .gitignore
```

---

# 🚀 Execution Order

```text
1. init_database.sql
2. create_bronze_tables.sql
3. load_bronze.sql
4. create_silver_tables.sql
5. load_silver.sql
6. create_gold_views.sql
7. quality_checks_silver.sql
8. quality_checks_gold.sql
```

---
# 🛡️ License

This project is licensed under the **MIT License**.
