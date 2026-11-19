with balance_transaction_joined as (

    select * 
    from {{ ref('recurly__balance_transactions') }}
),

transaction_history as (

    select *
    from {{ ref('stg_recurly__transaction') }}
    where is_most_recent_record
),

-- recurly__balance_transactions keeps one transaction per invoice, so count every transaction on the invoice here.
line_item_invoice_days as (

    select distinct
        source_relation,
        account_id,
        cast({{ dbt.date_trunc("day", "created_at") }} as date) as date_day,
        invoice_id
    from balance_transaction_joined
),

daily_transactions as (

    select
        line_item_invoice_days.source_relation,
        line_item_invoice_days.account_id,
        line_item_invoice_days.date_day,
        count(distinct transaction_history.transaction_id) as daily_transactions
    from line_item_invoice_days
    join transaction_history
        on line_item_invoice_days.invoice_id = transaction_history.invoice_id
        and line_item_invoice_days.source_relation = transaction_history.source_relation
    group by 1, 2, 3
),

line_items_grouped as (


    select
        source_relation,
        account_id,
        cast({{ dbt.date_trunc("day", "created_at") }} as date) as date_day,
        cast({{ dbt.date_trunc("week", "created_at") }} as date) as date_week,
        cast({{ dbt.date_trunc("month", "created_at") }} as date) as date_month,
        cast({{ dbt.date_trunc("year", "created_at") }} as date) as date_year,
        count(distinct invoice_id) as daily_invoices,
        sum(case when lower(type) = 'charge'
            then amount
            else 0
            end) as daily_charges,
        sum(case when lower(type) = 'credit'
            then amount
            else 0
            end) as daily_credits,
        sum(amount) as daily_balance,
        sum(discount) as daily_discounts,
        sum(tax) as daily_taxes,
        sum(case when lower(type) = 'charge'
            then 1
            else 0
            end) as daily_charge_count,
        sum(case when lower(type) = 'credit'
            then 1
            else 0
            end) as daily_credit_count
    from balance_transaction_joined
    {{ dbt_utils.group_by(6) }}
),

final as (

    select
        line_items_grouped.source_relation,
        line_items_grouped.account_id,
        line_items_grouped.date_day,
        line_items_grouped.date_week,
        line_items_grouped.date_month,
        line_items_grouped.date_year,
        coalesce(daily_transactions.daily_transactions, 0) as daily_transactions,
        line_items_grouped.daily_invoices,
        line_items_grouped.daily_charges,
        line_items_grouped.daily_credits,
        line_items_grouped.daily_balance,
        line_items_grouped.daily_discounts,
        line_items_grouped.daily_taxes,
        line_items_grouped.daily_charge_count,
        line_items_grouped.daily_credit_count
    from line_items_grouped
    left join daily_transactions
        on line_items_grouped.account_id = daily_transactions.account_id
        and line_items_grouped.date_day = daily_transactions.date_day
        and line_items_grouped.source_relation = daily_transactions.source_relation
)

select *
from final