{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}
 
-- this test ensures the recurly__monthly_recurring_revenue end model matches the prior version

with prod as (
    
    select 
        account_daily_id,
        source_relation,
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
where abs(prod_charge_balance - dev_charge_balance) >= 0.01
or abs(prod_credit_balance - dev_credit_balance) >= 0.01
or abs(prod_discount_balance - dev_discount_balance) >= 0.01
or abs(prod_tax_balance - dev_tax_balance) >= 0.01