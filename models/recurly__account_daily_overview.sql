 with account_running_totals as (

    select * 
    from {{ ref('int_recurly__account_running_totals') }}
),
 
final as (

    select *
        {{ fivetran_utils.persist_pass_through_columns('recurly_account_pass_through_columns', identifier='account_overview') }},      
        {{ dbt_utils.surrogate_key(['account_running_totals.account_id','date_day']) }} as account_daily_id
    from account_running_totals
)    

select *
from final