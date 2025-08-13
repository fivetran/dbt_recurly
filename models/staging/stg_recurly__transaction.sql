with base as (

    select *
    from {{ ref('stg_recurly__transaction_tmp') }}
),

fields as (

    select
        {{ 
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recurly__transaction_tmp')),
                staging_columns = get_transaction_columns()
            ) 
        }}
    from base
),

final as (

    select  
        id as transaction_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        account_id,
        cast(amount as {{ dbt.type_float() }}) as amount,
        billing_city,
        billing_country,
        billing_first_name,
        billing_last_name,
        billing_phone,
        billing_postal_code,
        billing_region,
        billing_street_1,
        billing_street_2,
        cast(collected_at as {{ dbt.type_timestamp() }}) as collected_at,
        collection_method,
        currency,
        customer_message,
        customer_message_locale,
        gateway_approval_code,
        gateway_message,
        gateway_reference,
        gateway_response_code,
        gateway_response_time,
        gateway_response_values,
        invoice_id,
        refunded as is_refunded,
        success as is_successful,
        row_number() over (partition by id order by created_at desc) = 1 as is_most_recent_record,
        origin,
        original_transaction_id, 
        payment_gateway_id,
        payment_gateway_name,
        payment_gateway_type,
        payment_method_object,
        status,
        status_code,
        status_message,
        TYPE as type,
        uuid,
        cast(voided_at as {{ dbt.type_timestamp() }}) as voided_at,
        voided_by_invoice_id
    from fields
)

select *
from final
