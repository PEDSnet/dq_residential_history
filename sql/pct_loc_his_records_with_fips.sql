BEGIN;
with get_numerators as (
	select 
		geocode_year,
		sum(case when lf.geocode_tract is not null and lf.geocode_tract not in ('', ' ') then 1 else 0 end) as n_tract_present,
		sum(case when lf.geocode_group is not null and lf.geocode_group not in ('', ' ')then 1 else 0 end) as n_block_group_present
	from 
		{{site}}_pedsnet.location_history lh
	left join 
		{{site}}_pedsnet.location_fips lf
		on lh.location_id = lf.location_id
	group by
		geocode_year
),

get_denominator as (
	select 
		count(*) as n_total
	from 
		{{site}}_pedsnet.location_history
)

INSERT INTO dq_residential_history.pct_loc_his_records_with_fips (
	site,
    pct_records_with_2010_tract,
    pct_records_with_2020_tract,
    pct_records_with_2010_block_group,
    pct_records_with_2020_block_group
)
select 
	'{{ site }}' as site,
	max(coalesce(case when geocode_year = '2010' then trunc((n_tract_present::numeric / n_total::numeric),4) end,0)) as pct_records_with_2010_tract,
	max(coalesce(case when geocode_year = '2020' then trunc((n_tract_present::numeric / n_total::numeric),4) end,0)) as pct_records_with_2020_tract,
	max(coalesce(case when geocode_year = '2010' then trunc((n_block_group_present::numeric / n_total::numeric),4) end,0)) as pct_records_with_2010_block_group,
	max(coalesce(case when geocode_year = '2020' then trunc((n_block_group_present::numeric / n_total::numeric),4) end,0)) as pct_records_with_2020_block_group
from 
	get_denominator, get_numerators;
COMMIT;