with subscription_history as (

    select * 
    from {{ var('subscription_history') }}
),

account_overview as (

    select * 
    from {{ ref('recurly__account_overview') }}
),

plan_history as (

    select * 
    from {{ var('plan_history') }}
)


select 
    subscription_history.subscription_id,
    subscription_history.activated_at,
    subscription_history.add_ons_total, 
    subscription_history.canceled_at,
    subscription_history.current_period_ended_at,
    subscription_history.current_period_started_at,
    {{ dbt_utils.datediff('subscription_history.current_period_started_at', 'subscription_history.current_period_started_at', 'day') }} as current_interval_days,
    subscription_history.expires_at,
    subscription_history.expiration_reason, 
    subscription_history.subscription_period,  
    subscription_history.state as subscription_state,
    subscription_history.subtotal, 
    subscription_history.trial_ends_at,
    subscription_history.trial_started_at,
    {{ dbt_utils.datediff('subscription_history.trial_started_at', 'subscription_history.trial_ends_at', 'day') }} as trial_interval_days,
    subscription_history.unit_amount, 
    account_overview.account_id as account_id,
    account_overview.account_created_at,
    account_overview.account_email,
    account_overview.account_first_name, 
    account_overview.account_last_name, 
    account_overview.account_state as account_state,
    plan_history.code as plan_code,
    plan_history.created_at as plan_created_at,
    plan_history.deleted_at as plan_deleted_at,
    plan_history.is_tax_exempt as plan_is_tax_exempt,
    plan_history.name as plan_name,
    plan_history.state as plan_state,
    plan_history.total_billing_cycles as plan_total_billing_cycles
from subscription_history

left join account_overview
    on subscription_history.account_id = account_overview.account_id
left join plan_history
    on subscription_history.plan_id = plan_history.plan_id