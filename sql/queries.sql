-- ============================================================
-- HR Analytics — Attrition — key SQL queries (SQLite)
-- Dataset: 5,000 employee records
-- ============================================================

-- 1. Workforce KPIs
SELECT COUNT(*) employees,
       SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END) employees_left,
       ROUND(100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) attrition_rate,
       ROUND(AVG(monthly_income),0) avg_income,
       ROUND(AVG(job_satisfaction),2) avg_satisfaction,
       ROUND(AVG(years_at_company),1) avg_tenure
FROM employees;

-- 2. Attrition by department
SELECT department, COUNT(*) employees,
       SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END) exits,
       ROUND(100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) attrition_rate,
       ROUND(AVG(monthly_income),0) avg_income
FROM employees GROUP BY department ORDER BY attrition_rate DESC;

-- 3. The overtime effect (biggest driver)
SELECT overtime, COUNT(*) employees,
       ROUND(100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) attrition_rate
FROM employees GROUP BY overtime;

-- 4. Job satisfaction ladder
SELECT job_satisfaction, COUNT(*) employees,
       ROUND(100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) attrition_rate
FROM employees GROUP BY job_satisfaction ORDER BY job_satisfaction;

-- 5. Age bands
SELECT CASE WHEN age < 25 THEN '18-25'
            WHEN age < 35 THEN '26-35'
            WHEN age < 45 THEN '36-45'
            ELSE '46+' END AS age_band,
       COUNT(*) employees,
       ROUND(100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) attrition_rate
FROM employees GROUP BY age_band ORDER BY age_band;

-- 6. Salary bands — are we paying people to stay?
SELECT CASE WHEN monthly_income < 40000 THEN '<40k'
            WHEN monthly_income < 70000 THEN '40-70k'
            WHEN monthly_income < 100000 THEN '70-100k'
            ELSE '100k+' END AS income_band,
       COUNT(*) employees,
       ROUND(100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) attrition_rate
FROM employees GROUP BY income_band ORDER BY income_band;

-- 7. Commute distance — quiet attrition driver
SELECT CASE WHEN distance_from_home < 10 THEN '0-9'
            WHEN distance_from_home < 20 THEN '10-19'
            ELSE '20+' END AS distance_band,
       COUNT(*) employees,
       ROUND(100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) attrition_rate
FROM employees GROUP BY distance_band ORDER BY distance_band;

-- 8. Tenure bands — when do people leave?
SELECT CASE WHEN years_at_company < 2 THEN '0-1'
            WHEN years_at_company < 5 THEN '2-4'
            WHEN years_at_company < 10 THEN '5-9'
            ELSE '10+' END AS tenure_band,
       COUNT(*) employees,
       ROUND(100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) attrition_rate
FROM employees GROUP BY tenure_band ORDER BY tenure_band;

-- 9. Role-level risk (window function: rank roles by attrition)
SELECT job_role, COUNT(*) employees,
       ROUND(100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) attrition_rate,
       DENSE_RANK() OVER (ORDER BY 100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*) DESC) risk_rank
FROM employees GROUP BY job_role;

-- 10. Composite risk cohort: overtime + low satisfaction + long commute
SELECT COUNT(*) employees,
       SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END) exits,
       ROUND(100.0*SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) attrition_rate
FROM employees
WHERE overtime='Yes' AND job_satisfaction <= 2 AND distance_from_home >= 20;
