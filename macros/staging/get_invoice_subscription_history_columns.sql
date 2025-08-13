{% macro get_invoice_subscription_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "invoice_id", "datatype": dbt.type_string()},
    {"name": "invoice_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "subscription_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
