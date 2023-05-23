-- 1. Selecting the data to be used
SELECT
	location AS 'Location',
	date AS 'Date',
	ISNULL(total_cases, 0) AS 'Total Cases',
	new_cases AS 'New Cases',
	ISNULL(total_deaths, 0) AS 'Total Deaths',
	population AS 'Population'
FROM
	MortesCovid$
ORDER BY
	location, date


-- 2. Looking at Total Cases vs Total Deaths in Brazil over time

SELECT
	location AS 'Location',
	population as 'Population',
	FORMAT(date, 'yyy/MM/dd') AS 'Date',
	ISNULL(total_cases, 0)  AS 'Total Cases',
	ISNULL(total_deaths, 0) AS 'Total Deaths',
	ISNULL(FORMAT(CONVERT(FLOAT, total_deaths)/CONVERT(FLOAT,total_cases), '0.00%'), '0.00%') AS 'Death Rate (%)'
FROM
	MortesCovid$
WHERE
	Location LIKE 'Brazil'
ORDER BY
	location, date

-- Nowadays (18/05/2023) the COVID-19 death rate in Brazil is 1,87%

SELECT TOP(1)
	FORMAT(date, 'yyyy/MM/dd') AS 'Date', 
	FORMAT(CONVERT(FLOAT, total_deaths)/CONVERT(FLOAT, total_cases), '0.00%') AS 'Death Ratio (%)'
FROM
	MortesCovid$
WHERE
	Location = 'Brazil'
ORDER BY
	CONVERT(FLOAT, total_deaths)/CONVERT(FLOAT, total_cases) DESC

-- The most critic COVID-19 death ratio in Brazil happened in 2020 may 1st, when it was close to 7,00%


-- 3. Looking at Total Cases vs Population in Brazil over time

SELECT
	location AS 'Location',
	FORMAT(date, 'yyy/MM/dd') AS 'Date',
	population AS 'Population',
	ISNULL(total_cases, 0) AS 'Total Cases',
	ISNULL(FORMAT(CONVERT(FLOAT, total_cases)/CONVERT(FLOAT, population), '0.00%'), '0.00%') AS 'Infection Rate (%)'
FROM
	MortesCovid$
WHERE
	Location = 'Brazil'
ORDER BY
	location, date

-- By the time this analysis had been conducted, 17,42% of the brazilian population had gotten COVID-19 at some point


-- 4. Looking at the 10 countries with highest Infetcion Rate compared to Population
SELECT TOP(10)
	RANK() OVER(ORDER BY MAX(CONVERT(FLOAT, total_cases)/CONVERT(FLOAT, population)) DESC) AS 'Ranking',
	location AS 'Location',
	population AS 'Population',
	MAX(CONVERT(FLOAT, total_cases)) AS 'Higest Infection Count',
	FORMAT(MAX(CONVERT(FLOAT, total_cases)/CONVERT(FLOAT, population)), '0.00%') AS 'Infection Rate (%)'
FROM
	MortesCovid$
WHERE
	continent IS NOT NULL
GROUP BY
	location, population
ORDER BY
	MAX(CONVERT(FLOAT, total_cases)/CONVERT(FLOAT, population)) DESC

-- What's Brazil's position in this ranking?
CREATE VIEW vwRankingIR AS

SELECT
	RANK() OVER(ORDER BY MAX(CONVERT(FLOAT, total_cases)/CONVERT(FLOAT, population)) DESC) AS 'Ranking',
	location AS 'Location',
	population AS 'Population',
	MAX(CONVERT(FLOAT, total_cases)) AS 'Higest Infection Count',
	FORMAT(MAX(CONVERT(FLOAT, total_cases)/CONVERT(FLOAT, population)), '0.00%') AS 'Infection Rate (%)'
FROM
	MortesCovid$
WHERE
	continent IS NOT NULL
GROUP BY
	location, population

SELECT
	Ranking,
	Location,
	[Higest Infection Count],
	[Infection Rate (%)]
FROM
	vwRankingIR
WHERE 
	location = 'Brazil'

-- Brazil stands in the 101st position when compared to other countries (17,42% infection rate)


-- 5. Looking at the 10 countries with highest Death Rate compared to Total Cases
SELECT 
	RANK() OVER(ORDER BY MAX(CONVERT(FLOAT, total_deaths))/MAX(CONVERT(FLOAT, total_cases)) DESC) AS 'Ranking',
	location AS 'Location',
	MAX(CONVERT(FLOAT, total_cases)) AS 'Total Cases',
	MAX(CONVERT(FLOAT, total_deaths)) AS 'Higest Death Count',
	FORMAT(MAX(CONVERT(FLOAT, total_deaths))/MAX(CONVERT(FLOAT, total_cases)), '0.00000%') AS 'Death Rate (%)'
FROM
	MortesCovid$
WHERE 
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	MAX(CONVERT(FLOAT, total_deaths))/MAX(CONVERT(FLOAT, total_cases)) DESC

-- But what about Brazil? Where does Brazil stand when compared to other countries?
CREATE VIEW vwRankingDR AS

SELECT 
	RANK() OVER(ORDER BY MAX(CONVERT(FLOAT, total_deaths))/MAX(CONVERT(FLOAT, total_cases)) DESC) AS 'Ranking',
	location AS 'Location',
	MAX(CONVERT(FLOAT, total_cases)) AS 'Total Cases',
	MAX(CONVERT(FLOAT, total_deaths)) AS 'Higest Death Count',
	FORMAT(MAX(CONVERT(FLOAT, total_deaths))/MAX(CONVERT(FLOAT, total_cases)), '0.00%') AS 'Death Rate (%)'
FROM
	MortesCovid$
WHERE 
	continent IS NOT NULL
GROUP BY
	location, population

SELECT
	Ranking,
	Location,
	[Higest Death Count],
	[Death Rate (%)]
FROM
	vwRankingDR
WHERE 
	location = 'Brazil'

-- Brazil stands in the 49th position when compared to other countries (1,87% death versus cases rate)


-- 6. Looking at the 10 countries with highest Death Count
SELECT TOP(10)
	location AS 'Location',
	FORMAT(MAX(CONVERT(FLOAT, total_deaths)), 'N') AS 'Higest Death Count'
FROM
	MortesCovid$
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	MAX(CONVERT(FLOAT, total_deaths)) DESC

-- Altough Brazil stands in intermediary positions when talking about the death versus cases ratio, in the absolute death count it is the 2nd place


-- 7. Death count by Continent
SELECT
	location AS 'Continent',
	FORMAT(MAX(CONVERT(FLOAT, total_deaths)), 'N') AS 'Death Count'
FROM
	MortesCovid$
WHERE
	continent IS NULL
	AND
	location IN ('North America', 'Europe', 'Asia', 'South America', 'Africa', 'Oceania')
GROUP BY
	location
ORDER BY
	MAX(CONVERT(FLOAT, total_deaths)) DESC

-- Europe was the continent with the biggest death count (2.061.428) 

-- Now the death ratio when comparing death count versus population
SELECT
	RANK() OVER(ORDER BY MAX(CONVERT(FLOAT, total_deaths)/CONVERT(FLOAT, population)) DESC) AS 'Ranking',
	location AS 'Continent',
	population AS 'Population',
	MAX(CONVERT(FLOAT, total_deaths)) AS 'Death Count',
	FORMAT(MAX(CONVERT(FLOAT, total_deaths)/CONVERT(FLOAT, population)), '0.00%') AS 'Death Rate (%)'
FROM
	MortesCovid$
WHERE
	continent IS NULL
	AND
	location IN ('North America', 'Europe', 'Asia', 'South America', 'Africa', 'Oceania')
GROUP BY
	location, population
ORDER BY
	MAX(CONVERT(FLOAT, total_deaths)/CONVERT(FLOAT, population)) DESC

-- Shouth America has the biggest death ratio (~ 0.31%)

-- 8. Now looking at global numbers

SELECT
	FORMAT(SUM(CONVERT(FLOAT, new_cases)), 'N') AS 'Total Cases',
	FORMAT(SUM(CONVERT(FLOAT, new_deaths)), 'N') AS 'Total Deaths',
	FORMAT(CONVERT(FLOAT,SUM(CONVERT(FLOAT, new_deaths)))/CONVERT(FLOAT, SUM(CONVERT(FLOAT, new_cases))), '0.00%') AS 'Death Rate (%)'
FROM
	MortesCovid$

-- Globally there have been 3.248.689.566 registered cases, 28.948.137 registered deaths , resulting in a death ratio of 0,89%


-- 9. Now let's take a look at the vaccination numbers (Population vs Vaccination) over time

-- Using CTE

WITH PopVac AS  (
SELECT
	M.location AS 'Location',
	M.date AS 'Date',
	M.population AS 'Population',
	ISNULL(V.new_vaccinations, 0) AS 'New Vaccinations',
	ISNULL(SUM(CONVERT(FLOAT, V.new_people_vaccinated_smoothed)) OVER(PARTITION BY M.location ORDER BY M.location, M.date), 0) AS 'Total Vaccinations'
FROM
	MortesCovid$ M
LEFT JOIN
	VacinasCovid$ V
	ON M.date = V.date
	AND
	M.location = V.location
WHERE
	M.continent IS NOT NULL
)

SELECT 
	*,
	ISNULL(FORMAT(CONVERT(FLOAT,[Total Vaccinations])/CONVERT(FLOAT, Population), '0.00%'), '0.00%') AS 'Population Vaccinated (%)'
FROM 
	PopVac
ORDER BY
	Location, Date

-- Using a Temp Table
CREATE TABLE tPopVac (
	Location NVARCHAR(225),
	Date DATETIME,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	Total_Vaccinations NUMERIC,
)

INSERT INTO tPopVac
SELECT
	M.location AS 'Location',
	M.date AS 'Date',
	M.population AS 'Population',
	ISNULL(V.new_vaccinations, 0) AS 'New Vaccinations',
	ISNULL(SUM(CONVERT(FLOAT, V.new_people_vaccinated_smoothed)) OVER(PARTITION BY M.location ORDER BY M.location, M.date), 0) AS 'Total Vaccinations'
FROM
	MortesCovid$ M
LEFT JOIN
	VacinasCovid$ V
	ON M.date = V.date
	AND
	M.location = V.location
WHERE
	M.continent IS NOT NULL
	
SELECT 
	*,
	ISNULL(FORMAT(CONVERT(FLOAT,[Total_Vaccinations])/CONVERT(FLOAT, Population), '0.00%'), '0.00%') AS 'Population Vaccinated (%)'
FROM 
	tPopVac
ORDER BY
	Location, Date

	