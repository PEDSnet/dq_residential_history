BEGIN;
with all_patient_location_data as (
	select 
		lh.entity_id as person_id,
		geocode_year,
		case when lf.geocode_tract is not null and lf.geocode_tract not in ('', ' ') then 1 else 0 end as tract_present,
		case when lf.geocode_group is not null and lf.geocode_group not in ('', ' ')then 1 else 0 end as block_group_present
	from 
		{{site}}_pedsnet.location_history lh
	inner join 
		{{site}}_pedsnet.location_fips lf
		on lh.location_id = lf.location_id
),

group_by_person_id as (
	select 
		person_id,
		geocode_year,
		case when sum(tract_present) > 0 then 1 else null end as tract_present,
		case when sum(block_group_present) > 0 then 1 else null end as block_group_present
	from 
		all_patient_location_data
	group by
		person_id,
		geocode_year
),
	
get_numerators as (
select 
	geocode_year,
	count(tract_present) as n_tract_present,
	count(block_group_present) as n_block_group_present
from 
	group_by_person_id
group by 
	geocode_year
),

get_denominator as (
select 
	count(person_id) as n_total
from 
	{{site}}_pedsnet.person p
)

INSERT INTO dq_residential_history.pct_pats_with_loc_his_and_fips (
	site,
    pct_pats_with_2010_tract,
    pct_pats_with_2020_tract,
    pct_pats_with_2010_block_group,
    pct_pats_with_2020_block_group
)
select 
	'{{ site }}' as site,
	max(coalesce(case when geocode_year = '2010' then trunc((n_tract_present::numeric / n_total::numeric),4) end,0)) as pct_pats_with_2010_tract,
	max(coalesce(case when geocode_year = '2020' then trunc((n_tract_present::numeric / n_total::numeric),4) end,0)) as pct_pats_with_2020_tract,
	max(coalesce(case when geocode_year = '2010' then trunc((n_block_group_present::numeric / n_total::numeric),4) end,0)) as pct_pats_with_2010_block_group,
	max(coalesce(case when geocode_year = '2020' then trunc((n_block_group_present::numeric / n_total::numeric),4) end,0)) as pct_pats_with_2020_block_group
from 
	get_denominator, get_numerators;
COMMIT;