# Brz Ecommerce Analytics

## 1. Project Overview

This project designs a SQL Server database and analytical layer for the Brazilian E-Commerce Public Dataset by Olist. It supports business analysis of orders, customers, sellers, products, payments, reviews, delivery performance, and geographic activity.

## 2. Software Requirements

- Microsoft SQL Server 2017 or later
- SQL Server Management Studio (SSMS)
- Power BI Desktop or Power BI Service for dashboard visualization
- Windows operating system

## 3. Data Requirements

Download the Brazilian E-Commerce Public Dataset by Olist from Kaggle:

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The following source tables are required:

- `orders`
- `customers`
- `order_items`
- `order_payments`
- `order_reviews`
- `products`
- `sellers`
- `geolocation`
- `product_category_name_translation`

The imported SQL Server table names must match the names used by the scripts. In particular, the current scripts use `customer` and `order_item`.

## 4. Database Requirements

The database must be named `Brz_Ecomerce` unless the SQL scripts are updated consistently.

The database must support:

- Primary keys for core entities
- Foreign keys for referential integrity
- Geolocation ZIP-code normalization
- Nonclustered indexes for common filters, joins, and aggregations
- Analytical views for reusable business logic

## 5. Execution Requirements

Run the SQL scripts in this order:

1. `01_Brz_Ecommerce_Database_Setup.sql`
2. Import the CSV files into SQL Server
3. Complete the remaining setup and validation queries in `01_Brz_Ecommerce_Database_Setup.sql`
4. `02_Brz_Ecommerce_Data_Model_Views.sql`
5. `03_Brz_Ecommerce_Business_Analysis.sql`

The setup script must not be rerun after data import if it would drop and recreate the database.

## 6. Functional Requirements

The solution must:

- Create and configure the ecommerce database.
- Load and organize the source ecommerce data.
- Enforce primary-key and foreign-key relationships.
- Normalize repeated geolocation ZIP-code values.
- Create analytical views for orders, customers, sellers, products, payments, and geographic zones.
- Calculate customer acquisition and geographic concentration.
- Analyze sales, products, categories, and average order value.
- Rank sellers and measure market concentration.
- Measure delivery times and late-delivery rates.
- Analyze payment methods and transaction values.
- Evaluate customer review scores and their relationship to delivery times.
- Validate row counts and referential integrity.

## 7. Analytical Outputs

The project must produce results that support:

- Top states and cities by customer or order volume
- Monthly new-customer growth
- Top and lowest-selling product categories
- Average order value by customer and order
- Top products by estimated sales value
- Top-10 category sales concentration
- Seller order rankings and market share
- Average delivery performance by seller, state, and category
- On-time delivery percentage
- Payment method usage and average transaction value
- Installment versus single-payment analysis
- Average review scores by customer state
- Relationship between delivery time and customer satisfaction

## 8. Documentation Requirements

The repository must include:

- SQL source scripts
- A project README
- SQL analysis documentation
- A project report
- English filenames and user-facing descriptions
- Dashboard screenshots linked from the README

## 9. Performance and Quality Requirements

- Queries should use the analytical views where appropriate.
- Primary keys, foreign keys, and indexes should support reliable joins and filtering.
- Aggregations should avoid duplicate payment, item, or review values.
- Validation queries should be run after database setup.
- Results should be reproducible using the same dataset and execution order.
