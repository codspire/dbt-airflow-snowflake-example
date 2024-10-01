FROM quay.io/astronomer/astro-runtime:12.1.1

ENV AIRFLOW__CORE__TEST_CONNECTION=Enabled

RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
pip install --no-cache-dir dbt-snowflake && deactivate