{% set fields = ['rolling_account_balance','rolling_invoices','rolling_transactions','rolling_charge_balance','rolling_credit_balance','rolling_discount_balance','rolling_tax_balance','rolling_charges','rolling_credits'] %}

with account_rolling_totals as (

    select * 
    from {{ ref('int_recurly__account_rolling_totals') }}
),

account_partitions as (

    select
        *,
        {% for f in fields %}
        sum(case when {{ f }} is null  
            then 0  
            else 1  
                end) over (order by account_id, date_day rows unbounded preceding) as {{ f }}_partition
        {%- if not loop.last -%},{%- endif -%}
        {% endfor %}          
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
        {% for f in fields %}
        coalesce({{ f }},   
            first_value({{ f }}) over (partition by {{ f }}_partition order by date_day rows unbounded preceding)) as {{ f }}
        {%- if not loop.last -%},{%- endif -%}
        {% endfor %}
    from account_partitions
)    

select *
from final