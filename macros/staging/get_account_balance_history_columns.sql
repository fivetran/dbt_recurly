{% macro get_account_balance_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "account_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "past_due", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}
