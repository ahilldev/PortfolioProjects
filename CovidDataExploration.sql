-- Select data that will be used 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project..CovidDeaths$
ORDER BY 1,2


-- Looking at total cases vs total deaths
-- Shows the amount of people who contracted covid and died in your country
-- I queried US data because that is where I live
--USE CTE to simplify creating views for later visualizations

with CasesvsDeaths(location, date, total_cases, total_deaths, DeathPercentage)
as
(
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project..CovidDeaths$
WHERE location like '%states%'

)
SELECT *
FROM CasesvsDeaths;

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid
-- I querired US because that is where I live
--USE CTE to simplify creating views for later visualizations

with CasesvsInfected(location, date, population, total_cases, PercentPopulationInfected)
as
(
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM Project..CovidDeaths$
WHERE location like '%states%'
)
SELECT *
FROM CasesvsInfected;

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM Project..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM Project..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population
with HighestDeathCount(location, TotalDeathCount)
as
(
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Project..CovidDeaths$
WHERE continent is not null
GROUP BY Location
--ORDER BY TotalDeathCount desc
)
SELECT *
FROM HighestDeathCount;




--	BREAKING THINGS DOWN BY CONTINIENT --

--Showing continents with highest death counts per population

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM Project..CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


--Looking at Continents with Highest Infection Rate compared to Population

SELECT continent,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Project..CovidDeaths$
GROUP BY continent, population
ORDER BY PercentPopulationInfected desc

-- GLOBAL NUMBERS -- 

-- Total cases and deaths sorted by date

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths as)/SUM(New_Cases)*100 as DeathPercentage
FROM Project..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Total world population cases and deaths as of May 2023

SET ANSI_WARNINGS OFF
SET ARITHABORT OFF
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/ (SUM(new_cases))*100 as DeathPercentage
FROM Project..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--Join the covid death and covid vaccinations tables
-- Look at total population vs total vaccinations
--USE CTE to simplify query

with PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
FROM Project..CovidDeaths$ dea
JOIN Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

)

SELECT *, (RollingPeopleVaccinated/population)* 100 as PercentageVaccinated 
FROM PopvsVac

--Creating views to store data for later visualizations

Create view PopvsVac as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
FROM Project..CovidDeaths$ dea
JOIN Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

---------------

Create view CasesvsDeaths as 
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project..CovidDeaths$
WHERE location like '%states%'

------------

Create view CasesvsInfected as 
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project..CovidDeaths$
WHERE location like '%states%'

Create view HighestInfected as 
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Project..CovidDeaths$
GROUP BY Location, Population

Create view HighestDeathCount as
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Project..CovidDeaths$
WHERE continent is not null
GROUP BY Location









