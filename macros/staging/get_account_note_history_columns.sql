{% macro get_account_note_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "account_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "message", "datatype": dbt.type_string()},
    {"name": "object", "datatype": dbt.type_string()},
    {"name": "user_email", "datatype": dbt.type_string()},
    {"name": "user_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
