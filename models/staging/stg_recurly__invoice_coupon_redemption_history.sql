with base as (

    select * 
    from {{ ref('stg_recurly__invoice_coupon_redemption_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_recurly__invoice_coupon_redemption_history_tmp')),
                staging_columns=get_invoice_coupon_redemption_history_columns()
            )
        }}
    from base
),

final as (
    
    select 
        coupon_redemption_id,
        invoice_id,
        cast(invoice_updated_at as {{ dbt.type_timestamp() }}) as invoice_updated_at,
        row_number() over (partition by coupon_redemption_id order by invoice_updated_at desc) = 1 as is_most_recent_record
    from fields
)

select *
from final
