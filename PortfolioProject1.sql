SELECT*
	FROM PortfolioProject..CovidDeaths
	WHERE Continent is not null	
	ORDER BY 3,4


	--SELECT*
	--FROM PortfolioProject..CovidVaccinations
	--ORDER BY 3,4

	SELECT Location,date,total_cases,new_cases,total_deaths,population
	FROM PortfolioProject..CovidDeaths
	ORDER BY 1,2

	--Looking at Total cases vs Total Deaths
	--Shows likelihood of dying if you contract covid in your country

	SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE location like 'india'
	ORDER BY 1,2

	--Looking at Toatal cases vs Population
	--Shows what percentage of Population got Covid

	SELECT Location,date,total_cases,Population,(total_cases/Population)*100 AS PercentPopulationInfected
	FROM PortfolioProject..CovidDeaths
	--WHERE location like 'india'
	ORDER BY 1,2

	--Looking at countries with Highest infection rate compared to population

		SELECT Location,Population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/Population))*100 AS PercentPopulationInfected
	FROM PortfolioProject..CovidDeaths
	--WHERE location like 'india'
	Group by Location,Population
	ORDER BY PercentPopulationInfected desc


	--Looking at countries with Highest Death Count per Population

	SELECT Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths
	--WHERE location like 'india'
	WHERE Continent is not null
	Group by Location
	ORDER BY TotalDeathCount desc

	--LETS BREAK THINGS DOWN BY CONTINENT

	--Showing continents with the highest death count per population

	SELECT continent ,MAX(cast(Total_deaths as int)) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths
	--WHERE location like 'india'
	WHERE continent is not null 
	AND location NOT like '%income%'
	Group by continent 
	ORDER BY TotalDeathCount desc


	--GLOBAL NUMBERS

	SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
	FROM PortfolioProject..CovidDeaths
	--WHERE location like 'india'
	WHERE continent is not null
	--Group by date
	ORDER BY 1,2

	--Looking at Total Population vs Vaccinations

SELECT *
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	    ON dea.location=vac.location
		and dea.date=vac.date



		SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
		,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
		--(RollingPeopleVaccinated/Population)*100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	    ON dea.location=vac.location
		and dea.date=vac.date
		WHERE dea.continent is not null
		Order by 2,3

--USE CTE

With PopvsVac (Continent,location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
		,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
		--(RollingPeopleVaccinated/Population)*100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	    ON dea.location=vac.location
		and dea.date=vac.date
		WHERE dea.continent is not null
		--Order by 2,3
		)

		SELECT * , (RollingPeopleVaccinated/Population)*100
		FROM PopvsVac
		

--TEMP TABLE

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later vizualizations.

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


SELECT*
FROM PercentPopulationVaccinated