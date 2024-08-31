-- Identify the top 5 skills that are most frequently mentioned in job postings. Use a subquery to find the skill IDs with the highest counts in the skills_job_dim table and then join this result with the skills_dim table to get the skill names.

WITH top_skill_id AS (
    SELECT
        skill_id,
        COUNT(*) AS postings
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY postings DESC
    LIMIT 5
)
SELECT
    sd.skills,
    ts.postings
FROM
    top_skill_id ts
INNER JOIN
    skills_dim sd ON sd.skill_id = ts.skill_id;

-- Determine the size category ('Small', 'Medium', or 'Large') for each company by first identifying the number of job postings they have. Use a subquery to calculate the total job postings per company. A company is considered 'Small' if it has less than 10 job postings, 'Medium' if the number of job postings is between 10 and 50, and 'Large' if it has more than 50 job postings. Implement a subquery to aggregate job counts per company before classifying them based on size.

WITH job_counts AS (
    SELECT 
        f.company_id,
        COUNT(*) AS job_postings
    FROM job_postings_fact f
    GROUP BY f.company_id
)
SELECT 
    d.name AS company_name,
    jc.job_postings,
    CASE 
        WHEN jc.job_postings < 10 THEN 'Small'
        WHEN jc.job_postings BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS size_category
FROM 
    job_counts jc
INNER JOIN 
    company_dim d ON d.company_id = jc.company_id;

-- Find companies that offer an average salary above the overall average yearly salary of all job postings. Use subqueries to select companies with an average salary higher than the overall average salary (which is another subquery).

WITH 
company_avg_salary AS (
    SELECT company_id, AVG(salary_year_avg) as avg_salary
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    GROUP BY company_id
),
overall_avg_salary AS (
    SELECT AVG(salary_year_avg) as overall_avg_salary
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
)

SELECT
    cd.name,
    cs.avg_salary
FROM company_avg_salary cs
INNER JOIN company_dim cd ON cd.company_id = cs.company_id
CROSS JOIN overall_avg_salary oas
WHERE cs.avg_salary > oas.overall_avg_salary
ORDER BY cs.avg_salary DESC

-- Explore job postings by listing job id, job titles, company names, and their average salary rates, while categorizing these salaries relative to the average in their respective countries. Include the month of the job posted date. Use CTEs, conditional logic, and date functions, to compare individual salaries with national averages.

WITH avg_salary_country AS (
    SELECT 
        job_country, 
        AVG(salary_hour_avg) AS avg_hourly_salary, 
        AVG(salary_year_avg) AS avg_yearly_salary 
    FROM job_postings_fact 
    GROUP BY job_country
)
SELECT 
    f.job_country AS country, 
    c.name AS company_name, 
    f.job_title, 
    f.salary_hour_avg, 
    f.salary_year_avg, 
    CASE 
        WHEN f.salary_hour_avg - avg_hourly_salary > 0 THEN 'Above Average' 
        WHEN f.salary_hour_avg - avg_hourly_salary < 0 THEN 'Below Average' 
        ELSE 'n/a' 
    END AS diff_country_average_hourly, 
    CASE 
        WHEN f.salary_year_avg - avg_yearly_salary > 0 THEN 'Above Average' 
        WHEN f.salary_year_avg - avg_yearly_salary < 0 THEN 'Below Average' 
        ELSE 'n/a' 
    END AS diff_country_average_yearly, 
    EXTRACT(YEAR FROM f.job_posted_date) AS year_posted, 
    EXTRACT(MONTH FROM f.job_posted_date) AS month_posted 
FROM job_postings_fact f 
INNER JOIN company_dim c ON c.company_id = f.company_id 
INNER JOIN avg_salary_country acs ON acs.job_country = f.job_country 
WHERE f.salary_hour_avg IS NOT NULL OR f.salary_year_avg IS NOT NULL 
ORDER BY country, company_name, f.job_title

-- Calculate the number of unique skills required by each company. Aim to quantify the unique skills required per company and identify which of these companies offer the highest average salary for positions necessitating at least one skill. For entities without skill-related job postings, list it as a zero skill requirement and a null salary. Use CTEs to separately assess the unique skill count and the maximum average salary offered by these companies.

-- Counts the distinct skills required for each company's job posting
WITH required_skills AS (
  SELECT
    companies.company_id,
    COUNT(DISTINCT skills_to_job.skill_id) AS unique_skills_required
  FROM
    company_dim AS companies 
  LEFT JOIN job_postings_fact as job_postings ON companies.company_id = job_postings.company_id
  LEFT JOIN skills_job_dim as skills_to_job ON job_postings.job_id = skills_to_job.job_id
  GROUP BY
    companies.company_id
),
-- Gets the highest average yearly salary from the jobs that require at least one skills 
max_salary AS (
  SELECT
    job_postings.company_id,
    MAX(job_postings.salary_year_avg) AS highest_average_salary
  FROM
    job_postings_fact AS job_postings
  WHERE
    job_postings.job_id IN (SELECT job_id FROM skills_job_dim)
  GROUP BY
    job_postings.company_id
)
-- Joins 2 CTEs with table to get the query
SELECT
  companies.name,
  required_skills.unique_skills_required as unique_skills_required, --handle companies w/o any skills required
  max_salary.highest_average_salary
FROM
  company_dim AS companies
LEFT JOIN required_skills ON companies.company_id = required_skills.company_id
LEFT JOIN max_salary ON companies.company_id = max_salary.company_id
ORDER BY
	companies.name;




