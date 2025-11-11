{% set fields = ['rolling_account_balance','rolling_invoices','rolling_transactions','rolling_charge_balance','rolling_credit_balance','rolling_discount_balance','rolling_tax_balance','rolling_charges','rolling_credits'] %}

with balance_transaction_periods as (

    select * 
    from {{ ref('int_recurly__transactions_date_spine') }}
),

account_balances as (

    select *
    from {{ ref('int_recurly__transactions_grouped') }}
), 

account_rolling_overview as (

    select
        *,
        sum(daily_balance) over (partition by account_id {{ recurly.partition_by_source_relation() }} order by date_day, account_id rows unbounded preceding) as rolling_account_balance,
        sum(daily_invoices) over (partition by account_id {{ recurly.partition_by_source_relation() }} order by date_day, account_id rows unbounded preceding) as rolling_invoices,
        sum(daily_transactions) over (partition by account_id {{ recurly.partition_by_source_relation() }} order by date_day, account_id rows unbounded preceding) as rolling_transactions,
        sum(daily_charges) over (partition by account_id {{ recurly.partition_by_source_relation() }} order by date_day, account_id rows unbounded preceding) as rolling_charge_balance,
        sum(daily_credits) over (partition by account_id {{ recurly.partition_by_source_relation() }} order by date_day, account_id rows unbounded preceding) as rolling_credit_balance,
        sum(daily_discounts) over (partition by account_id {{ recurly.partition_by_source_relation() }} order by date_day, account_id rows unbounded preceding) as rolling_discount_balance,
        sum(daily_taxes) over (partition by account_id {{ recurly.partition_by_source_relation() }} order by date_day, account_id rows unbounded preceding) as rolling_tax_balance,
        sum(daily_charge_count) over (partition by account_id {{ recurly.partition_by_source_relation() }} order by date_day, account_id rows unbounded preceding) as rolling_charges,
        sum(daily_credit_count) over (partition by account_id {{ recurly.partition_by_source_relation() }} order by date_day, account_id rows unbounded preceding) as rolling_credits
    from account_balances
),

final as (

    select
        coalesce(account_rolling_overview.source_relation, balance_transaction_periods.source_relation) as source_relation,
        coalesce(account_rolling_overview.account_id, balance_transaction_periods.account_id) as account_id,
        coalesce(account_rolling_overview.date_day, balance_transaction_periods.date_day) as date_day,
        coalesce(account_rolling_overview.date_week, balance_transaction_periods.date_week) as date_week,
        coalesce(account_rolling_overview.date_month, balance_transaction_periods.date_month) as date_month,
        coalesce(account_rolling_overview.date_year, balance_transaction_periods.date_year) as date_year,
        account_rolling_overview.daily_transactions,
        account_rolling_overview.daily_balance,
        account_rolling_overview.daily_invoices,
        account_rolling_overview.daily_charges,
        account_rolling_overview.daily_credits,
        account_rolling_overview.daily_discounts,
        account_rolling_overview.daily_taxes,
        account_rolling_overview.daily_charge_count,
        account_rolling_overview.daily_credit_count,
        {% for f in fields %}
        case when account_rolling_overview.{{ f }} is null and date_index = 1
            then 0
            else account_rolling_overview.{{ f }}
            end as {{ f }},
        {% endfor %}
        balance_transaction_periods.date_index
    from balance_transaction_periods
    left join account_rolling_overview
        on account_rolling_overview.source_relation = balance_transaction_periods.source_relation
        and account_rolling_overview.account_id = balance_transaction_periods.account_id
        and account_rolling_overview.date_day = balance_transaction_periods.date_day
        and account_rolling_overview.date_week = balance_transaction_periods.date_week
        and account_rolling_overview.date_month = balance_transaction_periods.date_month
        and account_rolling_overview.date_year = balance_transaction_periods.date_year
)

select * 
from final