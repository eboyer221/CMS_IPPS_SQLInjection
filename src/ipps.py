"""
CS3810: Principles of Database Systems
Instructor: Thyago Mota
Student(s):Emily Boyer and Michael Runnels
Description: A data load script for the IPPS database
"""
import os

import psycopg2
import csv
import configparser as cp


def read_config(filename='../src/config.ini', section='db'):
    config = cp.RawConfigParser()
    config.read(filename)
    db_params = {}
    if config.has_section(section):
        params = config.items(section)
        for param in params:
            db_params[param[0]] = param[1]
    else:
        raise Exception(f'Section {section} not found in the {filename} file')
    return db_params


def connect_to_db(db_params):
    try:
        conn = psycopg2.connect(**db_params)
        return conn
    except psycopg2.OperationalError as e:
        print(f"Error connecting to database: {e}")
        return None


def insert_into_table(conn, data):
    for table_name, columns_and_rows in data.items():
        try:
            cursor = conn.cursor()

            # Extract column names from the dictionary
            columns = ', '.join(columns_and_rows[0].keys())

            # Construct the placeholders string for pyformat style
            placeholders = ', '.join([f'%({col})s' for col in columns_and_rows[0]])

            # Construct the INSERT query with pyformat style placeholders
            insert_query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"

            # Execute the query for each row
            for row in columns_and_rows:
                validate_data(row, table_name)  # Validate data before insertion
                cursor.execute(insert_query, row)  # Pass the row directly as values

            # Commit the transaction
            conn.commit()
            print(f"Data inserted into {table_name} table successfully!")
        except (psycopg2.Error, Exception) as e:
            print(f"Error inserting data into {table_name} table: {e}")
            conn.rollback()


def validate_data(data, table_name):
    if table_name == 'Discharges_and_Charges':
        for field in ['Tot_Dschrgs', 'Avg_Submtd_Cvrd_Chrg', 'Avg_Tot_Pymt_Amt', 'Avg_Mdcr_Pymt_Amt']:
            if not isinstance(data[field], (int, float)):
                raise ValueError(f"Invalid data type for {field} in table {table_name}")


def main():
    db_params = read_config()
    conn = connect_to_db(db_params)
    os.chdir("../data")
    if not conn:
        return
    wd = os.getcwd()
    data = {
        'States': list(),
        'Providers': list(),
        'Cities': list(),
        'RUCAs': list(),
        'Discharges_and_Charges': list(),
        'DRGs': list()
    }
    states = set()
    rucas = set()
    providers = set()
    cities = set()
    dc_c = set()
    drg = set()
    try:
        cursor = conn.cursor()
        with open(f"MUP_IHP_RY23_P03_V10_DY21_PRVSVC.CSV") as f:
            reader = csv.DictReader(f, delimiter=',', quotechar='"')
            for row in reader:
                abrvtn_ = row['Rndrng_Prvdr_State_Abrvtn']
                if abrvtn_ not in states:
                    data['States'].append({
                        'FIPS': int(row['Rndrng_Prvdr_State_FIPS']),
                        'Rndrng_Prvdr_State_Abrvtn': abrvtn_
                    })
                    states.add(abrvtn_)
                #Append data for RUCAs table
                abrvtn_ruca = row['Rndrng_Prvdr_RUCA']
                if abrvtn_ruca not in rucas:
                    data['RUCAs'].append({
                        'Rndrng_Prvdr_RUCA': abrvtn_ruca,
                        'Rndrng_Prvdr_RUCA_Desc': row['Rndrng_Prvdr_RUCA_Desc']
                    })
                    rucas.add(abrvtn_ruca)

                abrvtn_drg = row['DRG_Cd']
                if abrvtn_drg not in drg:
                    data['DRGs'].append({
                        'DRG':  abrvtn_drg,
                        'DRG_Desc': row['DRG_Desc']
                    })
                    drg.add(abrvtn_drg)

                abrvtn_prvdr = row['Rndrng_Prvdr_CCN']
                if abrvtn_prvdr not in providers:
                    data['Providers'].append({
                        'Rndrng_Prvdr_CCN': int(abrvtn_prvdr),
                        'Rndrng_Prvdr_Org_Name': str(row['Rndrng_Prvdr_Org_Name']),
                        'Rndrng_Prvdr_St': str(row['Rndrng_Prvdr_St']),
                        'Rndrng_Prvdr_Zip5': int(row['Rndrng_Prvdr_Zip5']),
                        'Rndrng_Prvdr_State_FIPS': int(row['Rndrng_Prvdr_State_FIPS'])
                    })
                    providers.add(abrvtn_prvdr)

                city_zip = row['Rndrng_Prvdr_Zip5']
                if city_zip not in cities:
                    data['Cities'].append({
                        'Zip5': int(city_zip),
                        'City': str(row['Rndrng_Prvdr_City']),
                        'RUCA': float(row['Rndrng_Prvdr_RUCA'])
                    })
                    cities.add(city_zip)

                abrvtn_dc_c =(row['Rndrng_Prvdr_CCN'],row[ 'DRG_Cd'])
                if abrvtn_dc_c not in dc_c:
                    data['Discharges_and_Charges'].append({
                        'Rndrng_CCN': int(row['Rndrng_Prvdr_CCN']),
                        'DRG_Cd': int(row['DRG_Cd']),
                        'Tot_Dschrgs': int(row['Tot_Dschrgs']),
                        'Avg_Submtd_Cvrd_Chrg': float(row['Avg_Submtd_Cvrd_Chrg']),
                        'Avg_Tot_Pymt_Amt': float(row['Avg_Tot_Pymt_Amt']),
                        'Avg_Mdcr_Pymt_Amt': float(row['Avg_Mdcr_Pymt_Amt'])
                    })
                    dc_c.add(abrvtn_dc_c)

            insert_into_table(conn, data)

        conn.commit()
        print("All data inserted successfully!")
    except Exception as e:
        print(f"Error: {e}")
        conn.rollback()
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    main()

