{{ config(enabled=var('recurly__using_credit_payment_history', true)) }}

select * 
from {{ var('credit_payment_history') }}
