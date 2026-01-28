# **Hands-on Data Modeling - Designing for Transactions (OLTP) (3.5 hours)**

_I used Miro for the diagrams._

### **Conceptual Modeling Practice**
Draw a conceptual ERD.

![Image](https://github.com/user-attachments/assets/c5254a66-7959-45c7-ad39-1b78261ad681)

### **Logical Modeling & Normalization from Scratch**
1. Start with a de-normalized idea (e.g., a simple transaction log where customer and product details are repeated for every purchase).

| trans_id | order_id | order_date | order_status | order_total | customer_id | customer_name |      customer_email     | customer_city | customer_country | customer_reg_date | product_id |  product_name  | product_category | product_price | product_weight | quantity | unit_price | payment_id | payment_method | payment_amount | payment_date |
|:--------:|:--------:|:----------:|:------------:|:-----------:|:-----------:|:-------------:|:-----------------------:|:-------------:|:----------------:|:-----------------:|:----------:|:--------------:|:----------------:|:-------------:|:--------------:|:--------:|:----------:|:----------:|:--------------:|:--------------:|:------------:|
|     1    |  ORD001  | 2023-03-01 |   Delivered  |     1305    |   CUST001   |  Alice Smith  | alice.smith@example.com |    New York   |        USA       |     2023-01-05    |   PROD001  |  Laptop Pro X  |    Electronics   |      1200     |       1.8      |     1    |    1200    |   PAY001   |   Credit Card  |      1305      |  2023-03-01  |
|     2    |  ORD001  | 2023-03-01 |   Delivered  |     1305    |   CUST001   |  Alice Smith  | alice.smith@example.com |    New York   |        USA       |     2023-01-05    |   PROD002  |      Mouse     |    Electronics   |       25      |       0.1      |     1    |     25     |   PAY001   |   Credit Card  |      1305      |  2023-03-01  |
|     3    |  ORD001  | 2023-03-01 |   Delivered  |     1305    |   CUST001   |  Alice Smith  | alice.smith@example.com |    New York   |        USA       |     2023-01-05    |   PROD003  |    Keyboard    |    Electronics   |       80      |       0.9      |     1    |     80     |   PAY001   |   Credit Card  |      1305      |  2023-03-01  |
|     4    |  ORD002  | 2023-03-02 |   Delivered  |      60     |   CUST002   |  Bob Johnson  |    bob.j@example.com    |  Los Angeles  |        USA       |     2023-01-10    |   PROD004  | T-Shirt Cotton |      Apparel     |       20      |       0.2      |     3    |     20     |   PAY002   |     PayPal     |       60       |  2023-03-02  |

REDUNDANCY
- Alice's info (name, email, city, country) is repeated 3 times because she bought 3 items in one order
- The order details (order_id, order_date, order_total) are repeated 3 times
- Payment info is repeated 3 times
- Product info (name, category, price, weight) is repeated every time that product is sold

UPDATE ISSUES
- If Alice changes her email, you have to update it in every row where she appears
- If a product price changes, you have to update it everywhere

INSERT ISSUES:
- Can't add a new product unless someone buys it
- Can't add a new customer unless they place an order

DELETE ISSUES:
- If you delete the last order for a customer, you lose all their information
- If you delete the last order containing a product, you lose that product's details


2. Guide them step-by-step to normalize it to 3NF, creating separate tables for Customers, Products, Orders, Order_Items, Payments.

**- 1NF: Goal is to make sure every column contains only one value and each row is unique.**
| trans_id (PK) | order_id | order_date | order_status | order_total | customer_id | customer_name |      customer_email     | customer_city | customer_country | customer_reg_date | product_id |     product_name    | product_category | product_price | product_weight | quantity | unit_price | payment_id | payment_method | payment_amount | payment_date |
|:-------------:|:--------:|:----------:|:------------:|:-----------:|:-----------:|:-------------:|:-----------------------:|:-------------:|:----------------:|:-----------------:|:----------:|:-------------------:|:----------------:|:-------------:|:--------------:|:--------:|:----------:|:----------:|:--------------:|:--------------:|:------------:|
|       1       |  ORD001  | 2023-03-01 |   Delivered  |     1305    |   CUST001   |  Alice Smith  | alice.smith@example.com |    New York   |        USA       |     2023-01-05    |   PROD001  |     Laptop Pro X    |    Electronics   |      1200     |       1.8      |     1    |    1200    |   PAY001   |   Credit Card  |      1305      |  2023-03-01  |
|       2       |  ORD001  | 2023-03-01 |   Delivered  |     1305    |   CUST001   |  Alice Smith  | alice.smith@example.com |    New York   |        USA       |     2023-01-05    |   PROD002  |    Wireless Mouse   |    Electronics   |       25      |       0.1      |     1    |     25     |   PAY001   |   Credit Card  |      1305      |  2023-03-01  |
|       3       |  ORD001  | 2023-03-01 |   Delivered  |     1305    |   CUST001   |  Alice Smith  | alice.smith@example.com |    New York   |        USA       |     2023-01-05    |   PROD003  | Mechanical Keyboard |    Electronics   |       80      |       0.9      |     1    |     80     |   PAY001   |   Credit Card  |      1305      |  2023-03-01  |
|       4       |  ORD002  | 2023-03-02 |   Delivered  |      60     |   CUST002   |  Bob Johnson  |    bob.j@example.com    |  Los Angeles  |        USA       |     2023-01-10    |   PROD004  |    T-Shirt Cotton   |      Apparel     |       20      |       0.2      |     3    |     20     |   PAY002   |     PayPal     |       60       |  2023-03-02  |

ISSUES:
- Lots of repeated data
- Customer info repeated in every transaction
- Product info repeated in every transaction
- Order info repeated for each item in that order

**- 2NF: If there's information that depends on only part of the primary key, move it to its own table**

Split based on what each attribute depends on:

**Dependency 1: Attributes depending on trans_id**
- order_id, product_id, quantity, unit_price depend on the specific transaction line

| order_item_id (PK) | order_id (FK) | product_id (FK) | quantity | unit_price |
|:------------------:|:-------------:|:---------------:|:--------:|:----------:|
|       ITEM001      |     ORD001    |     PROD001     |     1    |    1200    |
|       ITEM002      |     ORD001    |     PROD002     |     1    |     25     |
|       ITEM003      |     ORD001    |     PROD003     |     1    |     80     |
|       ITEM004      |     ORD002    |     PROD004     |     3    |     20     |

**Dependency 2: Attributes depending on order_id**
- order_date, order_status, order_total, customer_id depend on the order

| order_id (PK) | customer_id (FK) | order_date | order_status | order_total |
|:-------------:|:----------------:|:----------:|:------------:|:-----------:|
|     ORD001    |      CUST001     | 2023-03-01 |   Delivered  |     1305    |
|     ORD002    |      CUST002     | 2023-03-02 |   Delivered  |      60     |

**Dependency 3: Attributes depending on customer_id**
- customer_name, customer_email, customer_city, customer_country, customer_reg_date depend on the customer

| customer_id (PK) | customer_name |      customer_email     | customer_city | customer_country | customer_reg_date |
|:----------------:|:-------------:|:-----------------------:|:-------------:|:----------------:|:-----------------:|
|      CUST001     |  Alice Smith  | alice.smith@example.com |    New York   |        USA       |     2023-01-05    |
|      CUST002     |  Bob Johnson  |    bob.j@example.com    |  Los Angeles  |        USA       |     2023-01-10    |

**Dependency 4: Attributes depending on product_id**
- product_name, product_category, product_price, product_weight depend on the product

| product_id (PK) |     product_name    | product_category | product_price | product_weight |
|:---------------:|:-------------------:|:----------------:|:-------------:|:--------------:|
|     PROD001     |     Laptop Pro X    |    Electronics   |      1200     |       1.8      |
|     PROD002     |    Wireless Mouse   |    Electronics   |       25      |       0.1      |
|     PROD003     | Mechanical Keyboard |    Electronics   |       80      |       0.9      |
|     PROD004     |    T-Shirt Cotton   |      Apparel     |       20      |       0.2      |

**Dependency 5: Attributes depending on payment_id**
- order_id, payment_method, payment_amount, payment_date depend on the payment

| payment_id (PK) | order_id (FK) | payment_method | payment_amount | payment_date |
|:---------------:|:-------------:|:--------------:|:--------------:|:------------:|
|      PAY001     |     ORD001    |   Credit Card  |      1305      |  2023-03-01  |
|      PAY002     |     ORD002    |     PayPal     |       60       |  2023-03-02  |

IMPROVEMENTS:
- Customer info stored once per customer
- Product info stored once per product  
- Order info stored once per order
- Much less redundancy


**- 3NF: Remove transitive dependencies - every non-key attribute must depend directly on the primary key, not on another non-key attribute**

Checked each 2NF table:
- order_items: quantity and unit_price depend directly on order_item_id ✓
- orders: all attributes depend directly on order_id ✓
- customers: all attributes depend directly on customer_id ✓ (city and country both describe customer location, not deriving one from the other)
- products: all attributes depend directly on product_id ✓
- payments: all attributes depend directly on payment_id ✓

**2NF tables already meet 3NF - no transitive dependencies found**

### **ERD Creation for Normalized Schema**
1. Use the ERD tool to draw the logical ERD for the normalized E-commerce schema they just created.

OLTP
![Image](https://github.com/user-attachments/assets/2f45273e-fbe8-4e36-b23b-72cc89b574d5)

3. Discuss how this new schema addresses redundancy and data integrity.
REDUNDANCY FIXED:
- Each customer's details stored once in customers table
- Each product's details stored once in products table
- Each order's details stored once in orders table
- Each payment's details stored once in payments table

UPDATE ISSUES FIXED:
- Change customer email once in customers table - automatically reflects everywhere
- Update product price once in products table - all references updated
- Modify order status once in orders table - consistent across system

INSERT ISSUES FIXED:
- Can add new products to products table before anyone orders them
- Can add new customers to customers table before they place orders
- Can add payment methods without requiring existing orders

DELETE ISSUES FIXED:
- Delete an order without losing customer information (customer still exists in customers table)
- Delete last order for a product without losing product details (product still exists in products table)
- Delete payment without affecting order or customer data

DATA INTEGRITY:
- Foreign keys ensure referential integrity
- Can't create order for non-existent customer (customer_id FK constraint)
- Can't add order_item for non-existent product (product_id FK constraint)
- Can't add payment for non-existent order (order_id FK constraint)
- Invalid relationships are prevented at database level

RELATIONSHIPS DEFINED:
- customers → orders (one-to-many): One customer can have multiple orders
- orders → order_items (one-to-many): One order can contain multiple items
- products → order_items (one-to-many): One product can appear in multiple order items
- orders → payments (one-to-many): One order can have multiple payments

submitted by: @kristhiacayle
submitted to: @jgvillanuevastratpoint
submission date: 01/22/26
