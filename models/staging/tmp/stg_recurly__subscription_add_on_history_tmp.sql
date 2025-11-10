{{ config(enabled=var('recurly__using_subscription_add_on_history', true)) }}

{{
    recurly.recurly_union_connections(
        connection_dictionary='recurly_sources',
        single_source_name='recurly',
        single_table_name='subscription_add_on_history'
    )
}}
