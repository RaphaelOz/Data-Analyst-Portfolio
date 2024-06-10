SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- SELECT Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows the LIKElihood of dying if you contract covid in Australia
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%australia%'
ORDER BY 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population is infected
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%australia%'
ORDER BY 1, 2


-- Looking at Countries with the Highest Infection Rate compared to the Population.
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY infection_rate DESC

-- Looking at Countries with the Highest infection rate compared to the Population with a Population higher than 1 million.
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE population > 1000000
GROUP BY location, population
ORDER BY infection_rate DESC

-- Looking at the Countries with the Highest Death Count.
SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC


-- Breaking down by Continent.

-- Showing the Continents with the Highest Death Count
SELECT continent, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC


-- Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, (SUM(CAST(new_deaths AS int))/ SUM(new_cases))*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) 
	OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- USING CTE
WITH PopVsVac 
AS 
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) 
	OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopVsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) 
	OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) 
	OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3



-- Visualisation for PowerBI
-- Table 1. 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
--FROM PortfolioProject..CovidDeaths
----WHERE location LIKE '%states%'
--WHERE location = 'World'
----GROUP BY date
--ORDER BY 1,2


-- Table 2. 

-- We take these out AS they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc


-- Table 3.

SELECT  continent, location, population, MAX(total_cases) AS highest_infection_count,  
	Max((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY percent_population_infected desc




-- Table 4.


SELECT continent, location, population,date, MAX(total_cases) AS highest_infection_count,  
	Max((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY continent, location, population, date
ORDER BY percent_population_infected desc
