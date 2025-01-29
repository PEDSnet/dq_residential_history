BEGIN;
CREATE Sequence if not exists {{ site }}_pedsnet.location_history_dedup_geocodes_id;
COMMIT;

BEGIN;
create table if not exists {{ site }}_pedsnet.location_history_geocodes_normalized as 
select
    nextval('{{ site }}_pedsnet.location_history_dedup_geocodes_id') as location_history_dedup_geocodes_id,
    census_year,
    person_id,
    start_date,
    end_date, 
    SUBSTRING(census_block_group FROM 1 FOR 2) AS geocode_state,
    SUBSTRING(census_block_group FROM 3 FOR 3) AS geocode_county,
    SUBSTRING(census_block_group FROM 6 FOR 6) AS geocode_tract,
    SUBSTRING(census_block_group FROM 12 FOR 1) AS geocode_block_group
from
    (
    select *
    from {{ site }}_pedsnet.location_history_dedup_2010_geocodes
    union
    select *
    from {{ site }}_pedsnet.location_history_dedup_2020_geocodes
    ) as combine_census_years
order by
    census_year,
    person_id,
    start_date,
    end_date;
COMMIT;

BEGIN;
drop table {{ site }}_pedsnet.location_history_dedup_2010_geocodes;
drop table {{ site }}_pedsnet.location_history_dedup_2020_geocodes;
DROP Sequence {{ site }}_pedsnet.location_history_id_missing_pats;
DROP Sequence {{ site }}_pedsnet.location_history_dedup_geocodes_id;

