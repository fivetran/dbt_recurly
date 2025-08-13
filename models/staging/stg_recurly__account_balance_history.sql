with base as (

    select * 
    from {{ ref('stg_recurly__account_balance_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_recurly__account_balance_history_tmp')),
                staging_columns=get_account_balance_history_columns()
            )
        }}
    from base
),

final as (
    
    select 
        account_id, 
        cast(account_updated_at as {{ dbt.type_timestamp() }}) as account_updated_at,
        cast(amount as {{ dbt.type_float() }}) as amount,
        currency,
        past_due,
        row_number() over (partition by account_id order by account_updated_at desc) = 1 as is_most_recent_record
    from fields
)

select *
from final
