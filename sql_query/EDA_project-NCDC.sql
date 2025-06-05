
-- Understanding the dataset metrics

-- Brief overview
SELECT *
FROM monthly_disease_report
LIMIT 10;

-- No of diseases
SELECT COUNT(DISTINCT Disease)
FROM monthly_disease_report;

-- No of LGAs
SELECT COUNT(DISTINCT LGA)
FROM monthly_disease_report;

-- No of states
SELECT COUNT(DISTINCT `state`)
FROM monthly_disease_report;


-- EDA

-- Total suspected cases
SELECT SUM(co_total) as total_suspected_cases
FROM monthly_disease_report;

-- Total investigated cases
SELECT sum(ci_total) as total_investigated_cases
FROM monthly_disease_report;

-- Total death cases
SELECT SUM(dio_total) as total_death
FROM monthly_disease_report;

-- Monthly suspected cases per disease
SELECT *
FROM (
    SELECT 
        disease, 
        `month`, 
        SUM(co_total) AS total_suspected_cases
    FROM monthly_disease_report
    GROUP BY disease, `month`
) AS grouped
ORDER BY disease, total_suspected_cases DESC;

-- Monthy Investigated Cases per disease (Top months)
SELECT *
FROM (
    SELECT 
        disease, 
        `month`, 
        SUM(ci_total) AS total_investigated_cases
    FROM monthly_disease_report
    GROUP BY disease, `month`
) AS grouped
ORDER BY disease, total_investigated_cases DESC;

-- High Risk Demographic
SELECT SUM(co_0to28d + co_1to11m) as infants,
		SUM(co_12to59m + co_5to9y) as children,
		SUM(co_10to19y) as teens,
        SUM(co_20to40y) as adults,
        SUM(co_ovr40y) as adults_over_40
FROM monthly_disease_report;

-- Most Common Disease in each Demographic
 -- Overview
SELECT disease, SUM(co_0to28d + co_1to11m) as infants,
		SUM(co_12to59m + co_5to9y) as children,
		SUM(co_10to19y) as teens,
        SUM(co_20to40y) as adults,
        SUM(co_ovr40y) as adults_over_40
FROM monthly_disease_report
GROUP BY disease;
 -- Infants
 SELECT disease, SUM(co_0to28d + co_1to11m) as infants
FROM monthly_disease_report
GROUP BY disease
ORDER BY 2 DESC;
 -- Children
 SELECT disease, SUM(co_12to59m + co_5to9y) as children
FROM monthly_disease_report
GROUP BY disease
ORDER BY 2 DESC;
 -- Teens
 SELECT disease, SUM(co_10to19y) as teens
FROM monthly_disease_report
GROUP BY disease
ORDER BY 2 DESC;
 -- Adults(20-40y)
 SELECT disease, SUM(co_20to40y) as adults
FROM monthly_disease_report
GROUP BY disease
ORDER BY 2 DESC;
 -- Adults over 40y
 SELECT disease, SUM(co_ovr40y) as adults_over_40
FROM monthly_disease_report
GROUP BY disease
ORDER BY 2 DESC;

-- Top 10 LGA by case count
SELECT LGA, SUM(co_total) as total_suspected_case
FROM monthly_disease_report
GROUP BY LGA
ORDER BY total_suspected_case DESC
LIMIT 10;

-- Top 5 states by case count
SELECT state, SUM(co_total) as total_suspected_case
FROM monthly_disease_report
GROUP BY state
ORDER BY total_suspected_case DESC
LIMIT 5;

-- Top 5 diseases
SELECT disease, SUM(co_total) as total_case_count
FROM monthly_disease_report
GROUP BY disease
ORDER BY total_case_count DESC
LIMIT 5;

-- Top disease ratio by demographic
SELECT disease, SUM(co_total) as case_count, ROUND((SUM(co_0to28d + co_1to11m) *100) / SUM(co_total), 1) as infants,
		ROUND((SUM(co_12to59m + co_5to9y)* 100)/ SUM(co_total), 1) as children,
		ROUND((SUM(co_10to19y)*100)/ SUM(co_total), 1) as teens,
        ROUND((SUM(co_20to40y)*100)/ SUM(co_total), 1) as adults_20_to_40y,
        ROUND((SUM(co_ovr40y)*100)/ SUM(co_total), 1) as adults_over_40
FROM monthly_disease_report
WHERE disease IN ('Malaria', 'Typhoid Fever', 'Malaria (Pregnant Women)', 'High Blood Pressure', 'Diarrhoea (Watery without blood)')
GROUP BY disease;

-- Top 5 fatal diseases
SELECT disease, SUM(dio_total) as total_death_count
FROM monthly_disease_report
GROUP BY disease
ORDER BY total_death_count DESC
LIMIT 5;

-- Investigation rate 2013 vs 2015
WITH inv_rate_2013 as (
SELECT (inv_count * 100)/ case_count as investigation_rate_2013
FROM(
SELECT SUM(co_total) AS case_count,
	SUM(ci_total) AS inv_count
FROM monthly_disease_report
WHERE year = 2013) AS grouped
),
 inv_rate_2015 as (
SELECT (inv_count * 100)/ case_count as investigation_rate_2015
FROM(
SELECT SUM(co_total) AS case_count,
	SUM(ci_total) AS inv_count
FROM monthly_disease_report
WHERE year = 2015) AS grouped
)
SELECT ROUND(investigation_rate_2013, 1), ROUND(investigation_rate_2015, 1)
FROM inv_rate_2013, inv_rate_2015;

-- Investigation rate of top 5 diseases
SELECT disease, case_count_disease, ROUND((case_inv_disease * 100)/case_count_disease, 2) as inv_rate_disease
FROM (SELECT disease, SUM(co_total) as case_count_disease, SUM(ci_total) as case_inv_disease
	FROM monthly_disease_report
	GROUP BY disease) as grouped
ORDER BY 2 DESC
LIMIT 5;

-- Top 5 least investigated diseases
SELECT disease, ROUND((case_inv * 100)/ case_count, 2) as inv_rate
FROM (SELECT disease, SUM(co_total) as case_count, SUM(ci_total) as case_inv
	FROM monthly_disease_report
	GROUP BY disease
    ) as grouped
ORDER BY inv_rate
LIMIT 5;

-- Fatality rate 2013 vs 2015
WITH fat_rate_2013 as (
SELECT (fat_count * 100)/ case_count as fatality_rate_2013
FROM(
SELECT SUM(co_total) AS case_count,
	SUM(dio_total) AS fat_count
FROM monthly_disease_report
WHERE year = 2013) AS grouped
),
 fat_rate_2015 as (
SELECT (fat_count * 100)/ case_count as fatality_rate_2015
FROM(
SELECT SUM(co_total) AS case_count,
	SUM(dio_total) AS fat_count
FROM monthly_disease_report
WHERE year = 2015) AS grouped
)
SELECT ROUND(fatality_rate_2013, 2), ROUND(fatality_rate_2015, 2)
FROM fat_rate_2013, fat_rate_2015;

-- Timely report rate
WITH tim_rpt_2013 as (
SELECT (timely_rpt * 100)/ total_rpt as timely_rpt_2013
FROM (SELECT MAX(totalhfs) as total_rpt,
	MAX(timelyrpts) as timely_rpt
FROM monthly_disease_report
WHERE year = 2013) as grouped
),
tim_rpt_2015 as (
SELECT (timely_rpt * 100)/ total_rpt as timely_rpt_2015
FROM (SELECT MAX(totalhfs) as total_rpt,
	MAX(timelyrpts) as timely_rpt
FROM monthly_disease_report
WHERE year = 2015) as grouped
)
SELECT ROUND(timely_rpt_2013, 1) as timely_report_2013, ROUND(timely_rpt_2015, 1) as timely_report_2015
FROM tim_rpt_2013, tim_rpt_2015;

-- Timely report rate of top 5 states by case count
SELECT state, ROUND((timelyrpt * 100)/ totalhfs, 2) as report_rate
FROM (SELECT state, SUM(co_total), MAX(totalhfs) as totalhfs, MAX(timelyrpts) as timelyrpt
FROM monthly_disease_report
GROUP BY state
ORDER BY 2 DESC
LIMIT 5) as grouped;

-- Outbreak detection (Spike Analysis) of top 5 diseases
SELECT 
    disease,
    report_date,
    SUM(co_total) as case_count,
    LAG(SUM(co_total), 1) OVER (PARTITION BY disease ORDER BY report_date) AS previous_month,
    SUM(co_total) - LAG(SUM(co_total), 1) OVER (PARTITION BY disease ORDER BY report_date) AS spike
FROM monthly_disease_report
WHERE disease IN ('Malaria', 'Diarrhoea (Watery without blood)', 'Malaria (Pregnant Women)', 'High Blood Pressure', 'Typhoid Fever')
GROUP BY disease, report_date;

-- Silent zones (States with Little to no report)
SELECT state, SUM(hfs) as total_hfs, SUM(norpt) as no_rpts, ROUND((SUM(norpt)*100)/SUM(hfs), 2) as no_rpt_rate
FROM
(SELECT state, lga, report_date, MAX(totalhfs) as hfs, MAX(norpts) as norpt
FROM monthly_disease_report
GROUP BY report_date, state, lga) as grouped
GROUP BY state
ORDER BY no_rpt_rate DESC
LIMIT 10;


