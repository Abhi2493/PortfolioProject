Select *
from PortfolioProject2..CovidDeaths
order by 3,4

Select *
from PortfolioProject2..CovidVaccinations
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject2..CovidDeaths
order by 1,2



-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 AS Deathpercentage
from PortfolioProject2..CovidDeaths
order by 1,2

--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 AS Deathpercentage
from PortfolioProject2..CovidDeaths
where location  = 'India'
and continent is not null
order by 1,2


---Looking at Total Cases vs Population
--- Shows what percentage of population got covid

Select location, date, Population, total_cases, (convert(float,total_cases)/convert(float,population))*100 as PopulationPercentInfected
from PortfolioProject2..CovidDeaths
where location = 'India'
order by 1,2


--- Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, Max(total_cases) as HighestInfectionCount, Max((convert(float,total_cases)/convert(float,population)))*100 as PopulationPercentInfected
from PortfolioProject2..CovidDeaths
--where location = 'India'
group by location, Population
order by PopulationPercentInfected desc



---Showing Countries with Highest Death Count per Population

Select location, Max(Total_deaths) as TotalDeathCount
from PortfolioProject2..CovidDeaths
--where location = 'India'
where continent is not null
group by location
order by TotalDeathCount desc



---Let's break things down by Continent

---Showing Continents with Highest Death Count per Population

Select Continent, Max(Total_deaths) as TotalDeathCount
from PortfolioProject2..CovidDeaths
--where location = 'India'
where continent is not null
group by Continent
order by TotalDeathCount desc


---Global Numbers

Select date, sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, 
sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage

from PortfolioProject2..CovidDeaths
--where location  = 'India'
where continent is not null
group by date
order by 1,2


---Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) as CountNew_vaccinations
from PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac as

(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) as CountNew_vaccinations
from PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null)

select *, (cast(CountNew_vaccinations as float)/cast(population as float))*100
from PopvsVac


---Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(continent nvarchar(255), 
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric,
CountNew_vaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) as CountNew_vaccinations
from PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3

select *, (cast(CountNew_vaccinations as float)/cast(population as float))*100
from #PercentPopulationVaccinated


-- Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) as CountNew_vaccinations
from PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select * 
from PercentPopulationVaccinated