use birdstrikes;

-- Do the same with speed. If speed is NULL or speed < 100 create a “LOW SPEED” category, otherwise, mark as “HIGH SPEED”. Use IF instead of CASE!
select
    speed,
    IF(
        speed is null or speed < 100, "LOW SPEED", "HIGH SPEED"
    ) as speed_category
from birdstrikes;

-- How many distinct ‘aircraft’ we have in the database?
select COUNT(distinct aircraft) from birdstrikes;
-- A: 3

-- What was the lowest speed of aircrafts starting with ‘H’
select MIN(speed) from birdstrikes where aircraft like "H%";
-- A: 9

-- Which phase_of_flight has the least of incidents?
select
    phase_of_flight,

    COUNT(*) as incidents
from birdstrikes group by phase_of_flight order by incidents limit 1;
-- A: Taxi with only 2 incidents

-- What is the rounded highest average cost by phase_of_flight?

select
    phase_of_flight,
    ROUND(AVG(cost)) as cost
from birdstrikes
group by phase_of_flight
order by cost desc
limit 1;

-- A: 54673

-- What the highest AVG speed of the states with names less than 5 characters?

select

    state, AVG(speed) as avg_speed
from
    birdstrikes
group by state having LENGTH(state) < 5 order by avg_speed desc limit 1;

-- A: Iowa - 2862.5
