Select *
From PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null
order by 1,2

-- Looking at Total Cases VS the population
-- Shows what percentage of population got Covid

Select location, date, Population, total_cases, (total_cases/population)*100 as Percenatage_Population_Infected
From PortfolioProject..CovidDeaths
Where location like '%India%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to the population

Select location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percentage_Population_Infected
From PortfolioProject..CovidDeaths
-- Where location like '%India%'
where continent is not null
Group by location, Population
order by Percentage_Population_Infected desc

-- Showing Countries with highest death count per population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%India%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break things down by continent	



-- Showing the continent with highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%India%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is not null
-- Group by date
order by 1,2


-- Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

 -- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
 as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac 



-- TEMP Table


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 


-- Creating View to store data for later visualizations 

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentagePopulationVaccinated
