{% macro get_plan_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "deleted_at", "datatype": dbt.type_timestamp()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "interval_unit", "datatype": dbt.type_string()},
    {"name": "interval_length", "datatype": dbt.type_int()},
    {"name": "trial_unit", "datatype": dbt.type_string()},
    {"name": "trial_length", "datatype": dbt.type_int()},
    {"name": "total_billing_cycles", "datatype": dbt.type_int()},
    {"name": "auto_renew", "datatype": "boolean"},
    {"name": "accounting_code", "datatype": dbt.type_string()},
    {"name": "setup_fee_accounting_code", "datatype": dbt.type_string()},
    {"name": "tax_code", "datatype": dbt.type_string()},
    {"name": "tax_exempt", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}
