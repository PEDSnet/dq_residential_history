BEGIN;

with fix_dates as (
	select 
		entity_id as person_id,
		start_date,
		coalesce(end_date, '9999-01-01'::date) as end_date
	from 
		{{ site }}_pedsnet.location_history
),

order_dates as (
	select 
		entity_id as person_id,
		start_date,
		end_date,
		LAG(end_date) over (partition by entity_id order by start_date, end_date) as prev_end_date
	from 
		fix_dates
),	

group_dates as (
	SELECT 
	    	person_id, 
	    	start_date, 
	    	end_date,
		prev_end_date,
	        SUM(CASE WHEN start_date > prev_end_date THEN 1 ELSE 0 END)
	           OVER (partition by person_id ORDER BY start_date) AS group_id
    FROM 
	order_dates
),

min_max_dates as (
	SELECT 
	    	person_id, 
		group_id,
	    	min(start_date) over (partition by person_id,group_id) as start_date, 
		max(end_date) over (partition by person_id,group_id) as end_date, 
		row_number() over (partition by person_id,group_id) as row_num
    	FROM 
		group_dates
),

prev_dates as (
	select 
		person_id,
		start_date,
		end_date,
		LAG(end_date) over (partition by person_id order by start_date, end_date) as prev_end_date
	from 
		min_max_dates
	where 
		row_num = 1
		and start_date > '2009-01-01'

),

get_numerator as (
	select 
		count(distinct person_id) as ct_pats_with_30_day_gap
	from 
		prev_dates
	where 
		prev_end_date + interval '30 days' < start_date
),

get_denominator as (
	select
		count(*) as ct_pats_total
	from
		{{ site }}_pedsnet.person

)

INSERT INTO dq_residential_history.pct_pats_with_30d_gap (
	site,
    ct_pats_with_30_day_gap,
    pct_pats_with_30_day_gap
)
select 
	'{{ site }}' as site,
	max(coalesce(ct_pats_with_30_day_gap)),
	max(coalesce(trunc(ct_pats_with_30_day_gap::numeric / ct_pats_total::numeric,4))) as pct_pats_with_30_day_gap
from 
	get_denominator, get_numerator;
COMMIT;
