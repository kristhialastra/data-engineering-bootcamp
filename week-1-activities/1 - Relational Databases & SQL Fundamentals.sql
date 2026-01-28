-- Create Customers and Products tables using the suggested dataset columns. Define Primary Keys.

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL,
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    weight DECIMAL(8, 2)
);

-- INSERT 10-15 rows of sample data into each table from the customers.csv and products.csv dataset components.

SELECT 'customers' as table_name, COUNT(*) as row_count FROM customers
UNION ALL
SELECT 'products' as table_name, COUNT(*) as row_count FROM products;

-- Practice basic data retrieval (SELECT *, SELECT specific_columns, SELECT DISTINCT, WHERE conditions (AND, OR, LIKE, IN), ORDER BY, LIMIT).

SELECT DISTINCT country, city, name, email, registration_date
FROM customers
WHERE (country IN ('USA', 'UK', 'Japan') OR city LIKE '%New%')
  AND registration_date > '2023-01-10'
ORDER BY registration_date DESC
LIMIT 5;


-- Problem: Retrieve all products in the 'Electronics' category. Find all customers registered after a specific date.

SELECT product_name, category
FROM products
WHERE category = 'Electronics'

SELECT * FROM customers
WHERE registration_date > '2023-01-15'
