with account_history as (

    select * 
    from {{ var('account_history') }}
    where is_most_recent_record
),

recurly__balance_transactions as (

    select * 
    from {{ ref('recurly__balance_transactions') }}
),

mrr_balance_transactions as (

    select 
        account_id,
        amount,
        {{ dbt_utils.date_trunc('month', 'created_at') }} as account_month 
    from recurly__balance_transactions
    where lower(type) = 'charge' 
        and started_at is not null
        and ended_at is not null
), 

mrr_by_account as (

    select 
        account_id,
        account_month,
        row_number() over (partition by account_id order by account_month) as account_month_number,
        sum(amount) as current_month_mrr
    from mrr_balance_transactions
    group by 1,2

),

current_vs_previous_mrr as 
(
    
    select 
        *,
        lag(current_month_mrr) over (partition by account_id order by account_month) as previous_month_mrr
    from mrr_by_account
),

mrr_type_enhanced as (

    select 
        *,
        case when current_month_mrr > previous_month_mrr then 'expansion'
            when current_month_mrr < previous_month_mrr then 'contraction'
            when current_month_mrr = previous_month_mrr then 'unchanged'
            when previous_month_mrr is null then 'new'
            when (current_month_mrr = 0.0 or current_month_mrr is null)
                and (previous_month_mrr != 0.0)
                then 'churned'
            when (previous_month_mrr = 0.0 and current_month_mrr > 0.0 
                and account_month_number >= 3) 
                then 'reactivation'
            end as mrr_type
    from current_vs_previous_mrr
)

select 
    mrr_type_enhanced.*,
    account_history.code as account_code,
    account_history.created_at as account_created_at,
    account_history.email as account_email,
    account_history.first_name as account_first_name,
    account_history.last_name as account_last_name,
    account_history.username as account_username
from mrr_type_enhanced
left join account_history on mrr_type_enhanced.account_id = account_history.account_id