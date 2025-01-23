BEGIN;
with get_numerator as (
	select 
		count(person_id) as ct_pats_missing_loc_his_record
	from 
		{{ site }}_pedsnet.person p
	where 
		 not exists
			(
			select 
				1
			from
				{{ site }}_pedsnet.location_history lh
			where
				p.person_id = lh.entity_id
			)
),

get_denominator as (
	select 
		count(person_id) as ct_total_pats
	from 
		{{ site }}_pedsnet.person p
)

INSERT INTO dq_residential_history.pct_pats_without_loc_his_record (
	site,
    ct_pats_missing_loc_his_record,
    pct_pats_missing_loc_his_record
)
select 
	'{{ site }}' as site,
	max(coalesce(ct_pats_missing_loc_his_record,0)),
	max(coalesce(trunc(ct_pats_missing_loc_his_record::numeric / ct_total_pats::numeric, 4),0)) as pct_pats_missing_loc_his_record
from
	get_denominator, get_numerator;
commit;