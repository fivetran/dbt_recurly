with transactions_grouped as (

    select * 
    from {{ ref('int_recurly__transactions_grouped') }}
),

balance_transaction_joined as (

    select * 
    from {{ ref('recurly__balance_transactions') }}
),
 
account_current_month as (
        
        select account_id,
                sum(case when {{ dbt_utils.date_trunc('month', 'date_day') }} = {{ dbt_utils.date_trunc('month', dbt.current_timestamp_backcompat()) }}
                        then daily_transactions
                        else 0 
                        end) as transactions_this_month,
                sum(case when {{ dbt_utils.date_trunc('month', 'date_day') }} = {{ dbt_utils.date_trunc('month', dbt.current_timestamp_backcompat()) }}
                        then daily_invoices
                        else 0 
                        end) as invoices_this_month,
                sum(case when {{ dbt_utils.date_trunc('month', 'date_day') }} = {{ dbt_utils.date_trunc('month', dbt.current_timestamp_backcompat()) }}
                        then daily_balance
                        else 0 
                        end) as balance_this_month,
                sum(case when {{ dbt_utils.date_trunc('month', 'date_day') }} = {{ dbt_utils.date_trunc('month', dbt.current_timestamp_backcompat()) }}
                        then daily_charges
                        else 0 
                        end) as charges_this_month,
                sum(case when {{ dbt_utils.date_trunc('month', 'date_day') }} = {{ dbt_utils.date_trunc('month', dbt.current_timestamp_backcompat()) }}
                        then daily_credits
                        else 0 
                        end) as credits_this_month,
                sum(case when {{ dbt_utils.date_trunc('month', 'date_day') }} = {{ dbt_utils.date_trunc('month', dbt.current_timestamp_backcompat()) }}
                        then daily_discounts
                        else 0 
                        end) as discounts_this_month,
                sum(case when {{ dbt_utils.date_trunc('month', 'date_day') }} = {{ dbt_utils.date_trunc('month', dbt.current_timestamp_backcompat()) }}
                        then daily_credits
                        else 0 
                        end) as taxes_this_month
        from transactions_grouped
        {{ dbt_utils.group_by(1) }}  
),


account_min_max as (

    select 
        account_id,
        min(case when lower(type) = 'charge' 
            then {{ 'created_at' }} 
            else null end) as first_charge_date,
        max(case when lower(type) = 'charge' 
            then {{ 'created_at' }}
            else null end) as most_recent_charge_date,
        min(invoice_created_at) as first_invoice_date,
        max(invoice_created_at) as most_recent_invoice_date,
        min(transaction_created_at) as first_transaction_date,
        max(transaction_created_at) as most_recent_transaction_date
    from balance_transaction_joined
    {{ dbt_utils.group_by(1) }}
),


account_totals as (

    select 
        account_id,
        sum(daily_transactions) as total_transactions,
        sum(daily_invoices) as total_invoices,
        sum(daily_charges) as total_charges,
        sum(daily_credits) as total_credits,
        sum(daily_balance) as total_balance,
        sum(daily_discounts) as total_discounts,
        sum(daily_taxes) as total_taxes,
        sum(daily_charge_count) as total_charge_count,
        sum(daily_credit_count) as total_credit_count
    from transactions_grouped
    {{ dbt_utils.group_by(1) }}
),

final as (

    select distinct
        account_totals.*,
        account_current_month.transactions_this_month,
        account_current_month.invoices_this_month,
        account_current_month.balance_this_month,
        account_current_month.charges_this_month,
        account_current_month.credits_this_month,
        account_current_month.discounts_this_month,
        account_current_month.taxes_this_month,
        account_min_max.first_charge_date,
        account_min_max.most_recent_charge_date,
        account_min_max.first_invoice_date,
        account_min_max.most_recent_invoice_date,
        account_min_max.first_transaction_date,
        account_min_max.most_recent_transaction_date
    from account_totals
    left join account_current_month 
        on account_totals.account_id = account_current_month.account_id
    left join account_min_max
        on account_totals.account_id = account_min_max.account_id
)

select *
from final