 with final as (

    select * 
    from {{ ref('int_recurly__account_running_totals') }}
) 

select *
from final