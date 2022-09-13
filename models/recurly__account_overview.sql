with balance_transaction_joined as (

    select * 
    from {{ ref('recurly__balance_transactions') }}
),

account_history as (

    select * 
    from {{ var('account_history') }}
),

transactions_grouped as (

    select 
        account_id,
        count(distinct transaction_id) as total_transactions,
        count(distinct invoice_id) as total_invoices,
        sum(case when type in ('charge') 
            then amount
            else 0 
            end) as total_charges,
        sum(case when type in ('credit') 
            then amount
            else 0 
            end) as total_credits,
        sum(amount) as total_gross_transaction_amount,
        sum(discount) as total_discounts,
        sum(tax) as total_taxes,
        sum(case when type in ('charge') 
            then 1
            else 0 
            end) as total_charge_count,
        sum(case when type in ('credit') 
            then 1
            else 0 
            end) as total_credit_count,
        count(distinct (case when {{ dbt_utils.date_trunc('month', date_timezone('transaction_created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
            then transaction_id  
            end)) as transactions_this_month,
        count(distinct (case when {{ dbt_utils.date_trunc('month', date_timezone('invoice_created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
            then invoice_id  
            end)) as invoices_this_month,
        sum(case when type in ('charge') and {{ dbt_utils.date_trunc('month', date_timezone('created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
            then amount 
            else 0 
            end) as charges_this_month,
        sum(case when type in ('credit') and {{ dbt_utils.date_trunc('month', date_timezone('created_at')) }} = {{ dbt_utils.date_trunc('month', date_timezone(dbt_utils.current_timestamp())) }}
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
        min(case when type in ('charge') 
            then {{ date_timezone('created_at') }}
            else null 
            end) as first_charge_date,
        max(case when type in ('charge') 
            then {{ date_timezone('created_at') }}
            else null 
            end) as most_recent_charge_date,
        min( {{ date_timezone('invoice_created_at') }} ) as first_invoice_date,
        max( {{ date_timezone('invoice_created_at') }} ) as most_recent_invoice_date,
        max( {{ date_timezone('invoice_due_at') }} ) as next_invoice_due_at,
        min( {{ date_timezone('transaction_created_at') }} ) as first_transaction_date,
        max( {{ date_timezone('transaction_created_at') }} ) as most_recent_transaction_date

    from balance_transaction_joined
    group by 1

)

select 
    account_history.account_id,
    account_history.email,
    account_history.created_at as account_created_at,
    account_history.state as account_state,
    coalesce(transaction_grouped.total_transactions, 0) as total_transactions,
    coalesce(transaction_grouped.total_invoices, 0) as total_invoices,
    coalesce(transaction_grouped.total_charges, 0) as total_charges,
    coalesce(transaction_grouped.total_credits, 0) as total_credits,
    coalesce(transaction_grouped.total_gross_transaction_amount, 0) as total_gross_transaction_amount,
    coalesce(transaction_grouped.total_discounts, 0) as total_discounts,
    coalesce(transaction_grouped.total_net_taxes, 0) as total_net_taxes,
    coalesce(transaction_grouped.total_charge_count, 0) as total_charge_count,
    coalesce(transaction_grouped.total_credit_count, 0) as total_credit_count,
    coalesce(transaction_grouped.transactions_this_month, 0) as transactions_this_month,
    coalesce(transaction_grouped.invoices_this_month, 0) as invoices_this_month,
    coalesce(transaction_grouped.charges_this_month, 0) as charges_this_month,
    coalesce(transaction_grouped.credits_this_month, 0) as credits_this_month,
    coalesce(transaction_grouped.gross_transaction_amount_this_month, 0) as gross_transaction_amount_this_month,
    coalesce(transaction_grouped.discounts_this_month, 0) as discounts_this_month,
    coalesce(transaction_grouped.taxes_this_month, 0) as taxes_this_month,
    transaction_grouped.first_charge_date,
    transaction_grouped.most_recent_charge_date,
    transaction_grouped.first_invoice_date,
    transaction_grouped.most_recent_invoice_date,
    transaction_grouped.next_invoice_due_at,
    transaction_grouped.first_transaction_date,
    transaction_grouped.most_recent_transaction_date

from account_history
left join transactions_grouped 
    on account_history.account_id = transactions_grouped.account_id