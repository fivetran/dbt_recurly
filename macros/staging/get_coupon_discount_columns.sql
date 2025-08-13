{% macro get_coupon_discount_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "coupon_id", "datatype": dbt.type_string()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "fivetran_id", "datatype": dbt.type_string()},
    {"name": "percentage", "datatype": dbt.type_string()},
    {"name": "trial_length", "datatype": dbt.type_int()},
    {"name": "trial_unit", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
