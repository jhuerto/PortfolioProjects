SELECT *
FROM
    `agile-aleph-333105.covid19_202002to202201.covid_deaths`

--
SELECT 
    location,
    date,
    total_cases
FROM 
    covid19_202002to202201.covid_deaths


--Total Cases vs Total Deaths in UAE
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS death_percentage
FROM 
    covid19_202002to202201.covid_deaths
WHERE 
    location = 'United Arab Emirates'
ORDER BY 
    1, 2


--Total cases vs Population
SELECT 
    location,
    date,
    total_cases,
    population,
    (total_cases/population) AS percent_population_infected
FROM 
    covid19_202002to202201.covid_deaths
ORDER BY 
    1, 2


--Countreis with Highest Infection Rate Compared to Population
SELECT 
    location,
    population,
    MAX(total_cases) AS higehst_infection_count,
    MAX((total_cases/population))*100 AS percent_population_infected
FROM 
    covid19_202002to202201.covid_deaths
GROUP BY 
    location,
    population
ORDER BY 
    percent_population_infected DESC


-- Countries with Highest Death Count per Population
SELECT 
    location,
    MAX(cast(total_deaths AS INT)) AS total_death_count
FROM 
    covid19_202002to202201.covid_deaths
WHERE 
    continent IS NOT NULL 
GROUP BY 
    location
ORDER BY 
    total_death_count DESC



-- By Continent
SELECT 
    continent,
    MAX(cast(total_deaths AS INT)) AS total_death_count
FROM 
    covid19_202002to202201.covid_deaths
WHERE 
    continent IS NOT NULL 
GROUP BY 
    continent
ORDER BY 
    total_death_count DESC


-- Continents with Highest Death Count per Population
SELECT 
    continent
    MAX(total_deaths) AS total_death_count
FROM 
    covid19_202002to202201.covid_deaths
WHERE 
    continent IS NOT NULL 
GROUP BY 
    continent
ORDER BY 
    total_death_count DESC


-- Worldwide Numbers per Day
SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(cast(new_deaths AS INT)) AS total_deaths,
    SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM 
    covid19_202002to202201.covid_deaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
     date


-- Worldwide Numbers
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(cast(new_deaths AS INT)) AS total_deaths,
    SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM 
    covid19_202002to202201.covid_deaths
WHERE 
    continent IS NOT NULL


-- Total Population vs Vaccinations
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_getting_vaccinated
FROM 
    covid19_202002to202201.covid_deaths dea
    JOIN covid19_202002to202201.covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    2, 3


-- With CTE
WITH PopVsVac AS (
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_getting_vaccinated
FROM 
    covid19_202002to202201.covid_deaths dea
    JOIN covid19_202002to202201.covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
)
SELECT *, (people_getting_vaccinated/population)*100
FROM 
    PopVsVac


-- Temp Table
CREATE TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_getting_vaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_getting_vaccinated
FROM 
    covid19_202002to202201.covid_deaths dea
    JOIN covid19_202002to202201.covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date

SELECT *, (people_getting_vaccinated/population)*100
FROM 
    PercentPopulationVaccinated


-- Create View to Store Data for Later Visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_getting_vaccinated
FROM 
    covid19_202002to202201.covid_deaths dea
    JOIN covid19_202002to202201.covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL

  total_death_count DESC