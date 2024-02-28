-- Select the data we are going to work with
-- Note: when the continent column is null then the location column contains continent values, so I added the following statement to each query to avoid getting data for continents when selecting location:
-- WHERE continent IS NOT NULL

SELECT continent, location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NULL
ORDER BY location, date DESC;

-- Fixing data type for total_cases from 'varchar' to 'int' so we don't get errors when performing arithmatic calculations

ALTER TABLE PortfolioProject1..CovidDeaths
ALTER COLUMN total_cases INT;

-- Total Cases versus Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE location='Israel' AND continent IS NOT NULL
ORDER BY location, date;
-- The probability of dying if one contracts COVID in Israel as of January 2024 is 0.26%

-- Total cases versus Population
-- Shows what percentage of the population has COVID

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Percentage_Population_Infected
FROM PortfolioProject1.dbo.CovidDeaths
WHERE location='Israel' AND continent IS NOT NULL
ORDER BY location, date;
-- Approximately 51% of the population is infected with COVID as of January 2024

-- Highest Infection Rate compared to Population

SELECT Location, MAX(total_cases) AS Highest_Infection_Count, population, MAX((total_cases/population))*100 AS Percentage_Highest_Population_Infected
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percentage_Highest_Population_Infected DESC;
-- The country with the highest percentage of population infected is Brunei, with around 75% of the population infected

-- Total death count by country

SELECT Location, MAX(cast(total_deaths as INT)) AS Highest_Death_Count
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Highest_Death_Count DESC;
-- Note: using the 'cast' function to convert total_deaths from VARCHAR to INT since the data returned is incorrect due to SQL not considering the total_death values as numbers

-- Total death count per continent

SELECT location, MAX(cast(total_deaths as INT)) AS Highest_Death_Count
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NULL 
AND location NOT IN ('World', 'High income', 'Upper middle income', 'Lower middle income','European Union', 'Low income')
GROUP BY location
ORDER BY Highest_Death_Count DESC;
-- Note: if the 'continent' column is not null the 'location' column contains the correct numbers for the continents, but it also contains values we don't need (e.g. High income, Low income, European Union) so I excluded them with the WHERE statement

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject1.dbo.CovidDeaths
--WHERE location='Israel' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Vaccinations data

select * from PortfolioProject1..CovidVaccinations;

-- Total population versus total vaccinations 

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.people_vaccinated,
	(people_vaccinated/population)*100 AS PercentagePeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS deaths
JOIN PortfolioProject1..CovidVaccinations AS vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
WHERE deaths.continent IS NOT NULL
ORDER BY location, date;

-- Create a view to store data for visualizations

DROP VIEW percentage_people_vaccinated;
CREATE VIEW percentage_people_vaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.people_vaccinated,
	(people_vaccinated/population)*100 AS PercentPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS deaths
JOIN PortfolioProject1..CovidVaccinations AS vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
WHERE deaths.continent IS NOT NULL
--ORDER BY location, date;
