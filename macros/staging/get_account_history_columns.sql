{% macro get_account_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "deleted_at", "datatype": dbt.type_timestamp()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "bill_to", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "username", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "cc_emails", "datatype": dbt.type_string()},
    {"name": "company", "datatype": dbt.type_string()},
    {"name": "vat_number", "datatype": dbt.type_string()},
    {"name": "tax_exempt", "datatype": "boolean"},
    {"name": "account_city", "datatype": dbt.type_string()},
    {"name": "account_country", "datatype": dbt.type_string()},
    {"name": "account_postal_code", "datatype": dbt.type_string()},
    {"name": "account_region", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('recurly_account_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
