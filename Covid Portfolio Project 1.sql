--Curated a visualization based on a few selcted queries
 --1

SELECT SUM(new_cases)AS TotalCases,
       SUM(cast(new_deaths AS int))AS TotalDeaths,
       SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths$ --WHERE location like '%states%'

WHERE continent IS NOT NULL --GROUP BY date
ORDER BY 1, 2;


--2
SELECT LOCATION,
       SUM(cast(new_deaths AS int))AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths$ --WHERE location like '%states%'

WHERE continent IS NULL
  AND LOCATION not in ('World',
                       'European Union',
                       'International')
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC;


--3
SELECT LOCATION,
       Population,
       MAX(total_cases) AS HighestInfectionCount,
       MAX((total_cases/Population))*100 AS PercentageofPopulationInfected
FROM PortfolioProject1..CovidDeaths$ --WHERE location like '%states%'
GROUP BY LOCATION,
         Population
ORDER BY PercentageofPopulationInfected DESC;


--4

SELECT LOCATION,
       Population, date, MAX(total_cases) AS HighestInfectionCount,
                         MAX((total_cases/Population))*100 AS PercentageofPopulationInfected
FROM PortfolioProject1..CovidDeaths$ --WHERE location like '%states%'
GROUP BY LOCATION,
         Population, date
ORDER BY PercentageofPopulationInfected DESC 



--Covid-19 Portfolio Project Query

SELECT *
FROM PortfolioProject1..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3, 4 
		 
--SELECT *
--FROM PortfolioProject1..CovidVaccinations$
--ORDER BY 3,4

SELECT LOCATION, date, total_cases,
                       new_cases,
                       total_deaths,
                       population
FROM PortfolioProject1..CovidDeaths$
ORDER BY 1, 2 


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying when you contract covid in your country

SELECT LOCATION, date, total_cases,
                       total_deaths,
                       (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths$
WHERE LOCATION like '%states%'
ORDER BY 1, 2 


--Looking at Total Cases vs Population
--Shows percentage of population that contracted covid

SELECT LOCATION, date, total_cases,
                       population,
                       (total_cases/population)*100 AS PercentageofPopulationInfected
FROM PortfolioProject1..CovidDeaths$
WHERE LOCATION like '%states%'
ORDER BY 1, 2 
		 
		 
--Looking at countries with highest infection rate compared to population

SELECT LOCATION,
       population,
       MAX(total_cases) AS HighestInfectionCount,
       MAX((total_cases/population))*100 AS PercentageofPopulationInfected
FROM PortfolioProject1..CovidDeaths$ --WHERE location like '%states%'
GROUP BY population,
         LOCATION
ORDER BY PercentageofPopulationInfected DESC 


--Showing Countries with the Highest Death Count per population

SELECT LOCATION,
       MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths$ --WHERE location like '%states%'

WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC 



--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continent with the highest death count per population

SELECT continent, 
       MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths$ --WHERE location like '%states%'

WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC --GLOBAL NUMBERS

SELECT SUM(new_cases)AS TotalCases, 
       SUM(cast(new_deaths AS int))AS TotalDeaths, 
       SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths$ --WHERE location like '%states%'

WHERE continent IS NOT NULL --GROUP BY date
ORDER BY 1, 2 
		 
		 
--Looking at Total Population vs Vaccinations
--Percentage of Population that have received at least one Covid Vaccine

SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT (int, vac.new_vaccinations)) OVER(PARTITION BY dea.location
                                                     ORDER BY dea.location,
                                                              dea.date) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 


--USE CTE used to calculate on Partition By in previous query
WITH PopvsVac(Continent,
              LOCATION, Date, Population,
                              RollingPeopleVaccinated,
                              New_Vaccinations) AS
  (SELECT dea.continent,
          dea.location,
          dea.date,
          dea.population,
          vac.new_vaccinations,
          SUM(CONVERT (int, vac.new_vaccinations)) OVER(PARTITION BY dea.location
                                                        ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject1..CovidDeaths$ dea
   JOIN PortfolioProject1..CovidVaccinations$ vac ON dea.location = vac.location
   AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL --ORDER BY 2,3
)
SELECT*,
      (RollingPeopleVaccinated/Population)*100
FROM PopvsVac 


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (Continent nvarchar(255),
                                                     LOCATION nvarchar(255), Date datetime,
                                                                                  Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT (int, vac.new_vaccinations)) OVER(PARTITION BY dea.location
                                                     ORDER BY dea.location,
                                                              dea.date) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac ON dea.location = vac.location
AND dea.date = vac.date --WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*,
      (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated 


--Create view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT (int, vac.new_vaccinations)) OVER(PARTITION BY dea.location
                                                     ORDER BY dea.location,
                                                              dea.date) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL