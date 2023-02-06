select *
from PortfolioProject..CovidDeaths

select *
from PortfolioProject..CovidVaccinations

select location, date, population, total_cases, total_deaths
from PortfolioProject..CovidDeaths

-- số ca mắc covid và tỷ lệ trên tổng số dân
select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths

-- số ca mắc covid và tỷ lệ chết trên tổng số ca mắc
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'Vietnam'
order by 1,2

-- tình hình hiện tại
select location, max(total_cases/population)*100 as 'CasesPercentage', population
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 2 desc

-- tỷ lệ chết trên số người mắc covid hiện tại
select location, max(cast(total_deaths as int)) as Deaths, max(total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc

-- Phân chia theo continent
select *
from PortfolioProject..CovidDeaths
where continent is null

-- total_deaths, total_cases, population hiện tại theo continent
select location, population, max(total_cases) as TotalCases, max(total_deaths) as TotalDeaths, max(total_cases/population)*100 as CasesPercentage, max(total_deaths/total_cases) as DeathsPercentage
from PortfolioProject..CovidDeaths
where continent is null
group by location, population
order by 1 

-- tình hình thế giới theo date
select date, location, population, new_cases, total_cases, total_deaths, (total_cases/population)*100 as CasesPercentage, (total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
where location like 'world'
order by 1

-- join 2 table by CTE
with PopVsVac
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, RollingPeopleVaccinated/population*100
from PopVsVac
where location like 'Vietnam'

-- create table
drop table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into  #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from  #PercentPopulationVaccinated