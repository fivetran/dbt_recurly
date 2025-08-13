with base as (

    select *
    from {{ ref('stg_recurly__subscription_history_tmp') }}
),

fields as (

    select 
        {{ 
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recurly__subscription_history_tmp')),
                staging_columns = get_subscription_history_columns()
            ) 
        }}
    from base
),

final as (

    select  
        id as subscription_id,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        account_id,
        cast(activated_at as {{ dbt.type_timestamp() }}) as activated_at,
        add_ons_total,
        cast(canceled_at as {{ dbt.type_timestamp() }}) as canceled_at,
        collection_method,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        currency,
        cast(current_period_ends_at as {{ dbt.type_timestamp() }}) as current_period_ended_at,
        cast(current_period_started_at as {{ dbt.type_timestamp() }}) as current_period_started_at,
        cast(current_term_ends_at as {{ dbt.type_timestamp() }}) as current_term_ended_at,
        cast(current_term_started_at as {{ dbt.type_timestamp() }}) as current_term_started_at,
        expiration_reason,
        cast(expires_at as {{ dbt.type_timestamp() }}) as expires_at,
        auto_renew as has_auto_renew,
        row_number() over (partition by id order by current_period_started_at desc) = 1 as is_most_recent_record,
        object,
        cast(paused_at as {{ dbt.type_timestamp() }}) as paused_at, 
        plan_id,
        quantity,
        remaining_billing_cycles,
        remaining_pause_cycles,
        renewal_billing_cycles,
        state,
        subtotal,
        total_billing_cycles,
        cast(trial_ends_at as {{ dbt.type_timestamp() }}) as trial_ends_at,
        cast(trial_started_at as {{ dbt.type_timestamp() }}) as trial_started_at,
        cast(unit_amount as {{ dbt.type_float() }}) as unit_amount,
        uuid

        --The below macro adds the fields defined within your accounts_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('recurly_subscription_pass_through_columns') }}

    from fields
)

select *
from final
