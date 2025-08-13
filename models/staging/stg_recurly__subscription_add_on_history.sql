{{ config(enabled=var('recurly__using_subscription_add_on_history', true)) }}

with base as (

    select * 
    from {{ ref('stg_recurly__subscription_add_on_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_recurly__subscription_add_on_history_tmp')),
                staging_columns=get_subscription_add_on_history_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as subscription_add_on_id,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at, 
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at, 
        cast(expired_at as {{ dbt.type_timestamp() }}) as expired_at,
        object,         
        plan_add_on_id,
        quantity, 
        subscription_id, 
        cast(unit_amount as {{ dbt.type_float() }}) as unit_amount,
        row_number() over (partition by id order by updated_at desc) = 1 as is_most_recent_record
    from fields
)

select *
from final
