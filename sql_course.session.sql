SELECT *
FROM job_postings_fact
LIMIT 50;

SELECT *
FROM company_dim
LIMIT 50;

SELECT * 
FROM skills_dim
LIMIT 50;

SELECT *
FROM skills_job_dim
LIMIT 50;



/* Practice problem 1
 Write a query to find the average salary both yearly and hourly
 for job postings that were posted after June 1, 2023. Group the 
results by job schedule type */

-- Practice Problem 1 for data analysts
SELECT 
    job_title_short AS position,
    avg(salary_year_avg) AS yearly_average_salary,
    avg(salary_hour_avg) AS hourly_average_salary,
    job_schedule_type
FROM 
    job_postings_fact
WHERE
    job_posted_date > TO_DATE('2023-06-01','yyyy-mm-dd')
    AND job_title_short = 'Data Analyst'
GROUP BY
    job_title_short, job_schedule_type
LIMIT 100
    


--Practice Problem 1 (General)
SELECT 
    avg(salary_year_avg) AS yearly_average_salary,
    avg(salary_hour_avg) AS hourly_average_salary,
    job_schedule_type
FROM
    job_postings_fact
GROUP BY
    job_schedule_type


/*Practice problem 2
Write a query to count the number of job postings for each month in 2023
adjusting the job_posted_date to be in New York time zone before extracting the month
Group by and order by the month
*/

SELECT
   -- job_title_short,
    COUNT(job_id) AS number_of_jobs,
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') AS date_month,
    EXTRACT(YEAR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') AS date_year
FROM 
    job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') = 2023
 /*AND job_title_short = 'Data Analyst' */
GROUP BY
    date_month, /*job_title_short,*/ date_year
ORDER BY date_month ASC;


/*Write a query to find companies(include company name) that have posted jobs offering health
insurance, where these postings were made in the second quarter of 2023. Use date extraction to
filter by quarter*/


SELECT *
FROM job_postings_fact
LIMIT 500;

SELECT *
FROM company_dim
LIMIT 50;

SELECT * 
FROM skills_dim
LIMIT 50;

SELECT *
FROM skills_job_dim
LIMIT 50;

CREATE TABLE january_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = 1
   

CREATE TABLE february_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = 2
  


CREATE TABLE march_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = 3
  


SELECT 
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite '
    END AS location_category
FROM
    job_postings_fact
WHERE 
    job_title_short = 'Data Analyst'
GROUP BY
    location_category



--Sub Queries



WITH february_jobs AS
     (
    SELECT *
    FROM 
        job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = 2
    )


 
SELECT *
FROM
    february_jobs
LIMIT 100;

SELECT 
    company_id,
    job_no_degree_mention,
    (
    SELECT 
        name 
    FROM
        company_dim
    ) AS company_name
FROM 
    job_postings_fact
WHERE
    job_no_degree_mention = true
LIMIT 1000;


SELECT *
FROM company_dim;

SELECT 
    company_id,
    name AS company_name
FROM
    company_dim
WHERE company_id IN (
    SELECT
           company_id
    FROM
            job_postings_fact
    WHERE   
            job_no_degree_mention = true
)

/* Common Table Expressions and Subqueries
They are used for organizing and simplifying complex queries*/


--Sub query
SELECT *
FROM
    (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
    ) AS january_jobs


--Common table expression

WITH january_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)
SELECT * 
FROM january_jobs


--List of companies that offer jobs that dont have any 
--requirements for degree

SELECT 
        name AS company_name,
        company_id
FROM
        company_dim
WHERE   company_id IN (
                    SELECT
                            company_id
                    FROM
                            job_postings_fact
                    WHERE 
                            job_no_degree_mention = true 
                        )
/* Common Table Expressions 
Find companies that have the most job openings
-get the total number of job postings per company id
-Return the total number of jobs with the company name*/

WITH company_jobs_count AS (
        SELECT 
                company_id,
                COUNT(*) AS total_jobs
        FROM
                job_postings_fact
        GROUP BY 
                company_id
)

SELECT cd.name AS company_name,
        cjc.total_jobs
FROM     
        company_jobs_count cjc 
LEFT JOIN company_dim cd ON cjc.company_id = cd.company_id 
ORDER BY 
        total_jobs DESC;

--Question 1
/* 
Identify the top 5 skills that are most frequently mentioned in
job postings.
- Use a subquery to find the skill IDs with the highest counts in the
skills_job_dim table
- join this result with the skills_dim table to get the skill names
*/


WITH frequently_mentioned_skills AS 
                (
            SELECT 
                job_title_short,
                skill_id,
                COUNT(*) AS times_mentioned
            FROM
                skills_job_dim sjd
            INNER JOIN job_postings_fact jpf ON jpf.job_id = sjd.job_id
            WHERE job_title_short = 'Data Analyst'
            GROUP BY
                    job_title_short, skill_id
            ORDER BY
                times_mentioned DESC
                )

SELECT 
            job_title_short,
            sd.skills,
            times_mentioned
FROM
            frequently_mentioned_skills fms
INNER JOIN  skills_dim sd ON sd.skill_id = fms.skill_id 
ORDER BY
            fms.times_mentioned DESC
LIMIT 5;


/*Question 2
Determine the size category('Small', 'Meduim' or 'Large') for each
company by first identifying the number of job postings they have. Use
a sub query to calculate the total job postings per company. A company is
considered 'small' if it has less than 10 job postings, 'Meduim'
if the number of job postings is between 10 and 50, and Large if it has more 
than 50 job postings. Implement a subquery to aggregate job counts per company before 
classifying them based on size.
*/

SELECT 
    company_id,
    COUNT(*)
FROM 
    job_postings_fact
GROUP BY
    company_id

SELECT 
    name AS company_name
FROM 
    company_dim
WHERE 
    company_id IN (

        
    )












/*Practice Problem 7
Find the count of the number of remote job postings per skills
--Display the top 5 skills by their demand in remote jobs
--Include skill ID, name, and count of postings requiring the skill
*/


WITH remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim sjd
    INNER JOIN job_postings_fact jpf ON sjd.job_id = jpf.job_id
    WHERE 
        jpf.job_work_from_home = true 
    AND job_title_short = 'Data Analyst'
    GROUP BY
        skill_id
)

SELECT 
    rjs.skill_id,
    sd.skills AS name_of_skill,
    skill_count
FROM 
    remote_job_skills rjs
INNER JOIN skills_dim sd ON rjs.skill_id = sd.skill_id
ORDER BY   
    skill_count DESC
LIMIT 5;

/*
Union Operators
Used to join tables together
--same number of columns and datatype
*/

SELECT 
    job_id,
    job_location,
    job_title_short
FROM
    january_jobs

UNION

SELECT 
    job_id,
    job_location,
    job_title_short
FROM
    february_jobs

/*
Practice Problem 8
Find job postings from the first quarter that have a salary 
greater than $70K
-- Combine job postings table from the first quarter of 2023 (Jan-Mar)
-- Get job postings with an average yearly salary > 70,000
*/


SELECT 
        quarter1_postings.job_title_short,
        quarter1_postings.job_location,
        quarter1_postings.job_via,
        quarter1_postings.job_posted_date::DATE,
        quarter1_postings.salary_year_avg
FROM
        (SELECT *
        FROM
            january_jobs
        UNION ALL
        SELECT *
        FROM
            february_jobs
        UNION ALL   
        SELECT *
        FROM 
            march_jobs
        )
        AS quarter1_postings
WHERE
        quarter1_postings.salary_year_avg > 70000
    AND
        quarter1_postings.job_title_short = 'Data Analyst'
ORDER BY 
        quarter1_postings.salary_year_avg DESC














SELECT 
    company_id,
    COUNT(*)
FROM 
    job_postings_fact
GROUP BY
    company_id

SELECT 
    name AS company_name
FROM 
    company_dim
WHERE 
    company_id IN (

        
    )












