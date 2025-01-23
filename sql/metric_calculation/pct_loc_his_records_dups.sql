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
	sum(ct) as ct_loc_his_dup_records,
	count(ct) as ct_loc_his_dup_records_distinct
from
	find_exact_dups
group by 
	geocode_year
),

get_denominator as (
select 
	count(*) as ct_total_loc_his_records
from 
	{{ site }}_pedsnet.location_history
)

INSERT INTO dq_residential_history.pct_loc_his_records_dups (
	site,
    ct_loc_his_dup_records_2010,
    ct_loc_his_dup_records_distinct_2010,
    pct_loc_his_dup_records_2010,
    ct_loc_his_dup_records_2020,
    ct_loc_his_dup_records_distinct_2020,
    pct_loc_his_dup_records_2020
)
select 
	'{{ site }}' as site,
	max(coalesce(case when geocode_year = '2010' then ct_loc_his_dup_records end,0)) as ct_loc_his_dup_records_2010,
	max(coalesce(case when geocode_year = '2010' then ct_loc_his_dup_records_distinct end,0)) as ct_loc_his_dup_records_distinct_2010,
	max(coalesce(case when geocode_year = '2010' then trunc((ct_loc_his_dup_records::numeric / ct_total_loc_his_records::numeric),4) end,0)) as pct_loc_his_dup_records_2010,
	max(coalesce(case when geocode_year = '2020' then ct_loc_his_dup_records end,0)) as ct_loc_his_dup_records_2020,
	max(coalesce(case when geocode_year = '2020' then ct_loc_his_dup_records_distinct end,0)) as ct_loc_his_dup_records_distinct_2020,
	max(coalesce(case when geocode_year = '2020' then trunc((ct_loc_his_dup_records::numeric / ct_total_loc_his_records::numeric),4) end,0)) as pct_loc_his_dup_records_2020
from	
	get_denominator, get_numerators;
COMMIT;