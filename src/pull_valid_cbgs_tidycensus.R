### PULL Valid 2010 and 2020
install.packages("RPostgres")
install.packages("DBI")
install.packages("gsubfn")
install.packages("ini")
install.packages("tidyverse")
install.packages("tidycensus")

library(RPostgres)
library(DBI)
library(gsubfn)
library(ini)
library(tidyverse)
library(tidycensus)

#postgres connection
db_config <- read.ini("database.ini")
postgresql_config <- db_config$postgresql
con <- dbConnect(RPostgres::Postgres(),
                 dbname <- postgresql_config$database,
                 host <- postgresql_config$host,
                 port <- 5432,
                 password <- postgresql_config$password,
                 user <- postgresql_config$user
                 )

# get state codes used by all sites
# exclude US territories that cannot pull data for
query <- "
      select
        distinct geocode_state
      from
      (
        SELECT geocode_state FROM cchmc_pedsnet.location_fips
        union
        SELECT geocode_state FROM colorado_pedsnet.location_fips
        union
        SELECT geocode_state FROM chop_pedsnet.location_fips
        union
        SELECT geocode_state FROM lurie_pedsnet.location_fips
        union
        SELECT geocode_state FROM national_pedsnet.location_fips
        union
        SELECT geocode_state FROM nationwide_pedsnet.location_fips
        union
        SELECT geocode_state FROM nemours_pedsnet.location_fips
        union
        SELECT geocode_state FROM seattle_pedsnet.location_fips
        union
        SELECT geocode_state FROM stanford_pedsnet.location_fips
        union
        SELECT geocode_state FROM texas_pedsnet.location_fips
      ) as t1
      where geocode_state not in ('60', '66', '69','74','78', 'VI','UM','MP','GU','AS')
      order by geocode_state"

site_states <- dbGetQuery(con, query)
states <- site_states$geocode_state

#use tidycensus get_decennial function to pull 2010 cbgs for each state
2010_block_groups <- lapply(states, function(state) {
  print(state)
  get_decennial(
    geography = "block group",
    variables = "P001001",
    year = 2010,
    state = state,
    output = "wide",
    key = "API KEY" #sign up to get API key here: https://api.census.gov/data/key_signup.html
    )
})

#write 2010 cbgs to database
2010_block_groups_all <- bind_rows(2010_block_groups)
dbExecute(con,'set search_path to dq_residential_history')
dbWriteTable(con, "fips_2010", combined_pop, row.names = FALSE)

#use tidycensus get_decennial function to pull 2020 cbgs for each state
2020_block_groups <- lapply(states, function(state) {
  print(state)
  get_decennial(
    geography = "block group",
    variables = "H1_001N",
    year = 2020,
    state = state,
    output = "wide",
    key = "API KEY" #sign up to get API key here: https://api.census.gov/data/key_signup.html
  )
})

#write 2020 cbgs to database
2020_block_groups_all <- bind_rows(2020_block_groups)
dbExecute(con,'set search_path to dq_residential_history')
dbWriteTable(con, "fips_2020", combined_pop, row.names = FALSE)