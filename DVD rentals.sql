/* Query used for first insight*/
SELECT DISTINCT f.title AS movie,
c.name AS film_categories ,
COUNT(r.rental_id) OVER (PARTITION BY f.title) AS rental_count
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 2,1

/* Query used for second insight */
SELECT f.title AS movie,
c.name as Category,
f.rental_duration AS rental_duration,
NTILE(4) over (partition by f.rental_duration) AS std_quartile
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')


/* Query used for Third insight*/
SELECT
payment_month,
customer_name,
COUNT(payment_id),
sum(amount)
FROM
(SELECT first_name || ' ' || last_name AS customer_name,
date_trunc('month',payment_date) AS payment_month,
p.payment_id,
p.amount
FROM rental r
JOIN payment p
ON p.rental_id = r.rental_id
JOIN customer c
ON p.customer_id = c.customer_id
WHERE payment_date between '2007-01-01' AND '2007-12-31')t3
WHERE customer_name IN
(SELECT customer_name
  FROM
    (SELECT c.first_name || ' ' || c.last_name AS customer_name,
    SUM(amount) AS total_amount
    FROM rental r
    JOIN payment p
    ON p.rental_id = r.rental_id
    JOIN customer c
    ON p.customer_id = c.customer_id
    WHERE payment_date BETWEEN '2007-01-01' AND '2007-12-31'
    GROUP BY 1
    ORDER BY 2 desc
    LIMIT 10)
    t1)
GROUP BY 1,2
ORDER BY 2,1

/* Query used for fourth insight subsection 1 */
SELECT *,
total_monpay - previous_total_monpay AS difference_total_monpay
FROM
(SELECT
pay_month,
customer_name,
COUNT(payment_id),
SUM(amount) as total_monpay,
LAG(sum(amount)) OVER (PARTITION BY customer_name ORDER BY pay_month) AS previous_total_monpay
FROM
(SELECT date_trunc('month', payment_date) as pay_month,
first_name||' '||last_name AS customer_name,
payment_id,
amount
FROM
customer c
JOIN payment p
ON c.customer_id = p.customer_id
WHERE payment_date between '2007-01-01' and '2007-12-31')t1
WHERE customer_name IN
(SELECT customer_name
FROM
(SELECT first_name||' '||last_name as customer_name,
SUM(amount)
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
WHERE payment_date between '2007-01-01' and '2007-12-31'
GROUP BY 1
ORDER BY 2 desc
LIMIT 10)t1
)
GROUP BY 2,1
order by 2,1
)t3

/* Query used for fourth Insight sub section 2 */

SELECT customer_name,
MAX(difference_total_monpay) max_diff
FROM
(SELECT *,
total_monpay - previous_total_monpay AS difference_total_monpay
FROM
(SELECT
pay_month,
customer_name,
COUNT(payment_id),
SUM(amount) as total_monpay,
LAG(sum(amount)) OVER (PARTITION BY customer_name ORDER BY pay_month) AS previous_total_monpay
FROM
(SELECT date_trunc('month', payment_date) as pay_month,
first_name||' '||last_name AS customer_name,
payment_id,
amount
FROM
customer c
JOIN payment p
ON c.customer_id = p.customer_id
WHERE payment_date between '2007-01-01' and '2007-12-31')t1
WHERE customer_name IN
(SELECT customer_name
FROM
(SELECT first_name||' '||last_name as customer_name,
SUM(amount)
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
WHERE payment_date between '2007-01-01' and '2007-12-31'
GROUP BY 1
ORDER BY 2 desc
LIMIT 10
)t1
)
GROUP BY 2,1
order by 2,1
)t3
)t4
 GROUP BY 1
 ORDER BY 2 desc
