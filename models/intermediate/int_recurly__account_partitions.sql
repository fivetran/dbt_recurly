{% set fields = ['rolling_account_balance','rolling_invoices','rolling_transactions','rolling_charge_balance','rolling_credit_balance','rolling_discount_balance','rolling_tax_balance','rolling_charges','rolling_credits'] %}

with account_rolling_totals as (

    select * 
    from {{ ref('int_recurly__account_rolling_totals') }}
),


final as (

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
)

select * 
from final