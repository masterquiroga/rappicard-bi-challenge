import argparse
import pandas as pd
import numpy as np
import dateparser as dp
from google.oauth2 import service_account
from google.cloud import bigquery

from googleapiclient.discovery import build
from googleapiclient.errors import HttpError


# Define command-line arguments
parser = argparse.ArgumentParser(description='Read data from a local XLSX file, clean the data, and upload it to BigQuery')
parser.add_argument('--xlsx-file', default='./data/raw/BIQUIZ.xlsx', help='The path to the XLSX file')
parser.add_argument('--sheet-name', default='Hoja1', help='The name of the sheet within the XLSX file')
parser.add_argument('--project-id', default='rappicard-bi-challenge', help='The ID of the Google Cloud project')
parser.add_argument('--dataset-id', default='raw', help='The ID of the BigQuery dataset')
parser.add_argument('--table-id', default='events', help='The ID of the BigQuery table')
parser.add_argument('--key-file', default='./keys/credentials.json', help='The path to the service account key file')



def read_xlsx_data(xlsx_file, sheet_name):
    """
    Reads data from an XLSX file.

    Args:
        xlsx_file (str): The path to the XLSX file.
        sheet_name (str): The name of the sheet within the XLSX file.

    Returns:
        pandas.DataFrame: The data in the specified sheet.
    """

    # Read data from the specified sheet
    df = pd.read_excel(
        xlsx_file,
        sheet_name=sheet_name,
        parse_dates=False,
        dtype="str",
        names = [
            "ID",
            "UPDATE",
            "STATUS",
            "MOTIVE",
            "INTEREST_RATE",
            "AMOUNT",
            "PRODUCT_ID",
            "CAT",
            "TXN",
            "CP",
            "DELIVERY_SCORE",
            "SALES_CHANNEL"
        ]
    )

    return df


def clean_data(df):
    """
    Cleans the data to ensure it can be uploaded to BigQuery.

    Args:
        df (pandas.DataFrame): The raw data.

    Returns:
        pandas.DataFrame: The cleaned data.
    """
    # Replace rows with missing values
    # df.fillna("", inplace=True)
    df.replace(np.nan, "", regex=True, inplace=True)
    df.drop_duplicates(inplace=True)
    
    # Parse dates 
    df["UPDATE"] = df["UPDATE"].apply(lambda _: 
        dp.parse(
            _,
            languages = ["es", "en"],
            settings = {"TIMEZONE" : "America/Mexico_City"}
        )
    ).apply(lambda _: _.date())
    
    # Impute null values with mean value for numerical columns
    # num_cols = ['INTEREST_RATE', 'AMOUNT', 'TXN', 'CAT', 'CP', 'DELIVERY_SCORE']
    # for col in num_cols:
    #     df[col].fillna(df[col].mean(), inplace=True)
    
    # # Impute null values with mode value for categorical columns
    # cat_cols = ['STATUS', 'MOTIVE', 'SALES_CHANNEL']
    # for col in cat_cols:
    #     df[col].fillna(df[col].mode()[0], inplace=True)
        
    # # Convert datatype of numerical columns to float
    # df[num_cols] = df[num_cols].astype('float')

    # # Convert datatype of CP column to string
    # df['CP'] = df['CP'].astype('str')


    # # Replace "CREDITED" with "APPROVED"
    # df['STATUS'] = np.where(df['STATUS'] == 'CREDITED', 'APPROVED', df['STATUS'])

    # # Remove rows with status other than "APPROVED", "DELIVERED", or "REJECTED"
    # # valid_statuses = ['APPROVED', 'DELIVERED', 'REJECTED']
    # # df = df[df['STATUS'].isin(valid_statuses)]

    # Convert columns to appropriate data types
    # df['AMOUNT'] = df['AMOUNT'].astype(float)
    # df['INTEREST_RATE'] = df['INTEREST_RATE'].astype(float) / 100
    # df['CAT'] = df['CAT'].astype(float) / 100
    
def upload_to_bigquery(df, project_id, dataset_id, table_id, key_file):
    """
    Uploads the data to BigQuery.

    Args:
        df (pandas.DataFrame): The cleaned data.
        project_id (str): The ID of the Google Cloud project.
        dataset_id (str): The ID of the BigQuery dataset.
        table_id (str): The ID of the BigQuery table.
        key_file (str): The path to the service account key file.
    """

    # Authenticate and create the BigQuery client
    credentials = service_account.Credentials.from_service_account_file(key_file)
    bq = bigquery.Client(project=project_id, credentials=credentials)

    # Set the table reference
    table_ref = bq.dataset(dataset_id).table(table_id)

    # Define the schema
    schema = [
        bigquery.SchemaField('ID', 'STRING', mode='REQUIRED'),
        bigquery.SchemaField('UPDATE', 'DATE', mode='REQUIRED'),
        bigquery.SchemaField('STATUS', 'STRING', mode='NULLABLE'),
        bigquery.SchemaField('MOTIVE', 'STRING', mode='NULLABLE'),
        bigquery.SchemaField('INTEREST_RATE', 'STRING', mode='NULLABLE'),
        bigquery.SchemaField('AMOUNT', 'STRING', mode='NULLABLE'),
        bigquery.SchemaField('PRODUCT_ID', 'STRING', mode='NULLABLE'),
        bigquery.SchemaField('CAT', 'STRING', mode='NULLABLE'),
        bigquery.SchemaField('TXN', 'STRING', mode='NULLABLE'),
        bigquery.SchemaField('CP', 'STRING', mode='NULLABLE'),
        bigquery.SchemaField('DELIVERY_SCORE', 'STRING', mode='NULLABLE'),
        bigquery.SchemaField('SALES_CHANNEL', 'STRING', mode='NULLABLE')
    ]

    # Create the table if it doesn't already exist
    try:
        bq.get_table(table_ref)
    except:
        table = bigquery.Table(table_ref, schema=schema)
        bq.create_table(table)

    # Write the DataFrame to BigQuery
    job_config = bigquery.LoadJobConfig(schema=schema)
    job = bq.load_table_from_dataframe(df, table_ref, job_config=job_config)
    job.result()

    print(f'Successfully uploaded {len(df)} rows to BigQuery.')
    
    
if __name__ == '__main__':
    args = parser.parse_args()

    # Read the data from XLSX file
    df = read_xlsx_data(args.xlsx_file, args.sheet_name)

    # Clean the data
    clean_data(df)

    # Upload the data to BigQuery
    upload_to_bigquery(df, args.project_id, args.dataset_id, args.table_id, args.key_file)
    
    # Alternatively also save it locally
    df.to_csv("./data/preproc/events.csv")
