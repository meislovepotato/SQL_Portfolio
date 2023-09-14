select *
from portfolioproject..coviddeaths
order by 3,4
select *
from portfolioproject..covidvaccination
order by 3,4


-- Select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..coviddeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
where continent is not null
where location like '%states%'
order by 1,2


-- changing data type 
ALTER TABLE portfolioproject..coviddeaths
ALTER COLUMN total_deaths float;
ALTER TABLE portfolioproject..coviddeaths
ALTER COLUMN population float;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as percentofpopulationinfected
from portfolioproject..coviddeaths
where continent is not null
where location like '%states%'
order by 1,2


-- looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentofpopulationinfected
from portfolioproject..coviddeaths
where continent is not null
group by location, population
order by percentofpopulationinfected desc


-- Showing Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
where continent is not null
group by location, population
order by totaldeathcount desc


-- Lets Break things down by Continent
-- Showing the continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc


-- Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
where continent is not null
order by 1,2



-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


-- Use Temp Table

create table #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

drop view if exists percentpopulationvaccinated
-- Creating view to store data for later visualizations
CREATE VIEW percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from percentpopulationvaccinated


/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

