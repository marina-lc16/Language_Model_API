# lab_sql_temp_tables_views_ctes

USE SAKILA;

# Step 1: Create a View
/* First, create a view that summarizes rental information for each customer. 
The view should include the customer's ID, name, email address, 
and total number of rentals (rental_count).
*/

/*
sakila.customer: customer_id, first_name, email, address_id
sakila.rental: rental_id, customer_id

customer_id
first_name
email
count(rental_id)
*/

DROP VIEW  sakila.Total_number_of_rental;

CREATE VIEW sakila.Total_number_of_rental AS 
(SELECT c.customer_id, first_name as name, email as email_address, count(distinct(rental_id)) as rental_count
FROM sakila.customer as c
JOIN sakila.rental as r
ON c.customer_id = r.customer_id
GROUP BY c.customer_id);

SELECT * from sakila.Total_number_of_rental ;


# Step 2: Create a Temporary Table
/* Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
The Temporary Table should use the rental summary view created in Step 1 
to join with the payment table and calculate the total amount paid by each customer.
*/

DROP TEMPORARY TABLE total_amount_paid_per_customer;

SELECT * FROM sakila.payment;

SELECT p.customer_id, sum(p.amount) as total_paid
FROM 
sakila.payment as p
JOIN 
sakila.Total_number_of_rental as r
ON
p.customer_id = r.customer_id
GROUP BY p.customer_id;

CREATE TEMPORARY TABLE total_amount_paid_per_each_customer AS (
SELECT p.customer_id, sum(p.amount) as total_paid
FROM 
sakila.payment as p
JOIN 
sakila.Total_number_of_rental as r
ON
p.customer_id = r.customer_id
GROUP BY p.customer_id);

SELECT * from total_amount_paid_per_each_customer;


# Step 3: Create a CTE and the Customer Summary Report
/* Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
The CTE should include the customer's name, email address, rental count, and total amount paid.

Next, using the CTE, create the query to generate the final customer summary report, which should include: 
customer name, email, rental_count, total_paid and average_payment_per_rental, 
this last column is a derived column from total_paid and rental_count.
*/

# View: sakila.Total_number_of_rental 
# Temp: total_amount_per_customer 

WITH customer_payment_summary AS (
SELECT tn.customer_id, tn.name, tn.email_address, tn.rental_count, ta.total_paid
FROM sakila.Total_number_of_rental as tn
JOIN sakila.total_amount_paid_per_each_customer as ta
ON tn.customer_id = ta.customer_id)
SELECT * FROM customer_payment_summary;

# PENDING QUERY add COLUMN average_payment_per_rental
WITH customer_payment_summary AS (
SELECT tn.customer_id, tn.name, tn.email_address, tn.rental_count, ta.total_paid, AVG(ta.total_paid+tn.rental_count) as average_payment_per_rental
FROM sakila.Total_number_of_rental as tn
JOIN sakila.total_amount_paid_per_each_customer as ta
ON tn.customer_id = ta.customer_id)
SELECT * FROM customer_payment_summary
group by tn.rental_count;


