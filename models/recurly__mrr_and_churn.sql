with mrr_balance_transactions as (

    select *,
        {{ dbt_utils.date_trunc('month', 'created_at') }} as mrr_month 
    from {{ ref('recurly__balance_transactions') }}
    where type like 'charge' 
    and started_at is not null
    and ended_at is not null
), 

mrr_by_account as (

    select account_id,
        mrr_month,
        row_number() over (partition by account_id order by mrr_month) as account_month_number,
        sum(amount) as current_month_mrr
    from mrr_balance_transactions
    group by 1,2

),

current_vs_previous_mrr as 
(
select *,
    lag(current_month_mrr) over (partition by account_id order by mrr_month) as previous_month_mrr
from mrr_by_account
)

select *,
    case when current_month_mrr > previous_month_mrr then 'Expansion'
        when current_month_mrr < previous_month_mrr then 'Contraction'
        when current_month_mrr = previous_month_mrr then 'Unchanged'
        when previous_month_mrr is null then 'New'
        when current_month_mrr = 0.0 or current_month_mrr is null
            and (previous_month_mrr != 0.0)
            then 'Churned'
        when previous_month_mrr = 0.0 and current_month_mrr > 0.0 
            and account_month_number >= 3 then 'Reactivation'
        end as mrr_type
from current_vs_previous_mrr