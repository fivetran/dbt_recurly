{% set fields = ['rolling_account_balance','rolling_invoices','rolling_transactions','rolling_charge_balance','rolling_credit_balance','rolling_discount_balance','rolling_tax_balance','rolling_charges','rolling_credits'] %}

with account_partitions as (

    select * 
    from {{ ref('int_recurly__account_partitions') }}
),

account_overview as (

    select * 
    from {{ ref('recurly__account_overview') }}
),

final as (

    select
        account_partitions.source_relation,
        account_partitions.account_id,
        account_overview.account_created_at,
        account_overview.account_city,
        account_overview.account_company,
        account_overview.account_country,
        account_overview.account_code,
        account_overview.account_email,
        account_overview.account_first_name,
        account_overview.account_last_name,
        account_overview.account_is_tax_exempt,
        account_overview.account_postal_code,
        account_overview.account_region,
        account_overview.account_state,
        account_overview.account_username

        {{ fivetran_utils.persist_pass_through_columns('recurly_account_pass_through_columns', identifier='account_overview') }},
        {{ dbt_utils.generate_surrogate_key(['account_partitions.source_relation','account_partitions.account_id','date_day']) }} as account_daily_id,

        date_day,
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
            first_value({{ f }}) over (partition by account_partitions.source_relation, account_partitions.account_id, {{ f }}_partition order by date_day rows unbounded preceding)) as {{ f }}
        {%- if not loop.last -%},{%- endif -%}
        {% endfor %}
    from account_partitions
    left join account_overview
        on account_partitions.account_id = account_overview.account_id
        and account_partitions.source_relation = account_overview.source_relation
)    

select *
from final