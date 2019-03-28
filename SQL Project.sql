-- 1a. Display the first and last names of all actors from the table actor.
use sakila;
select last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select CONCAT(upper(actor.first_name), ' ', upper(actor.last_name)) as Actor_name
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select * from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor
where last_name like '%LI%'
order by last_name, first_name
asc;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country.country_id, country.country 
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
    -- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor
add column Description BLOB after last_name; 

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
Drop column Description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as 'Frequency_of_Last_Name'
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) as 'Frequency_of_Last_Name'
from actor
group by last_name
having Frequency_of_Last_Name >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
    -- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
	-- based on hint:
SHOW CREATE TABLE address;

-- Or: create a new address table and name it as "Address_1"??
    CREATE TABLE address_1 (
 address_id INTEGER(11) AUTO_INCREMENT NOT NULL,
 address VARCHAR(50) NOT NULL,
 address2 VARCHAR(50) NOT NULL,
 district VARCHAR(20) NOT NULL,
 city_id INTEGER(10) NOT NULL,
 postal_code VARCHAR(10) NOT NULL,
 location GEOMETRY NOT NULL,
 last_update timestamp,
 PRIMARY KEY (address_id)
);

SELECT * FROM address_1;
Describe address_1;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select staff.first_name, staff.last_name, address.address
from staff
join address
on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select staff.first_name, staff.last_name, sum(payment.amount) as 'Total amount rung up'
from payment
join staff
on staff.staff_id = payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select film.film_id, film.title, count(film_actor.film_id) as 'Num of Actors'
from film
inner join film_actor
on film.film_id = film_actor.film_id
group by film.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select film.film_id, film.title, count(inventory.film_id) as 'Num of Copies'
from film
inner join inventory
on film.film_id = inventory.film_id
where film.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select customer.last_name, customer.first_name, sum(payment.amount)
from payment
join customer
on customer.customer_id = payment.customer_id
group by customer.customer_id
order by customer.last_name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
	-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE title like "K%" 
OR title like "Q%"
AND language_id IN
(
  SELECT language_id
  FROM language
  WHERE name IN ('ENGLISH')
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN 
  (
  SELECT film_id
  FROM film
  WHERE title = "ALONE TRIP"
  )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a
ON c.address_id = a.address_id
JOIN city ct
ON a.city_id = ct.city_id
JOIN country cy
ON ct.country_id = cy.country_id
WHERE country = "CANADA";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title as "Film Title", c.name as "Movie Type"
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
WHERE c.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title as "Movie", count(r.rental_id) as "Rent Times"
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY i.film_id
ORDER BY count(r.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, sum(p.amount) as "Total_Revenue"
FROM store s
JOIN inventory i
ON s.store_id = i.store_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, ct.country
FROM store s
JOIN address a
ON s.address_id = a.address_id
JOIN city c
ON a.city_id = c.city_id
JOIN country ct
ON c.country_id = ct.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
    -- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name as "Movie Genres", sum(p.amount) as "Gross Revenue"
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory i
ON fc.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY c.category_id
ORDER BY sum(p.amount) DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
    -- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW `top_five_genres` 
AS SELECT c.name as "Movie Genres", sum(p.amount) as "Gross Revenue"
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory i
ON fc.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY c.category_id
ORDER BY sum(p.amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM `top_five_genres`;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW `top_five_genres`;




