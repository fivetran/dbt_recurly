{% macro apply_source_relation() -%}

{{ adapter.dispatch('apply_source_relation', 'recurly') () }}

{%- endmacro %}

{% macro default__apply_source_relation() -%}

{% if var('recurly_sources', []) != [] %}
, _dbt_source_relation as source_relation
{% else %}
, '{{ var("recurly_database", target.database) }}' || '.'|| '{{ var("recurly_schema", "recurly") }}' as source_relation
{% endif %}

{%- endmacro %}