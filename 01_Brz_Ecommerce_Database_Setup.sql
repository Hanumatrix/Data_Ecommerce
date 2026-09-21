/*======================================================
Script name: Brz Ecommerce project
Start date: 2024-06-10
Platform: SQL Server
Script scope:
    - Create the Brz_Ecomerce database
    - Tables
    - Views
    - Stored procedures
Objectives:
    - Create KPIs
    - Store the main ecommerce data
    - Support dashboards
Author: Tushar Rana
Dataset source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
======================================================*/

--======================================================
-- 1.1 Create Database (SETUP)
--======================================================

--======================================================
-- 1.1 Create Database
--======================================================
IF DB_ID('Brz_Ecomerce') IS NOT NULL
    DROP DATABASE Brz_Ecomerce;

CREATE DATABASE Brz_Ecomerce;

USE Brz_Ecomerce;

--======================================================
-- 1.2. Load Data (using the SSMS import wizard)
--======================================================
/*
Data is loaded using the SSMS import wizard:
- Right-click the Brz_Ecomerce database
- Select Tasks -> Import Data
- Follow the steps to import the CSV files into the tables
Note: the CSV files intentionally contain data type errors
that are corrected later in this script
*/

--======================================================
-- 1.3. Primary and Foreign Keys
--======================================================

-- Orders
ALTER TABLE orders
ADD CONSTRAINT PK_orders_Order_Id PRIMARY KEY (order_id);

-- Customers
ALTER TABLE customer
ADD CONSTRAINT PK_customer_Customer_Id PRIMARY KEY (customer_id);

-- FK Orders → Customers
ALTER TABLE orders
ADD CONSTRAINT FK_orders_Customer_Id FOREIGN KEY (customer_id) REFERENCES customer(customer_id);

-- Correct customer_id data type incompatibility
ALTER TABLE [dbo].[customer] DROP CONSTRAINT [PK_customer_Customer_Id] WITH (ONLINE = OFF);
GO
ALTER TABLE customer ALTER COLUMN customer_id NVARCHAR(100) NOT NULL;
GO
ALTER TABLE customer ADD CONSTRAINT PK_customer_Customer_Id PRIMARY KEY (customer_id);
ALTER TABLE orders ADD CONSTRAINT FK_orders_Customer_Id FOREIGN KEY (customer_id) REFERENCES customer(customer_id);

-- Order Payments
ALTER TABLE order_payments
ADD CONSTRAINT FK_order_payments_Order_Id FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Products
ALTER TABLE products
ADD CONSTRAINT PK_products_Product_Id PRIMARY KEY (product_id);

-- Order Items → Products
ALTER TABLE order_item
ADD CONSTRAINT FK_order_items_Product_Id FOREIGN KEY (product_id) REFERENCES products(product_id);

-- Sellers
ALTER TABLE sellers
ADD CONSTRAINT PK_sellers_Seller_Id PRIMARY KEY (seller_id);

-- Order Items → Sellers
ALTER TABLE order_item
ADD CONSTRAINT FK_order_item_Seller_Id FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);

-- Order Items → Orders
ALTER TABLE order_item
ADD CONSTRAINT FK_Order_Item_Order_Id FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Correct Order Reviews data type incompatibility and add the Orders FK
ALTER TABLE order_reviews
ALTER COLUMN order_id NVARCHAR(100) NOT NULL;
GO
ALTER TABLE order_reviews
ADD CONSTRAINT FK_order_reviews_Order_Id FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Product Category Translation
ALTER TABLE product_category_name_translation
ADD CONSTRAINT PK_product_category_name_translation_Product_Category_Name PRIMARY KEY (product_category_name);

ALTER TABLE products
ADD CONSTRAINT FK_products_Product_Category_Name FOREIGN KEY (product_category_name) REFERENCES product_category_name_translation(product_category_name);

--======================================================
-- 1.4. Geolocation Normalization
--======================================================
CREATE TABLE Geolocation_ZipCode(
    geolocation_zip_code_prefix NVARCHAR(100) PRIMARY KEY
);

INSERT INTO Geolocation_ZipCode(geolocation_zip_code_prefix)
SELECT DISTINCT geolocation_zip_code_prefix
FROM geolocation;

-- FK Customer → Geolocation
ALTER TABLE customer
ADD CONSTRAINT FK_Customer_ZipCode FOREIGN KEY (customer_zip_code_prefix) REFERENCES Geolocation_ZipCode(geolocation_zip_code_prefix);

-- FK Sellers → Geolocation
ALTER TABLE sellers
ADD CONSTRAINT FK_Sellers_ZipCode FOREIGN KEY (seller_zip_code_prefix) REFERENCES Geolocation_ZipCode(geolocation_zip_code_prefix);

-- FK Geolocation → Geolocation_ZipCode
ALTER TABLE geolocation
ADD CONSTRAINT FK_Geolocation_Zipcode FOREIGN KEY (geolocation_zip_code_prefix) REFERENCES Geolocation_ZipCode(geolocation_zip_code_prefix);

--======================================================
-- 1.5. Indexes
--======================================================

-- Customer
CREATE NONCLUSTERED INDEX IX_Customer_State ON customer(customer_state);
GO
CREATE NONCLUSTERED INDEX IX_Customer_City ON customer(customer_city);
GO

-- Orders
CREATE NONCLUSTERED INDEX IX_Orders_Purchase_Timestamp ON orders(order_purchase_timestamp);
GO
CREATE NONCLUSTERED INDEX IX_Orders_Order_Status ON orders(order_status);
GO

-- Order Items
CREATE NONCLUSTERED INDEX IX_Order_Item_Product_Id ON order_item(product_id);
GO
CREATE NONCLUSTERED INDEX IX_Order_Item_Seller_Id ON order_item(seller_id);
GO
CREATE NONCLUSTERED INDEX IX_Order_Item_Order_Id ON order_item(order_id);
GO

-- Order Payments
CREATE NONCLUSTERED INDEX IX_Order_Payments_Payment_Type ON order_payments(payment_type);
GO

-- Order Reviews
CREATE NONCLUSTERED INDEX IX_Order_Reviews_Review_Score ON order_reviews(review_score);
GO
CREATE NONCLUSTERED INDEX IX_Order_Reviews_Order_Id ON order_reviews(order_id);
GO
CREATE NONCLUSTERED INDEX IX_Order_Reviews_ReviewID ON order_reviews(review_id);
GO

-- Products
CREATE NONCLUSTERED INDEX IX_Products_Product_Category_Name ON products(product_category_name);
GO

-- Product Category Translation
CREATE NONCLUSTERED INDEX IX_Product_Category_Name_Translation_Product_Category_Name_English ON product_category_name_translation(product_category_name_english);
GO

-- Sellers
CREATE NONCLUSTERED INDEX IX_Sellers_Seller_State ON sellers(seller_state);
GO
CREATE NONCLUSTERED INDEX IX_Sellers_Seller_City ON sellers(seller_city);
GO

-- Composite index on order_item to speed up joins and unique item counts
CREATE NONCLUSTERED INDEX IX_OrderItem_Product_OrderItem
ON order_item(product_id, order_id, order_item_id);

-- Composite index on customer to improve city/state grouping and rankings
CREATE NONCLUSTERED INDEX IX_Customer_City_State
ON customer(customer_city, customer_state);

-- Composite index on sellers for seller geography analysis
CREATE NONCLUSTERED INDEX IX_Sellers_City_State
ON sellers(seller_city, seller_state);

-- Composite index on orders to speed up customer and status joins and filters
CREATE NONCLUSTERED INDEX IX_Orders_Customer_Status
ON orders(customer_id, order_status);

-- Composite index on order_payments for payment type and value analysis
CREATE NONCLUSTERED INDEX IX_OrderPayments_Type_Value
ON order_payments(payment_type, payment_value);

-- Composite index on order_reviews to relate scores to orders
CREATE NONCLUSTERED INDEX IX_OrderReviews_Order_Score
ON order_reviews(order_id, review_score);

--======================================================
-- 1.6. Validation Queries
--=====================================================

-- Should return the total number of orders
SELECT COUNT(*) FROM orders;

-- Should show the top 10 customers
SELECT top 10 * FROM customer;

-- Should show the unique order statuses
SELECT DISTINCT order_status FROM Orders;

-- Should return zero rows when integrity is valid
SELECT * FROM orders WHERE customer_id NOT IN(SELECT customer_id FROM customer);

--======================================================
-- End of Script
--======================================================