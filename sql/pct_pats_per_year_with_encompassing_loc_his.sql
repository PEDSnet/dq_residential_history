BEGIN;
WITH year_range AS (
    SELECT generate_series(2009, 2024) AS year
),
	
get_numerator as (
	SELECT
	    yr.year,
	    COUNT(DISTINCT t.entity_id) AS ct_pats_with_loc_his_for_year
	FROM 
		year_range yr
	LEFT JOIN 
		{{site}}_pedsnet.location_history t
		ON yr.year BETWEEN EXTRACT(YEAR FROM t.start_date) AND coalesce(EXTRACT(YEAR FROM t.end_date), 2025)
	GROUP BY 
		yr.year
),

get_denominator as (
	select 
		count(*) as ct_total_pats
	from 
		{{site}}_pedsnet.person
)

INSERT INTO dq_residential_history.pct_pats_per_year_with_encompassing_loc_his (
	site,
    year,
    ct_pats_with_loc_his_for_year,
    pct_pats_with_loc_his_for_year
)
select 
	'{{ site }}' as site,
	year,
	max(coalesce(ct_pats_with_loc_his_for_year,0)),
	max(coalesce(trunc(ct_pats_with_loc_his_for_year::numeric / ct_total_pats::numeric, 4),0)) as pct_pats_with_loc_his_for_year
from
	get_denominator, get_numerator
group by
	year
ORDER BY 
	year;
COMMIT;