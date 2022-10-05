with balance_transaction_joined as (

    select * 
    from {{ ref('recurly__balance_transactions') }}
)

select 
    account_id,
    count(distinct transaction_id) as total_transactions,
    count(distinct invoice_id) as total_invoices,
    sum(case when lower(type) = 'charge' 
        then amount
        else 0 
        end) as total_charges,
    sum(case when lower(type) = 'credit' 
        then amount
        else 0 
        end) as total_credits,
    sum(amount) as total_gross_transaction_amount,
    sum(discount) as total_discounts,
    sum(tax) as total_net_taxes,
    sum(case when lower(type) = 'charge' 
        then 1
        else 0 
        end) as total_charge_count,
    sum(case when lower(type) = 'credit' 
        then 1
        else 0 
        end) as total_credit_count,
    count(distinct (case when {{ dbt_utils.date_trunc('month', date_timezone('transaction_created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
        then transaction_id  
        end)) as transactions_this_month,
    count(distinct (case when {{ dbt_utils.date_trunc('month', date_timezone('invoice_created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
        then invoice_id  
        end)) as invoices_this_month,
    sum(case when lower(type) = 'charge' and {{ dbt_utils.date_trunc('month', date_timezone('created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
        then amount 
        else 0 
        end) as charges_this_month,
    sum(case when lower(type) = 'credit' and {{ dbt_utils.date_trunc('month', date_timezone('created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
        then amount 
        else 0 
        end) as credits_this_month,
    sum(case when {{ dbt_utils.date_trunc('month', date_timezone('created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
        then amount 
        else 0 
        end) as gross_transaction_amount_this_month,
    sum(case when {{ dbt_utils.date_trunc('month', date_timezone('created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
        then discount 
        else 0 
        end) as discounts_this_month,
    sum(case when {{ dbt_utils.date_trunc('month', date_timezone('created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
        then tax 
        else 0 
        end) as taxes_this_month,
    min(case when lower(type) = 'charge' 
        then {{ date_timezone('created_at') }}
        else null 
        end) as first_charge_date,
    max(case when lower(type) = 'charge' 
        then {{ date_timezone('created_at') }}
        else null 
        end) as most_recent_charge_date,
    min( {{ date_timezone('invoice_created_at') }} ) as first_invoice_date,
    max( {{ date_timezone('invoice_created_at') }} ) as most_recent_invoice_date,
    min( {{ date_timezone('transaction_created_at') }} ) as first_transaction_date,
    max( {{ date_timezone('transaction_created_at') }} ) as most_recent_transaction_date
from balance_transaction_joined
group by 1