# 📦 Brz Ecommerce — Power BI Analytics

> **Analysis of 100,000+ orders from a Brazilian marketplace (2016–2018) with interactive visualizations and dynamic dashboards**  
> Tools: Power BI · Power Query · DAX · SQL Server

**Author:** Tushar Rana

---

## 🏷️ Technologies

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Power Query](https://img.shields.io/badge/Power_Query-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-009688?style=for-the-badge)
![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Kaggle](https://img.shields.io/badge/Dataset-Kaggle-20BEFF?style=for-the-badge&logo=kaggle&logoColor=white)

---

## 🔗 Report Access

| Resource                  | Link                                                                                                                                                                                                                 |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 📊 **Interactive report** | [View report in Power BI Service](https://app.powerbi.com/view?r=eyJrIjoiYWRkZDZmNWQtZmM1Ni00OTlhLTllMmMtMzMwMjBlYjRkMTg2IiwidCI6IjE4YzQ0ODRlLWFmYjctNGFjYS04NDM1LWZmYzQwOGY0YjE3NiJ9&pageName=7a6c62f682e264b660a5) |
| 📦 **Original dataset**   | [Brazilian E-Commerce — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)                                                                                                                         |

---

## 📊 Dashboard Preview

### 💰 Sales Overview — Revenue, Average Order Value, and Key KPIs

![Sales Dashboard](screenshots/Sales_2.png)

### 🗺️ Geographic Distribution and Regional Sales Segmentation

![Sales Dashboard 2](screenshots/Sales.png)

### 📊 Operational Performance — Satisfaction, Logistics, and Seller Efficiency

![Performance Dashboard](screenshots/Performance.png)

### 🏆 Seller Ranking and Market Concentration Analysis

![Performance Dashboard 2](screenshots/Performance_2.png)

### 📈 Sales History — Trends, Seasonality, and the November Effect

![Sales History](screenshots/Sales_History.png)

### 🛍️ Product Category Profitability Analysis

![Product Category Table](screenshots/Product_Category_Table.png)

### 📦 Product Details — Volume, Price, and Sales Behavior

![Products Table](screenshots/Products_Table.png)

## 📌 Project Description

This project builds on previous work in **SQL Server**, where the main business questions were answered using optimized queries and views. That analysis validated data quality, business logic, and metric accuracy.

The project now extends into **Power BI**, using the existing data model and SQL analysis. The goal is to **make the results more accessible through interactive visualizations and dynamic dashboards**.

> 📁 The SQL Server analysis is documented in the companion repository section:
> **[Brz Ecommerce — SQL Server Analysis](./SQL_README.md)**

### What Makes This Project Special?

The direct **SQL Server to Power BI connection through ODBC** delivers clean, optimized data and avoids unnecessary transformations. The hybrid star model uses `dim_ordenes_detalles` as its central hub, allowing order and item metrics to be analyzed without duplicating results. Inactive relationships with `USERELATIONSHIP` support analysis from multiple date perspectives.

---

## 📑 Table of Contents

### 🧭 Navigation

- The sections follow the project workflow: **Load → Clean → Model → Analyze → Conclude**.
- Return to the contents with `Ctrl+F` and search for **"📑 Table of Contents"**.

---

- [1 — Key KPIs](#1--key-kpis)
- [2 — Project Architecture](#2--project-architecture)
  - [2.1 — Data Loading](#21--data-loading)
  - [2.2 — Power Query Cleaning](#22--power-query-cleaning)
  - [2.3 — Power BI Modeling](#23--power-bi-modeling)
    - [Model Tables](#model-tables)
    - [Relationships](#relationships)
    - [Calendar Table](#calendar-table)
    - [Review and Order Status Adjustments](#review-and-order-status-adjustments)
- [3 — Business Analysis](#3--business-analysis)
  - [3.1 — Customers and Market](#31--customers-and-market)
  - [3.2 — Sales and Products](#32--sales-and-products)
  - [3.3 — Sellers](#33--sellers)
  - [3.4 — Logistics and Delivery](#34--logistics-and-delivery)
  - [3.5 — Payments and Billing](#35--payments-and-billing)
  - [3.6 — Customer Satisfaction](#36--customer-satisfaction)
- [4 — Next Steps](#4--next-steps)
- [5 — Final Conclusions](#5--final-conclusions)
- [6 — Repository Structure](#6--repository-structure)
- [7 — Dataset](#7--dataset)
- [Contact](#contact)

---

## 1 — Key KPIs

| Metric                         | Value                          |
| ------------------------------ | ------------------------------ |
| 💰 Total Sales                 | $8,700,000                     |
| 👥 Unique Customers            | 53,000                         |
| 📦 Order Volume                | 54,000                         |
| 🎫 Average Order Value         | $161.07                        |
| ✅ On-Time Delivery SLA        | 90.8% (89,944 / 99,000 orders) |
| ⭐ Average Review Score        | 4.09 / 5.00                    |
| 🏪 Top 10 Seller Concentration | 7.28% of the market            |

---

## 2 — Project Architecture

```
SQL Server (Brz_Ecommerce)
        │
        ▼ ODBC connection + native SQL
┌─────────────────────────┐
│   POWER QUERY (ETL)     │  ← Cleaning, normalization, and calendar table
│  dim_ordenes_detalles   │
│  dim_cliente            │
│  dim_vendedores         │
│  dim_productos          │
│  dim_ordenes_pago       │
│  fact_orders_items      │
│  Tabla_Calendario       │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  DATA MODEL             │  ← Hybrid star model + DAX measures
│  VertiPaq Engine        │  ← Power BI internal analytics engine
│  Hub: dim_ord_detalles  │
│  Active relationships   │
│  Inactive relationships │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  DASHBOARDS             │  ← Interactive visualizations
│  Sales Dashboard        │
│  Performance Dashboard  │
│  Sales History          │
│  Product Details        │
│  Category Details       │
└─────────────────────────┘
```

---

### 2.1 — Data Loading

- Data was loaded through an **ODBC connection** to SQL Server from the **Brz_Ecommerce** database.
- Data was retrieved with **optimized SQL queries** from the six analytical views, which allowed the project to:
  - Reduce processing steps in Power BI.
  - Avoid unnecessary Power Query transformations.
  - Deliver clean data ready for modeling.
- This approach provides a more efficient workflow and better model performance.

---

### 2.2 — Power Query Cleaning

- Unnecessary columns were removed to improve model performance.
- State, city, and product-category names were standardized.
- Null values in `seller_id`, product categories, and reviews were reviewed and handled.
- Data types were adjusted:
  - **Dates:** `order_purchase_timestamp`, `order_delivered_customer_date`
  - **Numeric:** `payment_value`, `freight_value`
  - **Text:** `estado`, `ciudad`, `categoria_producto`

---

### 2.3 — Power BI Modeling

The model evolved from a classic star schema into a **hybrid architecture** centered on `dim_ordenes_detalles`. This hub contains customer, seller, date, status, and review metrics, reducing duplication and simplifying analysis.

#### Model Tables

**🟦 Fact Table — `fact_orders_items`**  
Fact table at the granularity of each item sold in an order.

- `order_item_id`
- `order_id`
- `customer_id`
- `product_id`
- `seller_id`
- `price`
- `freight_value`
- `shipping_limit_date`

---

**🟩 Central Dimension — `dim_ordenes_detalles`**  
Central model hub. Contains order information, dates, status, and review metrics.

- `order_id`
- `customer_id`
- `seller_id`
- `order_status`
- `fecha_compra`
- `fecha_aprobacion`
- `fecha_entrega_cliente`
- `fecha_entrega_estimada`
- `fecha_envio_transportista`
- `fecha_limite_envio`
- `AvgReviewScore`
- `CountReviews`
- `MaxReviewScore`
- `MinReviewScore`

---

**🟩 Dimension — `dim_cliente`**  
Customer geographic and demographic information.

- `customer_id`
- `customer_unique_id`
- `customer_city`
- `customer_state`
- `customer_zip_code_prefix`
- `geolocation_lat`
- `geolocation_lng`

---

**🟩 Dimension — `dim_vendedores`**  
Seller information.

- `seller_id`
- `seller_city`
- `seller_state`
- `seller_zip_code`

---

**🟩 Dimension — `dim_productos`**  
Product catalog.

- `product_id`
- `product_category`

---

**🟩 Payments — `dim_ordenes_pago`**  
Payment details by order.

- `order_id`
- `payment_sequential`
- `payment_type`
- `payment_value`

---

**📅 Table — `Tabla_Calendario`**  
Date table for temporal analysis and time intelligence.

- `fecha` / `fechask`
- `año` / `mes` / `mescorto`
- `añomes` / `añomescorto`
- `trimestre` / `añotrimestre`
- `semanaAño` / `SemanaMes`
- `cierresemana` / `iniciomes` / `finmes`
- `dia` / `diacorto` / `diaaño` / `diasemana`

---

#### Relationships

**Active relationships (all 1:N):**

- **dim_cliente (1)** → **dim_ordenes_detalles (N)**
- **dim_vendedores (1)** → **dim_ordenes_detalles (N)**
- **dim_productos (1)** → **fact_orders_items (N)**
- **dim_ordenes_detalles (1)** → **fact_orders_items (N)**
- **dim_ordenes_pago (N)** → **dim_ordenes_detalles (1)**
- **Tabla_Calendario (1)** → **dim_ordenes_detalles (N)** — through `fecha_compra`

**Inactive relationships** _(activated with `USERELATIONSHIP` in specific measures)_:

- **dim_cliente (1)** → **fact_orders_items (N)**
- **dim_vendedores (1)** → **fact_orders_items (N)**
- **Tabla_Calendario (1)** → **dim_ordenes_detalles (N)** — through `order_delivered_customer_date`
- **Tabla_Calendario (1)** → **dim_ordenes_detalles (N)** — through `order_approved_at`

---

#### Calendar Table

To enable time-intelligence functions (YTD, YoY, MTD), `Tabla_Calendario` was created in Power Query from the `fecha_compra` column.

- **Active relationship:** `Tabla_Calendario[Fecha]` → `dim_ordenes_detalles[fecha_compra]`
- Inactive relationships to `order_delivered_customer_date` and `order_approved_at` support delivery- and approval-date analysis with `USERELATIONSHIP`.
- It includes complete hierarchies: year, quarter, month, week, day, and auxiliary month-start and month-end columns.

---

#### Review and Order Status Adjustments

The following modeling changes simplified the model and improved readability:

**Centralized reviews in `dim_ordenes_detalles`:**

- Direct loading of `db_ordenes_reviews` was disabled.
- Reviews were grouped by `order_id` and aggregated metrics were calculated:
  - `AvgReviewScore` → Average reviews per order.
  - `CountReviews` → Number of reviews per order.
  - `MinReviewScore` / `MaxReviewScore` → Minimum and maximum review per order.
- These columns were integrated into `dim_ordenes_detalles`, avoiding extra relationships and reducing model cardinality.

**Null value handling:**

- `null` values were retained in review metrics so averages and sums are not distorted.
- `null` values help identify canceled or unreviewed orders when combined with `order_status`.

**Order status translation (`order_status`):**

| Original value | Translation |
| -------------- | ----------- |
| `approved`     | Approved    |
| `canceled`     | Canceled    |
| `created`      | Created     |
| `delivered`    | Delivered   |
| `invoiced`     | Invoiced    |
| `processing`   | Processing  |
| `shipped`      | Shipped     |
| `unavailable`  | Unavailable |

---

## 3 — Business Analysis

### 3.1 — Customers and Market

_Analysis of geographic reach and user-base expansion._

**3.1.1 — Concentration by state:**

| State | Unique Customers |
| ----- | ---------------- |
| SP    | 40,300           |
| RJ    | 12,380           |
| MG    | 11,259           |

> **Insight:** The market is strongly led by Brazil's Southeast region.
> SP represents approximately 42% of unique customers, followed by RJ and MG.
> The North and Northeast offer expansion opportunities because of lower penetration and large population potential.

**3.1.2 — New Customer Growth:**

- 🚀 **2016–2017 period:** Explosive **13,308.9%** growth during marketplace scaling.
- 📈 **2017–2018 period:** Sustained **20.7%** growth, indicating market consolidation.

**3.1.3 — Cities with the Highest Sales Volume:**

| City           | Sales Volume |
| -------------- | ------------ |
| São Paulo      | $2,200,000   |
| Rio de Janeiro | $1,160,000   |
| Belo Horizonte | $421,770     |
| Brasília       | $354,422     |
| Curitiba       | $247,390     |

---

### 3.2 — Sales and Products

_Identification of revenue drivers and consumer preferences._

**3.2.1 — Highest-Turnover Categories (Top 5):**

| Category              | Units Sold |
| --------------------- | ---------- |
| bed_bath_table        | 11,115     |
| health_beauty         | 9,670      |
| sports_leisure        | 8,641      |
| furniture_decor       | 8,334      |
| computers_accessories | 7,827      |

**3.2.2 — Average Order Value per Customer:** $161.07

**3.2.3 — Highest-Value Products:**

| Product SKU                        | Total Sales |
| ---------------------------------- | ----------- |
| `bb50f2e236e5eea0100680137654686c` | $63,885.00  |
| `6cdd53843498f92890544667809f1595` | $54,730.20  |
| `d6160fb7873f184099d9bc95e30376af` | $48,899.34  |

**3.2.4 — Seasonality and Time-Based Behavior:**

- **Annual sales peaks:** March through June contains the highest transaction volume.
- **Weekly pattern:** Monday through Thursday are the most active sales days.
- **The November effect:** Fridays in November become the strongest sales and new-customer acquisition days, driven by **Black Friday**.

> **Operational implication:** Black Friday requires specialized logistics planning. Inventory should be positioned in advance and capacity expanded during the two weeks before the final Friday of November.

---

### 3.3 — Sellers

_Evaluation of the partner ecosystem and operational efficiency._

**3.3.1 — Orders per Seller Ranking:**

The leading seller (`id:6560211a19b47992c3666cc44a7e94c0`) handles **1,841 orders**, followed by the second-ranked seller (`id:4a3ca9315b744ce9f8e9374361493884`) with 1,754.

**3.3.2 — Market Concentration:**

The top 10 sellers account for only **7.28%** of the market.

> **Insight:** Because it is below 10%, the marketplace shows healthy competition and low dependence on individual sellers. This reduces operational risk and benefits customers.

**3.3.3 — Delivery-Time Performance:**

- **Best seller:** `d13e50eaa47b4cbe9eb81465865d8cfc` with an average delivery time of **5 days**.
- **Efficient average:** the best sellers average **6.49 days**, compared with the overall average of **12.5 days**.

---

### 3.4 — Logistics and Delivery

_Analysis of delivery-time compliance and geographic distribution._

**3.4.1 — Average Delivery Time by State:**

- **Minimum:** 8.70 days — State **SP**
- **Maximum:** 29.34 days — State **RR**

**3.4.2 — Orders Delivered Within the Estimated Time (SLA):**

Of 99,000 total orders, **89,944 (90.8%)** were delivered on time.

**3.4.3 — States with the Highest Delay Rate:**

| State | Delay Rate |
| ----- | ---------- |
| AL    | 21.41%     |
| MA    | 17.43%     |
| SE    | 15.22%     |

> **Focus area:** Northeast states have delay rates well above the national average (9.2%). Regional logistics partnerships or intermediate distribution centers should be evaluated.

---

### 3.5 — Payments and Billing

_Analysis of payment preferences and payment methods._

**3.5.1 — Most-Used Payment Methods:**

Electronic methods dominate the payment system.

- **Credit Card:** preferred by most users.
- **Boleto Bancario:** the second most relevant option.

**3.5.2 — Average Transaction Value by Payment Type:**

| Payment Method | Average Order Value |
| -------------- | ------------------- |
| Credit Card    | $163.32             |
| Debit Card     | $142.57             |
| Boleto         | $142.57             |
| Voucher        | $65.70              |

> **Insight:** Credit-card customers make higher-value purchases than customers using other methods, creating an opportunity for payment-method-based offers.

**3.5.3 — Payment Mode: Single Payment vs. Installments:**

| Payment Mode   | % of Orders |
| -------------- | ----------- |
| Single Payment | 96.94%      |
| Installments   | 3.06%       |

---

### 3.6 — Customer Satisfaction

_Correlation between logistics operations and customer perception._

**3.6.1 — Negative Reviews by Order Status:**

A critical volume of negative reviews was identified for orders with **"Processing"** status.

> **Key insight:** dissatisfaction occurs during internal order processing, even **before** the package reaches the carrier. This indicates an internal operational issue rather than an external logistics issue.

**3.6.2 — Relationship: Delivery Time vs. Satisfaction:**

| State | Average Delivery Days | Average Score |
| ----- | --------------------- | ------------- |
| AM    | 26.36 days            | 4.21 ⭐       |
| RR    | 29.34 days            | 3.61 ⭐       |

> **Conclusion:** delivery time matters, but **the quality of service during the wait can mitigate the impact of a late delivery**. AM delivers late but provides good service; RR delivers late with poorer management.

**3.6.3 — Overall Satisfaction Performance:**

The average score for delivered transactions is **4.09 / 5.00**, with 57% of reviews receiving the maximum score of five stars. Logistics centers in the North and Northeast have clear opportunities for improvement.

---

## 4 — Next Steps

_Strategic roadmap for scaling the project._

- **🛡️ RLS implementation (Row Level Security):** configure row-level security so each seller can access only their own metrics in a multi-user environment.
- **⚡ Alert automation:** create Power Automate flows that notify logistics when the SLA in critical states (AL, MA) falls below 85%.
- **📈 Model expansion:** add customer acquisition cost (CAC) and marketing data to calculate actual ROI by product category.
- **📊 Executive Summary page:** create one screen with the five most important business findings for management.
- **🔧 Reclassify `dim_ordenes_pago`:** move it to a fact table to improve dimensional-model integrity.

---

## 5 — Final Conclusions

The **Brz Ecommerce** project demonstrates successful integration between SQL Server data engineering and strategic Power BI visualization. Processing more than **100,000 records** made it possible to:

1. **Identify seasonality patterns:** buying behavior changes sharply in November, requiring specialized logistics for Fridays in that month.
2. **Detect internal inefficiencies:** dissatisfaction in the North and Northeast is not caused only by transportation; the "Processing" status is the largest source of negative reviews.
3. **Validate marketplace health:** low top-10 seller concentration (7.28%) confirms a competitive, stable ecosystem with low dependency risk.

---

## 🛠️ Technology Stack

| Tool                | Project Application                                                |
| ------------------- | ------------------------------------------------------------------ |
| **SQL Server**      | ETL, cleaning, analytical views, and business-logic validation     |
| **Power BI**        | Hybrid dimensional modeling, advanced DAX, and UI/UX design        |
| **Power Query (M)** | Cleaning, normalization, calendar table, and review centralization |
| **DAX**             | KPIs, YoY, YTD, market concentration, and USERELATIONSHIP          |
| **Markdown**        | Technical documentation and communication of findings              |

---

## 6 — Estructura del Repositorio

```
📁 Proyecto2-BrzEcommerce/
│
├── 📝 SQL_README.md                       ← SQL Server documentation
├── 📝 README.md                           ← Power BI documentation
├── 📋 Ecommerce_Documentation.pdf         ← Complete project documentation
│
├── 🗄️ 01_Brz_Ecommerce_Database_Setup.sql
├── 🗄️ 02_Brz_Ecommerce_Data_Model_Views.sql
├── 🗄️ 03_Brz_Ecommerce_Business_Analysis.sql
│
└── 📁 screenshots/
    ├── Sales.png
    ├── Sales_2.png
    ├── Performance.png
    ├── Performance_2.png
    ├── Sales_History.png
    ├── Product_Category_Table.png
    └── Products_Table.png
```

---

## 7 — Dataset

- **Source:** [Brazilian E-Commerce Public Dataset by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Period:** September 2016 – October 2018
- **Records:** 99,441 orders / 112,650 items
- **Original tables:** orders, customers, order_items, order_payments, order_reviews, products, sellers, geolocation, product_category_name_translation.

---

## 📬 Contact

For business problem-solving through clean data and strategic visualizations, get in touch.

<div align="center">

[![LinkedIn](https://img.shields.io/badge/💼_LinkedIn-0A66C2?style=for-the-badge)](https://linkedin.com/in/joseph-velasco)
[![Portafolio](https://img.shields.io/badge/🌐_Portafolio-0B2545?style=for-the-badge)](https://sites.google.com/view/joseph-velasco-data-analyst/inicio)
[![GitHub](https://img.shields.io/badge/🐙_GitHub-181717?style=for-the-badge)](https://github.com/DatajosephVe)
[![Email](https://img.shields.io/badge/📧_Email-D14836?style=for-the-badge)](mailto:josephvelasco2223@gmail.com)
[![CV](https://img.shields.io/badge/📄_Download_CV-134074?style=for-the-badge)](https://drive.google.com/file/d/1TG7yL_QXA8ul9wR1ELk41zo_BYcCbFgc/view?usp=sharing)

📍 Venezuela 🇻🇪 · Available for remote work

</div>

---

> **"Turning complex data into business clarity."**

---
