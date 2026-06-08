{{
    fivetran_utils.union_connections(
        connection_dictionary='recurly_sources',
        single_source_name='recurly',
        single_table_name='billing_info_history'
    )
}}