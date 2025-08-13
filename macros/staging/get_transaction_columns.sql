{% macro get_transaction_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "voided_at", "datatype": dbt.type_timestamp()},
    {"name": "collected_at", "datatype": dbt.type_timestamp()},
    {"name": "original_transaction_id", "datatype": dbt.type_string()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "invoice_id", "datatype": dbt.type_string()},
    {"name": "voided_by_invoice_id", "datatype": dbt.type_string()},
    {"name": "uuid", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "origin", "datatype": dbt.type_string()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "success", "datatype": "boolean"},
    {"name": "refunded", "datatype": "boolean"},
    {"name": "billing_first_name", "datatype": dbt.type_string()},
    {"name": "billing_last_name", "datatype": dbt.type_string()},
    {"name": "billing_phone", "datatype": dbt.type_string()},
    {"name": "billing_street_1", "datatype": dbt.type_string()},
    {"name": "billing_street_2", "datatype": dbt.type_string()},
    {"name": "billing_city", "datatype": dbt.type_string()},
    {"name": "billing_region", "datatype": dbt.type_string()},
    {"name": "billing_postal_code", "datatype": dbt.type_string()},
    {"name": "billing_country", "datatype": dbt.type_string()},
    {"name": "collection_method", "datatype": dbt.type_string()},
    {"name": "payment_method_object", "datatype": dbt.type_string()},
    {"name": "status_code", "datatype": dbt.type_string()},
    {"name": "status_message", "datatype": dbt.type_string()},
    {"name": "customer_message", "datatype": dbt.type_string()},
    {"name": "customer_message_locale", "datatype": dbt.type_string()},
    {"name": "gateway_message", "datatype": dbt.type_string()},
    {"name": "gateway_reference", "datatype": dbt.type_string()},
    {"name": "gateway_approval_code", "datatype": dbt.type_string()},
    {"name": "gateway_response_code", "datatype": dbt.type_string()},
    {"name": "gateway_response_time", "datatype": dbt.type_float()},
    {"name": "payment_gateway_id", "datatype": dbt.type_string()},
    {"name": "payment_gateway_type", "datatype": dbt.type_string()},
    {"name": "payment_gateway_name", "datatype": dbt.type_timestamp()},
    {"name": "gateway_response_values", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}

