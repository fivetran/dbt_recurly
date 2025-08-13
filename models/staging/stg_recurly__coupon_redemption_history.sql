with base as (

    select * 
    from {{ ref('stg_recurly__coupon_redemption_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_recurly__coupon_redemption_history_tmp')),
                staging_columns=get_coupon_redemption_history_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as coupon_redemption_id,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        account_id,
        coupon_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        currency, 
        discounted, 
        cast(removed_at as {{ dbt.type_timestamp() }}) as removed_at,
        state
    from fields
)

select *
from final
