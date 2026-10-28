# Nike Sales Analytics — SQL Server + Power BI

Final integrative project (*Proyecto Integrador Final*) of the **Data Analytics** course at [Coderhouse](https://www.coderhouse.com/). It solves a business case on a Nike sales dataset for the United States (**229,471 transactions**, January 2020 – December 2024): the raw data is modeled in **SQL Server**, loaded from JSON files with `OPENROWSET` + `OPENJSON`, explored through progressive **T-SQL** queries and finally communicated through a **Power BI** monthly sales report built with data storytelling principles.

The assignment instructions and the full written solution (theory questions, SQL exercise, ER diagram and dashboard explanation, with screenshots) are in [`Proyecto Integrador Final.pdf`](Proyecto%20Integrador%20Final.pdf). The repository also contains the source datasets (Excel, CSV and JSON), the SQL scripts in execution order, the `.pbix` report and a collection of Power BI color themes.

---

## Tech stack

| Category | Technology |
| --- | --- |
| Database | Microsoft SQL Server |
| Query language | T-SQL |
| IDE | SQL Server Management Studio (SSMS) |
| Visualization | Power BI Desktop (Power Query + DAX) |
| Data preparation | Microsoft Excel |
| Data formats | JSON, XLSX, CSV |

---

## Repository structure

```
data-analytics-nike/
├── Proyecto Integrador Final.pdf   # Assignment instructions + written solution
├── Dashboard.pbix                  # Power BI report
├── SQLQuery1.sql                   # 1. Database + star schema (DDL)
├── SQLQuery2.sql                   # 2. Data load from JSON (OPENROWSET + OPENJSON)
├── SQLQuery3.sql                   # 3. Practice: operators, filters, formatting, GROUP BY
├── SQLQuery4.sql                   # 4. Practice: subqueries, CTEs, JOINs, UNION, window functions
├── SQLQuery5.sql                   # 5. Model extension: DimClient dimension
├── SQLQuery6.sql                   # 6. Final assignment query
├── Dataset - Excel/                # Original workbook + campaigns + store images per state
├── Dataset - JSON/                 # One JSON file per table (dimensions + fact table)
└── Temas/                          # Power BI JSON color themes
```

---

## Data model

The `BD_Nike` database is organized as a **star schema**. At its center is the fact table `FactNikeSales`, with one row per sale storing the invoice date, size, unit price, units sold, unit cost and operating margin, plus the foreign keys that link it to the dimension tables. The **product** is not a single table but is split into several dimensions (name, description, category, sub-category, product type, brand, color, department and availability), which avoids repeating text in every sale and allows filtering the analysis by any attribute. The **location** of each sale is described by `DimRegion`, `DimState` and `DimCity`. Every relationship is one-to-many and enforced with foreign key constraints.

Since the original dataset has no customer information, a `DimClient` dimension was **derived** for the final assignment: 162 fictitious retailers (three per each of the 54 sale locations, e.g. *Peak Performance Albany*), each assigned to the sales of its same region, state and city with an uneven split (~50 / 33 / 17 %) so client volumes differ as they would in reality. In Power BI the model is completed with a DAX **calendar table**, the campaigns per product (`Campaña.xlsx`) and the store images per state (`Sucursales_Estados.csv`).

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

Run them **in order** — each script depends on the previous one. Scripts 1 to 4 were developed during the course classes; scripts 5 and 6 (and the date fix in script 2) belong to the final assignment.

| # | Script | Purpose |
| --- | --- | --- |
| 1 | `SQLQuery1.sql` | Creates the `BD_Nike` database, the 12 base dimension tables and `FactNikeSales` with all its foreign keys. |
| 2 | `SQLQuery2.sql` | Loads every JSON file into its table using `OPENROWSET` + `OPENJSON`. Cleans the data on the way: renames columns with spaces, replaces decimal commas with `REPLACE` + `TRY_CONVERT` and parses `INVOICE DATE` as `dd/mm/yyyy` (style `103`). The original style `101` swapped day and month and dropped most rows (90,270 instead of 229,471). Ends with a verification query. |
| 3 | `SQLQuery3.sql` | Practice activity: relational and logical operators, `LIKE` patterns, `IN`, `BETWEEN`, `CASE`, arithmetic, `ROUND` / `CAST` / `FORMAT`, `ORDER BY`, `TOP`, `GROUP BY`, `HAVING`. |
| 4 | `SQLQuery4.sql` | Practice activity: scalar subqueries and `ISNULL`, CTE refactoring, `INNER` / `LEFT` / `RIGHT JOIN`, regional consolidation with `UNION`, ranking per city and size share with window functions. |
| 5 | `SQLQuery5.sql` | Creates `DimClient` with CTEs + `CROSS JOIN`, links it to the fact table (`id_Client` FK + index) and runs integrity checks. Idempotent: it cleans up a previous run before starting. |
| 6 | `SQLQuery6.sql` | Final query: client name, purchase date and sale total for the last 30 days of available data (computed from `MAX(InvoiceDate)`), ordered by date descending. Returns 3,682 sales from December 2024. |

---

## Power BI dashboard

`Dashboard.pbix` is a **monthly sales report for a marketing team**, designed as a story that goes from the general picture to the detail and ends with a recommendation. Every chart title states its conclusion, so the report can be understood by reading the titles alone. For December 2024 it includes:

- **Headline**: *"December 2024 was the best December of the last five years"*.
- **Slicers** for period, region, product and client, to repeat the analysis on any month or market.
- **KPI cards**: revenue ($85.8M), change vs. previous month (+0.7%) and vs. previous year (+12.8%), margin (54.7%) and active clients (162 vs. 135).
- **Line chart** of monthly revenue, with 2024 highlighted against previous years (Q4 recovery after the September drop).
- **Grouped bar chart** by region, year-over-year (West +59.7%; Northeast and South down).
- **Bar charts** by category (footwear explains 59% of revenue) and by department (men account for 6 of every 10 dollars).
- **Top 5 clients table** (together under 10% of monthly revenue).
- **Proposal box**: replicate the West's commercial actions in the Northeast and South, and reinforce footwear.

Alternative color palettes can be imported from `Temas/` via *View → Themes → Browse for themes* in Power BI Desktop.

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

**Made by...**

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
