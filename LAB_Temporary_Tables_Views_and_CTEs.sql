USE sakila;

CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.email, 
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id, 
    crs.first_name, 
    crs.last_name, 
    crs.email, 
    crs.rental_count, 
    SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
JOIN payment p ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id, crs.first_name, crs.last_name, crs.email, crs.rental_count;

WITH CustomerSummary_CTE AS (
    SELECT 
        crs.first_name, 
        crs.last_name, 
        crs.email, 
        crs.rental_count, 
        cps.total_paid
    FROM customer_rental_summary AS crs
    JOIN customer_payment_summary AS cps ON crs.customer_id = cps.customer_id
)
SELECT 
    first_name, 
    last_name, 
    email, 
    rental_count, 
    total_paid,
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM CustomerSummary_CTE
ORDER BY total_paid DESC;