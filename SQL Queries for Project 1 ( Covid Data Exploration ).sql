--Exploring a Covid 19 Dataset from 'Our World in Data ' website.
-- The data I analyzed is from February 24 2020 to April 30 2021.
--Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types

-- 1. Viewing all data from the Covid Deaths Table
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- 2. Viewing all data from the Covid Vaccinations Table
SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

-- 3. Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you get infected with Covid in Canada.
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases * 100 ) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada' AND continent is not null
ORDER BY 1,2

-- 4. Looking at Total Cases vs Total Population
--Shows what percent of population has been infected with Covid in Canada
SELECT location, date, total_cases, population, (total_cases / population * 100 ) AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada' AND continent is not null
ORDER BY 1,2

-- 5. Looking at Countries with Highest Infection Rates compared to their Population
SELECT location, SUM(new_cases) AS TotalCases, population, (SUM(new_cases) / population * 100 ) AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectionPercentage DESC

-- 6. Looking at Countries with Highest Death Count
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 7. Looking at Countries with Highest Death Percentage per Population
SELECT location, population, MAX(Cast(total_deaths as int)) AS TotalDeathCount, ( MAX(Cast(total_deaths as int)) / population * 100 ) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY DeathPercentage DESC

-- 8. Looking at Continents with Highest Death Count
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- 9. Looking at Global Cases and Deaths for Each Day
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- 10. Looking at Total Global Cases and Deaths from Feb 24 2020 upto April 30 2021
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 

-- 11. Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- 12. Looking at Total Population vs Vaccination Percentage using a CTE
-- We do this to use  the alias RollingVacciantionCount column in our calculations.
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null)
--ORDER BY 2,3

SELECT *, (RollingVaccinationCount / Population )*100 AS VacPerc
FROM PopVsVac

-- 13. Looking at Total Population vs Vaccination Percentage using a TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated --This is useful when you want to do changes to your temp table.
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingVaccinationCount / Population )*100 AS VacPerc
FROM #PercentPopulationVaccinated

-- 14. Creating a View 
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated

