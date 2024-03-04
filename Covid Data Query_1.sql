Select * 
 From ProtfolioProjects..CovidDeathsNew$ 
 Where continent is not null	

Select location, date, total_cases, new_cases, total_deaths, population 
 From ProtfolioProjects..CovidDeathsNew$ 
 order by 1,2

--Total cases vs Total Deaths in India
Select location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float))*100 as DeathPercent
 From ProtfolioProjects..CovidDeathsNew$ 
 Where location like '%india%'
 and continent is not null
 order by 1,2

 --Countries with highest infection rate vs population 
Select location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
 From ProtfolioProjects..CovidDeathsNew$ 
 Where continent is not null
 group by location,population
 order by PercentPopulationInfected desc
 

 --Countries with Highest Death Count vs Population
Select location, Max(total_deaths) as TotalDeathCount
 From ProtfolioProjects..CovidDeathsNew$ 
 Where continent is not null
 group by location
 order by TotalDeathCount

 --Breaking down by Continent

 -- Continents with highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
 From ProtfolioProjects..CovidDeathsNew$ 
 Where continent is not null
 group by continent
 order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, Sum(new_cases) as Total_cases, Sum(new_deaths) as Total_deaths, sum(new_deaths)/ sum(nullif(new_cases,0))*100 as DeathPercent
 From ProtfolioProjects..CovidDeathsNew$ 
 where continent is not null
 and new_cases is not null
 group by date
 order by 1,2


 --Exploring Vaccinations Table

--Total population vs vaccination

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated -- using bigint since arithematic overflow error.
 From ProtfolioProjects..CovidDeathsNew$ as dea
 join ProtfolioProjects..CovidVaccinesNew$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Using CTE
With PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVacinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated -- using bigint since arithematic overflow error.
 From ProtfolioProjects..CovidDeathsNew$ as dea
 join ProtfolioProjects..CovidVaccinesNew$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select * , RollingPeopleVacinated/Population *100
from PopvsVac


--- TEMP TABLE(another approach)

Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated(
Continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVacinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated -- using bigint since arithematic overflow error.
 From ProtfolioProjects..CovidDeathsNew$ as dea
 join ProtfolioProjects..CovidVaccinesNew$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select * , RollingPeopleVacinated/Population *100
From #PercentPopulationVaccinated



--Creating VIEW for Data Visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated -- using bigint since arithematic overflow error.
 From ProtfolioProjects..CovidDeathsNew$ as dea
 join ProtfolioProjects..CovidVaccinesNew$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select * 
From PercentPopulationVaccinated
