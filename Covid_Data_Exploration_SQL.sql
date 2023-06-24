-- Show the covid deaths table values.
SELECT * 
FROM PortfolioProject .. CovidDeaths
ORDER BY 3,4

-- Show the covid vaccination table values.
SELECT * 
FROM PortfolioProject .. CovidVaccinations
ORDER BY 3,4

-- Selected data for further uses.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject .. CovidDeaths
ORDER BY 1,2

--  Looking for howmany percent population got affected 
--Basic function of below formula --> (total_deaths/total_cases)*100
SELECT location, date, total_cases, total_deaths, CONVERT(DECIMAL(15,3),(CONVERT(decimal(15,3), total_deaths)/CONVERT(decimal(15,3),total_cases)))*100  as DeathPercentage
FROM PortfolioProject .. CovidDeaths 
ORDER BY 1,2 desc

-- Looking for howmany percent population got affected in perticular country
--For India
SELECT location, date, total_cases, total_deaths, CONVERT(DECIMAL(15,3),(CONVERT(decimal(15,3), total_deaths)/CONVERT(decimal(15,3),total_cases)))*100  as DeathPercentage
FROM PortfolioProject .. CovidDeaths
Where location like 'Ind%'
ORDER BY 1,2

-- Looking for countries who were highly affected.   
SELECT date, location, population, MAX(CONVERT(bigint, total_cases)) as HighestInfected, MAX((CONVERT(int, total_cases)/population))*100 PercentInfected
FROM PortfolioProject .. CovidDeaths
Group by  date, location, population
ORDER BY  PercentInfected desc


-- Looking for highest death count per population in different location.   
SELECT  location, MAX(CONVERT(bigint, total_deaths)) as TotalDeathCount
FROM PortfolioProject .. CovidDeaths
Group by  location
ORDER BY  TotalDeathCount desc

-- Breakdown total death count for continent.   
SELECT  continent, MAX(CONVERT(bigint, total_deaths)) as TotalDeathCount
FROM PortfolioProject .. CovidDeaths
Where continent is not null
Group by  continent
ORDER BY  TotalDeathCount desc

--Global death percentage
SELECT SUM(CONVERT(int, new_cases)) as TotalCases, SUM(CONVERT(int,new_deaths)) as TotalDeaths, 
CONVERT(DECIMAL(15,3), (SUM(CONVERT(DECIMAL(15,3),new_deaths))/SUM(CONVERT(DECIMAL(15,3), new_cases)))*100) as DeathPercentage
FROM PortfolioProject .. CovidDeaths
Where continent is not null
ORDER BY  DeathPercentage desc

--Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location) as NewVaccineTaker
--,(NewVaccineTaker/dea.population)*100
FROM PortfolioProject .. CovidDeaths dea
JOIN PortfolioProject .. CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY  2,3

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, NewVaccineTakers)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location) as NewVaccineTakers
--,(NewVaccineTakers/dea.population)*100 // Can't able to use it 
FROM PortfolioProject .. CovidDeaths dea
JOIN PortfolioProject .. CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
SELECT *, (NewVaccineTakers/Population)*100 as VtakersPercentage
FROM PopvsVac


--Temp Table
DROP Table if exists #PercentPopulationVaccinated

CREATE Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
NewVaccinTakers numeric
)

INSERT into #PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location) as NewVaccineTakers
	FROM PortfolioProject .. CovidDeaths dea
	JOIN PortfolioProject .. CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null

SELECT *, (NewVaccinTakers/Population)*100 as VtakersPercentage
FROM #PercentPopulationVaccinated


--Create view

CREATE view PercentPopulationVaccinated as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location) as NewVaccineTakers
	FROM PortfolioProject .. CovidDeaths dea
	JOIN PortfolioProject .. CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
