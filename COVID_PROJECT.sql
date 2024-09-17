--SELECT TOP (5) * 
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4;--first sort by the 3rd column and then the 4th column

--SELECT TOP (10) *
--FROM PortfolioProject..CovidVaccinations;


--Selecting the data that would be used in the project

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;


--Looking at the Total cases VS Total Deaths in a country
-- Shows the likelihood of dying if someone is infected by covid in Canada
SELECT Location,total_cases, date, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Canada'
ORDER BY 1, 2;


--Looking at Total cases vs Population
--Shows whaat percentage of total population is infected
SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS CasesVSpopulation
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Canada'
ORDER BY 1, 2;

--Looking at Countries with the highest Infection Rate compare to population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX(total_cases/population) * 100 AS HighestInfCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestInfCount DESC;

--Highest Death Count per population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


--Looking at continent with the highest Infection Rate compare to population
SELECT continent, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population) * 100 AS HighestInfCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestInfCount DESC;

--Highest Death Count per population based on Continent
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC; 





-- Showing continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount,MAX((CAST(total_deaths AS INT)/population)*100) AS TDCPP
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Looking at total death percentage in each day
SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date, total_cases, total_deaths
ORDER BY 1,2;

-- NEW CASES IN EACH DATE
SELECT date, SUM(CAST(new_cases AS INT)) AS NewCases, Sum(cast(new_deaths as int)) as NewDeaths, (Sum(CAST(new_deaths AS INT))/SUm(new_cases)*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;


-- NEW VS OLD CASES IN WHOLE WORLD IN TOTAL
SELECT  SUM(CAST(new_cases AS INT)) AS NewCases, Sum(cast(new_deaths as int)) as NewDeaths, (Sum(CAST(new_deaths AS INT))/SUm(new_cases)*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

--Looking at Total population VS Total number vaccinized
--USING CTE
WITH POP_VS_VAC (continent,location, date,population, new_vaccinations,total_vaccination)
as
(
SELECT CD.continent, CD.location, CD.date, population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS total_vaccination
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.location = CV.location 
	and CD.date = CV.date
WHERE CD.continent is not null
---order by 2,3
)

SELECT *, (total_vaccination/population)*100 as PopVSVac from POP_VS_VAC;


--TEMP TABLE
DROP TABLE IF EXISTS PervPOP_VAC;
Create Table PervPOP_VAC
(
continent nvarchar(255),
location nvarchar(255),
date  datetime,
Population numeric,
new_vaccinations numeric,
total_vaccination numeric
)
INSERT INTO PervPOP_VAC
SELECT CD.continent, CD.location, CD.date, population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS total_vaccination
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.location = CV.location 
	and CD.date = CV.date
WHERE CD.continent is not null

SELECT *, (total_vaccination/population)*100 as PopVSVac from PervPOP_VAC;


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS
CREATE VIEW PervPOP_VAC1 AS
SELECT CD.continent, CD.location, CD.date, population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS total_vaccination
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.location = CV.location 
	and CD.date = CV.date
WHERE CD.continent is not null

SELECT *,(total_vaccination/population)*100 as PopVSVac  FROM PervPOP_VAC1;