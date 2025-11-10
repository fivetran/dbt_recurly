{{ config(enabled=var('recurly__standardized_billing_model_enabled', True)) }}

with line_items as (

    select * 
    from {{ ref('stg_recurly__line_item_history') }}
    where is_most_recent_record
),

invoices as (

    select *
    from {{ ref('stg_recurly__invoice_history') }}
    where is_most_recent_record
),

transactions as (

    select * 
    from {{ ref('stg_recurly__transaction') }}
    where is_most_recent_record
        and status = 'success'
),

subscription_history as (

    select
        *,
        row_number() over (partition by source_relation, subscription_id, current_period_started_at, current_period_ended_at order by updated_at desc) = 1 as is_latest_period
    from {{ ref('stg_recurly__subscription_history') }}
),

plans as (

    select * 
    from {{ ref('stg_recurly__plan_history') }}
    where is_most_recent_record
),

accounts as (

    select * 
    from {{ ref('stg_recurly__account_history') }}
    where is_most_recent_record
),

subscriptions as (

    select 
        *
    from subscription_history
    where is_latest_period
),

enhanced as (

    select
        line_items.source_relation,
        line_items.invoice_id as header_id,
        line_items.line_item_id,
        cast(row_number() over (partition by line_items.source_relation, line_items.invoice_id order by line_items.created_at) as {{ dbt.type_int() }}) as line_item_index,
        line_items.created_at,
        line_items.currency,
        line_items.state as line_item_status,
        line_items.type as billing_type,
        transactions.type as transaction_type,
        invoices.state as header_status,
        line_items.plan_id as product_id,
        plans.name as product_name,
        line_items.origin as product_type,
        line_items.description as product_category,
        line_items.quantity,
        line_items.unit_amount,
        line_items.discount as discount_amount,
        line_items.tax as tax_amount,
        line_items.amount as total_amount,
        transactions.transaction_id as payment_id,
        cast(null as {{ dbt.type_string() }}) as payment_method_id,
        transactions.payment_method_object as payment_method,
        transactions.collected_at as payment_at,
        cast(null as {{ dbt.type_numeric() }}) as fee_amount,
        invoices.refundable_amount as refund_amount,
        transactions.is_refunded,
        transactions.created_at as refunded_at,
        line_items.subscription_id,
        plans.name as subscription_plan,
        subscriptions.current_period_started_at as subscription_period_started_at,
        subscriptions.current_period_ended_at as subscription_period_ended_at,
        subscriptions.state as subscription_status,
        line_items.account_id as customer_id,
        accounts.created_at as customer_created_at,
        'account' as customer_level,
        {{ dbt.concat(["accounts.first_name", "''", "accounts.last_name"]) }} as customer_name,
        accounts.company as customer_company,
        accounts.email as customer_email,
        accounts.account_city as customer_city,
        accounts.account_country as customer_country
    from line_items
    left join invoices
        on invoices.invoice_id = line_items.invoice_id
        and invoices.source_relation = line_items.source_relation
    left join transactions
        on transactions.invoice_id = invoices.invoice_id
        and transactions.source_relation = invoices.source_relation
    left join accounts
        on accounts.account_id = line_items.account_id
        and accounts.source_relation = line_items.source_relation
    left join subscriptions
        on subscriptions.subscription_id = line_items.subscription_id
            and subscriptions.source_relation = line_items.source_relation
            and subscriptions.current_period_started_at <= line_items.created_at
            and subscriptions.current_period_ended_at > line_items.created_at
    left join plans
        on cast(plans.plan_id as {{ dbt.type_string() }}) = cast(line_items.plan_id as {{ dbt.type_string() }})
        and plans.source_relation = line_items.source_relation
),

final as (

    select
        source_relation,
        header_id,
        line_item_id,
        line_item_index,
        'line_item' as record_type,
        created_at,
        currency,
        header_status,
        product_id,
        product_name,
        transaction_type,
        billing_type,
        product_type,
        quantity,
        unit_amount,
        discount_amount,
        tax_amount,
        total_amount,
        payment_id,
        cast(null as {{ dbt.type_string() }}) as payment_method_id,
        payment_method,
        payment_at,
        fee_amount,
        cast(null as {{ dbt.type_float() }}) as refund_amount,
        subscription_id,
        subscription_plan,
        subscription_period_started_at,
        subscription_period_ended_at,
        subscription_status,
        customer_id,
        customer_created_at,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country
    from enhanced

    union all

    -- Refund information is only reliable at the invoice header. Therefore the below operation creates a new line to track the refund values.
    select
        source_relation,
        header_id,
        line_item_id,
        cast(0 as {{ dbt.type_int() }}) as line_item_index,
        'header' as record_type,
        created_at,
        currency,
        header_status,
        product_id,
        product_name,
        transaction_type,
        billing_type,
        cast(null as {{ dbt.type_string() }}) as product_type,
        cast(null as {{ dbt.type_float() }}) as quantity,
        cast(null as {{ dbt.type_float() }}) as unit_amount,
        cast(null as {{ dbt.type_float() }}) as discount_amount,
        cast(null as {{ dbt.type_float() }}) as tax_amount,
        cast(null as {{ dbt.type_float() }}) as total_amount,
        payment_id,
        cast(null as {{ dbt.type_string() }}) as payment_method_id,
        payment_method,
        payment_at,
        fee_amount,
        refund_amount,
        subscription_id,
        subscription_plan,
        subscription_period_started_at,
        subscription_period_ended_at,
        subscription_status,
        customer_id,
        customer_created_at,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country
    from enhanced
    where is_refunded
        and line_item_index = 1
)

select *
from final