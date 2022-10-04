with subscription_history as (

    select *
    from {{ ref('recurly__subscription_overview') }}
),

subscription_churn_reason as (

    select subscription_id,
        activated_at,
        actual_end_date, 
        actual_interval_days,
        account_id,
        account_state,
        canceled_at,
        current_period_ended_at,
        current_period_started_at,
        expires_at,
        expiration_reason,
        plan_name,
        plan_state,
        subscription_period,
        subscription_state,
        subtotal,
        unit_amount,
        case when expires_at is null then null 
            when account_state not like 'active' then 'account closed'
            when expiration_reason like 'canceled' then 'canceled'
            when expiration_reason like 'nonpayment_gift' then 'gift ended'
            when expiration_reason like 'nonpayment' then 'non-payment'
            when expiration_reason like '%tax%' then 'tax location invalid' 
            when expiration_reason like 'nonpayment_trial' then 'trial ended'
            else 'non-renewing'
        end as churn_reason
    from subscription_history
)  

select *,
    case when churn_reason is null then null
        when churn_reason in ('tax location invalid', 'non-renewing') then 'involuntary'
        else 'voluntary'
        end as churn_reason_type
from subscription_churn_reason