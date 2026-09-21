# Brz Ecommerce - SQL Server Analysis

> Relational modeling, analytical views, and business queries for 100,000+ orders from a Brazilian marketplace (2016-2018).

**Author:** Tushar Rana - Data Analyst

## Technologies

- SQL Server
- T-SQL
- SQL Server Management Studio (SSMS)
- Kaggle Brazilian E-Commerce Public Dataset by Olist

## Project Description

This project builds a relational SQL Server database, an analytical view layer, and a business-analysis query layer for the Brazilian E-Commerce Public Dataset by Olist.

The solution demonstrates relational modeling, referential integrity, geolocation normalization, indexing, reusable analytical views, and business reporting queries.

## Quick Start

Run the project in this order:

1. Open `01_Brz_Ecommerce_Database_Setup.sql` in SSMS.
2. Create the `Brz_Ecomerce` database.
3. Import the dataset CSV files into SQL Server.
4. Complete the setup script to create keys, normalization objects, indexes, and validation queries.
5. Run `02_Brz_Ecommerce_Data_Model_Views.sql` to create the analytical views.
6. Run `03_Brz_Ecommerce_Business_Analysis.sql` to run the business queries.

The setup script expects these imported table names:

```text
orders
customer
order_item
order_payments
order_reviews
products
sellers
geolocation
product_category_name_translation
```

The source dataset uses some plural table names. Rename the imported tables to the names above, or update the SQL scripts consistently before running them.

## 1. Database Setup

### 1.1 Database creation

The setup script creates the `Brz_Ecomerce` database and selects it as the active database. The script drops an existing database with the same name, so use this section only when creating a fresh environment.

### 1.2 Data loading

Load the CSV files with the SSMS import wizard before running the key and index sections of the setup script. The imported data is then corrected where the source data types do not match the required relationships.

### 1.3 Keys and referential integrity

The setup script creates primary keys for orders, customers, products, sellers, and translated product categories. It also creates foreign keys connecting orders, customers, products, sellers, payments, reviews, and product categories.

### 1.4 Geolocation normalization

`Geolocation_ZipCode` stores unique ZIP-code prefixes. The customer, seller, and geolocation tables reference this normalized table through foreign keys.

### 1.5 Indexes

Nonclustered indexes support common filters, joins, rankings, and aggregations across customers, orders, order items, payments, reviews, products, and sellers. Composite indexes support city, state, customer, order, payment, and review analysis.

### 1.6 Validation

The setup validation queries check:

- Total order count
- Top customers
- Unique order statuses
- Missing customer references

## 2. Analytical Views

### 2.1 `vw_orders_detail`

The base order-detail view combines orders, order items, products, customers, sellers, payments, and reviews. It provides granular order-item data for downstream analysis.

Important design decisions:

- Payments are joined at order level.
- Reviews are joined through `order_id`.
- No analytical aggregation is applied in this base view.

### 2.2 `vw_info_clientes`

The customer view summarizes customer location, purchased items, average order value per item, total purchase value, freight value, freight percentage, and review count.

### 2.3 `vw_info_vendedores`

The seller view summarizes seller location, order count, units sold, customers served, cities served, states served, total sales, average order value, and review performance.

Payments and reviews are pre-aggregated by order to reduce duplicate values.

### 2.4 `vw_info_producto`

The product view summarizes product category, customer region, minimum price, maximum price, average price, accumulated sales, unique orders, and units sold.

### 2.5 `vw_info_pagos`

The payment view summarizes payment method usage by customer city and state, including unique orders, usage count, and total paid value.

### 2.6 `vw_info_zonas`

The zone view summarizes sales and delivery performance by city and ZIP-code prefix. It includes customers, sellers, orders, items, payment totals, review scores, delivery times, and freight costs.

Orders are consolidated before the final aggregation to reduce duplicate payment, item, and review values.

## 3. Business Analysis

The business-analysis script answers questions about:

### Customers and market

- Customer concentration by state and city
- Monthly new-customer growth
- Highest-volume customer locations

### Sales and products

- Highest- and lowest-selling product categories
- Average order value by customer and order
- Products with the highest estimated net sales
- Top-10 category sales concentration

### Sellers

- Sellers with the highest order volume
- Top-10 seller market concentration
- Seller delivery-time performance

### Logistics and delivery

- Average delivery time by state and category
- On-time delivery percentage
- States and cities with the highest late-delivery rate

### Payments and billing

- Most-used payment methods
- Average transaction value by payment method
- Installment versus single-payment orders

### Customer satisfaction

- Average review score by customer state
- Product categories with negative reviews
- Relationship between delivery time and review score

## 4. Dataset

- **Source:** [Brazilian E-Commerce Public Dataset by Olist - Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Period:** September 2016 - October 2018
- **Records:** 99,441 orders and 112,650 items
- **Tables:** orders, customers, order_items, order_payments, order_reviews, products, sellers, geolocation, and product_category_name_translation

## 5. Repository Structure

```text
Ecommerce-Analytics/
|
|- 01_Brz_Ecommerce_Database_Setup.sql
|- 02_Brz_Ecommerce_Data_Model_Views.sql
|- 03_Brz_Ecommerce_Business_Analysis.sql
|- Ecommerce_Documentation.pdf
|- README.md
|- SQL_README.md
|- REQUIREMENTS.md
|- screenshots/
|  |- Sales.png
|  |- Sales_2.png
|  |- Performance.png
|  |- Performance_2.png
|  |- Sales_History.png
|  |- Product_Category_Table.png
|  `- Products_Table.png
```

## 6. Related Documentation

- [Power BI README](./README.md)
- [Project Requirements](./REQUIREMENTS.md)
- [Project Documentation](./Ecommerce_Documentation.pdf)
