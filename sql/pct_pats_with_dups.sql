BEGIN;
with find_exact_dups as (
	select 
		lh.entity_id as person_id,
		geocode_year,
		trim(geocode_state||geocode_county||geocode_tract||geocode_group) as census_block_group,
		start_date,
		end_date,
		count(distinct location_history_id) as ct
	from 
		{{ site }}_pedsnet.location_history lh
	inner join 
		{{ site }}_pedsnet.location_fips lf
		on lh.location_id = lf.location_id
	group by
		lh.entity_id,
		geocode_year,
		trim(geocode_state||geocode_county||geocode_tract||geocode_group),
		start_date,
		end_date
	having count(*) > 1
),
	
get_numerators as (
select 
	geocode_year,
	count(distinct person_id) as ct_pats_with_dups
from
	find_exact_dups
group by 
	geocode_year
),

get_denominator as (
select 
	count(*) as ct_total_pats
from 
	{{ site }}_pedsnet.person
)

INSERT INTO dq_residential_history.pct_pats_with_dups (
	site,
    ct_pats_dup_records_2010,
    pct_pats_dup_records_2010,
    ct_pats_dup_records_2020,
    pct_pats_dup_records_2020
)
select 
	'{{ site }}' as site,
	max(coalesce(case when geocode_year = '2010' then ct_pats_with_dups end,0)) as ct_pats_dup_records_2010,
	max(coalesce(case when geocode_year = '2010' then trunc((ct_pats_with_dups::numeric / ct_total_pats::numeric),4) end,0)) as pct_pats_dup_records_2010,
	max(coalesce(case when geocode_year = '2020' then ct_pats_with_dups end,0)) as ct_pats_dup_records_2020,
	max(coalesce(case when geocode_year = '2020' then trunc((ct_pats_with_dups::numeric / ct_total_pats::numeric),4) end,0)) as pct_pats_dup_records_2020
from	
	get_denominator, get_numerators;
COMMIT;