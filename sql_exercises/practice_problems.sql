--- Get job details for BOTH 'Data Analyst' or 'Business Analyst' positions
    -- For ‘Data Analyst,’ I want jobs only > $100k
    -- For ‘Business Analyst,’ I only want jobs > $70K
-- Only include jobs located in EITHER:
    -- 'Boston, MA'
    -- 'Anywhere' (i.e., Remote jobs)
-- Query Notes: Include job title abbreviation, location, posting source, and average yearly salary

SELECT
    f.job_title_short,
    f.job_location,
    f.job_via,
    f.salary_year_avg
FROM
    job_postings_fact f
WHERE
    f.job_location IN('Boston, MA', 'Anywhere') AND
    (
        f.job_title_short = 'Data Analyst' AND f.salary_year_avg > 100000 OR
        f.job_title_short = 'Business Analyst' AND f.salary_year_avg > 70000
    );

/* 
Look for non-senior data analyst or business analyst roles
    - Only get job titles that include either ‘Data’ or ‘Business’
    - Also include those with ‘Analyst’ in any part of the title
    - Don’t include any job titles with ‘Senior’ followed by any character
- Get the job title, location, and average yearly salary
*/

SELECT 
	job_title,
	job_location AS location,
	salary_year_avg AS salary
FROM 
	job_postings_fact
WHERE 
	(job_title LIKE '%Data%' OR job_title LIKE '%Business%') 
	AND job_title LIKE '%Analyst%'
	AND job_title NOT LIKE '%Senior%';

-- Find the average, minimum, and maximum salary range for each `job_title_short`
-- Only include job titles with more than 5 postings (I.e., filter out outliers)

SELECT 
  job_title_short,
  AVG(salary_year_avg) AS avg_salary,
  MIN(salary_year_avg) AS lowest_avg_salary_offered, 
  MAX(salary_year_avg) AS highest_avg_salary_offered 
FROM 
  job_postings_fact
GROUP BY 
  job_title_short
HAVING 
  COUNT(job_id) > 5;

/*
- Find the average salary and number of job postings for each skill for this:
    - Write a query to list each unique skill from the **`skills_dim`** table.
    - Count how many job postings mention each skill from the **`skills_to_job_dim`** table.
    - Calculate the average yearly salary for job postings associated with each skill.
    - Group the results by the skill name.
    - Order By the average salary
*/

SELECT
    skills,
    COUNT(sj.job_id) AS job_postings,
    ROUND(AVG(f.salary_year_avg), 2) AS salary_year_avg
FROM
    skills_dim s
INNER JOIN
    skills_job_dim sj ON
    sj.skill_id = s.skill_id
INNER JOIN
    job_postings_fact f ON
    f.job_id = sj.job_id
GROUP BY
    s.skill_id
ORDER BY
    job_postings DESC;

-- Find the count of the number of remote job postings per skill
    -- Display the top 5 skills in descending order by their demand in remote jobs
    -- Include skill ID, name, and count of postings requiring the skill
    -- Why? Identify the top 5 skills in demand for remote jobs

SELECT
    s.skills,
    COUNT(sj.job_id) AS job_postings
FROM
    skills_dim s
INNER JOIN
    skills_job_dim sj ON
    sj.skill_id = s.skill_id
INNER JOIN
    job_postings_fact f ON
    f.job_id = sj.job_id
WHERE
    f.job_work_from_home = TRUE
GROUP BY
    s.skill_id
ORDER BY
    job_postings DESC
LIMIT 5;

-- Create three tables:
    -- Jan 2023 jobs
    -- Feb 2023 jobs
    -- Mar 2023 jobs
-- This will be used in another practice problem below.

CREATE TABLE january_jobs AS 
	SELECT * 
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS 
	SELECT * 
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS 
	SELECT * 
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

-- Retrieve the job id, job title short, job location, job via, skill and skill type for each job posting from the first quarter (January to March). Using a subquery to combine job postings from the first quarter (these tables were created in the Advanced Section - Practice Problem 6) Only include postings with an average yearly salary greater than $70,000.

SELECT
	quarter1_job_postings.job_title_short,
	quarter1_job_postings.job_location,
	quarter1_job_postings.job_via,
	quarter1_job_postings.job_posted_date::DATE
FROM
-- Gets all rows from January, February, and March job postings 
	(
		SELECT *
		FROM january_jobs
		UNION ALL
		SELECT *
		FROM february_jobs
		UNION ALL 
		SELECT *
		FROM march_jobs
	) AS quarter1_job_postings 
WHERE
	quarter1_job_postings.salary_year_avg > 70000
	--AND job_postings.job_title_short = 'Data Analyst'
ORDER BY
	quarter1_job_postings.salary_year_avg DESC;

