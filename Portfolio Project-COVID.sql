
SELECT * FROM [Portfolio project]..CovidDeaths
 ORDER BY 3,4

SELECT * FROM [Portfolio project]..CovidVaccination
ORDER BY 1, 2

-- Total Case vs Total Death

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio project]..CovidDeaths
WHERE Location LIKE '%Ethiopia%'
 ORDER BY 1, 2

 -- Total Case vs Population
 
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
FROM [Portfolio project]..CovidDeaths
WHERE Location LIKE '%Ethiopia%'
 ORDER BY 1, 2

 -- Countries with highest infection rate
SELECT Location,population, MAX(total_cases), MAX( (total_cases/population))*100 as PopulationPercentageInfected
FROM [Portfolio project]..CovidDeaths
GROUP BY Location,population
 ORDER BY PopulationPercentageInfected DESC

 --By Continent

 SELECT continent, MAX(cast(total_deaths as int ) ) as TotalDeathCount
FROM [Portfolio project]..CovidDeaths
WHERE continent is not null
GROUP BY continent
 ORDER BY TotalDeathCount DESC

 Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
 From [Portfolio project]..CovidDeaths
 Where continent is not null
 Group By date 
 Order by 1,2

 
  Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
 From [Portfolio project]..CovidDeaths
 Where continent is not null
 --Group By date 
 Order by 1,2


--Join the two table
select * from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date

-- Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
 With PopvsVacc(continent,Location, Date, Population,New_Vaccination, RollingPeopleVaccinated)
 as
 (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations))
 over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)* 100
from PopvsVacc

--Temp Table

DROP TABLE if exists #PopulationVaccinatedPercentage
Create table #PopulationVaccinatedPercentage
( Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
RollingPeopleVaccinated numeric)

Insert into #PopulationVaccinatedPercentage
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations))
 over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/Population)* 100
from #PopulationVaccinatedPercentage

--Create View
 
 CREATE VIEW PopulationVaccinatedPercentage AS
 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations))
 over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
 select * from PopulationVaccinatedPercentage