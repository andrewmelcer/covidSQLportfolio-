covidsqlportfolioproject
--Create Table one entitled 'coviddeaths'

--Create Table two entiteld 'covidvaccines'

--Check to see that the tables are functioning

Select * FROM coviddeaths
Select * FROM covidvaccines

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location = 'Spain'
order by DeathPercentage DESC

--Looking at the peak death percentage in Spain (PEAK--24th of May 2020)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location = 'Spain'
order by DeathPercentage DESC

--Looking at the peak death percentage in United States (PEAK--2nd of March 2020)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location = 'United States'
order by DeathPercentage DESC

--Spain had the higher peak death percantage compared to the United States

--Looking at Total Cases vs Population
--Shows what percentage of population have contracted Covid

SELECT date, population, total_cases, (total_cases/population)*100 as Percent_of_pop_infected
FROM coviddeaths
WHERE location = 'United States'
ORDER BY percentageofcases DESC

--Looking at Countries with highest infection rate compared to Population with a population greater than 100 Million

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Percent_of_pop_infected
FROM coviddeaths
WHERE population > 100000000
GROUP BY location, population
ORDER BY percent_of_pop_infected DESC 

--Showing Countries with the highest Death Count per Population
--Total deaths was a varchar data type so it was changed with cast function to integer 

SELECT location, MAX(cast(total_deaths as integer)) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC 

--Break the data down by Continent

SELECT continent, MAX(cast(total_deaths as integer)) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC 

--Seems to have errors as it is not adding Canada's total to North American total
--Let's try to break it down by continent being null

--Has errors as it includes income statistics
--Let's remove any income from the location

SELECT location, MAX(cast(total_deaths as integer)) as TotalDeathCount
FROM coviddeaths
WHERE continent is null and location != 'Upper middle income' and location != 'High income' and location != 'Lower middle income' and location != 'Low income' 
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(cast(total_deaths as integer)) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null and location != 'Upper middle income' and location != 'High income' and location != 'Lower middle income' and location != 'Low income' 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers by Date

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total Cases Globally

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE continent is not null
ORDER BY 1,2

--Death percentage as of Mid Feb is 1.4%

--Explore Covid Vaccinations Table

SELECT * 
FROM covidvaccines

--Join the two tables coviddeaths and covidvaccines with location and date

SELECT *
FROM coviddeaths dea
Join covidvaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	
--Looking at total population vs vaccination in United States

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
Join covidvaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null AND dea.location = 'United States'
ORDER by 2,3

--Looking at total population vs vaccination in Spain

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
Join covidvaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null AND dea.location = 'Spain'
ORDER by 2,3

--Looking at total population vs vaccination as a rolling count

--USE CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_People_vaccinated
FROM coviddeaths dea
Join covidvaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 as percentage_of_vaccinated_population
FROM PopvsVac

--Tenporary Table

CREATE TABLE percentpopulationvaccinated(
Continent varchar (255),
Location varchar (255),
Date date,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);

INSERT INTO percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_People_vaccinated
FROM coviddeaths dea
Join covidvaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3

SELECT *, (rolling_people_vaccinated/population)*100 as percentage_of_vaccinated_population
FROM percentpopulationvaccinated

--CREATE Views to store date for later Viz

CREATE VIEW spaindeathpercentage as 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location = 'Spain'
order by DeathPercentage DESC

CREATE VIEW unitedstatesdeathpercentage as 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location = 'United States'
order by DeathPercentage DESC

CREATE VIEW highestinfectionratelargecountries as 
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Percent_of_pop_infected
FROM coviddeaths
WHERE population > 100000000
GROUP BY location, population
ORDER BY percent_of_pop_infected DESC 

CREATE VIEW highestdeathcount as
SELECT location, MAX(cast(total_deaths as integer)) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC 

CREATE VIEW totalcasesglobally as
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE continent is not null
ORDER BY 1,2


DROP table if exists percentpopulationvaccinated;
CREATE VIEW percentpopulationvaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
Join covidvaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 

