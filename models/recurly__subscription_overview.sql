with subscription_history as (

    select * 
    from {{ var('subscription_history') }}
    where is_most_recent_record
),

plan_history as (

    select * 
    from {{ var('plan_history') }}
    where is_most_recent_record
),

subscription_enhanced as (

    select 
        *,
        coalesce(canceled_at, current_period_ended_at) as subscription_end_date,
        row_number() over (partition by subscription_id order by current_period_started_at) - 1 as subscription_period
        from subscription_history
),

account_overview as (

    select * 
    from {{ ref('recurly__account_overview') }}
),

plan_enhanced as (

    select 
        *, 
        case when lower(interval_unit) = 'months' then interval_length * 30
            when lower(interval_unit) = 'weeks' then interval_length * 7
            else interval_length 
            end as interval_days
    from plan_history
),

final as (

    select 
        subscription_enhanced.subscription_id,
        subscription_enhanced.updated_at,
        {{ dbt_utils.surrogate_key(['subscription_enhanced.subscription_id','subscription_enhanced.updated_at']) }} as subscription_key,
        subscription_enhanced.activated_at,
        subscription_enhanced.add_ons_total, 
        subscription_enhanced.canceled_at,
        subscription_enhanced.current_period_ended_at,
        subscription_enhanced.current_period_started_at,
        subscription_enhanced.expiration_reason, 
        subscription_enhanced.expires_at,
        subscription_enhanced.has_auto_renew,
        subscription_enhanced.subscription_period,  
        subscription_enhanced.state as subscription_state,
        subscription_enhanced.subscription_end_date,
        {{ dbt_utils.datediff('subscription_enhanced.current_period_started_at', 'subscription_enhanced.subscription_end_date', 'day') }} as subscription_interval_days,
        subscription_enhanced.subtotal, 
        subscription_enhanced.trial_ends_at,
        subscription_enhanced.trial_started_at,
        {{ dbt_utils.datediff('subscription_enhanced.trial_started_at', 'subscription_enhanced.trial_ends_at', 'day') }} as trial_interval_days,
        subscription_enhanced.unit_amount

        {{ fivetran_utils.persist_pass_through_columns('recurly_subscription_pass_through_columns', identifier='subscription_enhanced') }},

        account_overview.account_id as account_id,
        account_overview.account_created_at,
        account_overview.account_email,
        account_overview.account_first_name, 
        account_overview.account_last_name, 
        account_overview.account_state as account_state,
        plan_enhanced.code as plan_code,
        plan_enhanced.created_at as plan_created_at,
        plan_enhanced.deleted_at as plan_deleted_at,
        plan_enhanced.interval_days as plan_interval_days,
        plan_enhanced.is_tax_exempt as plan_is_tax_exempt,
        plan_enhanced.name as plan_name,
        plan_enhanced.state as plan_state,
        plan_enhanced.total_billing_cycles as plan_total_billing_cycles
    from subscription_enhanced
    left join account_overview
        on subscription_enhanced.account_id = account_overview.account_id
    left join plan_enhanced
        on subscription_enhanced.plan_id = plan_enhanced.plan_id
)

select * 
from final