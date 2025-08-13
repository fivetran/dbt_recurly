{{ config(enabled=var('recurly__using_subscription_change_history', true)) }}

select * 
from {{ var('subscription_change_history') }}
