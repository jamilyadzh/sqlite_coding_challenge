-- challenge.sql
-- I wrote these queries for SQLite (tested conceptually against standard SQLite syntax).
-- Validation steps you should run locally:
--  1) Open the provided bais_sqlite_lab.db in a SQLite client (VS Code + SQLTools, DB Browser for SQLite, or sqlite3 CLI).
--  2) Run each TASK block in order and inspect row counts / sample rows.
--  3) For numeric sanity checks, sum(order_items.quantity * order_items.unit_price) across all orders and compare to the sum of category revenues.



SELECT
  c.id AS customer_id,
  (c.first_name || ' ' || c.last_name) AS customer_full_name,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spend
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY c.id, customer_full_name
ORDER BY total_spend DESC
LIMIT 5;


-- TASK 2 — Total Revenue by Product Category (all orders)

SELECT
  p.category AS category,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN products p ON p.id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;


-- TASK 2b — Total Revenue by Product Category (Delivered orders only)

SELECT
  p.category AS category,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue_delivered
FROM order_items oi
JOIN products p ON p.id = oi.product_id
JOIN orders o ON o.id = oi.order_id
WHERE LOWER(o.status) = 'delivered'
GROUP BY p.category
ORDER BY revenue_delivered DESC;


-- TASK 3 — Employees Earning Above Their Department Average

SELECT
  e.first_name,
  e.last_name,
  d.name AS department_name,
  e.salary AS employee_salary,
  ROUND(da.avg_salary, 2) AS department_average_salary
FROM employees e
JOIN departments d ON d.id = e.department_id
JOIN (
  SELECT
    department_id,
    AVG(salary) AS avg_salary
  FROM employees
  GROUP BY department_id
) da ON da.department_id = e.department_id
WHERE e.salary > da.avg_salary
ORDER BY d.name ASC, employee_salary DESC;


-- TASK 4 — Cities with the Most Loyal Customers (Gold)

SELECT
  city,
  COUNT(*) AS gold_customer_count
FROM customers
WHERE LOWER(loyalty_level) = 'gold'
GROUP BY city
ORDER BY gold_customer_count DESC, city ASC;


-- TASK 4b — Loyalty distribution by city

SELECT
  city,
  SUM(CASE WHEN LOWER(loyalty_level) = 'gold' THEN 1 ELSE 0 END) AS gold_count,
  SUM(CASE WHEN LOWER(loyalty_level) = 'silver' THEN 1 ELSE 0 END) AS silver_count,
  SUM(CASE WHEN LOWER(loyalty_level) = 'bronze' THEN 1 ELSE 0 END) AS bronze_count,
  COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY gold_count DESC, city ASC;
