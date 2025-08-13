with base as (

    select *
    from {{ ref('stg_recurly__plan_currency_history_tmp') }}
),

fields as (

    select 
        {{ 
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recurly__plan_currency_history_tmp')),
                staging_columns = get_plan_currency_history_columns()
            ) 
        }}
    from base
),

final as (

    select
        plan_id,
        cast(plan_updated_at as {{ dbt.type_timestamp() }}) as plan_updated_at,
        currency,
        setup_fees,
        cast(unit_amount as {{ dbt.type_float() }}) as unit_amount,
        row_number() over (partition by plan_id order by plan_updated_at desc) = 1 as is_most_recent_record
    from fields
)

select *
from final
