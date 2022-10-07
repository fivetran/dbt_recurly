with account_rolling_totals as (

    select * 
    from {{ ref('int_recurly__account_rolling_totals') }}
),

balance_partition as (
    select
        *,
        sum(case when rolling_account_balance is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as balance_partition
    from account_rolling_totals
),

final as (
    select
        account_id,
        date_day,
        date_week,
        date_month,
        date_year,
        date_index,
        balance_partition,
        coalesce(daily_transactions,0) as daily_transactions,
        coalesce(daily_balance,0) as daily_net_change,
        coalesce(rolling_account_balance,
            first_value(rolling_account_balance) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_account_balance,
        coalesce(rolling_invoices,
            first_value(rolling_invoices) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_invoices,
        coalesce(rolling_transactions,
            first_value(rolling_transactions) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_transactions,
        coalesce(rolling_charge_balance,
            first_value(rolling_charge_balance) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_charge_balance,
        coalesce(rolling_credit_balance,
            first_value(rolling_credit_balance) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_credit_balance,
        coalesce(rolling_discount_balance,
            first_value(rolling_discount_balance) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_discount_balance,
        coalesce(rolling_tax_balance,
            first_value(rolling_tax_balance) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_tax_balance,
        coalesce(rolling_charges,
            first_value(rolling_charges) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_charges,
        coalesce(rolling_credits,
            first_value(rolling_credits) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_credits
    from balance_partition
)

select *
from final