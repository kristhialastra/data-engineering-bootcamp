# 🌀 Airflow + Postgres + Python Dockerized ETL Project

A minimal ETL setup using **Apache Airflow**, **PostgreSQL**, and **Python**, containerized using **Docker**.

---

## 📁 Project Structure

```
project-root/
├── airflow/
│ ├── dags/
│ └── logs/
├── datasets/
│ └── payments.csv
├── postgres/
│ └── init.sql
├── docker-compose.yml
└── .gitignore
```

## 📦 Docker Commands

| Action        | Command
|---------------|---------------
| Build containers  | docker-compose build
| Start Containers | docker-compose up
| Stop Containers | docker-compose down
| Restart Containers | docker-compose restart
| Open shell in container | docker exec -it airflow-webserver bash
| View logs | docker-compose logs -f airflow-webserver

## 📦 How to use the Repository

1. Installed WSL, Dbeaver, Docker Desktop on local machine
2. Clone the repository
3. Build and start all services defined in docker-compose.yml

    ```
    docker compose up -d
    ```

    Check if the containers are created

    ```
    docker ps
    ```
    
    If there are changes in the yml file recreate the containers

    ```
    docker compose up -d --build
    ```

4. Initialize airflow-webserver
        
    ```
    docker compose run airflow-webserver-lab airflow db init
    ```
    Rerun the container

    ```
    docker compose up -d
    ```

    Create or Reset Airflow Admin User
    ```
    docker exec -it airflow-webserver bash
    ```

    Create new admin user
    ```
    airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com \
    --password admin
    ```

    Access UI through http://localhost:8080 then log in using
    ```
    Username: admin
    Password: admin
    ```
5. Test if jupyternotebook is running 
    At **notebooks\create_ddl.ipynb** change the parameters and and run the scripts

6. Connect and test PostgreSQL database to dbeaver
    https://dbeaver.com/docs/dbeaver/Create-Connection/#use-the-new-connection-wizard

7. 