with balance_transactions as (

    select * 
    from {{ ref('recurly__balance_transactions') }}
),

balance_transaction_periods as (

    select * 
    from {{ ref('int_recurly__transactions_date_spine') }}
),

account_balance as (

    select 
        balance_transactions.account_id,
        cast({{ dbt_utils.date_trunc("day", "created_at") }} as date) as date_day, 
        count(distinct balance_transaction_id) as transactions, 
        sum(amount) as daily_balance
    from balance_transactions

    {{ dbt_utils.group_by(2) }}
),

gl_cumulative_balance as (
    select
        *,
        sum(daily_balance) over (partition by account_id order by date_day, account_id rows unbounded preceding) as rolling_account_balance
    from account_balance
),


balance_patch as (

    select 
        coalesce(gl_cumulative_balance.account_id, balance_transaction_periods.account_id) as account_id,
        coalesce(gl_cumulative_balance.date_day, balance_transaction_periods.date_day) as date_day, 
        gl_cumulative_balance.transactions,
        gl_cumulative_balance.daily_balance,
        case when gl_cumulative_balance.rolling_account_balance is null and date_index = 1
            then 0
            else gl_cumulative_balance.rolling_account_balance
                end as rolling_account_balance,
        balance_transaction_periods.date_index
    from balance_transaction_periods
    left join gl_cumulative_balance
        on gl_cumulative_balance.account_id = balance_transaction_periods.account_id 
        and gl_cumulative_balance.date_day = balance_transaction_periods.date_day
),

balance_value_partion as (
    select
        *,
        sum(case when rolling_account_balance is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as balance_partition
    from balance_patch

),

final as (
    select
        account_id,
        date_day,
        coalesce(transactions,0) as total_transactions,
        coalesce(daily_balance,0) as daily_net_change,
        coalesce(rolling_account_balance,
            first_value(rolling_account_balance) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_account_balance
    from balance_value_partion
)

select *
from final