# **Hands-on Dimensional Modeling - Building a Star Schema (3.5 hours)**

## **Applying Kimball's 4-step process**

### 1. Select the organizational process

- E-commerce Sales

### 2. Declare the grain

- One row per line item in each order _(This means if 1 order has 3 products, we get 3 rows in Sales_Fact. This is the most detailed level we can analyze.)_

### 3. Identify the dimensions
These are the "who, what, when, how" that describe our sales. The instructions used "e.g." not "i.e." when listing dimension examples (Dim_Customer, Dim_Product, Dim_Date), so I've added Dim_Payments because the payments table in the normalized schema has enough distinct attributes (payment_id, payment_method, payment_amount, payment_date) to justify being its own dimension rather than just columns in the fact table.

**Dim_Customer** - who bought?

|       Column      |   Type  |   
|:-----------------:|:-------:|
| customer_id (PK)  | VARCHAR | 
| customer_name     | VARCHAR |  
| email             | VARCHAR |  
| registration_date | DATE    |  
| city              | VARCHAR |   
| country           | VARCHAR |  

**Dim_Product** - what was bought?

|      Column     |   Type  |
|:---------------:|:-------:|
| product_id (PK) | VARCHAR |
| product_name    | VARCHAR |
| category        | VARCHAR |
| price           | DECIMAL |
| weight          | DECIMAL |

**Dim_Date** - when was it bought?

|      Column     |   Type  |
|:---------------:|:-------:|
| order_date (PK) | DATE    |
| year            | INT     |
| quarter         | INT     |
| month           | INT     |
| day_num         | INT     |
| day_name        | VARCHAR |

This dimension is created from order_date column in orders table to make time-based analysis easier.

**Dim_Payments** - how was it paid?

|      Column     |   Type  |
|:---------------:|:-------:|
| payment_id (PK) | VARCHAR |
| payment_method  | VARCHAR |
| payment_amount  | DECIMAL |
| payment_date    | DATE    |

This dimension captures payment details. One payment can cover multiple items if an order has multiple products.

### 4. Identify the facts
These are the numerical measures we analyze.

**Sales_Fact** - the main fact table

|       Column       |   Type  |          Description         |
|:------------------:|:-------:|:----------------------------:|
| order_item_id (PK) | VARCHAR | From order_items table       |
| order_id           | VARCHAR | Reference to order           |
| customer_id (FK)   | VARCHAR | Links to Dim_Customer        |
| product_id (FK)    | VARCHAR | Links to Dim_Product         |
| order_date (FK)    | DATE    | Links to Dim_Date            |
| payment_id (FK)    | VARCHAR | Links to Dim_Payments        |
| payment_method     | VARCHAR | Payment type used            |
| quantity           | INT     | MEASURE - units sold         |
| unit_price         | DECIMAL | MEASURE - price per unit     |
| order_total_amount | DECIMAL | MEASURE - total order amount |
| status             | VARCHAR | Context - order status       |

The measures (quantity, unit_price, order_total_amount) are facts because we can do aggregations or calculations like SUM, COUNT, AVG them to answer business questions for reporting (as the goal of a data warehouse/mart is.)

## **Designing a Star Schema**

![Image](https://github.com/user-attachments/assets/9c3665c0-6310-4592-98c6-de050693b294)

**Relationships**
- Dim_Customer → Sales_Fact: One customer can make zero or many purchases (customers can exist without purchases)
- Dim_Product → Sales_Fact: One product can appear in zero or many sales (products can exist in catalog without being sold)
- Dim_Date → Sales_Fact: One date can have zero or many sales transactions (dates can have no sales)
- Dim_Payments → Sales_Fact: One payment must cover one or many line items (payment requires at least one line item)

submitted by: @kristhiacayle
submitted to: @jgvillanuevastratpoint
submission date: 01/26/26

## Resubmission - Star Schema Corrections

**What I realized:**

I initially created Dim_Payments kasi I thought since payments table has its own attributes, it should be its own dimension. Same with order_total_amount, I included it kasi I thought we need it for reporting.

But then I realized payment info lives at the ORDER level while my fact table is at ORDER_ITEM level pala. So if 1 order has 3 products, all 3 rows would point to the same payment_id. When you aggregate, you'd count that payment 3 times. Same problem with order_total_amount - you'd be summing $150 three times instead of once. Mali pala.

**What I changed:**

- Removed Dim_Payments entirely
- Kept payment_method as a regular column in Sales_Fact (degenerate dimension lang siya)
- Removed order_total_amount - calculate this by summing (quantity × unit_price) grouped by order_id nalang

![Image](https://github.com/user-attachments/assets/3e7ff19e-72fa-4e62-9dae-5bfb175ea1dd)

resubmission date: 01/27/26 @jgvillanuevastratpoint  
