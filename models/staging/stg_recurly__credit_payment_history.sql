{{ config(enabled=var('recurly__using_credit_payment_history', true)) }}

with base as (

    select * 
    from {{ ref('stg_recurly__credit_payment_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_recurly__credit_payment_history_tmp')),
                staging_columns=get_credit_payment_history_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as credit_payment_id,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        account_id,
        action,        
        cast(amount as {{ dbt.type_float() }}) as amount,
        applied_to_invoice_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        currency,
        refund_transaction_id,
        original_credit_payment_id,
        original_invoice_id,
        uuid,
        cast(voided_at as {{ dbt.type_timestamp() }}) as voided_at,
        row_number() over (partition by id order by updated_at desc) = 1 as is_most_recent_record
    from fields
) 

select *
from final