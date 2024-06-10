SELECT continent, location, date, population, new_cases, new_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
	AND location NOT IN ('World', 'European Union', 'International')	-- Removing the above to have location as country
	AND location NOT IN('Greenland', 'Turkmenistan')					-- Removing Greenland and Turkmenistan due to no value
ORDER BY continent, location