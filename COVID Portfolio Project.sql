/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from PortfolioProject.dbo.Covid_Deaths
Where continent is not null 
order by 3, 4

--select *
--from PortfolioProject.dbo.Covid_Vaccsinations
--order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_Deaths
order by 1, 2

--Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
Where location like '%states%'
order by 1, 2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
order by 1, 2

--Countries with Highest Infection Rate compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


--Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
----Where location like '%states%'
Where continent is not null 
group by date	
order by 1, 2


--Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine


select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccsinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null 
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccsinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null 
)
select*,(RollingPeopleVaccinated/population)/100
from PopvsVac


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccsinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create view PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccsinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentagePopulationVaccinated
