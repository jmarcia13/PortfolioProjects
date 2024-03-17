Select *
From CovidPortfolioPoject..[Covid Deaths]
Order by 3,4


--Select *
--From CovidPortfolioPoject..[Covid Vaccinations]
--Order by 3,4

-- Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population 
from CovidPortfolioPoject..[Covid Deaths]
Order by 1,2




-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of dying if you attacrt Covid in your country 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidPortfolioPoject..[Covid Deaths]
where location like '%Canada%'
Order by 1,2





-- Looking at total cases vs population-- 
-- Shows what percentage of population got covid 


Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
from CovidPortfolioPoject..[Covid Deaths]
-- where location like '%Canada%' 
Order by 1,2


-- Looking at countries with highest infection rate compared to population 


Select location, population, MAX (total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected 
from CovidPortfolioPoject..[Covid Deaths]
 --where location like '%Canada%' 
Group by population, location 
Order by PercentPopulationInfected desc


-- Showing countries with the Highest Death Count Per Population 

Select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from CovidPortfolioPoject..[Covid Deaths]
 --where location like '%Canada%'
 Where continent is not null 
Group by location 
Order by TotalDeathCount desc


-- LET'S BREAK DOWN BY CONTINENT --



Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from CovidPortfolioPoject..[Covid Deaths]
 --where location like '%Canada%'
Where continent is not null 
Group by continent
Order by TotalDeathCount desc



-- Showing continents with the highest death counts per population -- 

Select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from CovidPortfolioPoject..[Covid Deaths]
 --where location like '%Canada%'
Where continent is null 
Group by location
Order by TotalDeathCount desc

-- GLOBAL NUMBERS -- 

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum (cast(new_deaths as int))/SUM (New_Cases)*100  as DeathPercentage
from CovidPortfolioPoject..[Covid Deaths]
--where location like '%Canada%'
where continent is not null 
--group by date
Order by 1,2



-- Looking at total population vs vaccinations 


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
From [Covid Deaths] dea as RollingPeopleVaccinated
, -- (RollingPeopleVaccinated
join [Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Order by 2,3


-- CTE 
With PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From [Covid Deaths] dea  
join [Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Temp Table--

 
DROP TABLE if exists #PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated 
(
    Continent nvarchar(255), 
    Location nvarchar (255), 
    Date datetime, 
    Population numeric, 
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric  
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Covid Deaths] dea  
join [Covid Vaccinations] vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 

-- Calculate percentage of population vaccinated
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated 

-- Drop the temporary table if no longer needed
-- DROP TABLE #PercentPopulationVaccinated;


-- Stored Data to Visualize later -- 
Select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from CovidPortfolioPoject..[Covid Deaths]
 --where location like '%Canada%'
Where continent is null 
Group by location
Order by TotalDeathCount desc


-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Covid Deaths] dea  
join [Covid Vaccinations] vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 



Select *
From PercentPopulationVaccinated