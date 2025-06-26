from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from datetime import datetime

with DAG(
    dag_id='dag_controller',
    start_date=datetime(2024, 1, 1),
    schedule=None,  # Only runs manually or via trigger
    catchup=False,
    tags=["orchestration"]
) as dag:

    start = EmptyOperator(task_id='start')

    trigger_customer = TriggerDagRunOperator(
        task_id='insert_customers_csv_to_postgres',
        trigger_dag_id='insert_customers_csv_to_postgres',
        wait_for_completion=True  # Waits for customer DAG to finish
    )

    trigger_payment = TriggerDagRunOperator(
        task_id='insert_payments_csv_to_postgres',
        trigger_dag_id='insert_payments_csv_to_postgres',
        wait_for_completion=True  # Waits for payment DAG to finish
    )

    end = EmptyOperator(task_id='end')

    # Chain the tasks
    start >> trigger_customer >> trigger_payment >> end
