with cbgs as (
select 
	trim(geocode_state||geocode_county||geocode_tract||geocode_group) as census_block_group
from 
	{{ site }}_pedsnet.location_fips
where 
	geocode_year = 2010
),

get_numerator as (
select 
	count(distinct census_block_group) as ct_distinct_2010_cbg_invalid
from 
	cbgs
where
	not exists (select 1 from dq_residential_history.fips_2010 fips where fips.geoid = census_block_group)
),

get_denominator as (
	select
		count(distinct census_block_group) as ct_distinct_2010_cbg_total
	from 
		cbgs
)

insert into dq_residential_history.pct_distinct_2010_geocodes_invalid 
	(
		site,
		ct_distinct_2010_cbg_invalid,
		ct_distinct_2010_cbg_total,
		pct_distinct_2010_cbg_invalid
	)
select 
	'{{ site }}' as site, 
	ct_distinct_2010_cbg_invalid,
	ct_distinct_2010_cbg_total,
	trunc(ct_distinct_2010_cbg_invalid::numeric / (case when ct_distinct_2010_cbg_total = 0 then 1 else ct_distinct_2010_cbg_total end)::numeric,4) as pct_distinct_2010_cbg_invalid
from 
	get_denominator, get_numerator