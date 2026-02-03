{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}
 
-- this test ensures the recurly__monthly_recurring_revenue end model matches the prior version

with prod as (
    
    select 
        account_daily_id,
        source_relation,
        daily_charges,
        daily_credits,
        daily_discounts, 
        daily_net_change, 
        daily_taxes,
        rolling_account_balance,
        rolling_charge_balance,
        rolling_credit_balance,
        rolling_discount_balance,
        rolling_tax_balance
    from {{ target.schema }}_recurly_prod.recurly__account_daily_overview
),

dev as (

    select
        account_daily_id,
        source_relation,
        daily_charges,
        daily_credits,
        daily_discounts, 
        daily_net_change, 
        daily_taxes,
        rolling_account_balance,
        rolling_charge_balance,
        rolling_credit_balance,
        rolling_discount_balance,
        rolling_tax_balance
    from {{ target.schema }}_recurly_dev.recurly__account_daily_overview
),


final as (

    select
        prod.account_daily_id,
        prod.source_relation,
        prod.daily_charges as prod_daily_charges,
        dev.daily_charges as dev_daily_charges,
        prod.daily_credits as prod_daily_credits,
        dev.daily_credits as dev_daily_credits,
        prod.daily_discounts as prod_daily_discounts, 
        dev.daily_discounts as dev_daily_discounts, 
        prod.daily_net_change as prod_daily_change, 
        dev.daily_net_change as dev_daily_change, 
        prod.daily_taxes as prod_daily_taxes,
        dev.daily_taxes as dev_daily_taxes,
        prod.rolling_account_balance as prod_account_balance,
        dev.rolling_account_balance as dev_account_balance,
        prod.rolling_charge_balance as prod_charge_balance,
        dev.rolling_charge_balance as dev_charge_balance,
        prod.rolling_credit_balance as prod_credit_balance,
        dev.rolling_credit_balance as dev_credit_balance,
        prod.rolling_discount_balance as prod_discount_balance,
        dev.rolling_discount_balance as dev_discount_balance, 
        prod.rolling_tax_balance as prod_tax_balance,
        dev.rolling_tax_balance as dev_tax_balance

    from prod   
    full outer join dev
        on dev.account_daily_id = prod.account_daily_id 
        and dev.source_relation = prod.source_relation
)

select * 
from final
where abs(prod_account_balance - dev_account_balance) >= 0.01
or abs(prod_charge_balance - dev_charge_balance) >= 0.01
or abs(prod_credit_balance - dev_credit_balance) >= 0.01
or abs(prod_discount_balance - dev_discount_balance) >= 0.01
or abs(prod_tax_balance - dev_tax_balance) >= 0.01
or abs(prod_daily_charges - dev_daily_charges) >= 0.01
or abs(prod_daily_credits - dev_daily_credits) >= 0.01
or abs(prod_daily_discounts - dev_daily_discounts) >= 0.01
or abs(prod_daily_taxes - dev_daily_taxes) >= 0.01
or abs(prod_daily_change - dev_daily_change) >= 0.01