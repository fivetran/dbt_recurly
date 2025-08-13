with base as (

    select *
    from {{ ref('stg_recurly__billing_info_history_tmp') }}
),

fields as (
    select
        {{ 
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recurly__billing_info_history_tmp')),
                staging_columns = get_billing_info_history_columns()
            ) 
        }}
    from base
),

final as (

    select
        id as billing_id, 
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        account_id,
        billing_city,
        billing_country,
        billing_phone,
        billing_postal_code,
        billing_region,
        billing_street_1,
        billing_street_2,
        company,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at, 
        first_name,
        valid as is_valid,
        last_name,
        payment_method_card_type,
        payment_method_object,
        updated_by_country,
        updated_by_ip,
        vat_number,
        row_number() over (partition by id order by updated_at desc) = 1 as is_most_recent_record
    from fields
)

select *
from final
