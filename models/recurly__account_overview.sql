with account_history as (

    select * 
    from {{ var('account_history') }}
    where is_most_recent_record
),

balance_transaction_joined as (

    select * 
    from {{ ref('recurly__balance_transactions') }}
),

transactions_grouped as (

    select * 
    from {{ ref('int_recurly__transactions_grouped') }}
),

account_next_invoice as (

    select 
        account_id, 
        min(invoice_due_at) as next_invoice_due_at
    from balance_transaction_joined
    where invoice_due_at > {{ dbt_utils.date_trunc('day', dbt_utils.current_timestamp()) }}
    group by 1  
)

select 
    account_history.account_id,
    account_history.created_at as account_created_at,
    account_history.email as account_email,
    account_history.first_name as account_first_name,
    account_history.last_name as account_last_name,
    account_history.state as account_state,
    coalesce(transactions_grouped.total_transactions, 0) as total_transactions,
    coalesce(transactions_grouped.total_invoices, 0) as total_invoices,
    coalesce(transactions_grouped.total_charges, 0) as total_charges,
    coalesce(transactions_grouped.total_credits, 0) as total_credits,
    coalesce(transactions_grouped.total_gross_transaction_amount, 0) as total_gross_transaction_amount,
    coalesce(transactions_grouped.total_discounts, 0) as total_discounts,
    coalesce(transactions_grouped.total_net_taxes, 0) as total_net_taxes,
    coalesce(transactions_grouped.total_charge_count, 0) as total_charge_count,
    coalesce(transactions_grouped.total_credit_count, 0) as total_credit_count,
    coalesce(transactions_grouped.transactions_this_month, 0) as transactions_this_month,
    coalesce(transactions_grouped.invoices_this_month, 0) as invoices_this_month,
    coalesce(transactions_grouped.charges_this_month, 0) as charges_this_month,
    coalesce(transactions_grouped.credits_this_month, 0) as credits_this_month,
    coalesce(transactions_grouped.gross_transaction_amount_this_month, 0) as gross_transaction_amount_this_month,
    coalesce(transactions_grouped.discounts_this_month, 0) as discounts_this_month,
    coalesce(transactions_grouped.taxes_this_month, 0) as taxes_this_month,
    transactions_grouped.first_charge_date,
    transactions_grouped.most_recent_charge_date,
    transactions_grouped.first_invoice_date,
    transactions_grouped.most_recent_invoice_date,
    account_next_invoice.next_invoice_due_at,
    transactions_grouped.first_transaction_date,
    transactions_grouped.most_recent_transaction_date

from account_history
left join transactions_grouped 
    on account_history.account_id = transactions_grouped.account_id
left join account_next_invoice
    on transactions_grouped.account_id = account_next_invoice.account_id