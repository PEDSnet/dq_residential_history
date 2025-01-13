
# **Residential History Geocode Metrics**
This repository is used to run a set of metrics on Site-level PEDSnet data for determining the status and quality of residential history data. Output metrics are written to tables in a schema called `dq_residential_history`.

## Execution
- `config.py `contains functions to read the database.ini file and connect to either a postgres or trino database. In this case, all testing and execution was done using a postgres connection.

- `run_queries.py` contains helper functions for rendering and running SQL files, specifically for iterating across all PEDSnet sites by passing in a `site` variable into each query.

- `sql/` subdirectory contains the SQL logic for creating and populating all metrics.

- `main.ipynb` is where all functions are ran

## SQL Files / Output Tables


### `create_schema.sql`
> Creates the `dq_residential_history` schema.

### `create_tables.sql`
> Creates an empty table for each of the following queries below to insert into. 

### `pct_loc_his_records_with_fips`
> Calculates the percentage of location history records for a given site that have valid census tract or block group for census year 2010 and 2020. It uses a combination of aggregate functions to sum the valid records for each year and compute the percentages of records with valid geocode_tract and geocode_group information.
> 
> Table Fields
> 
> - `site`: The site identifier for the data being processed (represented by the variable {{ site }}).
> - `pct_records_with_2010_tract`: The percentage of records in the year 2010 that have a valid geocode_tract (non-null and not an empty string).
> - `pct_records_with_2020_tract`: The percentage of records in the year 2020 that have a valid geocode_tract (non-null and not an empty string).
> - `pct_records_with_2010_block_group`: The percentage of records in the year 2010 that have a valid geocode_group (non-null and not an empty string).
> - `pct_records_with_2020_block_group`: The percentage of records in the year 2020 that have a valid geocode_group (non-null and not an empty string).

### `pct_pats_with_loc_his_and_fips`

> Calculates the percentage of patients who have location history records with corresponding census tract or block group data for census years 2010 and 2020. It checks whether the census tract or block group data is present for each patient and year, then calculates the percentage of patients with such data by dividing the count of patients with location history data containing census information by the total number of patients.
> 
> Table Fields:
> 
> - `site`: The site identifier for the data being processed (represented by the variable {{ site }}).
> - `pct_pats_with_2010_tract`: The percentage of patients who have location history records with census tract data in 2010, calculated as the number of patients with census tract data divided by the total number of patients.
> - `pct_pats_with_2020_tract`: The percentage of patients who have location history records with census tract data in 2020, calculated as the number of patients with census tract data divided by the total number of patients.
> - `pct_pats_with_2010_block_group`: The percentage of patients who have location history records with census block group data in 2010, calculated as the number of patients with census block group data divided by the total number of patients.
> - `pct_pats_with_2020_block_group`: The percentage of patients who have location history records with census block group data in 2020, calculated as the number of patients with census block group data divided by the total number of patients.

### `pct_pats_without_loc_his_record`
> Calculates and inserts the count and percentage of patients who are missing location history records in the database. It checks for patients who do not have any corresponding records in the location_history table.
> 
> Table Fields:
> 
> - `site`: The site identifier for the data being processed (represented by the variable {{ site }}).
> - `ct_pats_missing_loc_his_record`: The count of patients (from the person table) who do not have any corresponding location history records.
> - `pct_pats_missing_loc_his_record`: The percentage of patients missing location history records, calculated as the count of missing records divided by the total number of patients.

### `pct_loc_his_records_dups` 
> Calculates the count and percentage of duplicate location history records for both 2010 and 2020 census block groups. It identifies duplicate records by checking for repeated combinations of person_id, census_block_group, start_date, and end_date in the location_history table, then calculates the total count of duplicates and distinct duplicates for census year, and finally computes the percentage of duplicates for those census years.
> 
> Table Fields:
> 
> - `site`: The site identifier for the data being processed (represented by the variable {{ site }}).
> - `ct_loc_his_dup_records_2010`: The total count of duplicate location history records for census year 2010.
> - `ct_loc_his_dup_records_distinct_2010`: The count of distinct duplicate location history records for census year 2010.
> - `pct_loc_his_dup_records_2010`: The percentage of duplicate location history records for census year 2010, calculated as the total duplicates divided by the total records.
> - `ct_loc_his_dup_records_2020`: The total count of duplicate location history records for census year 2020.
> - `ct_loc_his_dup_records_distinct_2020`: The count of distinct duplicate location history records for census year 2020.
> - `pct_loc_his_dup_records_2020`: The percentage of duplicate location history records for census year 2020, calculated as the total duplicates divided by the total records.


### `pct_pats_with_dups`
> Calculates the count and percentage of patients who have duplicate location history records for census years 2010 and 2020. The query identifies records with duplicate location history data based on person_id, geocode_year, and location information, then calculates the count of patients with such duplicates for the specified years. The percentage is computed by dividing the count of patients with duplicates by the total number of patients.
> 
> Table Fields:
> 
> - `site`: The site identifier for the data being processed (represented by the variable {{ site }}).
> - `ct_pats_dup_records_2010`: The count of distinct patients who have duplicate location history records in 2010.
> - `pct_pats_dup_records_2010`: The percentage of patients with duplicate location history records in 2010, calculated as the count of such patients divided by the total number of patients.
> - `ct_pats_dup_records_2020`: The count of distinct patients who have duplicate location history records in 2020.
> - `pct_pats_dup_records_2020`: The percentage of patients with duplicate location history records in 2020, calculated as the count of such patients divided by the total number of patients.

### `pct_loc_his_records_with_overlapping_geocode_dates`
> Calculates the number and percentage of location history records with overlapping census block group (census_block_group) location_history dates for census years 2010 and 2020. The query identifies overlapping date ranges for the same person_id and census_block_group within each census year, counts the overlapping records, and computes the percentages of such records for each year.
> 
> Table Fields
> 
> - `site`: The site identifier for the data being processed (represented by the variable {{ site }}).
> - `ct_loc_his_recs_with_overlap_2010_cbg_dates`: The count of location history records for the year 2010 that have overlapping census block group (census_block_group) date ranges.
> - `pct_loc_his_recs_with_overlap_2010_cbg_dates`: The percentage of location history records for the year 2010 that have overlapping census block group (census_block_group) date ranges, calculated as the count of overlapping records divided by the total number of records.
> - `ct_loc_his_recs_with_overlap_2020_cbg_dates`: The count of location history records for the year 2020 that have overlapping census block group (census_block_group) date ranges.
> - `pct_loc_his_recs_with_overlap_2020_cbg_dates`: The percentage of location history records for the year 2020 that have overlapping census block group (census_block_group) date ranges, calculated as the count of overlapping records divided by the total number of records.

### `pct_pats_with_overlapping_geocode_dates`
> Calculates the count and percentage of patients whose location history records overlap across multiple entries within the same census block group (CBG) for census years 2010 and 2020. It checks for overlapping start and end dates within the same census block group and calculates the overlap percentages by dividing the number of patients with such overlaps by the total number of patients.
> 
> Table Fields:
> 
> - `site`: The site identifier for the data being processed (represented by the variable {{ site }}).
> - `ct_pats_with_overlap_2010_cbg_dates`: The count of patients whose location history records overlap in census block groups (CBG) for the year 2010.
> - `pct_pats_with_overlap_2010_cbg_dates`: The percentage of patients whose location history records overlap in census block groups (CBG) for the year 2010, calculated as the count of patients with overlapping records divided by the total number of patients.
> - `ct_pats_with_overlap_2020_cbg_dates`: The count of patients whose location history records overlap in census block groups (CBG) for the year 2020.
> - `pct_pats_with_overlap_2020_cbg_dates`: The percentage of patients whose location history records overlap in census block groups (CBG) for the year 2020, calculated as the count of patients with overlapping records divided by the total number of patients.

### `pct_pats_with_30d_gap`
> Calculates the count and percentage of patients who have a 30-day gap between consecutive location history records. The query checks whether a patient's previous location history record ends more than 30 days before their next record starts. The count of such patients is computed, and the percentage is calculated as the count divided by the total number of patients.
> 
> Table Fields
> 
> - `site`: The site identifier for the data being processed (represented by the variable {{ site }}).
> - `ct_pats_with_30_day_gap`: The count of distinct patients who have at least one gap of more than 30 days between consecutive location history records.
> - `pct_pats_with_30_day_gap`: The percentage of patients who have at least one gap of more than 30 days between location history records, calculated as the count of such patients divided by the total number of patients.

### `pct_pats_per_year_with_encompassing_loc_his`
>  Calculates the count and percentage of patients who have at least one location history record for each year from 2009 to 2024.

> Table Fields
> 
> - `site`: The site identifier for the data being processed (represented by the variable {{ site }}).
> - `year`: The year spanning from 2009 to 2024.
> - `ct_pats_with_loc_his_for_year`: The count of distinct patients who have location history records during the given year.
> - `pct_pats_with_loc_his_for_year`: The percentage of patients who have location history records in that year, calculated as the count of patients with records divided by the total number of patients.
