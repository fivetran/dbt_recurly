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


final as (

    select 
        coalesce(account_balance.account_id, balance_transaction_periods.account_id) as account_id,
        coalesce(account_balance.date_day, balance_transaction_periods.date_day) as date_day, 
        account_balance.transactions,
        account_balance.daily_balance,
        balance_transaction_periods.date_index
    from account_balance
    left join balance_transaction_periods
        on account_balance.account_id = balance_transaction_periods.account_id 
        and account_balance.date_day = balance_transaction_periods.date_day
)   

select *
from final