with account_rolling_totals as (

    select * 
    from {{ ref('int_recurly__account_rolling_totals') }}
),

account_partitions as (

    select
        *,
        sum(case when rolling_account_balance is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as balance_partition,
        sum(case when rolling_invoices is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as invoice_partition,
        sum(case when rolling_transactions is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as transaction_partition,
        sum(case when rolling_charge_balance is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as charge_balance_partition,
        sum(case when rolling_credit_balance is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as credit_balance_partition,
        sum(case when rolling_discount_balance is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as discount_balance_partition,        
        sum(case when rolling_tax_balance is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as tax_balance_partition, 
        sum(case when rolling_charges is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as charges_partition,  
        sum(case when rolling_credits is null 
            then 0 
            else 1 
                end) over (order by account_id, date_day rows unbounded preceding) as credits_partition           
    from account_rolling_totals
),

final as (

    select
        account_id,
        date_day,        
        {{ dbt_utils.surrogate_key(['account_id','date_day']) }} as account_daily_id,
        date_week, 
        date_month, 
        date_year,  
        date_index, 
        coalesce(daily_transactions,0) as daily_transaction_count,
        coalesce(daily_balance,0) as daily_net_change,
        coalesce(daily_invoices,0) as daily_invoice_count,
        coalesce(daily_charges,0) as daily_charges,
        coalesce(daily_credits,0) as daily_credits,
        coalesce(daily_discounts,0) as daily_discounts,
        coalesce(daily_taxes,0) as daily_taxes,
        coalesce(daily_charge_count,0) as daily_charge_count,
        coalesce(daily_credit_count,0) as daily_credit_count,
        coalesce(rolling_account_balance,  
            first_value(rolling_account_balance) over (partition by balance_partition order by date_day rows unbounded preceding)) as rolling_account_balance,
        coalesce(rolling_invoices,
            first_value(rolling_invoices) over (partition by invoice_partition order by date_day rows unbounded preceding)) as rolling_invoices,
        coalesce(rolling_transactions,
            first_value(rolling_transactions) over (partition by transaction_partition order by date_day rows unbounded preceding)) as rolling_transactions,
        coalesce(rolling_charge_balance,
            first_value(rolling_charge_balance) over (partition by charge_balance_partition order by date_day rows unbounded preceding)) as rolling_charge_balance,
        coalesce(rolling_credit_balance,
            first_value(rolling_credit_balance) over (partition by credit_balance_partition order by date_day rows unbounded preceding)) as rolling_credit_balance,
        coalesce(rolling_discount_balance,
            first_value(rolling_discount_balance) over (partition by discount_balance_partition order by date_day rows unbounded preceding)) as rolling_discount_balance,
        coalesce(rolling_tax_balance,
            first_value(rolling_tax_balance) over (partition by tax_balance_partition order by date_day rows unbounded preceding)) as rolling_tax_balance,
        coalesce(rolling_charges,
            first_value(rolling_charges) over (partition by charges_partition order by date_day rows unbounded preceding)) as rolling_charges,
        coalesce(rolling_credits,
            first_value(rolling_credits) over (partition by credits_partition order by date_day rows unbounded preceding)) as rolling_credits
    from account_partitions
)    

select *
from final