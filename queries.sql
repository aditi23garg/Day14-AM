-- ============================================================
--   SQL ASSIGNMENT - Complete Queries File
-- ============================================================

-- ============================================================
-- SETUP: Create Tables & Insert Data
-- ============================================================

CREATE TABLE departments (
    dept_id   SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget    NUMERIC
);

CREATE TABLE employees (
    emp_id    SERIAL PRIMARY KEY,
    name      VARCHAR(50),
    salary    NUMERIC,
    dept_id   INT REFERENCES departments(dept_id),
    hire_date DATE
);

CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(50),
    lead_emp_id  INT REFERENCES employees(emp_id),
    budget       NUMERIC,
    start_date   DATE,
    end_date     DATE
);

-- Insert departments
INSERT INTO departments (dept_id, dept_name, budget) VALUES
(1, 'Engineering', 500000),
(2, 'HR',          200000),
(3, 'Sales',       300000),
(4, 'Marketing',   250000);

-- Insert employees
INSERT INTO employees (emp_id, name, salary, dept_id, hire_date) VALUES
(1,  'Alice',  90000, 1, '2020-01-15'),
(2,  'Bob',    75000, 1, '2019-06-01'),
(3,  'Carol',  60000, 2, '2021-03-10'),
(4,  'David',  55000, 2, '2022-07-20'),
(5,  'Eve',    80000, 3, '2018-11-05'),
(6,  'Frank',  70000, 3, '2020-09-15'),
(7,  'Grace',  65000, 4, '2021-01-01'),
(8,  'Hank',   72000, 1, '2023-02-28'),
(9,  'Ivy',    58000, 4, '2022-05-14'),
(10, 'Jack',   95000, 1, '2017-08-19');

-- Insert projects
INSERT INTO projects (project_id, project_name, lead_emp_id, budget, start_date, end_date) VALUES
(1, 'Website Revamp',  1,  120000, '2024-01-01', '2024-06-30'),
(2, 'HR System',       3,   80000, '2024-02-01', '2024-08-31'),
(3, 'Sales Dashboard', 5,  150000, '2024-03-01', '2024-09-30'),
(4, 'Ad Campaign',     7,   90000, '2024-04-01', '2024-10-31'),
(5, 'Data Pipeline',   10, 200000, '2024-05-01', '2024-12-31');


-- ============================================================
-- PART A: 5 Basic SELECT / WHERE Queries
-- ============================================================

-- Q1: Get all employees
SELECT * FROM employees;

-- Q2: Employees with salary greater than 70000
SELECT * FROM employees
WHERE salary > 70000;

-- Q3: Employees in Engineering (dept_id = 1)
SELECT * FROM employees
WHERE dept_id = 1;

-- Q4: Employees hired after 2020
SELECT name, hire_date FROM employees
WHERE hire_date > '2020-01-01';

-- Q5: Employees with salary between 60000 and 80000
SELECT name, salary FROM employees
WHERE salary BETWEEN 60000 AND 80000;


-- ============================================================
-- PART A: 5 JOIN Queries
-- ============================================================

-- Q6: Employee name + department name
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- Q7: Employees earning > 70000 with their department
SELECT e.name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 70000;

-- Q8: All departments even if no employees (LEFT JOIN)
SELECT d.dept_name, e.name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- Q9: Employees hired before 2021 with department name
SELECT e.name, e.hire_date, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.hire_date < '2021-01-01';

-- Q10: Employee name + department name + department budget
SELECT e.name, d.dept_name, d.budget
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;


-- ============================================================
-- PART A: 5 Aggregation Queries
-- ============================================================

-- Q11: Average salary per department
SELECT dept_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id;

-- Q12: Count of employees per department
SELECT dept_id, COUNT(*) AS employee_count
FROM employees
GROUP BY dept_id;

-- Q13: Maximum salary per department
SELECT dept_id, MAX(salary) AS max_salary
FROM employees
GROUP BY dept_id;

-- Q14: Departments where average salary > 70000 (HAVING)
SELECT dept_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id
HAVING AVG(salary) > 70000;

-- Q15: Total salary expense per department
SELECT dept_id, SUM(salary) AS total_salary
FROM employees
GROUP BY dept_id;


-- ============================================================
-- PART A: 5 Advanced SQL Problems
-- ============================================================

-- A1: Running Total using Window Function
SELECT name, salary,
       SUM(salary) OVER (ORDER BY emp_id) AS running_total
FROM employees;

-- A2: Top 3 earners per department using RANK
SELECT * FROM (
    SELECT name, dept_id, salary,
           RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rnk
    FROM employees
) ranked
WHERE rnk <= 3;

-- A3: Month-over-Month growth using LAG
-- (Using a sample monthly_revenue table for demonstration)
-- CREATE TABLE monthly_revenue (month DATE, revenue NUMERIC);
-- INSERT INTO monthly_revenue VALUES ('2024-01-01',100000),('2024-02-01',120000),('2024-03-01',110000);
-- SELECT month, revenue,
--        LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
--        revenue - LAG(revenue) OVER (ORDER BY month) AS growth
-- FROM monthly_revenue;

-- A4: CTE to find employees earning above their department average
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) AS avg_sal
    FROM employees
    GROUP BY dept_id
)
SELECT e.name, e.salary, da.avg_sal AS dept_avg_salary
FROM employees e
JOIN dept_avg da ON e.dept_id = da.dept_id
WHERE e.salary > da.avg_sal;

-- A5: Correlated Subquery - employees earning above their dept average
SELECT name, salary, dept_id
FROM employees e
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE dept_id = e.dept_id
);


-- ============================================================
-- PART A: EXPLAIN for 3 Queries
-- ============================================================

-- EXPLAIN 1: Filter by salary
EXPLAIN SELECT * FROM employees WHERE salary > 70000;
-- Insight: PostgreSQL does a Sequential Scan (Seq Scan) because there is no index
-- on salary. Adding an index would make this an Index Scan and much faster.

-- EXPLAIN 2: JOIN query
EXPLAIN SELECT e.name, d.dept_name
        FROM employees e
        JOIN departments d ON e.dept_id = d.dept_id;
-- Insight: PostgreSQL uses a Hash Join. It builds a hash table from the smaller
-- table (departments) and probes it for each row of employees.

-- EXPLAIN 3: Aggregation
EXPLAIN SELECT dept_id, AVG(salary) FROM employees GROUP BY dept_id;
-- Insight: PostgreSQL uses a HashAggregate node to group rows by dept_id
-- in memory, which is efficient for small group counts.


-- ============================================================
-- PART B: Projects Table - 3-table JOIN
-- ============================================================

-- B1: Employee name + department budget + project budget
SELECT e.name         AS employee_name,
       d.dept_name    AS department,
       d.budget       AS dept_budget,
       p.project_name AS project,
       p.budget       AS project_budget
FROM projects p
JOIN employees   e ON p.lead_emp_id = e.emp_id
JOIN departments d ON e.dept_id     = d.dept_id;

-- B2: Departments where total project budget exceeds department budget
SELECT d.dept_name,
       d.budget             AS dept_budget,
       SUM(p.budget)        AS total_project_budget
FROM projects p
JOIN employees   e ON p.lead_emp_id = e.emp_id
JOIN departments d ON e.dept_id     = d.dept_id
GROUP BY d.dept_name, d.budget
HAVING SUM(p.budget) > d.budget;


-- ============================================================
-- PART C: Interview Questions
-- ============================================================

-- C2: Each employee name, salary, and dept avg salary
--     for employees earning above company-wide average
--     (No subqueries or CTEs)
SELECT e.name,
       e.salary,
       AVG(e2.salary) AS dept_avg_salary
FROM employees e
JOIN employees e2 ON e.dept_id = e2.dept_id
WHERE e.salary > (SELECT AVG(salary) FROM employees)
GROUP BY e.emp_id, e.name, e.salary;

-- C3: Debugged Query
-- BUGGY VERSION:
-- SELECT department, AVG(salary) as avg_sal
-- FROM employees
-- WHERE AVG(salary) > 70000   -- ERROR: cannot use aggregate in WHERE
-- GROUP BY department;

-- FIXED VERSION:
SELECT dept_id, AVG(salary) AS avg_sal
FROM employees
GROUP BY dept_id
HAVING AVG(salary) > 70000;  -- Correct: use HAVING for aggregate filters


-- ============================================================
-- PART D: AI-Generated Interview Questions
-- ============================================================

-- D1: Employees with NO projects (JOINs + NULL handling)
SELECT e.name
FROM employees e
LEFT JOIN projects p ON e.emp_id = p.lead_emp_id
WHERE p.project_id IS NULL;

-- D2: NULL salary handling
SELECT * FROM employees
WHERE salary IS NULL OR salary < 50000;

-- D3: Performance - check query plan with EXPLAIN
EXPLAIN SELECT * FROM employees WHERE dept_id = 1;
-- Insight: Add index on dept_id to convert Seq Scan to Index Scan.

-- D4: Rank employees by salary within their department
SELECT name, dept_id, salary,
       RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS salary_rank
FROM employees;

-- D5: Departments where max salary is more than double the min salary
SELECT dept_id, MAX(salary) AS max_sal, MIN(salary) AS min_sal
FROM employees
GROUP BY dept_id
HAVING MAX(salary) > 2 * MIN(salary);
