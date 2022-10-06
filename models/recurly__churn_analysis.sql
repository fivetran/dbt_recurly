with subscription_history as (

    select *
    from {{ ref('recurly__subscription_overview') }}
),

subscription_churn_reason as (

    select 
        subscription_id,
        activated_at,
        account_id,
        account_state,
        canceled_at,
        current_period_ended_at,
        current_period_started_at,
        expires_at,
        expiration_reason,
        has_auto_renew,
        plan_name,
        plan_state,
        subscription_end_date, 
        subscription_interval_days,
        subscription_period,
        subscription_state,
        subtotal,
        unit_amount,
        case when expires_at is null then null 
            when account_state != 'active' then 'account closed'
            when lower(expiration_reason) = 'canceled' then 'canceled'
            when lower(expiration_reason) = 'nonpayment_gift' then 'gift ended'
            when lower(expiration_reason) = 'nonpayment' then 'non-payment'
            when lower(expiration_reason) = 'non renewing' then 'non-renewing'
-- haven't confirmed the below, will revisit with production data
            when lower(expiration_reason) = 'tax location invalid' then 'tax location invalid' 
            when lower(expiration_reason) like 'nonpayment_trial' then 'trial ended'
            else null 
        end as churn_reason
    from subscription_history
),


final as
(
    select 
        *,
        case when churn_reason is null then null
            when churn_reason in ('tax location invalid', 'non-renewing') then 'involuntary'
            else 'voluntary'
            end as churn_reason_type
    from subscription_churn_reason
)

select * 
from final