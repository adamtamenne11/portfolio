-- select data that we are goin to use
select Location, date, total_cases, new_cases, total_deaths, population
from covid.coviddeaths
order by 1,2;

-- total cases vs. total deaths (likely of death if caught covid)
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DP
from covid.coviddeaths
where location like '%states%'
order by 1,2;

-- total cases vs. population
select Location, date, Population, total_cases, (total_cases/population)*100 as PopulationInfected
from covid.coviddeaths
where location like '%states%'
order by 1,2;

-- highest infection rate
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentInfected
from covid.coviddeaths
-- where location like '%states%'
group by Location, Population
order by PercentInfected desc;

-- Showing countries with highest death count
select Location, MAX(Total_deaths) as TotalDeathCount
from covid.coviddeaths
group by location
order by TotalDeathCount;

-- by continent
select Location, MAX(Total_deaths) as TotalDeathCount
from covid.coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- GLOBAL (new cases vs. new deaths)
select date, SUM(new_cases), SUM(new_deaths) -- , (total_deaths/total_cases)*100 as DP
from covid.coviddeaths
where continent is not null
group by date
order by 1,2;


-- population vs. vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from coviddeaths dea
join covid.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 3,4;


-- use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from coviddeaths dea
join covid.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null)

select * from PopvsVac;