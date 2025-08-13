with base as (

    select * 
    from {{ ref('stg_recurly__coupon_discount_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_recurly__coupon_discount_tmp')),
                staging_columns=get_coupon_discount_columns()
            )
        }}
    from base
),

final as (
    
    select 
        coupon_id,
        cast(amount as {{ dbt.type_float() }}) as amount,
        currency,
        fivetran_id,
        percentage,
        trial_length,
        trial_unit,
        type
    from fields
)

select *
from final
