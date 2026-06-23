{{ config(enabled=var('recurly__using_subscription_change_history', true)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='recurly_sources',
        single_source_name='recurly',
        single_table_name='subscription_change_history'
    )
}}
