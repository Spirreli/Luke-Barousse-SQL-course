-- Find the average salary both yearly (salary_year_avg) and hourly (salary_hour_avg) for job postings using the job_postings_fact table that were posted after June 1, 2023. Group the results by job schedule type. Order by the job_schedule_type in ascending order.

SELECT 
    job_schedule_type AS "Schedule Type",
    AVG(salary_year_avg) AS "Average Yearly Salary",
    AVG(salary_hour_avg) AS "Average Hourly Salary"
FROM 
    job_postings_fact
WHERE
    job_posted_date > '2023-06-01'
GROUP BY
    job_schedule_type
ORDER BY
    job_schedule_type ASC

-- Count the number of job postings for each month in 2023, adjusting the job_posted_date to be in 'America/New_York' time zone before extracting the month. Assume the job_posted_date is stored in UTC. Group by and order by the month.

SELECT
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS month,
    COUNT(*) AS postings_count
FROM
    job_postings_fact
WHERE
    job_posted_date > '2023-01-01'
GROUP BY
    month
ORDER BY
    month;

-- Find companies (include company name) that have posted jobs offering health insurance, where these postings were made in the second quarter of 2023. Use date extraction to filter by quarter. And order by the job postings count from highest to lowest.

SELECT
    c.name AS "Company Name",
    COUNT(*) AS "Job Postings"  
FROM
    job_postings_fact f
INNER JOIN
    company_dim c ON
    f.company_id = c.company_id
WHERE
    f.job_health_insurance = TRUE AND
    EXTRACT(YEAR FROM f.job_posted_date) = 2023 AND
    EXTRACT(QUARTER FROM f.job_posted_date) = 2
GROUP BY
    c.name
ORDER BY
    COUNT(*) DESC
   