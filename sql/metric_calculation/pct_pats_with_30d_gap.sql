BEGIN;
with order_dates as (
select 
		entity_id as person_id,
		start_date,
		end_date,
		LAG(end_date) over (partition by entity_id order by start_date, end_date) as prev_end_date
	from 
		{{ site }}_pedsnet.location_history
	where
		start_date between '2009-01-01' and '2024-12-31'
),	

get_numerator as (
select 
	count(distinct person_id) as ct_pats_with_30_day_gap
from 
	order_dates
where 
	prev_end_date + interval '30 days' <= start_date
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