-- exercise 1.
create table employee
(
    id int not null,
    employee_name varchar(255) not null,
    primary key (id)
);

-- exercise 2.
select state
from birdstrikes
limit 144,1;
-- A: Tennessee

-- exercise 3.
select flight_date
from birdstrikes
order by flight_date desc
limit 1;
-- A: 2000-04-18

-- exercise 4.
select distinct cost
from birdstrikes
order by cost desc
limit 49,1;
-- A: 5345

-- exercise 5.
select state
from birdstrikes
where state is not null
  and bird_size is not null;
-- A: (empty, not null)

-- exercise 6.
select datediff(now(), flight_date) as date_apart
from birdstrikes
where weekofyear(flight_date) = 52
  and state = 'Colorado';
-- A: 7935 days