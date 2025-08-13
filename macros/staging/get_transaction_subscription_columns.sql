{% macro get_transaction_subscription_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "transaction_id", "datatype": dbt.type_string()},
    {"name": "subscription_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
