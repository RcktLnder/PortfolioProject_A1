-- SELECT DATA
SELECT * 
FROM portfolioproject.covidvaccinations
WHERE continent is not NULL;

SELECT location, `date`, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent is not NULL
ORDER by 1, 2;

-- Looking at total cases vs total deaths

SELECT location, `date`, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
FROM coviddeaths
WHERE continent is not NULL
ORDER by 1, 2;

-- Looking at total cases vs Population

SELECT location, `date`, total_cases, population, (total_cases/population) *100 AS ConfirmedCases
FROM coviddeaths
WHERE continent is not NULL
ORDER by 1, 2;


-- Looking at Countries with the Highest Infection Rate compared to Population

SELECT location, MAX(total_cases) AS HighestInfectionCount,
 population,
 MAX((total_cases/population)) *100 AS PercentagePopInfected
FROM coviddeaths
WHERE continent is not NULL
GROUP By location, population
ORDER BY PercentagePopInfected DESC;


-- Showing Countries with the Highest Death Count per Population


SELECT location, MAX(cast(total_deaths as float))  AS TotalDeathCount
FROM coviddeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Breakdown by continent


SELECT continent, MAX(cast(total_deaths as float))  AS TotalDeathCount
FROM coviddeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Showing continent with highest death count

SELECT continent, MAX(cast(total_deaths as float))  AS TotalDeathCount
FROM coviddeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--  Global Numbers

SELECT  `date`, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as float)) AS total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases) *100 AS DeathPercentage
FROM coviddeaths
WHERE continent is not NULL
GROUP BY date
ORDER by 1, 2;


SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as float)) AS total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases) *100 AS DeathPercentage
FROM coviddeaths
WHERE continent is not NULL
ORDER by 1, 2;

SELECT * 
FROM covidvaccinations;


-- Looking at the Total Pop vs Vaccinations
-- SUM(CONVERT(int, vac...) is how to do it

SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.`date`) AS ROLLINGCOUNT
FROM coviddeaths dea
Join covidvaccinations vac
	ON dea.location = vac.location
    and dea.`date` = vac.`date`
WHERE dea.continent is not NULL
ORDER by 2,3;


-- USE CTE

WITH PopvsVac( continent, location, date, population, new_vaccinations, ROLLINGCOUNT)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS ROLLINGCOUNT
FROM coviddeaths dea
Join covidvaccinations vac
	ON dea.location = vac.location
    and dea.date= vac.date
WHERE dea.continent is not NULL
-- ORDER by 2,3
)
SELECT *, (ROLLINGCOUNT/population) * 100 AS PercentVaccinated
FROM PopvsVac;

-- TEMP TABLE( PUT AT TOP TO HELP VISUALS)

-- DROP Table if exists #PercentpopVaccinated
Create Table #PercentpopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
ROLLINGCOUNT numeric
)

INSERT into #PercentpopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS ROLLINGCOUNT
FROM coviddeaths dea
Join covidvaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER by 2,3

SELECT *, (ROLLINGCOUNT/population) * 100
FROM #PercentpopVaccinated;


-- Creating View to store for later

CREATE View PercentVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS ROLLINGCOUNT
FROM coviddeaths dea
Join covidvaccinations vac
	ON dea.location = vac.location
    and dea.date= vac.date
WHERE dea.continent is not NULL;
-- ORDER by 2,3












