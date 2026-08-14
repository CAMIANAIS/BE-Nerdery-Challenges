
/*
    Challenge 1.
    Write a SQL query that counts the number of films in each category in the Pagila database.
    - The query should return two columns: category and film_count
    - category should display the name of each category
    - film_count should show the total number of films in that category
    - Results should be grouped by category name
 */

-- your query here
SELECT
name AS category,
COUNT(filCat.film_id) AS film_count
FROM film_category AS filCat
INNER JOIN category
ON category.category_id=filCat.category_id
INNER JOIN film
ON film.film_id=filCat.film_id
GROUP BY name

 /*
    Challenge 2.
    Write a SQL query that finds the top 5 customers who have spent the most money in the Pagila database.
    - The query should return three columns: first_name, last_name, and total_spent
    - total_spent should show the sum of all payments made by that customer
    - Results should be ordered by total_spent in descending order
    - The query should limit results to only the top 5 highest-spending customers
 */

 -- your query here

SELECT
first_name,
last_name,
SUM(payment.amount) AS total_spent
FROM customer
INNER JOIN payment
	ON customer.customer_id=payment.customer_id
GROUP BY customer.customer_id
ORDER BY total_spent DESC
LIMIT 5

/*
    Challenge 3.
    Write a SQL query that lists all film titles that have been rented in the past 10 years in the Pagila database.
    - The query should return one column: title
    - title should display the name of each film that has been rented
    - The time period for "recent" should be within the last 10 years from the current date
    - Results should only include films that have rental records in this time period
*/


-- your query here
SELECT
film.title
FROM inventory
INNER JOIN rental
	ON rental.inventory_id=inventory.inventory_id
INNER JOIN film
	ON film.film_id=inventory.film_id
WHERE rental.rental_date::date >=CURRENT_DATE -interval '10 years'
GROUP BY film.title

/*
    Challenge 4.
    Write a SQL query that lists all films that have never been rented in the Pagila database.
    - The query should return two columns: title and inventory_id
    - title should display the name of each film that has never been rented
    - inventory_id should show the inventory ID of the specific copy
*/


-- your query here

SELECT
film.title,
inventory.inventory_id
FROM inventory
LEFT JOIN rental
	ON inventory.inventory_id=rental.inventory_id
INNER JOIN film
	ON film.film_id=inventory.film_id
WHERE rental.rental_date::date IS NULL


/*
    Challenge 5.
    Write a SQL query that lists all films that were rented more times than the average rental count per film in the Pagila database.
    - The query should return two columns: title and rental_count
    - title should display the name of each film
    - rental_count should show the total number of times the film was rented
*/
WITH rental_count_film AS(SELECT
film.title,
count (rental.inventory_id) AS rental_count
FROM inventory
INNER JOIN rental
	ON inventory.inventory_id=rental.inventory_id
INNER JOIN film
	ON film.film_id=inventory.film_id
GROUP BY film.film_id
ORDER BY rental_count
)


SELECT 
rental_count_film.title,
rental_count
FROM rental_count_film 
WHERE rental_count> (SELECT AVG(rental_count) FROM rental_count_film );



-- your query here

/*
    Challenge 6.
    Write a SQL query that calculates rental activity for each customer.
    - The query should return the customer's first_name and last_name
    - It should also return their first rental date as first_rental
    - Their most recent rental date should be shown as last_rental
    - The difference in days between the first and last rentals should be shown as rental_span_days
    - Results should be grouped by customer and ordered by rental_span_days in descending order
*/

-- your query here
SELECT 
first_name,
last_name,
MIN(rental.rental_date) AS first_rental,
MAX(rental.rental_date) AS last_rental,
MAX(rental.rental_date)::date  - MIN(rental.rental_date)::date AS rental_span_days
FROM
customer 
INNER JOIN rental 
	ON rental.customer_id=customer.customer_id
GROUP BY customer.customer_id
ORDER BY rental_span_days DESC

/*
    Challenge 7.
    Find all customers who have not rented movies from every available genre.
    - The result should include the customer's first_name and last_name
    - Only include customers who are missing at least one genre in their rental history
*/


-- your query here

/* How many categories exists*/

WITH sum_total_categories AS(SELECT COUNT (name) AS total_categories
FROM category)


SELECT 
first_name,
last_name,
COUNT(DISTINCT category.category_id) AS genres_rented
FROM customer
INNER JOIN rental
	ON rental.customer_id=customer.customer_id
INNER JOIN inventory
	ON inventory.inventory_id=rental.inventory_id
INNER JOIN film_category 
	ON film_category.film_id=inventory.film_id
INNER JOIN category
	ON category.category_id=film_category.category_id
GROUP BY customer.customer_id
HAVING COUNT(DISTINCT category.category_id)<(SELECT total_categories FROM sum_total_categories)




/*
    Challenge 8.
    Create a materialized view that summarizes total rental revenue per film category.

    First, write a SQL query that returns the category name and the total revenue generated by rentals in that category.

    Use the following tables: payment, rental, inventory, film, film_category, and category.

    - Group the results by category name and order them by total revenue (descending).
    - Then, turn your query into a materialized view named revenue_by_category.
    - Query the materialized view to return:
    - All categories and their total revenue.
    - The top 3 categories by revenue.
    - Finally, refresh the materialized view manually using SQL.

    Once you finish the exercise, please answer the following questions: 
    
    When would you prefer a materialized view over a regular view? 
    How often should it be refreshed?
*/

-- your work here

--======================================================
-- Author: Camila Mamani
-- Date: 13 August 2026
-- Description: Materialized view of Revenue By Category
--======================================================
CREATE MATERIALIZED VIEW revenue_by_category AS (SELECT 
category.name AS category,
SUM(payment.amount) AS total_revenue
FROM payment
INNER JOIN rental
	ON payment.rental_id=rental.rental_id
INNER JOIN inventory
	ON inventory.inventory_id=rental.inventory_id
INNER JOIN film_category 
	ON film_category.film_id=inventory.film_id
INNER JOIN category
	ON category.category_id=film_category.category_id
GROUP BY category.category_id
ORDER BY total_revenue DESC)
---
SELECT * FROM revenue_by_category;
---
SELECT * FROM revenue_by_category
ORDER BY total_revenue DESC
LIMIT 3;

---
REFRESH MATERIALIZED VIEW revenue_by_category;


--When would you prefer a materialized view over a regular view? 
--two factors: you don't need instant freshness, and the underlying query is expensive enough that running it on every call would cost real performance.

--How often should it be refreshed?
--As a stored snapshot that only updates when refreshed (manually or via a scheduled trigger), and how stale it's allowed to get depends on the use case.