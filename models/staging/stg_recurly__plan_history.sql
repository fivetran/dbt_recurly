with base as (

    select *
    from {{ ref('stg_recurly__plan_history_tmp') }}
),

fields as (

    select 
        {{ 
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recurly__plan_history_tmp')),
                staging_columns = get_plan_history_columns()
            ) 
        }}
    from base
),

final as (

    select
        id as plan_id, 
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        accounting_code,
        code,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        cast(deleted_at as {{ dbt.type_timestamp() }}) as deleted_at,
        description,
        auto_renew as has_auto_renew,
        interval_length,
        interval_unit,
        row_number() over (partition by id order by updated_at desc) = 1 as is_most_recent_record,
        tax_exempt as is_tax_exempt,
        name,
        setup_fee_accounting_code,
        state,
        tax_code,
        total_billing_cycles,
        trial_length,
        trial_unit
    from fields
)

select *
from final
