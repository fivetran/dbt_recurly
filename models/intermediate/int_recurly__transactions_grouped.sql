with balance_transaction_joined as (

    select * 
    from {{ ref('recurly__balance_transactions') }}
),

final as (
    select  
        account_id,
        cast({{ dbt_utils.date_trunc("day", "created_at") }} as date) as date_day,             
        cast({{ dbt_utils.date_trunc("week", "created_at") }} as date) as date_week, 
        cast({{ dbt_utils.date_trunc("month", "created_at") }} as date) as date_month, 
        cast({{ dbt_utils.date_trunc("year", "created_at") }} as date) as date_year,  
        count(distinct transaction_id) as daily_transactions,
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
    {{ dbt_utils.group_by(5) }}
) 

select * 
from final