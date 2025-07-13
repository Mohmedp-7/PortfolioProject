USE PortfolioProject;
GO


Select * 
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4


--Select * 
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows percentage of death if you contracted covid 19 in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as death_percentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2


-- Shows what percentage got covid 19 in the United States

Select Location, date, population,total_cases, (total_cases/population)* 100 as percent_confirmed_positive
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, max(total_cases) as highest_infection_count, max((total_cases/population)) * 100 as percent_confirmed_positive   
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location, Population
order by percent_confirmed_positive desc

-- Showing countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as percent_confirmed_positive  
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by percent_confirmed_positive desc


-- Break it down by continent

--Showing continents with highest deathcounts

--Select location, MAX(cast(Total_deaths as int)) as percent_confirmed_positive  
--From PortfolioProject..CovidDeaths$
--Where continent is  null
--Group by location
--order by percent_confirmed_positive desc

Select continent, MAX(cast(Total_deaths as int)) as percent_confirmed_positive  
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by percent_confirmed_positive desc


-- Global Numbers by date 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as death_percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
order by 1,2

-- Global Numbers 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as death_percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations

Select *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_count_vacinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent,Location,Date,Population, New_Vaccinations, rolling_count_vacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rolling_count_vacinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (rolling_count_vacinated/Population)*100
From PopvsVac


-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_count_vacinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rolling_count_vacinated
From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (rolling_count_vacinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for tableau
DROP VIEW IF EXISTS PercentPopulationVacinated
GO 

Create View PercentPopulationVacinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.date) as rolling_count_vacinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
