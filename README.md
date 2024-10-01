## Credits

This project is forked from https://github.com/ClearPeaks/poc-dbt-airflow-snowflake

https://www.clearpeaks.com/orchestrating-dbt-on-snowflake-using-airflow-and-astro/

## Overview

This project shows a simple example of Apache Airflow, DBT, and Snowflake to construct a data pipeline. The objective is to import raw data into Snowflake, apply DBT transformations, and furnish clean, analysis-ready datasets for BI Tools visualization.

## Sample Dataset

We use a Maven Analytics sample dataset, comprising two CSV files, featuring churn customer data from a fictional telecom firm. The primary CSV file contains 38 columns encompassing personal, contractual, and revenue details of 7,043 California-based customers. The second CSV file includes zip code and population information.

https://mavenanalytics.io/data-playground

## Project Contents

The project contains the following files and folders:

- `dags`: This folder contains the Python files for your Airflow DAGs. By default, this directory includes two example DAGs:
    - `poc_dbt_snowflake`: PoC 
- `Dockerfile`: This file contains a versioned Astro Runtime Docker image that provides a differentiated Airflow experience. If you want to execute other commands or overrides at runtime, specify them here.
- `include`: This folder contains any additional files that you want to include as part of your project. It is empty by default.
- `packages.txt`: Install OS-level packages needed for your project by adding them to this file. It is empty by default.
- `requirements.txt`: Install Python packages needed for your project by adding them to this file. It is empty by default.
- `plugins`: Add custom or community plugins for your project to this file. It is empty by default.
- `airflow_settings.yaml`: Use this local-only file to specify Airflow Connections, Variables, and Pools instead of entering them in the Airflow UI as you develop DAGs in this project.


## Snowflake Setup

Login as `ACCOUNTADMIN` in your Snowflake account and perform below steps:

```sql
CREATE DATABASE POC_DBT_AIRFLOW_DB;

CREATE ROLE DBT_AIRFLOW_ROLE;

CREATE USER DBT_AIRFLOW_USER PASSWORD='abc123' DEFAULT_ROLE = DBT_AIRFLOW_ROLE DEFAULT_SECONDARY_ROLES = ('ALL') MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE DBT_AIRFLOW_ROLE TO USER DBT_AIRFLOW_USER;

CREATE OR REPLACE WAREHOUSE DBT_AIRFLOW_WH WITH WAREHOUSE_SIZE='X-SMALL';

GRANT USAGE, OPERATE ON WAREHOUSE DBT_AIRFLOW_WH TO ROLE DBT_AIRFLOW_ROLE;

GRANT OWNERSHIP ON DATABASE POC_DBT_AIRFLOW_DB TO ROLE DBT_AIRFLOW_ROLE;

GRANT ALL PRIVILEGES ON DATABASE POC_DBT_AIRFLOW_DB TO ROLE DBT_AIRFLOW_ROLE;
```

This will create create below resources in Snowflake
- Database `POC_DBT_AIRFLOW_DB`
- Role `DBT_AIRFLOW_ROLE`
- User `DBT_AIRFLOW_USER` . You'd need to login with this user and set a new password. The password will be used to configure Snowflake connection in Airflow.
- X-Small Warehouse `DBT_AIRFLOW_WH`


## Deploy Your Project Locally

1. Start Airflow on your local machine. Astro installation instructions https://www.astronomer.io/docs/astro/cli/install-cli

```
astro dev start
```

This command will spin up 4 Docker containers on your machine, each for a different Airflow component:
 - Postgres: Airflow's Metadata Database
 - Webserver: The Airflow component responsible for rendering the Airflow UI
 - Scheduler: The Airflow component responsible for monitoring and triggering tasks
 - Triggerer: The Airflow component responsible for triggering deferred tasks

2. Verify that all 4 Docker containers were created by running

```
docker ps
```
 - Running `astro dev start` will start your project with the Airflow Webserver exposed at port `8080` and Postgres exposed at port `5432`.

3. Access the Airflow UI for your local Airflow project. To do so, go to http://localhost:8080/ and log in with 'admin' for both your Username and Password.

You should also be able to access your Postgres Database at 'localhost:5432/postgres'.

4. Setup Snowflake Connection in Airflow
- Login to Airflow UI http://localhost:8080/
- Admin -> Connections
- Setup Snowflake connection
    - Connection Id: `snowflake_conn`
    - Login: `DBT_AIRFLOW_USER`
    - Password: Use the password that you've set after login to Snowflake with above user
    - Account: Your Snowflake Account Id
    - Warehouse: `DBT_AIRFLOW_WH`
    - Database: `POC_DBT_AIRFLOW_DB`
    - Region: Specify the Snowflake region, in my case it is `us-east-1`
    - Role: `DBT_AIRFLOW_ROLE`
    - Turn off OCSP certificate check for local testing
    - Click on Test to validate connection with Snowflake.

![](media/Airflow%20-%20Snowflake%20Connection%20Settings.png)

5. Trigger the DAG in Airflow

![](media/Airflow%20DAG.png)

6. Validate the data in Snowflake
![](media/Snowflake.png)