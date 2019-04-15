USE sakila;

-- 1a) Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b) Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT upper (concat ( first_name,' ', last_name)) AS 'Actor Name'
FROM actor;

-- 2a) You need to find the ID number, first name, and last name of an actor, of whom you know only the 
-- first name, "Joe." What is one query would you use to obtain this information?
     
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b) Find all actors whose last name contain the letters `GEN`
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c) Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order.

SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name;

-- 2d) Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:

select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a) Create a column in the table `actor` named `description` and use the data type `BLOB` 

ALTER TABLE actor 
ADD COLUMN description BLOB;

-- 3b) Delete the `description` column

ALTER TABLE actor
DROP COLUMN description;

-- 4a) List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) AS 'Last Name Count'
from actor
GROUP BY last_name;

-- 4b) List last names of actors and the number of actors who have that last name, but only for 
-- names that are shared by at least two actors

SELECT last_name, COUNT(last_name) AS Count
from actor
GROUP BY last_name
HAVING Count > 2;

-- 4c) The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as 
-- `GROUCHO WILLIAMS`. Write a query to fix the record.

UPDATE actor 
SET first_name = 'HARPO'
WHERE First_name = "Groucho" AND last_name = "Williams";


-- 4d) In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

-- ROLLBACK;

UPDATE actor 
SET first_name = 'Groucho'
WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
use sakila; 

DESCRIBE sakila.address;

-- ??? -- 6a. Use JOIN to display the first and last names, as well as the address, 
-- of each staff member. Use the tables staff and address:

SELECT s.first_name, s.last_name , a.address 
FROM address a
INNER JOIN staff s
ON a.address_id = s.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.

SELECT s.first_name, s.last_name, 
SUM(p.amount) AS 'TOTAL'
FROM staff s 
LEFT JOIN payment p  
ON s.staff_id = p.staff_id
GROUP BY s.first_name, s.last_name;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.

SELECT f.title, COUNT(fa.actor_id) AS 'Total actors'
FROM film_actor fa
INNER JOIN film f
ON fa.film_id = f.film_id
GROUP BY f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, 
COUNT(inventory_id) AS 'Total Copies'
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id 
WHERE title = 'Hunchback Impossible'
GROUP BY title;

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically by last name:

SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total'
FROM customer c 
LEFT JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY c.last_name;

-- 7a Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%'; 

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select first_name, last_name
from actor
where actor_id in 
(
select actor_id
from film_actor
where film_id in 
(
select film_id
from film
where title = 'Alone Trip' ));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
-- email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT first_name, last_name, email
FROM customer c
INNER JOIN address a 
ON a.address_id = c.address_id
INNER JOIN city 
ON a.city_id = city.city_id
INNER JOIN country
ON city.country_id = country.country_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a prom. 
-- Identify all movies categorized as family films.

SELECT title
FROM film
WHERE film_id IN
(
select film_id
from film_category
where category_id in 
(
SELECT category_id
FROM category
WHERE name = 'family'));

-- 7e. Display the most frequently rented movies in descending order.

SELECT title,
COUNT(f.film_id) AS 'Total'
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY Total DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id, SUM(p.amount) AS 'Total Revenue'
FROM payment p
JOIN staff s 
ON (p.staff_id=s.staff_id)
GROUP BY store_id;

-- 7g.Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, c.city, country.country
FROM store s
INNER JOIN address a
ON s.address_id = a.address_id
INNER JOIN city c
ON c.city_id = a.city_id
INNER JOIN country
ON country.country_id = c.country_id
GROUP BY store_id;

 -- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc 
ON c.category_id=fc.category_id
JOIN inventory i 
ON fc.film_id=i.film_id
JOIN rental r 
ON i.inventory_id=r.inventory_id
JOIN payment p ON 
r.rental_id=p.rental_id
GROUP BY c.name ORDER BY Gross LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
create view top_five_genres as
SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc 
ON c.category_id=fc.category_id
JOIN inventory i 
ON fc.film_id=i.film_id
JOIN rental r 
ON i.inventory_id=r.inventory_id
JOIN payment p ON 
r.rental_id=p.rental_id
GROUP BY c.name ORDER BY Gross LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres;





