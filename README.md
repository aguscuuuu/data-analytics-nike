# Nike Sales Analytics — SQL Server + Power BI

End-to-end **data analytics** project built on a Nike sales dataset for the United States (**229,471 transactions**, 2020–2024). The raw data is normalized into a **star schema** in **SQL Server**, loaded from JSON files with `OPENROWSET` + `OPENJSON`, explored through a progressive set of **T-SQL** practice queries (filters, aggregations, joins, CTEs, window functions) and finally visualized in an interactive **Power BI** dashboard.

The repository contains everything needed to reproduce the pipeline: source datasets (Excel, CSV and JSON), the SQL scripts in execution order, the `.pbix` report, the multimedia assets used in the dashboard and a collection of Power BI color themes.

---

## Table of contents

- [Features](#features)
- [Tech stack](#tech-stack)
- [Repository structure](#repository-structure)
- [Data model](#data-model)
- [Datasets](#datasets)
- [SQL scripts](#sql-scripts)
- [Power BI dashboard](#power-bi-dashboard)
- [Local installation](#local-installation)
- [Status](#status)
- [Author](#author)
- [License](#license)

---

## Features

- **Dimensional modeling**: a central fact table (`FactNikeSales`) surrounded by 13 dimension tables, all linked with foreign key constraints.
- **JSON ingestion** directly from SQL Server with `OPENROWSET(BULK ..., SINGLE_CLOB)` + `OPENJSON ... WITH (...)`, including date conversion of the invoice field.
- **Load verification** queries after every ingestion step.
- **SQL practice activities** covering relational / logical operators, `LIKE`, `IN`, `BETWEEN`, `CASE`, numeric formatting (`ROUND`, `CAST`, `FORMAT`), `GROUP BY` / `HAVING`, subqueries, CTEs, `INNER` / `LEFT` / `RIGHT JOIN`, `UNION` / `UNION ALL` and window functions (`ROW_NUMBER`, share-of-total calculations).
- **Model extension**: a `DimClient` dimension with fictitious retail clients, assigned to each sale according to its location (idempotent script with prior cleanup and integrity checks).
- **Interactive Power BI dashboard** with KPI cards (revenue, profitability, averages), custom navigation buttons (reset filters) and Nike / Jordan branding.

---

## Tech stack

| Category | Technology |
| --- | --- |
| Database | Microsoft SQL Server |
| Query language | T-SQL |
| IDE | SQL Server Management Studio (SSMS) |
| Visualization | Power BI Desktop |
| Data preparation | Microsoft Excel |
| Data formats | JSON, XLSX, CSV |

---

## Repository structure

```
data-analytics-nike/
├── Dashboard.pbix              # Power BI report
├── SQLQuery1.sql               # 1. Database + star schema (DDL)
├── SQLQuery2.sql               # 2. Data load from JSON (OPENROWSET + OPENJSON)
├── SQLQuery3.sql               # 3. Practice: operators, filters, formatting, GROUP BY
├── SQLQuery4.sql               # 4. Practice: subqueries, CTEs, JOINs, UNION, window functions
├── SQLQuery5.sql               # 5. Model extension: DimClient dimension
├── SQLQuery6.sql               # 6. Final assignment query
├── Dataset - Excel/            # Original workbook + campaigns + store images per state
├── Dataset - JSON/             # One JSON file per table (13 dimensions + fact table)
├── Multimedia/                 # Logos, icons, KPI images and GIFs used in the dashboard
└── Temas/                      # Power BI JSON color themes
```

---

## Data model

**Star schema** in the `BD_Nike` database:

```
                     DimCategory   DimSubCategory   DimProductType
                            \            |            /
   DimDepartment ──┐         \           |           /        ┌── DimBrand
   DimProductName ─┤          ┌──────────────────────┐        ├── DimColor
   DimDescription ─┼──────────│    FactNikeSales     │────────┼── DimAvailability
                   │          └──────────────────────┘        │
                   │            /        |         \          │
                 DimClient  DimRegion  DimState  DimCity ─────┘
```

### Fact table — `dbo.FactNikeSales`

| Column | Type | Description |
| --- | --- | --- |
| `SaleID` | `BIGINT IDENTITY` | Surrogate primary key |
| `InvoiceDate` | `DATE` | Invoice date |
| `id_Region`, `id_State`, `id_City` | `INT` (FK) | Sale location |
| `id_DEPARTMENT`, `id_Category`, `id_SubCategory` | `INT` (FK) | Product hierarchy |
| `id_PRODUCT_NAME`, `id_DESCRIPTION`, `id_PRODUCT_TYPE` | `INT` (FK) | Product attributes |
| `id_COLOR`, `id_BRAND`, `id_AVAILABILITY` | `INT` (FK) | Product attributes |
| `id_Client` | `INT` (FK) | Client (added in `SQLQuery5.sql`) |
| `PRODUCT_SIZE` | `NVARCHAR(40)` | Size (e.g. `S`, `M`, `L`, `9.5`) |
| `PricePerUnit` | `DECIMAL(12,2)` | Unit price |
| `UnitsSold` | `INT` | Units sold |
| `CostoUnitario` | `DECIMAL(12,2)` | Unit cost |
| `OperatingMargin` | `DECIMAL(6,3)` | Operating margin |

### Dimension tables

| Table | Content |
| --- | --- |
| `DimRegion` | Northeast, South, West, Midwest, Southeast |
| `DimState` / `DimCity` | U.S. states and cities where sales took place |
| `DimDepartment` | Kids, Men, Women |
| `DimCategory` | Accessories & Equipment, Clothing, Shoes |
| `DimSubCategory` | Product sub-categories |
| `DimBrand` | ACG, Jordan, Nike, NikePro, NikeSportswear, NIKEiD, NikeLab, Norecord |
| `DimProductType`, `DimProductName`, `DimDescription`, `DimColor` | Product catalog attributes |
| `DimAvailability` | Stock availability status |
| `DimClient` | Fictitious retail clients (name, type, location) |

---

## Datasets

| Folder | File | Description |
| --- | --- | --- |
| `Dataset - Excel` | `nike_data.xlsx` | Original source workbook |
| `Dataset - Excel` | `Campaña.xlsx` | Marketing campaigns per product (`id_Campaign`, `Campaign`, `id_PRODUCT_NAME`) |
| `Dataset - Excel` | `Sucursales_Estados.csv` | Store image URL per state (`;`-separated), used in the dashboard |
| `Dataset - JSON` | `ventas_nike.json` | Fact table: 229,471 sales (~46k per year, 2020–2024) |
| `Dataset - JSON` | `Categorias.json`, `Ciudad.json`, `Color.json`, … | One file per dimension table |

---

## SQL scripts

Run them **in order** — each script depends on the previous one.

| # | Script | Purpose |
| --- | --- | --- |
| 1 | `SQLQuery1.sql` | Creates the `BD_Nike` database, the 12 base dimension tables and `FactNikeSales` with all its foreign keys. |
| 2 | `SQLQuery2.sql` | Loads every JSON file into its table using `OPENROWSET` + `OPENJSON`, then verifies the load. |
| 3 | `SQLQuery3.sql` | Practice activity: relational and logical operators, `LIKE` patterns, `IN`, `BETWEEN`, `CASE`, arithmetic, `ROUND` / `CAST` / `FORMAT`, `ORDER BY`, `TOP`, `GROUP BY`, `HAVING`. |
| 4 | `SQLQuery4.sql` | Practice activity: scalar subqueries and `ISNULL`, CTE refactoring, `INNER` / `LEFT` / `RIGHT JOIN`, regional consolidation with `UNION`, ranking per city and size share with window functions. |
| 5 | `SQLQuery5.sql` | Creates `DimClient`, generates fictitious clients per location, links them to the fact table (`id_Client` FK + index) and runs integrity checks. Safe to re-run. |
| 6 | `SQLQuery6.sql` | Final query: sales per client in the last 30 days of available data. |

### Query example

```sql
-- top products by operating margin in each city
SELECT
    c.City AS Sucursal,
    np.ProductName AS Productos,
    v.OperatingMargin AS Margen_Operativo,
    ROW_NUMBER() OVER (PARTITION BY c.City ORDER BY v.OperatingMargin DESC) AS Ranking_Margen
FROM dbo.FactNikeSales v
INNER JOIN dbo.DimCity c
    ON v.id_City = c.id_City
INNER JOIN dbo.DimProductName np
    ON v.id_PRODUCT_NAME = np.id_PRODUCT_NAME;
```

---

## Power BI dashboard

`Dashboard.pbix` connects to the `BD_Nike` model and presents:

- **KPI cards**: total revenue, total and average profitability, average revenue and units sold.
- **Slicers and cross-filtering** by region, state, city, department, category, brand and date.
- **Custom navigation** with reset-filter buttons.
- **Branding** with Nike / Jordan logos, animated GIFs and store images per state.

Visual assets live in `Multimedia/`, and alternative color palettes can be imported from `Temas/` via *View → Themes → Browse for themes* in Power BI Desktop.

---

## Local installation

### Prerequisites
- Microsoft SQL Server (Express or Developer edition is enough).
- SQL Server Management Studio (SSMS) or Azure Data Studio.
- Power BI Desktop (Windows).

### Steps

1) Clone the repository
```sh
git clone https://github.com/aguscuuuu/data-analytics-nike.git
```

2) Copy the JSON files to the path expected by the load script

`SQLQuery2.sql` reads the files from `C:\data-json\`. Copy the content of `Dataset - JSON/` there (or edit the `BULK` paths in the script):
```powershell
New-Item -ItemType Directory -Force C:\data-json
Copy-Item "data-analytics-nike\Dataset - JSON\*" C:\data-json\
```

> The SQL Server service account must have read permissions on that folder.

3) Run the SQL scripts in SSMS, in order: `SQLQuery1.sql` → `SQLQuery6.sql`.

4) Open `Dashboard.pbix` in Power BI Desktop and, if needed, update the data source (*Transform data → Data source settings*) to point to your SQL Server instance. Then click **Refresh**.

---

## Status

- **Version:** `1.0.0`
- **Date:** `Oct 2026`

---

## Author

- **Agustín Cuenca** (`AgustinCuenca` · `aguabentura08@gmail.com`) — *Main developer*

## License

This work has been dedicated to the public domain under the **Creative Commons CC0 1.0 Universal Public Domain Dedication**. To the extent possible under law, the author has waived all copyright and related or neighboring rights.

> You can copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission.

> The dataset is used for educational purposes only. Nike, Jordan and related marks belong to their respective owners.

**© 2026 cueCode Software.**

```
                                   ______          __
                  _______  _____  / ____/___  ____/ /__
                 / ___/ / / / _ \/ /   / __ \/ __  / _ \
               / /__/ /_/ /  __/ /___/ /_/ / /_/ /  __/
                \___/\__,_/\___/\____/\____/\__,_/\___/  _____
                  / ___/____  / __/ /__      ______ _________
                  \__ \/ __ \/ /_/ __/ | /| / / __ `/ ___/ _ \
                 ___/ / /_/ / __/ /_ | |/ |/ / /_/ / /  /  __/
                /____/\____/_/  \__/ |__/|__/\__,_/_/   \___/
```
