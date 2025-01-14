BEGIN;
with lh_cbg as (
select 
    entity_id as person_id,
    start_date,
    coalesce(end_date,'9999-12-31'::date) as end_date,
    trim(geocode_state||geocode_county||geocode_tract||geocode_group) as census_block_group,
    geocode_year
from
    {{site}}_pedsnet.location_history lh 
inner join 
    {{site}}_pedsnet.location_fips fips 
    on lh.location_id = fips.location_id
),

sorted AS (
    SELECT 
    	person_id, 
        census_block_group,
    	geocode_year,
    	start_date, 
    	end_date,
        LAG(end_date) OVER (partition by person_id, geocode_year, census_block_group  ORDER BY person_id, geocode_year, census_block_group, start_date, end_date) AS prev_end_date
    FROM 
        lh_cbg 
),

link_overlap_together as (
SELECT 
    	person_id, 
        census_block_group,
    	geocode_year,
    	start_date, 
    	end_date,
		prev_end_date,
        SUM(CASE WHEN start_date > prev_end_date THEN 1 ELSE 0 END)
           OVER (partition by person_id, geocode_year, census_block_group ORDER BY start_date) AS group_id
    FROM sorted
),

get_overlaps as (
select 
	person_id, 
    census_block_group,
    geocode_year,
    group_id,
	count(*) as ct
from 
	link_overlap_together
group by
	person_id, 
    census_block_group,
    geocode_year,
    group_id
having count(*) > 1
),
	
get_numerators as (
select 
	geocode_year,
	sum(ct) as ct_loc_his_records_with_overlap_cbg_dates
from 
	get_overlaps
group by
	geocode_year
),

get_denominator as (
select 
	count(*) as ct_total_loc_his_records
from 
	{{site}}_pedsnet.location_history
)

INSERT INTO dq_residential_history.pct_loc_his_records_with_overlapping_geocode_dates (
	site,
    ct_loc_his_recs_with_overlap_2010_cbg_dates,
    pct_loc_his_recs_with_overlap_2010_cbg_dates,
    ct_loc_his_recs_with_overlap_2020_cbg_dates,
    pct_loc_his_recs_with_overlap_2020_cbg_dates
)
select 
	'{{ site }}' as site,
	max(coalesce(case when geocode_year = '2010' then ct_loc_his_records_with_overlap_cbg_dates end,0)) as ct_loc_his_recs_with_overlap_2010_cbg_dates,
	max(coalesce(case when geocode_year = '2010' then trunc((ct_loc_his_records_with_overlap_cbg_dates::numeric / ct_total_loc_his_records::numeric),4) end,0)) as pct_loc_his_recs_with_overlap_2010_cbg_dates,
	max(coalesce(case when geocode_year = '2020' then ct_loc_his_records_with_overlap_cbg_dates end,0)) as ct_loc_his_recs_with_overlap_2020_cbg_dates,
	max(coalesce(case when geocode_year = '2020' then trunc((ct_loc_his_records_with_overlap_cbg_dates::numeric / ct_total_loc_his_records::numeric),4) end,0)) as pct_loc_his_recs_with_overlap_2020_cbg_dates
from 
	get_denominator, get_numerators;
COMMIT;
