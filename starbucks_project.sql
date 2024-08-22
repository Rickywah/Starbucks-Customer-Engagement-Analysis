############################################################################################
################################ Project: Starbucks Customer Data ##########################
############################################################################################
Use Starbucks;

#### PORTFOLIO TABLE ####

-- create a new table after data cleaning and process
create table portfolio_proc as 
select reward, difficulty, duration, offer_type_proc as offer_type, id as offer_id, 
channel_web,channel_email,channel_mobile,channel_social
from (
	select *,
	trim(upper(offer_type)) as offer_type_proc,
	case when JSON_CONTAINS(channels, '["web"]') then 1 else 0 end as channel_web,
	case when JSON_CONTAINS(channels, '["email"]') then 1 else 0 end as channel_email,
	case when JSON_CONTAINS(channels, '["social"]') then 1 else 0 end as channel_social,
	case when JSON_CONTAINS(channels, '["mobile"]') then 1 else 0 end as channel_mobile
	from portfolio_raw
) as  process_table; 

select * from portfolio_proc;

#### PORFILE TABLE ####
select * from profile;
-- replace empty string to 'U', trim(), upper()
select *,case when gender in ('F','M','O') then trim(upper(gender)) else 'U' end as gender_proc from profile;

-- become member convert date
select became_member_on,cast(became_member_on as date) as became_member_on_date from profile; 

select became_member_on, year(cast(became_member_on as date)) as became_member_on_year from profile; 
 
-- income invert to number data type, empty string to NULL value?

-- transform empty sting to 0 and in number data type

SHOW VARIABLES LIKE 'sql_mode'; 
set sql_mode = 'NO_ENGINE_SUBSTITUTION';

select income, cast(income as signed) from profile;
-- transform empty string to null valueand in number data type

select income,
cast(nullif(income,'')as signed) from profile;

################
-- drop table profile_proc;
create table profile_proc as 
select MyUnknownColumn,
case when gender in ('F','M','O') then trim(upper(gender)) else 'U' end as gender,
age,
customer_id,
cast(became_member_on as date) as become_member_on,
YEAR(cast(became_member_on as date)) as become_member_year,
cast(cast(income as char) as signed) as income_zero,
cast( nullif(income,'') as signed) as income_null
from profile
where age!=118; -- due to data analysis result, 118 years old customer (2178) provide no value
################
select * from profile_proc;


#### TRANSCRIPT TABLE ####

select * from transcript_raw;

-- return all list of key in the column
select distinct JSON_KEYS(value) from transcript_raw;

-- filter record on JSON columns
select * from transcript where JSON_VALUE(value, '$. amount') > 30;
select * from transcript where trim(JSON_VALUE(value, '$."offer id"')) ='9b98b8c7a33c4b65b9aebfe6a799e6d9';
select * from transcript where value -> '$."offer id"' ='9b98b8c7a33c4b65b9aebfe6a799e6d9';

-- count
select 
value -> ' $."amount" ' value_offerid,
count(value)
from transcript_raw
group by value -> ' $."amount" ';

-- aggregation function
select person,
sum(value -> ' $."amount" ' ) sum_spending
from transcript_raw
where value -> ' $."amount" ' > 10
group by person
having sum(value -> ' $."amount" ' ) > 500;

-- extend the JSON column to columns

create table transcript_proc as
select MyUnknownColumn,person,event,
coalesce(replace(value -> ' $."offer id" ','"' ,''),replace(value ->  ' $."offer_id" ','"' ,''))  as offer_id,
value -> ' $."amount" ' as amount,
value -> ' $."reward" '  as reward,
time
from transcript
where person in (select customer_id from profile_proc);

-- show how many record per person
select person, count(*)  from transcript_proc group by person order by count(*) desc;

-- convert time(hour since became member) of transaction to datetime since became member
select 
a.*, 
b.become_member_on,
DATE_ADD( b.become_member_on , INTERVAL a.time hour) as time_dt
from transcript_proc a
left join profile_proc b on a.person=b.customer_id
where person='94de646f7b6041228ca7dec82adb97d2';

select * from profile_proc where customer_id='94de646f7b6041228ca7dec82adb97d2';

select * from portfolio_proc order by offer_type;



############################################################################################
################################ DATA ANALYSIS #############################################
############################################################################################


select * from profile_proc;
-- customer info gathering 
select min(become_member_on),max(become_member_on) from profile_proc;
select  count(*) from profile_proc; -- 17,000 customer

-- what percentage of each gender in all 17,000 customers? 
select gender, count(*)/(select count(*) from profile_proc ) as gender_percentage from profile_proc group by gender order by gender_percentage desc;


-- age
select age, count(*) as age_ct from profile_proc group by age order by age;
select age, count(*) from profile_proc where age = 118 and gender = "U" and income_null is null;


-- age distribution percentage, on < 30 , 30-40 , 50-60 , 60-70,  70-80 , 80+
-- 1. group the orignial age into age_group
-- 2. to calculate percentage, first get the total number of customer
-- 3. get the total number of customer in EACH age_group
-- 4. total # of customer in EACH age_group / total # of customer

select distinct
case when age<30 then 'less than 30' 
when age >=30 and age <40 then '30_40'
when age >=40 and age <50 then '40_50'
when age >=50 and age <60 then '50_60'
when age >=60 and age <70 then '60_70'
when age >=70 then 'greaterthan70'
else null end as age_group,
count(*) over() as total_ct,
count(*) over (partition by 
case when age<30 then 'less than 30'  
when age >=30 and age <40 then '30_40'
when age >=40 and age <50 then '40_50'
when age >=50 and age <60 then '50_60'
when age >=60 and age <70 then '60_70'
when age >=70 then 'greaterthan70'
else null end) / count(*) over ()as age_group_percentage
from profile_proc; 

 -- using WITH CLAUSE
with age_group_table as(
select *,
case when age < 30 then 'lessthan30'
when age >=30 and age <40 then '30_40'
when age >=40 and age <50 then '40_50'
when age >=50 and age <60 then '50_60'
when age >=60 and age <70 then '60_70'
when age >=70 then 'greaterthan70'
else null end as age_group
from profile_proc
)
select 
distinct
age_group,
count(*) over() as total_ct,
count(*) over(partition by age_group
) / count(*) over() as age_group_percentage
from age_group_table;

-- age distribution percentage
select distinct gender,
count(*) over() as gener_ct,
count(*) over(partition by gender
) / count(*) over() as gender_group_percentage
from profile_proc;

-- become_member_on's YEARMONTH  distribution percentage, 
 select become_member_on , extract(YEAR_MONTH from become_member_on) as date_v1 ,
 DATE_FORMAT(become_member_on, '%Y-%m') as date_v2
 from profile_proc;
 
-- porfolio table background knowledge, how many offer? max duration, min duration per offer_type? difficulty? rewards?

select count(distinct offer_id) from portfolio_proc; -- 10 different offer
select offer_type, count(offer_id) from portfolio_proc group by offer_type; -- BOGO/DISCOUNT each has 4 offer
 
 -- Extract each offer_type, the one most difficulty offer_id and it's rewards and duration.
-- 1. ranking each offer_type from the most diffculty 
-- 2. extract each offer_type first place , ranking=1
-- 3. extract ranking=1 rewards and duration
select 
offer_type, difficulty, reward, duration
from (
select *,
row_number() over(partition by offer_type order by difficulty desc) as difficulty_rank
from portfolio_proc
) as a 
where difficulty_rank = 1;


-- extract duration rank1 and rank 2 to do further analysis
select
offer_type,
max(case when difficulty_rank = 1 then duration end) as rank1_duration,
max(case when difficulty_rank = 2 then duration end) as rank2_duration
from (
select *,
row_number() over(partition by offer_type order by difficulty desc) as difficulty_rank
from portfolio_proc
) as a 
group by offer_type
;



#####################################################################
#################### DATA ANALYSIS II   #############################
#####################################################################


select count(distinct person) from transcript_proc; -- 14824
select count(distinct customer_id) from profile_proc; -- 14825

-- How many customer experience all process
-- (offer received > offer viewed > offer complete)
-- HOMEWORK : What is the percentage?   11915 customer has experience all 3 event / 14824
with event_agg_table as (
select person, json_arrayagg(event) as combined_event 
from 
(select distinct person, event from transcript_proc) a
 group by person
 )
 
 select count(*)
 from event_agg_table
 -- combined_Event includes all three process, which return True =1 
 where JSON_CONTAINS(
	combined_event, JSON_ARRAY('offer received','offer viewed','offer completed')) = 1
;

-- Demography of people who experience all process : gender
with event_agg_table as (
select person, json_arrayagg(event) as combined_event 
from 
(select distinct person, event from transcript_proc) a
 group by person
 )
 
 select 
 distinct 
 gender,
 count(*) over(partition by gender) as gender_ct,
 count(*) over() as total_ct,
 count(*) over(partition by gender) / count(*) over()  as `gender_%`
 from event_agg_table 
 left join profile_proc on person = customer_id
 where JSON_CONTAINS(
	combined_event, JSON_ARRAY('offer received','offer viewed','offer completed')) = 1
 ;
 
 
 -- offer_completed 
select 
person,
sum(case when event='offer received' then 1 else 0 end) as ct_OfferReceived,
sum(case when event='offer viewed' then 1 else 0 end) as ct_OfferViewed,
sum(case when event='offer completed' then 1 else 0 end) as ct_Completed
-- rate : %view, %completed 
 from transcript_proc
 group by person;

-- which type offer attract user to complete offer?
with a as (
select offer_id,count(*) as ct_offer_used from transcript_proc where event = 'offer completed' group by offer_id)

select * from a left join portfolio_proc b on a.offer_id = b.offer_id order by ct_offer_used desc;

-- demographic of user who complete offer more?
with a as (select person, 
sum(case when event = 'offer received' then 1 else 0 end) as recerived,
sum(case when event = 'offer viewed' then 1 else 0 end) as viwed,
sum(case when event = 'offer completed' then 1 else 0 end) as completed, 
sum(case when event = 'offer viewed' then 1 else 0 end) /sum(case when event = 'offer received' then 1 else 0 end) as view_percentage,
sum(case when event = 'offer completed' then 1 else 0 end) / sum(case when event = 'offer received' then 1 else 0 end) as complete_percentage
 from transcript_proc a
 group by person)
 
select case when age < 30 then 'lessthan30'
when age >=30 and age <40 then '30_40'
when age >=40 and age <50 then '40_50'
when age >=50 and age <60 then '50_60'
when age >=60 and age <70 then '60_70'
when age >=70 then 'greaterthan70'
else null end as age_group,
count(*) as ct_per_agegroup,
count(*) / (select count(*) from a where complete_percentage >= 0.7) as percentage_per_agegroup
from a left join profile_proc on person = customer_id
where complete_percentage >= 0.7
group by age_group
order by ct_per_agegroup desc;

-- income
with a as (select person, 
sum(case when event = 'offer received' then 1 else 0 end) as recerived,
sum(case when event = 'offer viewed' then 1 else 0 end) as viwed,
sum(case when event = 'offer completed' then 1 else 0 end) as completed, 
sum(case when event = 'offer viewed' then 1 else 0 end) /sum(case when event = 'offer received' then 1 else 0 end) as view_percentage,
sum(case when event = 'offer completed' then 1 else 0 end) / sum(case when event = 'offer received' then 1 else 0 end) as complete_percentage
 from transcript_proc a
 group by person)
 
select case when income_zero < 60000 then 'low_income'
when income_zero >= 60000 and  income_zero < 100000 then 'medium_income'
else 'high_income' end as income_group,
count(*) as ct_per_incomegroup,
count(*) / (select count(*) from a where complete_percentage >= 0.7) as percentage_per_incomegroup
from a left join profile_proc on person = customer_id
where complete_percentage >= 0.7
group by income_group
order by ct_per_incomegroup desc;
