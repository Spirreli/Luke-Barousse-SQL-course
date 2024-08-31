/* From the job_postings_fact table, categorize the salaries from job postings that are data analyst jobs and who have a yearly salary information. Put salary into 3 different categories:

If the salary_year_avg is greater than $100,000 then return ‘high salary’.
If the salary_year_avg is between $60,000 and $99,999 return ‘Standard salary’.
If the salary_year_avg is below $60,000 return ‘Low salary’.

Also order from the highest to lowest salaries. */

SELECT
    f.job_title,
    f.salary_year_avg,
    CASE
        WHEN f.salary_year_avg > 100000 THEN 'High'
        WHEN f.salary_year_avg >= 60000 THEN 'Standard'
        ELSE 'Low'
    END AS "Salary Category"
FROM
    job_postings_fact f
WHERE
    f.job_title_short = 'Data Analyst' AND
    f.salary_year_avg IS NOT NULL AND
    f.job_country = 'Belgium'
ORDER BY
    f.salary_year_avg DESC;

-- Count the number of unique companies that offer work from home (WFH) versus those requiring work to be on-site. Use the job_postings_fact table to count and compare the distinct companies based on their WFH policy (job_work_from_home).

SELECT 
    COUNT(DISTINCT CASE WHEN job_work_from_home = TRUE THEN company_id END) AS wfh_companies,
    COUNT(DISTINCT CASE WHEN job_work_from_home = FALSE THEN company_id END) AS non_wfh_companies
FROM job_postings_fact;

/* Write a query that lists all job postings with their job_id, salary_year_avg, and two additional columns using CASE WHEN statements called: experience_level and remote_option. Use the job_postings_fact table.

For experience_level, categorize jobs based on keywords found in their titles (job_title) as 'Senior', 'Lead/Manager', 'Junior/Entry', or 'Not Specified'. Assume that certain keywords in job titles (like "Senior", "Manager", "Lead", "Junior", or "Entry") can indicate the level of experience required. ILIKE should be used in place of LIKE for this.
NOTE: Use ILIKE in place of how you would normally use LIKE ; ILIKE is a command in SQL, specifically used in PostgreSQL. It performs a case-insensitive search, similar to the LIKE command but without sensitivity to case.

For remote_option, specify whether a job offers a remote option as either 'Yes' or 'No', based on job_work_from_home column. */

SELECT 
  job_id,
  salary_year_avg,
  CASE
      WHEN job_title ILIKE '%Senior%' THEN 'Senior'
      WHEN job_title ILIKE '%Manager%' OR job_title ILIKE '%Lead%' THEN 'Lead/Manager'
      WHEN job_title ILIKE '%Junior%' OR job_title ILIKE '%Entry%' THEN 'Junior/Entry'
      ELSE 'Not Specified'
  END AS experience_level,
  CASE
      WHEN job_work_from_home THEN 'Yes'
      ELSE 'No' 
  END AS remote_option
FROM 
  job_postings_fact
WHERE 
  salary_year_avg IS NOT NULL 
ORDER BY 
  job_id;