-- link location_history_normalized to 2020 fips codes
-- then consolidates records with same entity_id, 2020 census_block_group, and overlapping start_date and end_date
BEGIN;
create table if not exists {{ site }}_pedsnet.location_history_dedup_2020_geocodes as 
with lh_2020_fips_linkage as (
    select 
        location_history_id,
        entity_id as person_id,
        lh.location_id as location_id,
        start_date,
        coalesce(end_date,'9999-12-31'::date) as end_date,
        trim(geocode_state||geocode_county||geocode_tract||geocode_group) as census_block_group
    from
        {{ site }}_pedsnet.location_history_normalized lh 
    inner join 
        {{ site }}_pedsnet.location_fips fips 
        on lh.location_id = fips.location_id
        and fips.geocode_year = 2020
),

partition_and_sort as (
    SELECT 
        location_history_id,
    	person_id, 
        location_id,
        census_block_group,
    	start_date, 
    	end_date,
        LAG(end_date) OVER (partition by person_id, census_block_group ORDER BY person_id, census_block_group, start_date, end_date) AS prev_end_date
    FROM 
        lh_2020_fips_linkage
),

group_overlapping_cbg AS (
    SELECT 
        location_history_id,
    	person_id, 
        location_id,
        census_block_group,
    	start_date, 
    	end_date,
        SUM(CASE WHEN start_date > prev_end_date THEN 1 ELSE 0 END) OVER (partition by person_id, census_block_group ORDER BY start_date) AS group_id
    FROM
        partition_and_sort
),

get_min_max_date_in_group as (
    select
        location_history_id,
        person_id, 
        location_id,
        census_block_group,
        min(start_date) over (partition by person_id, census_block_group, group_id) as earliest_start_date,
        max(end_date) over (partition by person_id, census_block_group, group_id) as latest_end_date,
        row_number() over (partition by person_id, census_block_group, group_id) as num_row
    from
        group_overlapping_cbg
)

select
    person_id,
    earliest_start_date::date as start_date,
    latest_end_date::date as end_date,
    2020 as census_year,
    census_block_group
from    
    get_min_max_date_in_group
where 
    num_row = 1
order by
    person_id,
    start_date,
    end_date;
COMMIT;