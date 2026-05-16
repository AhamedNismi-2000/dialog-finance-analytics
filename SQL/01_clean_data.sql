 SELECT * FROM fintech

  -- remove the duplicate values

--         SELECT customer_id, COUNT(*)
--         FROM fintech
--         GROUP BY customer_id
--         HAVING COUNT(*) > 1;

--   WITH cte AS (
--     SELECT *,
--            ROW_NUMBER() OVER (
--                PARTITION BY customer_id
--            ) AS rn
--     FROM fintech
-- )
--     DELETE FROM fintech
--     WHERE customer_id IN (
--         SELECT customer_id
--         FROM cte
--         WHERE rn > 1
-- );


SELECT district,province FROM fintech