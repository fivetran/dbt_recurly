{{ config(enabled=var('recurly__using_credit_payment_history', true)) }}

{{
    recurly.recurly_union_connections(
        connection_dictionary='recurly_sources',
        single_source_name='recurly',
        single_table_name='credit_payment_history'
    )
}}
