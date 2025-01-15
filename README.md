# **Residential History Data Quality**
This repository is used to run a set of metrics on Site-level PEDSnet data for determining the status and quality of residential history data. Output metrics are written to tables in a schema called `dq_residential_history`. Metrics are then collected into an html report.

# Contents

##Config/
###`database.ini` 
> Enter database connection strings here

###`config.py` 
> Python helper functions to read the database.ini file and connect to either a postgres or trino database. 

##SRC/
###`run_queries.py` 
>Functions for rendering and running all .sql files. Specifically, it can iterate across all PEDSnet sites by passing in a `site` variable into each SQL query file.

###`main.ipynb` 
> Notebook where run_queries.py functions are ran

###`pull_valid_cbgs_tidycensus.R` 
> R script for pulling list of valid US census codes


##Reporting/
### `geocoding_summary.Rmd` 
> R script for visualizing results 

## SQL/

### `create_schema.sql`
> Creates the `dq_residential_history` schema.

### `create_tables.sql`
> Creates an empty table for each of the following queries below to insert into. 

### `pct_loc_his_records_with_fips.sql`
> Calculates the percentage of location history records for a given site that have valid census tract or block group for census year 2010 and 2020. It uses a combination of aggregate functions to sum the valid records for each year and compute the percentages of records with valid geocode_tract and geocode_group information.
> 
> Table Fields
> 
> - `site`: The site identifier for the data being processed.
> - `pct_records_with_2010_tract`: The percentage of location_history records in the year 2010 that have a valid geocode_tract.
> - `pct_records_with_2020_tract`: The percentage of location_history records in the year 2020 that have a valid geocode_tract.
> - `pct_records_with_2010_block_group`: The percentage of location_history records in the year 2010 that have a valid geocode_group.
> - `pct_records_with_2020_block_group`: The percentage of location_history records in the year 2020 that have a valid geocode_group.

### `pct_pats_with_loc_his_and_fips.sql`

> Calculates the percentage of patients who have location history records with corresponding census tract or block group data for census years 2010 and 2020. It checks whether the census tract or block group data is present for each patient and year, then calculates the percentage of patients with such data by dividing the count of patients with location history data containing census information by the total number of patients.
> 
> Table Fields:
> 
> - `site`: The site identifier for the data being processed.
> - `pct_pats_with_2010_tract`: The percentage of patients who have location history records with census tract data in 2010, calculated as the number of patients with census tract data divided by the total number of patients.
> - `pct_pats_with_2020_tract`: The percentage of patients who have location history records with census tract data in 2020, calculated as the number of patients with census tract data divided by the total number of patients.
> - `pct_pats_with_2010_block_group`: The percentage of patients who have location history records with census block group data in 2010, calculated as the number of patients with census block group data divided by the total number of patients.
> - `pct_pats_with_2020_block_group`: The percentage of patients who have location history records with census block group data in 2020, calculated as the number of patients with census block group data divided by the total number of patients.

### `pct_pats_without_loc_his_record.sql`
> Calculates and inserts the count and percentage of patients who are missing location history records in the database. It checks for patients who do not have any corresponding records in the location_history table.
> 
> Table Fields:
> 
> - `site`: The site identifier for the data being processed.
> - `ct_pats_missing_loc_his_record`: The count of patients (from the person table) who do not have any corresponding location history records.
> - `pct_pats_missing_loc_his_record`: The percentage of patients missing location history records, calculated as the count of missing records divided by the total number of patients.

### `pct_loc_his_records_dups.sql` 
> Calculates the count and percentage of duplicate location history records for both 2010 and 2020 census block groups. It identifies duplicate records by checking for repeated combinations of person_id, census_block_group, start_date, and end_date in the location_history table, then calculates the total count of duplicates and distinct duplicates for census year, and finally computes the percentage of duplicates for those census years.
> 
> Table Fields:
> 
> - `site`: The site identifier for the data being processed.
> - `ct_loc_his_dup_records_2010`: The total count of duplicate location history records for census year 2010.
> - `ct_loc_his_dup_records_distinct_2010`: The count of distinct duplicate location history records for census year 2010.
> - `pct_loc_his_dup_records_2010`: The percentage of duplicate location history records for census year 2010, calculated as the total duplicates divided by the total records.
> - `ct_loc_his_dup_records_2020`: The total count of duplicate location history records for census year 2020.
> - `ct_loc_his_dup_records_distinct_2020`: The count of distinct duplicate location history records for census year 2020.
> - `pct_loc_his_dup_records_2020`: The percentage of duplicate location history records for census year 2020, calculated as the total duplicates divided by the total records.


### `pct_pats_with_dups.sql`
> Calculates the count and percentage of patients who have duplicate location history records for census years 2010 and 2020. The query identifies records with duplicate location history data based on person_id, geocode_year, and location information, then calculates the count of patients with such duplicates for the specified years. The percentage is computed by dividing the count of patients with duplicates by the total number of patients.
> 
> Table Fields:
> 
> - `site`: The site identifier for the data being processed.
> - `ct_pats_dup_records_2010`: The count of distinct patients who have duplicate location history records in 2010.
> - `pct_pats_dup_records_2010`: The percentage of patients with duplicate location history records in 2010, calculated as the count of such patients divided by the total number of patients.
> - `ct_pats_dup_records_2020`: The count of distinct patients who have duplicate location history records in 2020.
> - `pct_pats_dup_records_2020`: The percentage of patients with duplicate location history records in 2020, calculated as the count of such patients divided by the total number of patients.

### `pct_loc_his_records_with_overlapping_geocode_dates.sql`
> Calculates the number and percentage of location history records with overlapping census block group (census_block_group) location_history dates for census years 2010 and 2020. The query identifies overlapping date ranges for the same person_id and census_block_group within each census year, counts the overlapping records, and computes the percentages of such records for each year.
> 
> Table Fields
> 
> - `site`: The site identifier for the data being processed.
> - `ct_loc_his_recs_with_overlap_2010_cbg_dates`: The count of location history records for the year 2010 that have overlapping census block group (census_block_group) date ranges.
> - `pct_loc_his_recs_with_overlap_2010_cbg_dates`: The percentage of location history records for the year 2010 that have overlapping census block group (census_block_group) date ranges, calculated as the count of overlapping records divided by the total number of records.
> - `ct_loc_his_recs_with_overlap_2020_cbg_dates`: The count of location history records for the year 2020 that have overlapping census block group (census_block_group) date ranges.
> - `pct_loc_his_recs_with_overlap_2020_cbg_dates`: The percentage of location history records for the year 2020 that have overlapping census block group (census_block_group) date ranges, calculated as the count of overlapping records divided by the total number of records.

### `pct_pats_with_overlapping_geocode_dates.sql`
> Calculates the count and percentage of patients whose location history records overlap across multiple entries within the same census block group (CBG) for census years 2010 and 2020. It checks for overlapping start and end dates within the same census block group and calculates the overlap percentages by dividing the number of patients with such overlaps by the total number of patients.
> 
> Table Fields:
> 
> - `site`: The site identifier for the data being processed.
> - `ct_pats_with_overlap_2010_cbg_dates`: The count of patients whose location history records overlap in census block groups (CBG) for the year 2010.
> - `pct_pats_with_overlap_2010_cbg_dates`: The percentage of patients whose location history records overlap in census block groups (CBG) for the year 2010, calculated as the count of patients with overlapping records divided by the total number of patients.
> - `ct_pats_with_overlap_2020_cbg_dates`: The count of patients whose location history records overlap in census block groups (CBG) for the year 2020.
> - `pct_pats_with_overlap_2020_cbg_dates`: The percentage of patients whose location history records overlap in census block groups (CBG) for the year 2020, calculated as the count of patients with overlapping records divided by the total number of patients.

### `pct_pats_with_30d_gap.sql`
> Calculates the count and percentage of patients who have a 30-day gap between consecutive location history records. The query checks whether a patient's previous location history record ends more than 30 days before their next record starts. The count of such patients is computed, and the percentage is calculated as the count divided by the total number of patients.
> 
> Table Fields
> 
> - `site`: The site identifier for the data being processed.
> - `ct_pats_with_30_day_gap`: The count of distinct patients who have at least one gap of more than 30 days between consecutive location history records.
> - `pct_pats_with_30_day_gap`: The percentage of patients who have at least one gap of more than 30 days between location history records, calculated as the count of such patients divided by the total number of patients.

### `pct_pats_per_year_with_encompassing_loc_his.sql`
>  Calculates the count and percentage of patients who have at least one location history record for each year from 2009 to 2024.

> Table Fields
> 
> - `site`: The site identifier for the data being processed.
> - `year`: The year spanning from 2009 to 2024.
> - `ct_pats_with_loc_his_for_year`: The count of distinct patients who have location history records during the given year.
> - `pct_pats_with_loc_his_for_year`: The percentage of patients who have location history records in that year, calculated as the count of patients with records divided by the total number of patients.

### `pct_distinct_2010_geocodes_invalid.sql`
> Calculates the percentage of distinct 2010 Census Block Groups (CBGs) in the location_fips table that are invalid by comparing them to a US Census reference table (fips_2010)

> Table Fields
> 
> - `site`: The site identifier for the data being processed.
> - `ct_distinct_2010_cbg_invalid`: The count of distinct 2010 Census Block Groups in the location_fips table that do not exist in the reference table fips_2010.
> - `ct_distinct_2010_cbg_total`: The total count of distinct 2010 Census Block Groups in the location_fips table.
> - `pct_distinct_2010_cbg_invalid`: The percentage of invalid distinct 2010 Census Block Groups, calculated as the ratio of ct_distinct_2010_cbg_invalid to ct_distinct_2010_cbg_total.

### `pct_distinct_2020_geocodes_invalid.sql`
> Calculates the percentage of distinct 2020 Census Block Groups (CBGs) in the location_fips table that are invalid by comparing them to a US Census reference table (fips_2020)

> Table Fields
> 
> - `site`: The site identifier for the data being processed.
> - `ct_distinct_2020_cbg_invalid`: The count of distinct 2020 Census Block Groups in the location_fips table that do not exist in the reference table fips_2020.
> - `ct_distinct_2020_cbg_total`: The total count of distinct 2020 Census Block Groups in the location_fips table.
> - `pct_distinct_2020_cbg_invalid`: The percentage of invalid distinct 2020 Census Block Groups, calculated as the ratio of ct_distinct_2020_cbg_invalid to ct_distinct_2020_cbg_total.

### `pct_loc_his_records_with_invalid_2010_geocodes.sql`

> Calculates the percentage of location_history records with a 2010 Census Block Group (CBG) whose CBG value is invalid by comparing to a US Census reference table (fips_2020)
> 
> Table Fields
> 
> - `site`: The site identifier for the data being processed.
> - `ct_loc_his_with_2010_cbg_invalid`: The count of location_history records that have a 2010 Census Block Group in the location_fips table that dose not exist in the reference table fips_2010
> - `ct_loc_his_with_2010_cbg_total`: The total count of location_history records that have a 2010 Census Block Group in the location_fips table.
> - `pct_loc_his_with_2010_cbg_invalid`: The percentage of location_history records with an invalid 2010 Census Block Group, calculated as the ratio of ct_loc_his_with_2010_cbg_invalid to ct_loc_his_with_2010_cbg_total

### `pct_loc_his_records_with_invalid_2020_geocodes.sql`

> Calculates the percentage of location_history records with a 2020 Census Block Group (CBG) whose CBG value is invalid by comparing to a US Census reference table (fips_2020)
> 
> Table Fields
> 
> - `site`: The site identifier for the data being processed.
> - `ct_loc_his_with_2020_cbg_invalid`: The count of location_history records that have a 2020 Census Block Group in the location_fips table that dose not exist in the reference table fips_2020
> - `ct_loc_his_with_2020_cbg_total`: The total count of location_history records that have a 2020 Census Block Group in the location_fips table.
> - `pct_loc_his_with_2020_cbg_invalid`: The percentage of location_history records with an invalid 2020 Census Block Group, calculated as the ratio of ct_loc_his_with_2010_cbg_invalid to ct_loc_his_with_2010_cbg_total
