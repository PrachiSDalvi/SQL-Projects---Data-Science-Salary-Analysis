
/*Checking an overview of out table*/
sp_help DS_Salary


/*viewing the data in the Table*/
select * from DS_Salary


/*Checking for NULLs in the table*/
select * from DS_Salary
Where [Record no] is null
or work_year is null
or experience_level is null
or employment_type is null
or job_title is null
or salary is null
or salary_currency is null
or salary_in_usd is null
or employee_residence is null
or remote_ratio is null
or company_location is null
or company_size is null;


/*Dropping not requried columns*/
ALTER TABLE DS_Salary  
DROP COLUMN salary, salary_currency, employee_residence;


/*updating the shortcuts for better understanding*/
update DS_Salary
Set experience_level = Case when experience_level = 'EN' Then 'Entry-level' 
			When experience_level = 'MI' Then 'Mid-level' 
			When experience_level = 'SE' Then 'Senior-level' 
			When experience_level = 'EX' Then 'Executive-level' End
, employment_type = Case when employment_type = 'FT' Then 'Full Time' 
			When employment_type = 'PT' Then 'Part Time' 
			When employment_type = 'CT' Then 'Contract' 
			When employment_type = 'FL' Then 'Freelance' End
, company_size = Case when company_size = 'S' Then 'Small' 
			When company_size = 'M' Then 'Medium' 
			When company_size = 'L' Then 'Large' End


/*Viewing the cleaned data*/
select * from DS_Salary

Select count(*) from DS_Salary


/*Count of Job Title in the table*/
select count(Distinct Job_Title) From DS_Salary;


/*Count of enteries by Job Title*/
select job_title, count(Job_Title) From DS_Salary Group by job_title order by 2 desc;


/*top 10 Average salaries by job title*/
select top 10 job_title, avg(salary_in_usd) as [Average Salary in USD] From DS_Salary Group by job_title order by 2 desc;


/*Average salaries by employment_type*/
select employment_type, avg(salary_in_usd) as [Average Salary in USD] From DS_Salary Group by employment_type order by avg(salary_in_usd) desc;


/*Average salaries by experience_level*/
select experience_level, count([Record no]) [Count of Records], avg(salary_in_usd) as [Average Salary in USD] From DS_Salary Group by experience_level order by avg(salary_in_usd) desc;


--Salary Trends Over the Years
SELECT work_year, AVG(salary_in_usd) AS avg_salary
FROM DS_Salary
GROUP BY work_year
ORDER BY work_year;


--Distribution of Employees and Average Salary by Remote Work Ratio
SELECT remote_ratio, COUNT(*) AS num_employees, AVG(salary_in_usd) AS avg_salary
FROM DS_Salary
GROUP BY remote_ratio;


--Average Salary by Company Size
SELECT company_size, AVG(salary_in_usd) AS avg_salary
FROM DS_Salary
GROUP BY company_size;



/*Top 3 Highest Paying Job Titles per Year*/
WITH RankedJobs AS (
    SELECT 
        work_year, 
        job_title, 
        AVG(salary_in_usd) AS avg_salary,
        RANK() OVER (PARTITION BY work_year ORDER BY AVG(salary_in_usd) DESC) AS rank_salary
    FROM DS_Salary
    GROUP BY work_year, job_title
)
SELECT * FROM RankedJobs WHERE rank_salary <= 3;




/*Salary growth by experience_level over the years*/
SELECT 
    work_year, 
    experience_level, 
    ROUND(AVG(salary_in_usd), 2) AS avg_salary, 
    LAG(ROUND(AVG(salary_in_usd), 2)) OVER (PARTITION BY experience_level ORDER BY work_year) AS prev_year_salary,
    (ROUND(AVG(salary_in_usd), 2) - LAG(ROUND(AVG(salary_in_usd), 2)) OVER (PARTITION BY experience_level ORDER BY work_year)) AS salary_growth_in_USD
FROM DS_Salary
GROUP BY work_year, experience_level
ORDER BY work_year, experience_level;



/*Pivoting data to show salary over the years by experience level*/
SELECT * FROM (
    SELECT 
        work_year, 
        experience_level, 
        ROUND(AVG(salary_in_usd), 2) AS avg_salary
    FROM DS_Salary
    GROUP BY work_year, experience_level
) AS source_data
PIVOT (
    MAX(avg_salary) 
    FOR experience_level IN ([Entry-level], [Mid-level], [Senior-level], [Executive-level])
) AS pivot_table
ORDER BY work_year;


