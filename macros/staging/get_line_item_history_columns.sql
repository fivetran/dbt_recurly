{% macro get_line_item_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "plan_id", "datatype": dbt.type_string()},
    {"name": "add_on_id", "datatype": dbt.type_string()},
    {"name": "invoice_id", "datatype": dbt.type_string()},
    {"name": "previous_line_item_id", "datatype": dbt.type_string()},
    {"name": "original_line_item_invoice_id", "datatype": dbt.type_string()},
    {"name": "subscription_id", "datatype": dbt.type_string()},
    {"name": "uuid", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "plan_code", "datatype": dbt.type_string()},
    {"name": "add_on_code", "datatype": dbt.type_string()},
    {"name": "invoice_number", "datatype": dbt.type_string()},
    {"name": "origin", "datatype": dbt.type_string()},
    {"name": "product_code", "datatype": dbt.type_string()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "quantity", "datatype": dbt.type_int()},
    {"name": "unit_amount", "datatype": dbt.type_int()},
    {"name": "subtotal", "datatype": dbt.type_int()},
    {"name": "discount", "datatype": dbt.type_float()},
    {"name": "tax", "datatype": dbt.type_int()},
    {"name": "taxable", "datatype": "boolean"},
    {"name": "tax_exempt", "datatype": "boolean"},
    {"name": "tax_code", "datatype": dbt.type_string()},
    {"name": "tax_type", "datatype": dbt.type_string()},
    {"name": "tax_region", "datatype": dbt.type_string()},
    {"name": "tax_rate", "datatype": dbt.type_float()},
    {"name": "proration_rate", "datatype": dbt.type_float()},
    {"name": "refund", "datatype": "boolean"},
    {"name": "refunded_quantity", "datatype": dbt.type_int()},
    {"name": "credit_applied", "datatype": dbt.type_float()},
    {"name": "start_date", "datatype": dbt.type_timestamp()},
    {"name": "end_date", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
