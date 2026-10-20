with balance_transaction_joined as (

    select
        *,
        row_number() over (partition by balance_transaction_id {{ fivetran_utils.partition_by_source_relation(package_name='recurly') }} order by transaction_created_at, transaction_id) = 1 as is_first_line_item_row
    from {{ ref('recurly__balance_transactions') }}
),

final as (

    select
        source_relation,
        account_id,
        cast({{ dbt.date_trunc("day", "created_at") }} as date) as date_day,
        cast({{ dbt.date_trunc("week", "created_at") }} as date) as date_week,
        cast({{ dbt.date_trunc("month", "created_at") }} as date) as date_month,
        cast({{ dbt.date_trunc("year", "created_at") }} as date) as date_year,
        count(distinct transaction_id) as daily_transactions,
        count(distinct invoice_id) as daily_invoices,
        sum(case when lower(type) = 'charge' and is_first_line_item_row
            then amount
            else 0
            end) as daily_charges,
        sum(case when lower(type) = 'credit' and is_first_line_item_row
            then amount
            else 0
            end) as daily_credits,
        sum(case when is_first_line_item_row then amount end) as daily_balance,
        sum(case when is_first_line_item_row then discount end) as daily_discounts,
        sum(case when is_first_line_item_row then tax end) as daily_taxes,
        sum(case when lower(type) = 'charge' and is_first_line_item_row
            then 1
            else 0
            end) as daily_charge_count,
        sum(case when lower(type) = 'credit' and is_first_line_item_row
            then 1
            else 0
            end) as daily_credit_count
    from balance_transaction_joined
    {{ dbt_utils.group_by(6) }}
) 

select * 
from final