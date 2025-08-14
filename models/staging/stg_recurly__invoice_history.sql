with base as (

    select *
    from {{ ref('stg_recurly__invoice_history_tmp') }}
),

fields as (

    select
        {{ 
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recurly__invoice_history_tmp')),
                staging_columns = get_invoice_history_columns()
            ) 
        }}
    from base
),

final as (

    select
        id as invoice_id, 
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        account_id,
        cast(balance as {{ dbt.type_float() }}) as balance,
        cast(closed_at as {{ dbt.type_timestamp() }}) as closed_at,
        collection_method,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        currency,
        discount,
        cast(due_at as {{ dbt.type_timestamp() }}) as due_at,
        row_number() over (partition by id order by updated_at desc) = 1 as is_most_recent_record,
        net_terms,
        number,
        origin,
        paid,
        po_number,        
        previous_invoice_id,
        refundable_amount,
        state,
        subtotal,
        tax,
        tax_rate,
        tax_region,
        tax_type,
        total,
        type
    from fields
)

select *
from final
