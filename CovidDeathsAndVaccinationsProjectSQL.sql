select *
 from [dbo].[CovidDeaths$]
 where continent is not null
order by 3,4



/*select * from [dbo].[CovidVaccinations$]
order by 3,4*/


-----------------------------------------------------------------------------------------------------------------------------------------------------
--- STEP 1. SELECT DATA THAT WE ARE GOING TO BE USING 

select location, DATE, total_cases, new_cases,total_deaths,population
from [dbo].[CovidDeaths$]
order by 1,2



----- TOTAL CASES VERSUS TOTAL DEATHS. DEATHS PER ENTIRE CASES %

create view TotalDeathsPercentage as
select location, DATE, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths$]
where location ='Canada' 
--order by 1,2

ALTER table [dbo].[CovidDeaths$]
add DeathPercentag nvarchar(255)

UPDATE [dbo].[CovidDeaths$]
set DeathPercentag = (cast (total_deaths/total_cases as int))*100      ----Adding a colum named DeathPercentage in the original table.



---LOOKING AT THE TOTAL CASES VERSUS THE POPULATION
---shows the percentage of population got covid

select location, DATE, population, total_cases,(total_cases/population)*100 as PopulationtoCasesPercentage
from [dbo].[CovidDeaths$]
where location like '%States%' 
order by 1,2


ALTER table [dbo].[CovidDeaths$]
add PopulationtoCasesPercentage NVARCHAR(255)

UPDATE [dbo].[CovidDeaths$]
set PopulationtoCasesPercentage = (total_cases/population)*100     --adding column named PopulationtoCasesPercentage on the orginal tables using nvarchar



--LOOKING AT THE COUNTRY WITH THE HIGHEST INFECTION RATES COMPARED TO POPULATION 


create view HighestInfectionCount as
select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PopulationtoCasesPercentage
from [dbo].[CovidDeaths$]
 where continent is not null
group by [location], population
--order by 4 desc 


--- Showing Countries with Highest Death Count Per Population

select location, Max(cast(total_deaths as int)) HighestDeathCount
from [dbo].[CovidDeaths$]
 where continent is not null
group by [location] 
order by 2 desc 

--BREAKING NUMBERS BY CONTINENT 

select continent, Max(cast(total_deaths as int)) HighestDeathCount
from [dbo].[CovidDeaths$]
 where [continent] is not null
group by continent 
order by 2 desc 


----Showing the continents with the highest death count per population 
create view HighestDeathCount as 
select continent, Max(cast(total_deaths as int)) HighestDeathCount
from [dbo].[CovidDeaths$]
 where [continent] is not null
group by continent 
--order by 2 desc 



---Global numbers breakdown

select sum(new_cases)TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths 
--(sum(cast(new_deaths as int )))/(sum(new_cases))*100 as GlobalDeathPercentage
from [dbo].[CovidDeaths$]
--where location ='Canada'
where continent is  null 
group by  DATE
order by 1                       


---joinign tables 

select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT (int, vac.new_vaccinations ))over(partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated, 
 from [dbo].[CovidDeaths$] DEA 
JOIN [dbo].[CovidVaccinations$] VAC
ON DEA.location = VAC.location
AND DEA.DATE=VAC.DATE
where dea.continent is not null
order by 2, 3

---use CTE to create a temp column in order to calculate max people vaccinated vs the population by location to see how many people were vaccinated per location
---

with PopvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT (int, vac.new_vaccinations ))over(partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated 
 from [dbo].[CovidDeaths$] DEA 
JOIN [dbo].[CovidVaccinations$] VAC
ON DEA.location = VAC.location
AND DEA.DATE=VAC.DATE
where dea.continent is not null
--order by 2, 3
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac


--- we can also use temps tables 
drop table #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated (
  continent NVARCHAR(255),
  Location NVARCHAR(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric  
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT (int, vac.new_vaccinations ))over(partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated 
 from [dbo].[CovidDeaths$] DEA 
JOIN [dbo].[CovidVaccinations$] VAC
ON DEA.location = VAC.location
AND DEA.DATE=VAC.DATE
where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-----creating view to store data for later visualisations...

Create view PercentPopulationVaccinated as
select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT (int, vac.new_vaccinations ))over(partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated 
 from [dbo].[CovidDeaths$] DEA 
JOIN [dbo].[CovidVaccinations$] VAC
ON DEA.location = VAC.location
AND DEA.DATE=VAC.DATE
where dea.continent is not null
--order by 2, 3





