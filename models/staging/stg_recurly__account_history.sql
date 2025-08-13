with base as (

    select *
    from {{ ref('stg_recurly__account_history_tmp') }}
),

fields as (

    select 
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recurly__account_history_tmp')),
                staging_columns = get_account_history_columns()
            )
        }}
    from base
),

final as (

    select
        id as account_id, 
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at, 
        account_city,
        account_country, 
        account_postal_code,
        account_region,
        bill_to, 
        cc_emails, 
        code, 
        company, 
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        cast(deleted_at as {{ dbt.type_timestamp() }}) as deleted_at,
        email,  
        first_name,
        row_number() over (partition by id order by updated_at desc) = 1 as is_most_recent_record,
        tax_exempt as is_tax_exempt, 
        last_name,
        state, 
        username, 
        vat_number

        --The below macro adds the fields defined within your accounts_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('recurly_account_pass_through_columns') }}

   from fields
)

select *
from final
