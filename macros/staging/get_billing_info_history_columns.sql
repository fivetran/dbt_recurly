{% macro get_billing_info_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "company", "datatype": dbt.type_string()},
    {"name": "billing_phone", "datatype": dbt.type_string()},
    {"name": "billing_street_1", "datatype": dbt.type_string()},
    {"name": "billing_street_2", "datatype": dbt.type_string()},
    {"name": "billing_city", "datatype": dbt.type_string()},
    {"name": "billing_region", "datatype": dbt.type_string()},
    {"name": "billing_postal_code", "datatype": dbt.type_string()},
    {"name": "billing_country", "datatype": dbt.type_string()},
    {"name": "vat_number", "datatype": dbt.type_string()},
    {"name": "valid", "datatype": "boolean"},
    {"name": "payment_method_object", "datatype": dbt.type_string()},
    {"name": "payment_method_card_type", "datatype": dbt.type_string()},
    {"name": "payment_method_first_six", "datatype": dbt.type_string()},
    {"name": "payment_method_last_four", "datatype": dbt.type_string()},
    {"name": "payment_method_exp_month", "datatype": dbt.type_int()},
    {"name": "payment_method_exp_year", "datatype": dbt.type_int()},
    {"name": "fraud_score", "datatype": dbt.type_string()},
    {"name": "fraud_decision", "datatype": dbt.type_string()},
    {"name": "fraud_risk_rules_triggered", "datatype": "variant"},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_by_ip", "datatype": dbt.type_string()},
    {"name": "updated_by_country", "datatype": dbt.type_string()} 
] %}

{{ return(columns) }}

{% endmacro %}
