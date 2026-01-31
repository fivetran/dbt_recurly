{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}
 
-- this test ensures the recurly__monthly_recurring_revenue end model matches the prior version

with prod as (
    
    select 
        account_monthly_id,
        source_relation,
        current_month_mrr,
        previous_month_mrr
    from {{ target.schema }}_recurly_prod.recurly__monthly_recurring_revenue
),

dev as (

    select
        account_monthly_id,
        source_relation,
        current_month_mrr,
        previous_month_mrr 
    from {{ target.schema }}_recurly_dev.recurly__monthly_recurring_revenue
),


final as (

    select
        prod.account_monthly_id, 
        prod.source_relation, 
        prod.current_month_mrr as prod_current_month_mrr,
        dev.current_month_mrr as dev_current_month_mrr,
        prod.previous_month_mrr as prod_previous_month_mrr,
        dev.previous_month_mrr as dev_previous_month_mrr
    from prod   
    full outer join dev
        on dev.account_monthly_id = prod.account_monthly_id 
        and dev.source_relation = prod.source_relation
)

select * 
from final
where abs(prod_current_month_mrr - dev_current_month_mrr) >= 0.01
or abs(prod_previous_month_mrr - dev_previous_month_mrr) >= 0.01