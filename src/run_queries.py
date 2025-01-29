from config.config import *
import time
import datetime
import os
import glob
import pandas as pd
from jinja2 import Template

#read SQL Query with site variable value parsed into template
def read_and_render_sql_file(file_path, site = ''):
    try:
        with open(file_path, 'r') as sql_file:
            sql_query = sql_file.read()
        template = Template(sql_query)
        rendered_sql = template.render({"site": site})
        return rendered_sql
    except Exception as e:
        print(f"Error rendering templated variables in SQL Query: {e}")

#execute SQL file
def execute_sql_file(sql_query):
    try:
        with get_db_connection('config/database.ini') as conn:
            with conn.cursor() as cur:
                cur.execute(sql_query)
                print("Successfully executed SQL file")
    except Exception as e:
        print(f"Error executing SQL query: {e}")

#loop across all sites and execute above two functions for each site
def render_and_execute_query_against_all_sites(file_path):
    for site in ['cchmc','chop','colorado','lurie','national','nationwide', 'nemours', 'seattle','stanford','texas']:
        print(site)
        site_query  = read_and_render_sql_file(file_path, site)
        execute_sql_file(site_query)