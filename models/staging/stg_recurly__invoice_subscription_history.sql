with base as (

    select *
    from {{ ref('stg_recurly__invoice_subscription_history_tmp') }}
),

fields as (

    select 
        {{ 
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recurly__invoice_subscription_history_tmp')),
                staging_columns = get_invoice_subscription_history_columns()
            ) 
        }}
    from base
),

final as (

    select
        invoice_id,
        cast(invoice_updated_at as {{ dbt.type_timestamp() }}) as invoice_updated_at,
        subscription_id,
        row_number() over (partition by invoice_id order by invoice_updated_at desc) = 1 as is_most_recent_record
    from fields
)
select *
from final
