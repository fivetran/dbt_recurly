{% macro get_credit_payment_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "applied_to_invoice_id", "datatype": dbt.type_string()},
    {"name": "original_invoice_id", "datatype": dbt.type_string()},
    {"name": "refund_transaction_id", "datatype": dbt.type_string()},
    {"name": "original_credit_payment_id", "datatype": dbt.type_string()},
    {"name": "uuid", "datatype": dbt.type_string()},
    {"name": "action", "datatype": dbt.type_string()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "voided_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
