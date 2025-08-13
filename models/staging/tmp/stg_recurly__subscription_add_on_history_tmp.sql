{{ config(enabled=var('recurly__using_subscription_add_on_history', true)) }}

select * 
from {{ var('subscription_add_on_history') }}
