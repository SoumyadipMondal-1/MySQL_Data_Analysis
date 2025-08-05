# Question Set 1 - Easy

/* Q1. Who is the senior most employee based on job title? */
SELECT employee_id, CONCAT( first_name, ' ', last_name) AS Employee_Name, title, levels, hire_date 
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* # Q2. Which countries have the most Invoices? */
SELECT billing_country, COUNT(*) AS Most_Invoices
FROM invoice
GROUP BY billing_country
ORDER BY Most_Invoices DESC;

/* Q3. What are top 3 values of total invoice? */
SELECT total AS total_invoices 
FROM invoice
ORDER BY total_invoices DESC
LIMIT 3;

/* Q4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals  */
SELECT  billing_city, SUM(total) AS Sum_of_total
FROM invoice 
GROUP BY billing_city
ORDER BY Sum_of_total DESC
LIMIT 1;

/* Q5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money */
SELECT C.customer_id, CONCAT( C.first_name, ' ', C.last_name) AS Customer_Name, SUM(I.total) AS Total_spent
FROM customer C JOIN invoice I
ON C.customer_id = I.customer_id
GROUP BY C.customer_id, C.first_name, C.last_name
ORDER BY Total_spent DESC
LIMIT 1;


# Question Set 2 – Moderate 

/* Q1. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */
SELECT C.customer_id, CONCAT( C.first_name, ' ', C.last_name) AS Customer_Name, C.email, G.name AS Genre
FROM customer C 
JOIN invoice I  ON C.customer_id = I.customer_id
JOIN invoice_line II ON I.invoice_id = II.invoice_id
JOIN track T ON II.track_id = T.track_id
JOIN genre G  ON T.genre_id = G.genre_id
GROUP BY C.customer_id, C.first_name, C.last_name, C.email, G.name
HAVING G.name = 'Rock'
ORDER BY C.email;

/* Q2. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */
SELECT AR.artist_id, AR.name AS Artist_Name, COUNT(*) AS Total_Tracks, G.name AS Genre
FROM artist AR
JOIN album AL ON AR.artist_id = AL.artist_id
JOIN track T ON AL.album_id = T.album_id
JOIN genre G ON T.genre_id = G.genre_id
GROUP BY AR.artist_id, AR.name, G.name
HAVING Genre = 'Rock'
ORDER BY Total_Tracks DESC
LIMIT 10;

/* Q3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */
SELECT track_id, name AS Track_Name, milliseconds AS Song_length_in_ms
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) AS Average_length FROM track)
ORDER BY Song_length_in_ms DESC;


# Question Set 3 – Advance

/* Q1. Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */
SELECT C.customer_id, CONCAT(C.first_name, ' ', C.last_name) AS Customer_name,AT.artist_id, AT.name AS Artist_name, 
SUM(IL.unit_price*IL.quantity) AS Total_spent
FROM customer C 
JOIN invoice I ON C.customer_id = I.customer_id
JOIN invoice_line IL ON I.invoice_id = IL.invoice_id
JOIN track T ON IL.track_id = T.track_id
JOIN album AL ON T.album_id = AL.album_id
JOIN artist AT ON AL.artist_id = AT.artist_id
GROUP BY C.customer_id, C.first_name, C.last_name,AT.artist_id, AT.name
ORDER BY Total_spent DESC;


/* Q2. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */
WITH Max_Purchase AS (
SELECT G.genre_id, G.name AS Genre_name, I.billing_country AS Country, COUNT(IL.quantity) AS Highest_amount
FROM genre G
JOIN track T ON G.genre_id = T.genre_id
JOIN invoice_line IL ON T.track_id = IL.track_id
JOIN invoice I ON IL.invoice_id = I.invoice_id
GROUP BY 1,2,3)
SELECT Country, Genre_name, Highest_amount 
FROM Max_Purchase 
WHERE (Country, Highest_amount) IN (
SELECT Country, MAX(Highest_amount) 
FROM Max_Purchase
GROUP BY Country)
ORDER BY Highest_amount DESC; 

/* Q3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount */
WITH Max_Buy AS(
SELECT C.customer_id, CONCAT(C.first_name, ' ', C.last_name) AS Customer_name, I.billing_country AS Country, SUM(I.total) as Most_spent
FROM customer C
JOIN invoice I ON C.customer_id = I.customer_id
GROUP BY 1,2,3
ORDER BY 4 DESC)
SELECT customer_id, Customer_name, Country, Most_spent
FROM Max_Buy
WHERE (Country, Most_spent) IN (
SELECT Country, MAX(Most_spent) 
FROM Max_Buy 
GROUP BY Country) 
ORDER BY Most_spent DESC;
