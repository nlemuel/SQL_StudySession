SELECT * FROM PortfolioProject..CovidDeaths$ 
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$ 
ORDER BY 1, 2


-- Total de casos vs Total de mortes
-- Probabilidade de morte em caso de contágio 
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths$ 
WHERE Location like '%brazil%'
AND continent IS NOT NULL
ORDER BY 1, 2


-- Total de casos vs População

SELECT Location, date, total_cases, Population, (total_cases/population)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths$ 
--WHERE Location like '%brazil%'
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Países com maior número de infecções comparado com a população 

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths$ 
--WHERE Location like '%brazil%'
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Países com maiores taxas de morte por População

SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths$ 
--WHERE Location like '%brazil%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC



--Por continente

-- Continentes com maiores taxas de mortalidade

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths$ 
--WHERE Location like '%brazil%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- Numeros globais
SELECT SUM(new_cases), SUM(cast(new_deaths AS INT)), SUM(cast(new_deaths AS INT))*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths$ 
--WHERE Location like '%brazil%'
WHERE continent IS NOT NULL
--GROUP BY DATE
ORDER BY 1, 2


-- População vs Vacinados

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TABELA TEMP

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Criando View para guardar dados para futuras consultas

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

