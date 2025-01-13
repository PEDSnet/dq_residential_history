import configparser
import psycopg2
import trino

def config(filename, section):
    # create a parser
    parser = configparser.ConfigParser()
    # read config file
    parser.read(filename)
    # get the section, sefault to postgresql
    db = {}
    #check .ini files for section input, if true, returns credential info in form of a dictionary
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('file {} not found'.format(filename))
    return db

def get_db_connection(filename):
    #get database config info and connect
    params = config(filename, section = 'postgresql')
    db_name = params['database']
    print('Connecting to the PostgreSQL database...')
    conn = psycopg2.connect(**params)
    return conn

def get_trino_connection(filename):
    #get database config info and connect
    params = config(filename, section = 'trino')
    # generate trino auth method
    if 'user' in params.keys() and 'password' in params.keys():
        params['auth'] = trino.auth.BasicAuthentication(params['user'], params['password'])
        del params['user']
        del params['password']
    if 'http_scheme' not in params.keys():
        params['http_scheme'] = 'https'
    conn = trino.dbapi.connect(**params)
    print('Connecting to Trino is successful')
    return conn