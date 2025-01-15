with cbgs as (
	select 
	    entity_id as person_id,
	    start_date,
	    trim(geocode_state||geocode_county||geocode_tract||geocode_group) as census_block_group,
	    geocode_year
	from
	    {{ site }}_pedsnet.location_history lh 
	inner join 
	    {{ site }}_pedsnet.location_fips fips 
	    on lh.location_id = fips.location_id
		and geocode_year = 2020
),

get_numerator as (
select 
	count(*) as ct_loc_his_with_2020_cbg_invalid
from 
	cbgs
where
	not exists (select 1 from dq_residential_history.fips_2020 fips where fips.geoid = census_block_group)
),

get_denominator as (
	select
		count(*) as ct_loc_his_with_2020_cbg_total
	from 
		cbgs
)

insert into dq_residential_history.pct_loc_his_records_with_invalid_2020_geocodes 
	(
		site,
		ct_loc_his_with_2020_cbg_invalid,
		ct_loc_his_with_2020_cbg_total,
		pct_loc_his_with_2020_cbg_invalid
	)
select 
	'{{ site }}' as site, 
	ct_loc_his_with_2020_cbg_invalid,
	ct_loc_his_with_2020_cbg_total,
	trunc(ct_loc_his_with_2020_cbg_invalid::numeric / (case when ct_loc_his_with_2020_cbg_total = 0 then 1 else ct_loc_his_with_2020_cbg_total end)::numeric,4) as pct_loc_his_with_2020_cbg_invalid
from 
	get_denominator, get_numerator