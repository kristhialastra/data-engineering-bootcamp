from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator
from airflow.operators.empty import EmptyOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
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
    dag_id='insert_payments_csv_to_postgres',
    default_args=default_args,
    schedule=None,  # Run manually
    description='Insert payments.csv into PostgreSQL',
    tags=['payments']
)

def insert_csv_to_postgres():
    csv_path = '/opt/airflow/datasets/payments.csv'
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
                    INSERT INTO internship.payments (payment_id, order_id, payment_method, amount, payment_date)
                    VALUES (%s, %s, %s, %s, %s)
                    """,
                    (
                        row['payment_id'],
                        row['order_id'],
                        row['payment_method'],
                        row['amount'],
                        row['payment_date']
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
    task_id='insert_csv',
    python_callable=insert_csv_to_postgres,
    dag=dag
)
insert_task

# start = DummyOperator(task_id="start")
# start = EmptyOperator(task_id='start')

# trigger_dag_b = TriggerDagRunOperator(
#         task_id="insert_csv_customer",
#         trigger_dag_id="insert_customers_csv_to_postgres",   # This should match dag_id in dag_b.py
#         wait_for_completion=True, # Optional: wait until dag_b finishes
#         reset_dag_run=True,       # Optional: override existing DAG run if needed
#         poke_interval=10          # How often to check if dag_b is done (if wait=True)
#     )

# start >> trigger_dag_b


if __name__ == "__main__":
    insert_csv_to_postgres()

