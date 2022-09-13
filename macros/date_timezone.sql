{% macro date_timezone(column) -%}

{{ adapter.dispatch('date_timezone', 'recurly')(column)  }}

{%- endmacro %}

{% macro bigquery__date_timezone(column) -%}

date(
    {{ column }}
    {% if var('recurly_timezone', none) %} , "{{ var('recurly_timezone') }}" {% endif %}
    )

{%- endmacro %}

{% macro postgres__date_timezone(column) -%}

{% set converted_date %}

{% if var('recurly_timezone', none) %}
    {{ column }} at time zone '{{ var('recurly_timezone') }}'
{% else %}
    {{ column }}
{% endif %}

{% endset %}

{{ dbt_utils.date_trunc('day',converted_date) }}

{%- endmacro %}


{% macro redshift__date_timezone(column) -%}

{% set converted_date %}

{% if var('recurly_timezone', none) %}
    convert_timezone('{{ var("recurly_timezone") }}', {{ column }})
{% else %}
    {{ column }}
{% endif %}

{% endset %}

{{ dbt_utils.date_trunc('day',converted_date) }}

{%- endmacro %}


{% macro default__date_timezone(column) -%}

{% set converted_date %}

{% if var('recurly_timezone', none) %}
    convert_timezone('{{ var("recurly_timezone") }}', {{ column }})
{% else %}
    {{ column }}
{% endif %}

{% endset %}

{{ dbt_utils.date_trunc('day',converted_date) }}

{%- endmacro %}