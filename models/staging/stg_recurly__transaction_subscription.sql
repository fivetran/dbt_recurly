with base as (

    select *
    from {{ ref('stg_recurly__transaction_subscription_tmp') }}
),

fields as (

    select 
        {{ 
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recurly__transaction_subscription_tmp')),
                staging_columns = get_transaction_subscription_columns()
            ) 
        }}
    from base

),

final as (

    select
        transaction_id, 
        subscription_id
    from fields
)

select *
from final
