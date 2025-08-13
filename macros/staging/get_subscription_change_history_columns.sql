{% macro get_subscription_change_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "plan_id", "datatype": dbt.type_string()},
    {"name": "subscription_id", "datatype": dbt.type_string()},
    {"name": "object", "datatype": dbt.type_string()},
    {"name": "unit_amount", "datatype": dbt.type_float()},
    {"name": "quantity", "datatype": dbt.type_int()},
    {"name": "activate_at", "datatype": dbt.type_timestamp()},
    {"name": "activated", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "deleted_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
