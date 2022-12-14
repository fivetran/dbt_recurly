 with account_running_totals as (

    select * 
    from {{ ref('int_recurly__account_running_totals') }}
),
 
final as (

    select *
    from account_running_totals
)    

select *
from final