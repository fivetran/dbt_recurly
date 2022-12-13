with account_history as (

    select * 
    from {{ var('account_history') }}
    where is_most_recent_record
),

balance_transaction_joined as (

    select * 
    from {{ ref('recurly__balance_transactions') }}
),

account_cumulatives as (

    select * 
    from {{ ref('int_recurly__account_cumulatives') }}
),

account_next_invoice as (

    select 
        account_id, 
        min(invoice_due_at) as next_invoice_due_at
    from balance_transaction_joined
    where invoice_due_at > {{ dbt_utils.date_trunc('day', dbt.current_timestamp_backcompat()) }}
    group by 1  
),

final as ( 

    select 
        account_history.account_id,
        account_history.created_at as account_created_at,
        account_history.account_city,
        account_history.code as account_code,       
        account_history.company as account_company,
        account_history.account_country,
        account_history.email as account_email,
        account_history.first_name as account_first_name,
        account_history.is_tax_exempt as account_is_tax_exempt,
        account_history.last_name as account_last_name,
        account_history.account_postal_code,
        account_history.account_region,
        account_history.state as account_state,
        account_history.username as account_username

        {{ fivetran_utils.persist_pass_through_columns('recurly_account_pass_through_columns', identifier='account_history') }},

        coalesce(account_cumulatives.total_transactions, 0) as total_transactions,
        coalesce(account_cumulatives.total_invoices, 0) as total_invoices,
        coalesce(account_cumulatives.total_charges, 0) as total_charges,
        coalesce(account_cumulatives.total_credits, 0) as total_credits,
        coalesce(account_cumulatives.total_balance, 0) as total_balance,
        coalesce(account_cumulatives.total_discounts, 0) as total_discounts,
        coalesce(account_cumulatives.total_taxes, 0) as total_taxes,
        coalesce(account_cumulatives.total_charge_count, 0) as total_charge_count,
        coalesce(account_cumulatives.total_credit_count, 0) as total_credit_count,
        coalesce(account_cumulatives.transactions_this_month, 0) as transactions_this_month,
        coalesce(account_cumulatives.invoices_this_month, 0) as invoices_this_month,
        coalesce(account_cumulatives.charges_this_month, 0) as charges_this_month,
        coalesce(account_cumulatives.credits_this_month, 0) as credits_this_month,
        coalesce(account_cumulatives.balance_this_month, 0) as balance_this_month,
        coalesce(account_cumulatives.discounts_this_month, 0) as discounts_this_month,
        coalesce(account_cumulatives.taxes_this_month, 0) as taxes_this_month,
        account_cumulatives.first_charge_date,
        account_cumulatives.most_recent_charge_date,
        account_cumulatives.first_invoice_date,
        account_cumulatives.most_recent_invoice_date,
        account_next_invoice.next_invoice_due_at,
        account_cumulatives.first_transaction_date,
        account_cumulatives.most_recent_transaction_date

    from account_history
    left join account_cumulatives 
        on account_history.account_id = account_cumulatives.account_id
    left join account_next_invoice
        on account_cumulatives.account_id = account_next_invoice.account_id
)

select * 
from final