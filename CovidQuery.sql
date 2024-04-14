--SELECT *
--FROM PortfolioProject..CovidDeaths

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order By 1,2

-- Looking at total cases vs total deaths
-- Shows percentage of population who caught covid and also passed
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Canada'
ORDER BY 1,2

-- Total Cases vs Population
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopToCase
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Canada' and continent is not null
ORDER BY 1,2

-- Which Country has the Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By location
order by TotalDeathCount DESC

-- Which continent has the highest death count
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null AND location != 'World'
Group By location
order by TotalDeathCount DESC


--	Highest deathcount per population by continent
SELECT location, population, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
Group By location
order by TotalDeathCount DESC


-- going to use the covid vaccination table

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date

-- Total population vs number of vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(int, vax.new_vaccinations)) OVER (Partition By dea.location	ORDER BY dea.location, dea.date) AS SumOfPplVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 2,3 


WITH PopvsVax (Continent, Location, Date, Population, New_Vax, SumOfPplVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(int, vax.new_vaccinations)) OVER (Partition By dea.location	ORDER BY dea.location, dea.date) AS SumOfPplVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3
)

SELECT *, (SumOfPplVaccinated/Population)*100 AS VacvsPopPercent
FROM PopvsVax

-- Temp Table

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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

DROP view if exists PercentPopulationVaccinated
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 