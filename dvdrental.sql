/* 
In this query, I used the DVDrental sample dataset provided by PostgreSQL Tutorial (http://www.postgresqltutorial.com/postgresql-sample-database/).
I rund simple queries to discovery the dataset and find answeres for some questions.
*/

--Data Manipulation
--First, I introduced a new category using the given settings.
INSERT INTO category (category_id, name, last_update) 
values ( nextval('category_category_id_seq'::regclass), 'Anime',  now());
		
--Now, I insert a new film.
INSERT INTO film (film_id, title, description,  release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, last_update, special_features) 
VALUES (nextval('film_film_id_seq'::regclass), 'Paprika', 'A revolutionary new psychotherapy treatment called dream therapy has been invented. A device called the "DC Mini" allows the user to view peoples dreams.',
					'2006','3','3','4.99','90','19.99','G'::mpaa_rating, now(),'{"Behind the Scenes"}');

--Update: the rating of the newly inserted film must be changes.
UPDATE film SET rating = 'R'  WHERE title='Paprika';

--Querying the data
--How many film are in the inventory in each categories?
SELECT category.name, COUNT(film.film_id)
	FROM category 
	JOIN film_category ON category.category_id=film_category.category_id
	JOIN film ON film_category.film_id=film.film_id
	GROUP BY category.name;

--Which costumer spends the most money at the rental company, and which customers spent more then 100$?
 SELECT customer.customer_id AS Customer_ID, sum(payment.amount) AS Total_amount
	FROM customer
	JOIN payment USING(customer_id)														  
	GROUP BY customer.customer_id
	HAVING sum(payment.amount)> 100
	ORDER BY 2 DESC;
		
--Which films ware rented by customer 15, and how long?
SELECT customer.customer_id AS customer_id, film.title, film.rental_duration, rental.rental_date, rental.return_date, DATE_PART('day', return_date - rental_date) AS rental_time
	FROM customer
	JOIN rental USING(customer_id)
	JOIN inventory USING(inventory_id)
	JOIN film USING(film_id)
	WHERE customer_id=15;

--How many of them were returned back too late and how many days later?
SELECT customer.customer_id AS customer_id, film.title, film.rental_duration, rental.rental_date, rental.return_date, 
		DATE_PART('day', return_date - rental_date) AS rental_time, rental_duration-DATE_PART('day', return_date - rental_date) AS days_of_delay
	FROM customer
	JOIN rental USING(customer_id)
	JOIN inventory USING(inventory_id)
	JOIN film USING(film_id)
	WHERE customer.customer_id=15 AND DATE_PART('day', return_date - rental_date) > film.rental_duration;

--If we calculate with an overdue fine 2$ per day, how much overdue fee needs to be paid for the company by each costumer?
SELECT customer.customer_id AS customer_id, first_name, last_name, email, sum(DATE_PART('day', return_date - rental_date)-rental_duration) AS days_of_delay, 
		SUM(DATE_PART('day', return_date - rental_date)-rental_duration)*2 AS late_fee
	FROM customer
	JOIN rental USING(customer_id)
	JOIN inventory USING(inventory_id)
	JOIN film USING(film_id)
	WHERE DATE_PART('day', return_date - rental_date) > film.rental_duration
	GROUP BY 1;	

--Which films are still not returned, and by which customer?
SELECT film.title, customer_id, first_name, last_name, email
	FROM customer
	JOIN rental USING(customer_id)
	JOIN inventory USING(inventory_id)
	JOIN film USING(film_id)
	WHERE return_date IS NULL;	

--Which countries belong to the TOP3 countries considering the total income?
 SELECT country, sum(payment.amount) AS Total_amount
	FROM country
	JOIN city USING(country_id)
	JOIN address USING(city_id)
	JOIN customer USING(address_id)
	JOIN rental USING(customer_id)
	JOIN payment USING(customer_id)
	GROUP BY country.country
	ORDER BY 2 DESC
	LIMIT 3;
		



