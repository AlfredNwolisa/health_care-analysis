SELECT * FROM dbo.covid_deaths
SELECT * FROM DBO.covid_vaccinations

---PERCENTAGE OF TOTAL DEATH

SELECT 
    dbo.covid_deaths.location,
    dbo.covid_deaths.[date],
    total_cases AS cases,
    total_deaths AS deaths,
     CASE 
         WHEN total_cases = 0 THEN 0 
         ELSE total_deaths * 100.0 / NULLIF(total_cases, 0)
    END AS pct_death 
FROM  
    dbo.covid_deaths 
GROUP BY 
  dbo.covid_deaths.location, dbo.covid_deaths.[date],dbo.covid_deaths.total_cases , dbo.covid_deaths.total_deaths
ORDER BY 1,2

-- TOTAL CASE VS POULTATION(percentage of population with covid

SELECT 
    dbo.covid_deaths.location,
    dbo.covid_deaths.[date],
    dbo.covid_deaths.total_cases AS cases,
    dbo.covid_deaths.population AS population,
     CASE 
         WHEN dbo.covid_deaths.total_cases = 0 THEN 0 
         ELSE CAST(dbo.covid_deaths.total_cases * 100.0 / NULLIF(dbo.covid_deaths.population, 0) AS FLOAT)
    END AS pct_case 
FROM  
    dbo.covid_deaths 
WHERE location = 'Nigeria'
GROUP BY 
  dbo.covid_deaths.location,dbo.covid_deaths.total_cases, dbo.covid_deaths.[population],dbo.covid_deaths.[date]
ORDER BY 1,2


--what countries have the highest infection rate compared per populations

SELECT 
    dbo.covid_deaths.location,
    dbo.covid_deaths.continent,
     dbo.covid_deaths.population AS population,
    MAX(dbo.covid_deaths.total_cases) AS highest_cases,
    --    cast(max(dbo.covid_deaths.total_cases/ dbo.covid_deaths.population) *100 as float) as Percntage_of_infected_population
     CASE 
         WHEN max(dbo.covid_deaths.total_cases) = 0 THEN 0 
         ELSE CAST(MAX(dbo.covid_deaths.total_cases * 100.0 / NULLIF(dbo.covid_deaths.population, 0)) AS FLOAT)
    END AS Percntage_of_infected_population 
FROM  
    dbo.covid_deaths 
WHERE continent is not NULL
GROUP BY 
  dbo.covid_deaths.location,dbo.covid_deaths.[population],dbo.covid_deaths.continent
ORDER BY Percntage_of_infected_population DESC

--what countries have the highest death rate per populations

SELECT continent, MAX(CAST(total_deaths as INT)) as death_count
from dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY [continent]
ORDER by 2 DESC


-----global numbers
--- daily deaths per new case
SELECT  date, SUM(new_cases) total_new_cases , SUM(CAST(new_deaths as INT)) total_new_deaths, 
case when SUM(new_cases) = 0 then 0
ELSE SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 
END AS new_death_percentage
from dbo.covid_deaths
where continent is NOT NULL
GROUP BY [date]
ORDER BY 1,2


--total population vs vaccine
--rolling vaccination per country
WITH pop (continent, location, date, population,new_vaccinations, rolling_vaccinated_people)
AS(

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, nullif(SUM(cast(v.new_vaccinations as BIGINT)) OVER (partition by d.location ORDER by d.location, d.date),0) as rolling_vaccinated_people
from covid_deaths d
join  covid_vaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not NULL
-- AND d.location = 'Nigeria'    
-- ORDER by    d.continent, d.location, d.date
)
SELECT *, cast( rolling_vaccinated_people/population *100 AS float)
FROM pop
WHERE [location] = 'Albania'