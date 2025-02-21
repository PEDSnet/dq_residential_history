begin;
CREATE TABLE IF NOT EXISTS dq_residential_history.pct_pats_with_loc_his_and_fips(
    site varchar(10),
    pct_pats_with_2010_tract numeric,
    pct_pats_with_2020_tract numeric,
    pct_pats_with_2010_block_group numeric,
    pct_pats_with_2020_block_group numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_loc_his_records_with_fips(
    site varchar(10),
    pct_records_with_2010_tract numeric,
    pct_records_with_2020_tract numeric,
    pct_records_with_2010_block_group numeric,
    pct_records_with_2020_block_group numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_loc_his_records_dups (
	site varchar(10),
    ct_loc_his_dup_records_2010 int,
    ct_loc_his_dup_records_distinct_2010 int,
    pct_loc_his_dup_records_2010 numeric,
    ct_loc_his_dup_records_2020 int,
    ct_loc_his_dup_records_distinct_2020 int,
    pct_loc_his_dup_records_2020 numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_pats_with_dups (
	site varchar(10),
    ct_pats_dup_records_2010 int,
    pct_pats_dup_records_2010 numeric,
    ct_pats_dup_records_2020 int,
    pct_pats_dup_records_2020 numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_pats_with_30d_gap (
	site varchar(10),
    ct_pats_with_30_day_gap int,
    pct_pats_with_30_day_gap numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_pats_without_loc_his_record (
	site varchar(10),
    ct_pats_missing_loc_his_record int,
    pct_pats_missing_loc_his_record numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_pats_per_year_with_encompassing_loc_his (
	site varchar(10),
    year int,
    ct_pats_with_loc_his_for_year int,
    pct_pats_with_loc_his_for_year numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_pats_with_overlapping_geocode_dates (
	site varchar(10),
    ct_pats_with_overlap_2010_cbg_dates int,
    pct_pats_with_overlap_2010_cbg_dates numeric,
    ct_pats_with_overlap_2020_cbg_dates int,
    pct_pats_with_overlap_2020_cbg_dates numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_loc_his_records_with_overlapping_geocode_dates (
	site varchar(10),
    ct_loc_his_recs_with_overlap_2010_cbg_dates int,
    pct_loc_his_recs_with_overlap_2010_cbg_dates numeric,
    ct_loc_his_recs_with_overlap_2020_cbg_dates int,
    pct_loc_his_recs_with_overlap_2020_cbg_dates numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_distinct_2010_geocodes_invalid (
		site varchar(10),
		ct_distinct_2010_cbg_invalid int,
		ct_distinct_2010_cbg_total int,
		pct_distinct_2010_cbg_invalid numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_distinct_2020_geocodes_invalid (
		site varchar(10),
		ct_distinct_2020_cbg_invalid int,
		ct_distinct_2020_cbg_total int,
		pct_distinct_2020_cbg_invalid numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_loc_his_records_with_invalid_2010_geocodes 
	(
		site varchar(10),
		ct_loc_his_with_2010_cbg_invalid int, 
		ct_loc_his_with_2010_cbg_total int,
		pct_loc_his_with_2010_cbg_invalid numeric
);

CREATE TABLE IF NOT EXISTS dq_residential_history.pct_loc_his_records_with_invalid_2020_geocodes 
	(
		site varchar(10),
		ct_loc_his_with_2020_cbg_invalid int, 
		ct_loc_his_with_2020_cbg_total int,
		pct_loc_his_with_2020_cbg_invalid numeric
);

commit;
