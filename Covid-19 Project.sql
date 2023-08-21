select *
from `portofolioproject-396402.1.covid_deaths`
where continent is not null
order by 3,4;

-- select *
-- from `portofolioproject-396402.1.covid_vaccinations`
-- order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from `portofolioproject-396402.1.covid_deaths`
where continent is not null
order by 1,2;

-- mengetahui total kasus vs total kematian

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as persentasi_kematian
from `portofolioproject-396402.1.covid_deaths`
where location = 'Indonesia'
order by 1,2 DESC;

-- mengetahui total kasus vs populasi

select location, date, total_cases, population,(total_cases/population) * 100 as persentasi_kasus
from `portofolioproject-396402.1.covid_deaths`
-- where location = 'Indonesia'
order by 5 DESC;

-- mengetahui negara dengan tingkat kasus tertinggi terhadap populasi

select location, population, MAX(total_cases) as total_kasus, MAX((total_cases/population)) * 100 as persentasi_kasus
from `portofolioproject-396402.1.covid_deaths`
where continent is not null
group by location, population
order by persentasi_kasus DESC;

-- mengetahui negara dengan tingkat kematian tertinggi

select location, MAX(population) as populasi, MAX(total_deaths) as kematian, MAX((total_deaths/population)) * 100 as persentasi_populasi_meninggal
from `portofolioproject-396402.1.covid_deaths`
where continent is not null
group by location
order by 4 DESC;

-- total kematian berdasarkan benua

select location, MAX(total_deaths) as total_kematian
from `portofolioproject-396402.1.covid_deaths`
where continent is null
group by location
order by 2 DESC;

-- total kematian berdasarkan benua (part 2)

with temp_benua as
  (
  select
    continent, 
    MAX(total_deaths) as total_kematian
  from `portofolioproject-396402.1.covid_deaths`
  where continent is not null
  group by continent, location
  order by 2 DESC)

select continent, SUM(total_kematian) AS kematian
from temp_benua
group by continent
order by 2 DESC;

-- total kematian berdasarkan benua (part 2)

select continent, SUM(total_kematian) AS kematian
from (
  select
    continent, 
    MAX(total_deaths) as total_kematian
  from `portofolioproject-396402.1.covid_deaths`
  where continent is not null
  group by continent, location
  order by 2 DESC)
group by continent
order by 2 DESC;

-- Global Number

select 
    date, 
    SUM(new_cases) as jumlah_kasus, 
    SUM(new_deaths) as jumlah_kematian, 
    (SUM(new_deaths)/SUM(new_cases)) * 100 as persentasi_kematian
from `portofolioproject-396402.1.covid_deaths`
where continent is not null AND new_cases is not null AND new_cases != 0
group by date
order by 1 DESC;

-- Global number (SUM)

select 
    SUM(new_cases) as jumlah_kasus, 
    SUM(new_deaths) as jumlah_kematian, 
    (SUM(new_deaths)/SUM(new_cases)) * 100 as persentasi_kematian
from `portofolioproject-396402.1.covid_deaths`
where continent is not null AND new_cases is not null AND new_cases != 0
-- group by date
order by 1 DESC;


-- Melihat total populasi vs total vaksinasi

select 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as run_total_vaksinasi
    -- lihat hasil agar paham
from `portofolioproject-396402.1.covid_deaths` as dea
join `portofolioproject-396402.1.covid_vaccinations` as vac
    on dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Melihat total populasi vs total vaksinasi (kelanjutan)

SELECT continent, location, date, population, new_vaccinations, run_total_vaksinasi, (run_total_vaksinasi/population)*100 as persentasi_vaksinasi
FROM (
      select 
          dea.continent, 
          dea.location, 
          dea.date, 
          dea.population, 
          vac.new_vaccinations,
          sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as run_total_vaksinasi
          -- lihat hasil agar paham
      from `portofolioproject-396402.1.covid_deaths` as dea
      join `portofolioproject-396402.1.covid_vaccinations` as vac
          on dea.location = vac.location AND dea.date = vac.date
      where dea.continent is not null
      order by 2,3)
ORDER BY 1,2,3;

-- Melihat total populasi vs total vaksinasi (kelanjutan) part 2

with popvac as (
select 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as run_total_vaksinasi
    -- lihat hasil agar paham
from `portofolioproject-396402.1.covid_deaths` as dea
join `portofolioproject-396402.1.covid_vaccinations` as vac
    on dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
order by 2,3)

SELECT *, (run_total_vaksinasi/population)
FROM popvac;


-- tabel sementara

create table `portofolioproject-396402.1.persentasi_populasi_vaksinasi`
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  run_total_vaksinasi numeric
);

insert into persentasi_populasi_vaksinasi
select 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as run_total_vaksinasi
    -- lihat hasil agar paham
from `portofolioproject-396402.1.covid_deaths` as dea
join `portofolioproject-396402.1.covid_vaccinations` as vac
    on dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null;

select *, (run_total_vaksinasi/population)
from `portofolioproject-396402.1.persentasi_populasi_vaksinasi`

