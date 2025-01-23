-- step 1 
-- consolidate records with same entity_id, location_id and overlapping start_date and end_date
-- create new table location_history_normalized
BEGIN;
create table {{ site }}_pedsnet.location_history_normalized as 
WITH partition_and_sort AS (
    SELECT 
		location_history_id,
    	entity_id, 
        location_id,
    	start_date, 
    	end_date,
        LAG(end_date) OVER (partition by entity_id, location_id ORDER BY entity_id, start_date, end_date) AS prev_end_date
    FROM 
    	{{ site }}_pedsnet.location_history
),

group_overlapping_location_id AS (
    SELECT 
	    location_history_id,
    	entity_id, 
        location_id,
    	start_date, 
    	end_date,
        SUM(CASE WHEN start_date > prev_end_date THEN 1 ELSE 0 END) OVER (partition by entity_id, location_id ORDER BY start_date) AS group_id
    FROM 
        partition_and_sort
),

get_min_max_date_in_group as (
    select
	    location_history_id,
        entity_id, 
        location_id,
        min(start_date) over (partition by entity_id, location_id, group_id) as earliest_start_date,
        max(end_date) over (partition by entity_id, location_id, group_id) as latest_end_date,
        row_number() over (partition by entity_id, location_id, group_id) as num_row
    from
        group_overlapping_location_id
)

select
    location_history_id,
    location_id,
    0 as relationship_type_concept_id,
    'Person' as domain_id,
    entity_id as entity_id,
    44814650 as location_preferred_concept_id,
    earliest_start_date::date as start_date,
    earliest_start_date::timestamp as start_datetime,
    latest_end_date::date as end_date,
    latest_end_date::timestamp as end_datetime
from    
    get_min_max_date_in_group
where 
    num_row = 1;
COMMIT;

-- step 2
-- in cases where date gaps exist for a patient that are > 30 days between location_history records, 
-- update location_history_normalized by setting end_dates of such records = next_start_date
BEGIN;
update 
    {{ site }}_pedsnet.location_history_normalized
set 
    end_date = get_next_start_date.next_start_date::date,
    end_datetime = get_next_start_date.next_start_date::timestamp
from 
    (
    select  
        *,
        LEAD(start_date) over (partition by entity_id order by start_date, end_date) as next_start_date
    from
         {{ site }}_pedsnet.location_history_normalized    
    ) as get_next_start_date
where
    {{ site }}_pedsnet.location_history_normalized.location_history_id = get_next_start_date.location_history_id
    and get_next_start_date.end_date + interval '30 days' < next_start_date;
COMMIT;

-- step 3
-- insert any patients who do not have a location_history record but do have a location_id in the person table AND a visit
-- set start_date to most recent visit max(visit_start_date)
BEGIN;
CREATE Sequence if not exists {{ site }}_pedsnet.location_history_id_missing_pats;

DO $$
DECLARE
    max_val bigint;
BEGIN
    SELECT COALESCE(MAX(location_history_id), 0) + 1 INTO max_val FROM {{ site }}_pedsnet.location_history_normalized;
    PERFORM setval('{{ site }}_pedsnet.location_history_id_missing_pats', max_val, false);
END $$;
COMMIT;

BEGIN;
with patients_without_location_history as (
select 
    person_id, 
    location_id
from 
    {{ site }}_pedsnet.person p
where 
    not exists 
        (
        Select 1 
        from {{ site }}_pedsnet.location_history_normalized lh
        where p.person_id = lh.entity_id
        )
    and p.location_id is not null
)

INSERT INTO {{ site }}_pedsnet.location_history_normalized (
    location_history_id,
    domain_id,
    end_date,
    end_datetime,
    entity_id,
    location_id,
    location_preferred_concept_id,
    relationship_type_concept_id,
    start_date,
    start_datetime
)
select 
	nextval('{{ site }}_pedsnet.location_history_id_missing_pats') as location_history_id,
    'Person' as domain_id,
    NULL as end_date,
	NULL as end_datetime,
    p.person_id as entity_id,
	p.location_id as location_id,
    44814650 as location_preferred_concept_id,
	0 as relationship_type_concept_id,
	most_recent_visit_date as start_date,
	most_recent_visit_date::timestamp as start_datetime
from 
    patients_without_location_history p
inner join  
	(
        select 
            person_id,
            max(visit_start_date) as most_recent_visit_date
        from 
            {{ site }}_pedsnet.visit_occurrence vo
        where 
            person_id in (select person_id from patients_without_location_history)
        group by
            person_id
	) as most_recent_visit
    on p.person_id = most_recent_visit.person_id;
COMMIT;