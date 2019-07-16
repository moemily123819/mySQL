-- created by Emily Mo
-- on  Mar 16, 2019
-- Homework for SQL 

USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`:
SELECT 
  first_name, 
  last_name 
  FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT 
  UPPER(CONCAT(first_name, ' ', last_name)) AS "Actor Name"
  FROM actor;
 
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT
  actor_id,
  first_name,
  last_name
  FROM actor WHERE first_name ='JOE';

 
--  2b. Find all actors whose last name contain the letters `GEN`:
SELECT *
  FROM actor WHERE last_name LIKE '%GEN%';

 
 
--  2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
 SELECT * 
   FROM actor WHERE last_name LIKE '%LI%'
   ORDER BY last_name, first_name;

 
-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
  country_id,
  country
  FROM country WHERE country IN (
  "AFGHANISTAN", "BANGLADESH", "CHINA");
  
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor 
  ADD COLUMN description BLOB NOT NULL;
  
SELECT *
  FROM actor;

  
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor 
  DROP COLUMN description;
  
SELECT *
  FROM actor;
  
  
-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
  last_name, count(last_name) as Count_of_Last_Name
  FROM actor GROUP by last_name;
  
  
--  4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT 
  last_name, count(last_name) as Count_of_Last_Name
  FROM actor GROUP by last_name HAVING Count_of_Last_Name >= 2;
  
  
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

SET SQL_SAFE_UPDATES = 0;

UPDATE actor 
  SET first_name="HARPO" WHERE first_name = "GROUCHO" and last_name ="WILLIAMS"; 

SELECT *
  FROM actor WHERE last_name = "WILLIAMS";

  
--  4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE actor 
  SET first_name="GROUCHO" WHERE first_name = "HARPO"; 

SET SQL_SAFE_UPDATES = 1;
  
--  5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?


CREATE TABLE IF NOT EXISTS address (
  address_id  SMALLINT(5) UNSIGNED AUTO_INCREMENT NOT NULL,
  address     VARCHAR(50) NOT NULL,
  address2    VARCHAR(50),
  district    VARCHAR(20) NOT NULL,
  city_id     SMALLINT(5) UNSIGNED NOT NULL,
  postal_code VARCHAR(10),
  phone       VARCHAR(20) NOT NULL,
  location    geometry NOT NULL,
  last_update TIMESTAMP NOT NULL,
  PRIMARY KEY (address_id),
  FOREIGN KEY (city_id) REFERENCES city (city_id)
  );

DESCRIBE address;  
SHOW CREATE TABLE address;


-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT 
  first_name,
  last_name,
  address
  FROM staff AS s
  JOIN address AS a WHERE s.address_id = a.address_id;
  

 --  6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
 Select 
   staff_id,
   first_name,
   last_name,
   (SELECT SUM(amount) FROM payment WHERE ((payment.staff_id = staff.staff_id) and (payment.payment_date LIKE '2005-08%')) ) as "Total_Amount"
   FROM staff
   ORDER by staff_id;
   
 
 -- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
-- SELECT 
--   title,
--   (SELECT COUNT(actor_id) FROM film_actor AS FA WHERE FA.film_id = film.film_id) as 'Number_of_actors'
--   FROM film;
 
 SELECT 
   F.title,
   count(FA.actor_id) as Number_of_Actors
   FROM film as F
   INNER JOIN film_actor as FA
   WHERE F.film_id = FA.film_id
   GROUP BY F.film_id;
 
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
 
-- SELECT film_id, count(inventory_id) as Number_of_Copies
--   FROM inventory WHERE film_id IN (
--		SELECT film_id
--		  FROM film WHERE title ='Hunchback Impossible');
          

 SELECT 
   title,
   (SELECT count(inventory_id) FROM inventory as i WHERE i.film_id = f.film_id) as 'Number_of_Copies'
   FROM film as f WHERE title ='Hunchback Impossible';
       
       
       
--  6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
  
 SELECT 
   c.first_name,
   c.last_name,
   (SELECT sum(amount) FROM payment as p WHERE p.customer_id = c.customer_id) as 'Total_Amount_Paid'
   FROM customer as c ORDER BY c.last_name;
   
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT 
  f.title
  FROM film as f WHERE (f.title LIKE 'Q%' or f.title LIKE 'K%')
  and f.language_id IN
  (SELECT 
    l.language_id
    FROM language as l WHERE l.name ='English');
 
 -- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
 
 SELECT 
   a.first_name,
   a.last_name
   FROM actor as a WHERE a.actor_id 
   IN 
   (SELECT 
     FA.actor_id
     FROM film_actor as FA WHERE FA.film_id 
     IN
      (SELECT 
         f.film_id
         FROM film as f WHERE f.title ='Alone Trip')
     );    
         
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT
  first_name,
  last_name,
  email,
  address_id
  FROM customer WHERE address_id IN
      (SELECT
        address_id
        FROM address WHERE city_id IN 
            (SELECT
              city_id 
              FROM city WHERE country_id IN
                  (SELECT 
                     country_id
                     FROM country WHERE country = 'CANADA')
        ));
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
 
 SELECT
   title
   FROM film WHERE film_id IN
            (SELECT 
              film_id
              FROM film_category WHERE category_id IN
                   (SELECT 
                      category_id
                      FROM category WHERE name ='Family')
				);
 

-- 7e. Display the most frequently rented movies in descending order.     
     
     
SELECT 
        title, count(f.film_id) as count_film
    FROM
        (`film` `f`
        JOIN `inventory` `i` ON (`f`.`film_id` = `i`.`film_id`)
        JOIN `rental` `r` ON (`r`.`inventory_id` = `i`.`inventory_id`))
    GROUP BY title
    ORDER BY count_film DESC;    
     

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT 
  s.store_id, sum(p.amount) as Total_Amount_Received
  FROM
  (`staff` `s`
      JOIN `payment` `p` ON (`s`.`staff_id` = `p`.`staff_id`))
      GROUP BY s.store_id
      ORDER BY s.store_id;
     

-- 7g. Write a query to display for each store its store ID, city, and country.

  
SELECT 
  s.store_id, c.city, co.country
  FROM
  (`store` `s`
      JOIN `address` `a` ON (`s`.`address_id` = `a`.`address_id`)
      JOIN `city` `c` ON (`c`.`city_id` = `a`.`city_id`)
      JOIN `country` `co` ON (`c`.`country_id` = `co`.`country_id`)
      )
  GROUP BY s.store_id
  ORDER BY s.store_id;
     
-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT 
  c.name as 'Genre',  
  sum(amount) as Gross_Revenue
  FROM
  (`payment` `p`
      JOIN `rental` `r` ON (`r`.`rental_id` = `p`.`rental_id`)
      JOIN `inventory` `i` ON (`i`.`inventory_id` = `r`.`inventory_id`)
      JOIN `film` `f` ON (`f`.`film_id` = `i`.`film_id`)
      JOIN `film_category` `FC` ON (`f`.`film_id` = `FC`.`film_id`)
      JOIN `category` `c` ON (`FC`.`category_id` = `c`.`category_id`)
      )
  GROUP BY c.name
  ORDER BY Gross_Revenue DESC
  LIMIT 5;
   
   
--  8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS 
SELECT 
  c.name as 'Genre',  
  sum(amount) as Gross_Revenue
  FROM
  (`payment` `p`
      JOIN `rental` `r` ON (`r`.`rental_id` = `p`.`rental_id`)
      JOIN `inventory` `i` ON (`i`.`inventory_id` = `r`.`inventory_id`)
      JOIN `film` `f` ON (`f`.`film_id` = `i`.`film_id`)
      JOIN `film_category` `FC` ON (`f`.`film_id` = `FC`.`film_id`)
      JOIN `category` `c` ON (`FC`.`category_id` = `c`.`category_id`)
      )
  GROUP BY c.name
  ORDER BY Gross_Revenue DESC
  LIMIT 5;
  
--  8b. How would you display the view that you created in 8a?
  
SELECT *
  FROM top_five_genres;
    
--  8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_five_genres;  
     