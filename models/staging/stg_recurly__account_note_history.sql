with base as (

    select * 
    from {{ ref('stg_recurly__account_note_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_recurly__account_note_history_tmp')),
                staging_columns=get_account_note_history_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as account_note_id, 
        account_id,
        cast(account_updated_at as {{ dbt.type_timestamp() }}) as account_updated_at,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        message,
        object,
        user_email,
        user_id,
        row_number() over (partition by id order by account_updated_at desc) = 1 as is_most_recent_record
    from fields
)

select *
from final
