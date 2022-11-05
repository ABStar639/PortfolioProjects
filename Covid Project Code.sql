select * 
from BigProject..CovidDeaths 
where continent is not null
order by 3,4;

select * 
from BigProject..CovidDeaths 
order by 3,4;

select *
from BigProject..CovidVaccination 
where continent is not null
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from BigProject..CovidDeaths
where continent is not null
order by 1,2;

---------------------------------------------------------Countries-----------------------------------------------------------------------
--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you get infected in a country
select location, date, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
from BigProject..CovidDeaths
where continent is not null
order by 1,2;

--Looking at Total Cases vs Population
--Shows percentage of population infected
select location, date, population, total_cases,  (total_cases/population)*100 as InfectPercentage
from BigProject..CovidDeaths
where continent is not null
order by 1,2;

---------------------------------------------------------------India----------------------------------------------------------------------
--Looking at Total Cases vs Total Deaths in India
--Likelihood of dying if you get infected by Covid in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from BigProject..CovidDeaths
where location like '%India'
order by 1,2;



--Looking at Total Cases vs Populations in India
select location, date, population, total_deaths, (total_cases/population)*100 as InfectPercentage
from BigProject..CovidDeaths
where location like '%India'
order by 1,2;

-------------------------------------------------------------------------------------------------------------------------------------------

--looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount,  max(total_cases/population)*100 as InfectPercentage
from BigProject..CovidDeaths
where continent is not null
group by location, population
order by InfectPercentage desc;

--looking at Countries with Highest Death Count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from BigProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-------------------------------------------------------------Contintents----------------------------------------------------------------------

--Total Cases vs Total Deaths
select continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from BigProject..CovidDeaths
where continent is not null
order by 1,2;

--Total Cases vs Population
select continent, date, total_cases, population, (total_cases/population)*100 as InfectPercentage
from BigProject..CovidDeaths
where continent is not null
order by 1,2;

--looking at Countries with Highest Infection Rate compared to Population
select continent, max(cast(total_cases as int)/population)*100 as MaxInfectPercentage
from BigProject..CovidDeaths
where continent is not null
group by continent
order by MaxInfectPercentage desc;

--looking at Countries with Highest Death Rate compared to Population
select continent, max(cast(total_deaths as int)/population)*100 as MaxDeathPercentage
from BigProject..CovidDeaths
where continent is not null
group by continent
order by MaxDeathPercentage desc;

---------------------------------------------------------Asia-------------------------------------------------------
--Total Cases vs Total Deaths
select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from BigProject..CovidDeaths
where continent like '%Asia'
order by 1,2;


--Total Cases vs Population
select continent, location, date, total_cases, population, (total_cases/population)*100 as InfectPercentage
from BigProject..CovidDeaths
where continent like '%Asia'
order by 1,2;
----------------------------------------------------------------------------------------------------------------------------------------------

--Showing the coninents with highest infection count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from BigProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

--Showing the coninents with respective death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from BigProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-----------------------------------------------------------------------Global Numbers--------------------------------------------
--World with daily death per infection
select date, sum(new_cases) as TotalInfected, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as InfectDeathPercentage
from BigProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

--World's total death per infection till September 2021
select sum(new_cases) as TotalInfected, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as InfectDeathPercentage
from BigProject..CovidDeaths
where continent is not null
order by 1,2;

select * 
from BigProject..CovidVaccination
where continent is not null;

-----------------------------------------------------------Joining death and vaccination table-------------------------------------------------
select *
from BigProject..CovidDeaths dea
join BigProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date;

-------------------------------------------------------Looking at toal population vs vaccinations-----------------------------------------
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
from BigProject..CovidDeaths dea
join BigProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--Looking at population vs vaccinations--
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccination
from BigProject..CovidDeaths dea
join BigProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--Looking at population vs total vaccination
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccination
from BigProject..CovidDeaths dea
join BigProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

---Use CTE
with PopVsVac (Continent, Location, Date, Population, New_Vaccincations, RollingPeopleVaccination)
as 
(select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccination
from BigProject..CovidDeaths dea
join BigProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
select *, (RollingPeopleVaccination/Population)*100 from PopVsVac;

--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccination
from BigProject..CovidDeaths dea
join BigProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
select *, (RollingPeopleVaccination/Population)*100 from #PercentPopulationVaccinated;

--Creating View to store data for later visualisation
create view PercenPopulationVaccinated as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccination
from BigProject..CovidDeaths dea
join BigProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

select * from PercenPopulationVaccinated;