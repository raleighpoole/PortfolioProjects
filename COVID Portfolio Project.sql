SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows percentage chance of dying if you contract covid in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 death_rate
FROM CovidDeaths
WHERE Location LIKE '%states' AND continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Population
--Show what percent of total population got Covid

SELECT Location, Date, population, total_cases, (total_cases/population)*100 Population_perc_contracted
FROM CovidDeaths
WHERE continent is not null AND Location LIKE 'mexico'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT Location, population, Max (total_cases) HighestInfectionCount
, MAX((total_cases/population))*100 Population_perc_contracted
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY Population_perc_contracted DESC

--Looking at Countries with highest death count per population

SELECT Location, Max(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Breaking things down by continent

SELECT location, Max(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT Date, SUM(new_cases) TotalCases, SUM(CAST(new_deaths as int)) TotalDeaths, SUM (cast(new_deaths as int))/SUM(new_cases)*100 DeathRate
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2 

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE

WITH PopulationVsVaccination (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopulationvsVaccination



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

CREATE VIEW DeathRateIfContracted as
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 death_rate
FROM CovidDeaths
WHERE Location LIKE '%states' AND continent is not null
ORDER BY 1,2

CREATE VIEW PercentGotCovid_Mex as
SELECT Location, Date, population, total_cases, (total_cases/population)*100 Population_perc_contracted
FROM CovidDeaths
WHERE continent is not null AND Location LIKE 'mexico'
ORDER BY 1,2

CREATE VIEW HighestDeathCount as
SELECT TOP (10) Location, Max(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

CREATE VIEW RollingPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent = 'Europe'
ORDER BY 2,3
