/*
Author:		Aviral Sharma

	*******************************************************
	*******************************************************
	Portfolio Project
	Exloratory Data Analysis in SQL
	*******************************************************
	*******************************************************

Datasets:	
			aviation_accidents
			cleaned in cleaning.sql

*/

SELECT *
FROM aviation_accidents
ORDER BY Country


--	Looking at most dangerous to fly countries in the 21st Century
SELECT Country, COUNT(*) AS total_accidents
FROM aviation_accidents
--WHERE EventDate > CONVERT(DATE, '1999-12-31')
GROUP BY Country
ORDER BY total_accidents DESC

--	Looking at statewise accidents in United States in 21st century
SELECT state_country, COUNT(*) AS total_accidents
FROM aviation_accidents
WHERE EventDate > CONVERT(DATE, '1999-12-31')
GROUP BY state_country
ORDER BY total_accidents DESC

--	Updated the cleaning.sql script to trim whitespace before state name
--	UPDATE aviation_accidents
--	SET state_country = TRIM(state_country)

-- Looking at most dangerous to fly state in USA
SELECT Location, COUNT(*) AS total_accidents
FROM aviation_accidents
WHERE state_country = 'CA' AND EventDate > CONVERT(DATE, '1999-12-31')
GROUP BY Location
ORDER BY total_accidents DESC

/*	Corrected in cleaning.sql script
--------------------------
--	Checking state_country to be correct after split
SELECT DISTINCT state_country
FROM aviation_accidents
WHERE Country = 'United States' AND LEN(state_country) !=2 AND state_country NOT IN ('LA,', '')

--	Correcting state where state_country is 'LA,'
UPDATE aviation_accidents
SET state_country = 'LA'
WHERE state_country = 'LA,'

--	Corrective other US states with additional location info
UPDATE aviation_accidents
SET state_country = TRIM(SUBSTRING(state_country, CHARINDEX(',', state_country)+1, len(state_country)))
WHERE state_country LIKE '%,%' AND Country = 'United States' AND LEN(state_country) !=2 AND state_country != 'LA,'
----------------------------
*/


-- Rolling Count of Injuries by State and Date for USA
SELECT	EventDate, Country, state_country, Location, total_injuries,
		SUM(total_injuries) OVER (PARTITION BY state_country ORDER BY state_country, EventDate) AS rolling_injury_count
FROM aviation_accidents
WHERE Country = 'United States' AND EventDate > CONVERT(DATE, '1999-12-31') AND len(state_country)=2 -- Leaving OUT states where state not available
ORDER BY state_country, EventDate

--	Looking at country wise total_injuries (with rolling count) for 21st Century
SELECT	Country, Location, EventDate , total_injuries,
		SUM(total_injuries) OVER (PARTITION BY Country ORDER BY Country, EventDate) AS rolling_injury_count
FROM aviation_accidents
WHERE EventDate > CONVERT(DATE, '1999-12-31')
ORDER BY Country, EventDate, Location 

--				Create a view for commercial flights (no test flights, instructional, Gliders, Skydiving, etc.)

--	Checking Purpose of flight distinct values and accident counts
SELECT Purpose#of#flight, COUNT(*) AS total_accidents
FROM aviation_accidents
GROUP BY Purpose#of#flight
ORDER BY total_accidents DESC


-- creating a view for flights with Purpose#of#flight - Personal or business in 21st century

SELECT *
FROM USState_Codes

SELECT state_country, Location, Country
FROM aviation_accidents
WHERE Country = 'United States' AND state_country = ''

ALTER TABLE USState_Codes
ADD Country nvarchar(255)

UPDATE USState_Codes
SET Country = 'United States'


CREATE VIEW [comm_accidents1] AS
WITH map_drill (EventDate, Country, TotalInjuries, TotalFatalInjuries, Location) AS
(
SELECT EventDate, aa.Country, total_injuries, Total#Fatal#Injuries, 
CASE WHEN aa.Country = 'United States' THEN US_State
ELSE aa.Country
END AS stateOrCountry
FROM aviation_accidents AS aa
LEFT OUTER JOIN USState_Codes AS sc ON aa.state_country = sc.Abbreviation AND aa.Country = sc.Country
WHERE EventDate > CONVERT(DATE, '1999-12-31')
)
SELECT Country, COUNT(TotalInjuries) AS TotalInjuries, COUNT(TotalFatalInjuries) AS TotalFatalInjuries, Location
FROM map_drill
GROUP BY Location, Country


SELECT *
FROM comm_accidents









--				Create temp table for predicting flight phase





--				CTE for cessna aircraft
