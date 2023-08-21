--SELECT * 
--FROM CovidDeaths
--order by 3,4

--SELECT * 
--FROM CovidVaccinations
--order by 3,4

--SELECT location, date, total_cases, new_cases, total_deaths, population 
--FROM CovidDeaths
--order by 1,2

-- total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercantage
FROM CovidDeaths
where continent is not null AND location = 'Indonesia'
order by 1,2


-- total cases vs population
SELECT location, date, population, total_cases,  (total_cases/population)*100 as CasesPerPopulation
FROM CovidDeaths
where continent is not null
--where location = 'Indonesia'
order by 1,2

-- Country with Highest infection rate compared to population
SELECT location, population, MAX(total_cases) as TotalInfectedMAX, MAX((total_cases/population))*100 as CasesPerPopulation
FROM CovidDeaths
where continent is not null
group by location, population
order by 4 DESC

-- Country with highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
where continent is not null
group by location
order by 2 DESC

-- Total DEATH by continent
-- Showing Continent with Highest Death Count
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
where continent is null
group by location
order by 2 DESC

-- Global Number

SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_death, sum(new_deaths)/sum(new_cases)*100 as DeathPercantage
FROM CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total Global Number
SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_death, sum(new_deaths)/sum(new_cases)*100 as DeathPercantage
FROM CovidDeaths
where continent is not null
order by 1,2

-- population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
from CovidDeaths dea
join CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
from CovidDeaths dea
join CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (New_vaccination/Population)*100 
from PopvsVac

--temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
from CovidDeaths dea
join CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

select * from #PercentPopulationVaccinated

-- Creating view for data visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated