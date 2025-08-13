{% macro get_invoice_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "due_at", "datatype": dbt.type_timestamp()},
    {"name": "closed_at", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "previous_invoice_id", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "origin", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "number", "datatype": dbt.type_string()},
    {"name": "collection_method", "datatype": dbt.type_string()},
    {"name": "po_number", "datatype": dbt.type_string()},
    {"name": "net_terms", "datatype": dbt.type_string()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "balance", "datatype": dbt.type_float()},
    {"name": "paid", "datatype": dbt.type_int()},
    {"name": "total", "datatype": dbt.type_int()},
    {"name": "subtotal", "datatype": dbt.type_int()},
    {"name": "refundable_amount", "datatype": dbt.type_int()},
    {"name": "discount", "datatype": dbt.type_int()},
    {"name": "tax", "datatype": dbt.type_int()},
    {"name": "tax_type", "datatype": dbt.type_string()},
    {"name": "tax_region", "datatype": dbt.type_string()},
    {"name": "tax_rate", "datatype": dbt.type_float()}
] %}

{{ return(columns) }}

{% endmacro %}
