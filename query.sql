SELECT c.customer_name, 
       p.product_name,
       MAX(o.total_quantity) AS max_quantity_ordered
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY c.customer_name, p.product_name
HAVING MAX(o.total_quantity) = (
    SELECT MAX(total_quantity)
    FROM (
        SELECT c.customer_name, 
               p.product_name,
               SUM(od.quantity) AS total_quantity
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        JOIN order_details od ON o.order_id = od.order_id
        JOIN products p ON od.product_id = p.product_id
        GROUP BY c.customer_name, p.product_name
    ) AS temp
);


SELECT YEAR(order_date) AS year,
       MONTH(order_date) AS month,
       SUM(order_amount) AS total_sales
FROM sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

SELECT product_name, 
       SUM(inventory_quantity) AS total_inventory
FROM products
WHERE product_id = `D10302`; 


SELECT customer_name, 
       category_name,
       MAX(order_quantity) AS max_quantity_ordered
FROM (
    SELECT c.customer_name, 
           p.category_name,
           SUM(od.quantity) AS order_quantity
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY c.customer_name, p.category_name
) AS temp
GROUP BY customer_name;


WITH MonthlySales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(order_amount) AS monthly_revenue
    FROM 
        sales
    GROUP BY 
        DATE_FORMAT(order_date, '%Y-%m')
),
LaggedSales AS (
    SELECT
        month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY month) AS lagged_monthly_revenue
    FROM
        MonthlySales
)
SELECT
    ms.month,
    ms.monthly_revenue,
    ls.lagged_monthly_revenue,
    (ms.monthly_revenue - ls.lagged_monthly_revenue) / ls.lagged_monthly_revenue AS growth_rate
FROM
    MonthlySales ms
LEFT JOIN
    LaggedSales ls
ON
    ms.month = ls.month;

SELECT product_name,
       SUM(quantity_sold) AS total_quantity_sold
FROM products
JOIN sales ON products.product_id = sales.product_id
GROUP BY product_name
ORDER BY total_quantity_sold DESC
LIMIT 1;


SELECT customer_name,
       MAX(order_date) AS latest_order_date
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customer_name;


SELECT category_name,
       AVG(unit_price) AS average_price
FROM products
JOIN categories ON products.category_id = categories.category_id
GROUP BY category_name;


SELECT c.customer_name,
       DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       COUNT(*) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY c.customer_name, month
ORDER BY c.customer_name, month;


SELECT c.category_name,
       COUNT(p.product_id) AS product_count,
       SUM(s.quantity_sold) AS total_quantity_sold
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY c.category_name;


SELECT o.order_id,
       p.product_name,
       od.quantity,
       od.unit_price
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE o.order_date = (SELECT MAX(order_date) FROM orders);


SELECT r_post_id,
       r_post_title,
       COUNT(*) AS review
FROM review
GROUP BY r_post_id, r_post_title
ORDER BY review DESC
LIMIT 10;
