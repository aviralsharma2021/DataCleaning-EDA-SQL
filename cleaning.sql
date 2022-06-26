/*
Author:		Aviral Sharma

	*******************************************************
	*******************************************************
	Portfolio Project
	Data Cleansing in SQL
	*******************************************************
	*******************************************************

Datasets:	
			Aviation Accident Database & Synopses
DOI:		https://doi.org/10.34740/KAGGLE/DSV/3021787

*/


SELECT Location, state_country
FROM AviationData;


--				Standardizing Case of Text; Make column contains a mix of upper case and lower case 
-- Example
SELECT Event#Id, Make
FROM AviationData
WHERE Event#Id IN ('20120710X03702', '20001213X32216');

--	Changing Make to Upper Case
UPDATE AviationData
SET Make = UPPER(Make);

--	Changing Location to Upper Case
UPDATE AviationData
SET Location = UPPER(Location)



--				Splitting Location to Area and State for US, Area and country for non-US locations
ALTER TABLE AviationData
ADD state_country nvarchar(255)

UPDATE AviationData
SET Location = SUBSTRING(Location, 1, CHARINDEX(',', Location)-1)
WHERE Location LIKE '%,%'		-- Takes care of locations where state or country is missing

UPDATE AviationData
SET state_country = SUBSTRING(Location, CHARINDEX(',', Location)+1, len(Location))
WHERE Location LIKE '%,%'



--				Removing time from event date
SELECT EventDate, CONVERT(Date, Event#Date)
FROM AviationData;


ALTER TABLE AviationData
ADD EventDate Date;


UPDATE AviationData
SET EventDate = CONVERT(Date, Event#Date);



--				Creating table copy using relevant columns
SELECT * FROM AviationData
SELECT  Event#Id, 
		EventDate, 
		Accident#Number, 
		Location, 
		state_country, 
		Country, 
		Injury#Severity, 
		Aircraft#damage,
		Make,
		Model,
		Number#of#Engines,
		Engine#Type,
		Purpose#of#flight,
		Total#Fatal#Injuries,
		Total#Minor#Injuries,
		Total#Serious#Injuries,
		Total#Uninjured,
		Weather#Condition,
		Broad#phase#of#flight
INTO aviation_accidents FROM AviationData

SELECT *
FROM aviation_accidents



--				Dealing with missing values
SELECT *
FROM aviation_accidents


--	Total Null Values per column
SELECT 'Location', SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'state_country', SUM(CASE WHEN state_country IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Country', SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Injury#Severity', SUM(CASE WHEN Injury#Severity IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Aircraft#damage', SUM(CASE WHEN Aircraft#damage IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Make', SUM(CASE WHEN Make IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Model', SUM(CASE WHEN Model IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Number#of#Engines', SUM(CASE WHEN Number#of#Engines IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Engine#Type', SUM(CASE WHEN Engine#Type IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Purpose#of#flight', SUM(CASE WHEN Purpose#of#flight IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Total#Fatal#Injuries', SUM(CASE WHEN Total#Fatal#Injuries IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Total#Minor#Injuries', SUM(CASE WHEN Total#Minor#Injuries IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Total#Serious#Injuries', SUM(CASE WHEN Total#Serious#Injuries IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Total#Uninjured', SUM(CASE WHEN Total#Uninjured IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Weather#Condition', SUM(CASE WHEN Weather#Condition IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents
UNION ALL
SELECT 'Broad#phase#of#flight', SUM(CASE WHEN Broad#phase#of#flight IS NULL THEN 1 ELSE 0 END) FROM aviation_accidents


--	Records where Injury Information is not available is not valuable
DELETE FROM aviation_accidents
WHERE Total#Fatal#Injuries is null or Total#Minor#Injuries is null or Total#Serious#Injuries is null or  Total#Uninjured is null  


/*
Location, Country, Make, Model, Weather#Condition and Broad#phase#of#flight can be set to UNKNOWN where not specified 
If state_country length > 2, country = state_country
Also to be set unknown - injuryseverity, aircraft damage, engine_type, purpose of flight
*/

UPDATE aviation_accidents
SET Location = 'UNKNOWN'
WHERE Location IS NULL

UPDATE aviation_accidents
SET Country = 'UNKNOWN'
WHERE Country IS NULL

UPDATE aviation_accidents
SET state_country = 'UNKNOWN'
WHERE state_country IS NULL

UPDATE aviation_accidents
SET Make = 'UNKNOWN'
WHERE Make IS NULL

UPDATE aviation_accidents
SET Model = 'UNKNOWN'
WHERE Model IS NULL


--	Weather#Condition has a value of UNK which means Unknown, set to UNKNOWN for uniformity
SELECT DISTINCT Weather#Condition
FROM aviation_accidents

UPDATE aviation_accidents
SET Weather#Condition = 'UNKNOWN'
WHERE Weather#Condition IS NULL OR Weather#Condition='UNK'


--	Broad#phase#of#flight has a value of Unknown, set to UNKNOWN for uniformity
SELECT DISTINCT Broad#phase#of#flight
FROM aviation_accidents

UPDATE aviation_accidents
SET Broad#phase#of#flight = 'UNKNOWN'
WHERE Broad#phase#of#flight IS NULL OR Broad#phase#of#flight='Unknown'


--	For some data, where Injury#Severity is Fatal, it has a value total deaths in bracket
SELECT Injury#Severity, Total#Fatal#Injuries
FROM aviation_accidents
WHERE Injury#Severity LIKE 'Fatal%'

UPDATE aviation_accidents
SET Injury#Severity = SUBSTRING(Injury#Severity, 1, CHARINDEX('(', Injury#Severity)-1)
WHERE Injury#Severity LIKE 'Fatal(%'

SELECT DISTINCT Injury#Severity
FROM aviation_accidents

UPDATE aviation_accidents
SET Injury#Severity = 'UNKNOWN'
WHERE Injury#Severity IS NULL OR Injury#Severity='Unavailable'


--	Aircraft#damage has a value of Unknown, set to UNKNOWN for uniformity
SELECT DISTINCT Aircraft#damage
FROM aviation_accidents

UPDATE aviation_accidents
SET Aircraft#damage = 'UNKNOWN'
WHERE Aircraft#damage IS NULL OR Aircraft#damage='Unknown'


--	Engine#Type has a value of Unknown, set to UNKNOWN for uniformity
SELECT DISTINCT Engine#Type
FROM aviation_accidents

UPDATE aviation_accidents
SET Engine#Type = 'UNKNOWN'
WHERE Engine#Type IS NULL OR Engine#Type='Unknown'


--	Purpose#of#flight has a value of Unknown, set to UNKNOWN for uniformity
SELECT DISTINCT Purpose#of#flight
FROM aviation_accidents

UPDATE aviation_accidents
SET Purpose#of#flight = 'UNKNOWN'
WHERE Purpose#of#flight IS NULL OR Purpose#of#flight='Unknown'


--	Setting Number#of#Engines = 2, as it is most common
UPDATE aviation_accidents
SET Number#of#Engines = 2
WHERE Number#of#Engines IS NULL


--				Add survival rate

ALTER TABLE aviation_accidents
ADD survival_rate float

UPDATE aviation_accidents
SET survival_rate = (Total#Minor#Injuries + Total#Serious#Injuries + Total#Uninjured) 
					/ (Total#Minor#Injuries + Total#Serious#Injuries + Total#Uninjured + Total#Fatal#Injuries) * 100
WHERE (Total#Minor#Injuries + Total#Serious#Injuries + Total#Uninjured + Total#Fatal#Injuries) != 0

DELETE FROM aviation_accidents
WHERE survival_rate IS NULL

SELECT *
FROM aviation_accidents
ORDER BY survival_rate


--				Add Total Injuries
ALTER TABLE aviation_accidents
ADD total_injuries float

UPDATE aviation_accidents
SET total_injuries = Total#Minor#Injuries + Total#Serious#Injuries + Total#Fatal#Injuries
