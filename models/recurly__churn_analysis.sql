with subscription_churn_reason as 
(
    select *,
         case when account_state not like 'active' then 'Account Closed' 
            when expiration_reason like 'canceled' then 'Canceled' 
            when expiration_reason like 'nonpayment_trial' then 'Trial Ended' 
            when expiration_reason like 'nonpayment_gift' then 'Gift Ended' 
            when expiration_reason like 'nonpayment' then 'Non-payment' 
            when expiration_reason like '%tax%' then 'Tax Location Invalid' 
            when has_auto_renew is false then 'Non-renewing'  
            end as churn_reason
    from {{ ref('recurly__subscription_overview') }} 
)

select *, 
    case when churn_reason in ('Tax Location Invalid', 'Non-renewing') then 'Involuntary'
        else 'Voluntary'
        end as churn_reason_type

from subscription_churn_reason