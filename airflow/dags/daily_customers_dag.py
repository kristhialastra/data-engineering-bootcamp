from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator
from datetime import datetime
import csv
import psycopg2
import logging
import os

default_args = {
    'start_date': datetime(2024, 1, 1),
    'catchup': False
}

dag = DAG(
    dag_id='insert_customers_csv_to_postgres',
    default_args=default_args,
    schedule=None,  # Run manually
    description='Insert customers.csv into PostgreSQL',
    tags=['customers']
)

def insert_csv_to_postgres():
    csv_path = '/opt/airflow/datasets/customers.csv'
    # csv_path = r'C:\Users\jemima.villanueva_st\Documents\codebase\docker-test\datasets\ecommerce_data\customers.csv'
    log = logging.getLogger(__name__)
    log.info("🔥 DAG task started.")

    if not os.path.exists(csv_path):
        log.error(f"❌ CSV file not found at {csv_path}")
        raise FileNotFoundError(f"File not found: {csv_path}")

    try:
        conn = psycopg2.connect(
            host='postgres',
            database='airflow',
            user='airflow',
            password='airflow'
        )
        cur = conn.cursor()

        with open(csv_path, newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            reader.fieldnames = [h.strip() for h in reader.fieldnames]  # sanitize headers
            log.info(f"📋 CSV Headers: {reader.fieldnames}")

            row_count = 0
            for row in reader:
                log.info(f"➡️ Inserting row: {row}")
                cur.execute(
                    """
                    INSERT INTO internship.customers (
                            customer_id, 
                            name,
                            email,
                            registration_date,
                            city,
                            country)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (
                        row['customer_id'],
                        row['name'],
                        row['email'],
                        row['registration_date'],
                        row['city'],
                        row['country']
                    )
                )
                row_count += 1

        conn.commit()
        cur.close()
        conn.close()
        
    except Exception as e:
        log.error(f"❌ Error inserting data: {str(e)}")
        raise

insert_task = PythonOperator(
    task_id='insert_csv_customer',
    python_callable=insert_csv_to_postgres,
    dag=dag
)

insert_task

# start = DummyOperator(task_id="start")

if __name__ == "__main__":
    insert_csv_to_postgres()

