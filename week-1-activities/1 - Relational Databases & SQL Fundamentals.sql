-- Enforce relationships by adding Foreign Keys to link Orders to Customers, Order_Items to Orders and Products using the suggested dataset.

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (product_id) REFERENCES products(product_id);

-- Join data: Retrieve order details along with customer names.

SELECT 
    orders.order_id,
    customers.name,
    orders.order_date,
    orders.total_amount,
    orders.status
FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id;

-- Join data: Find products that have never been ordered (using LEFT JOIN).

SELECT 
    products.product_id,
    products.product_name,
    products.category
FROM products
LEFT JOIN order_items ON products.product_id = order_items.product_id
WHERE order_items.order_item_id IS NULL;


-- Aggregation queries: Count total orders per customer.

select count(distinct order_id) as total_per_cust, customers.name
from orders right join customers on orders.customer_id = customers.customer_id 
group by customers.name
order by total_per_cust desc, customers.name

-- Aggregation queries: Calculate total revenue per product category.

select sum(orders.total_amount) as rev_per_prod_cat, products.category
from orders
join order_items on orders.order_id = order_items.order_id
join products on order_items.product_id = products.product_id
group by products.category
order by rev_per_prod_cat desc;

-- Aggregation queries: Find top 5 customers by total spending.

select sum(orders.total_amount) as total_spending, customers.name
from customers join orders on customers.customer.id = orders.customer.id
group by customers.name
order by total_spending desc
limit 5;

-- Mini-Project: Online Sales Data: Create tables and define appropriate relationships (Primary and Foreign Keys) for the full online store schema.

-- Task: Answer business questions using JOINs and aggregations: "Who are our top 10 customers by total order value?"

SELECT 
    customers.name,
    COUNT(DISTINCT orders.order_id) AS total_no_orders,
    COUNT(order_items.order_item_id) AS total_ordered_items,
    SUM(order_items.quantity * order_items.unit_price) AS totalorderval_from_unitprice
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
LEFT JOIN order_items ON orders.order_id = order_items.order_id
GROUP BY customers.customer_id, customers.name
ORDER BY total_ordered_items  DESC
LIMIT 10;

-- Task: Answer business questions using JOINs and aggregations: "Which product categories generate the most revenue?"

select products.category, sum(order_items.quantity * order_items.unit_price) as total_rev
from products join order_items on products.product_id = order_items.product_id
join orders on order_items.order_id = orders.order_id 
group by products.category
order by total_rev desc

-- Task: Answer business questions using JOINs and aggregations: "What's the average order size per customer?" - Assuming size refers to number of items ordered

SELECT 
    customers.customer_id,
    customers.name,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    COUNT(order_items.order_item_id) AS total_items,
    COUNT(order_items.order_item_id) / COUNT(DISTINCT orders.order_id) AS average_order_size
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
INNER JOIN order_items ON orders.order_id = order_items.order_id
GROUP BY customers.customer_id, customers.name
ORDER BY average_order_size DESC;

