
with line_items as (

    select * 
    from {{ var('line_item_history')}}
    where is_most_recent_record
),

invoices as (

    select *
    from {{ var('invoice_history')}}
    where is_most_recent_record
),

transactions as (

    select * 
    from {{ var('transaction')}}
    where is_most_recent_record
),

subscription_history as (

    select 
        *,
        row_number() over (partition by subscription_id, current_period_started_at, current_period_ended_at order by updated_at desc) = 1 as is_latest_period
    from {{ var('subscription_history') }}
),

plans as (

    select * 
    from {{ var('plan_history') }}
    where is_most_recent_record
),

accounts as (

    select * 
    from {{ var('account_history') }}
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
        line_items.invoice_id,
        line_items.line_item_id,
        row_number() over (partition by line_items.invoice_id order by line_items.created_at) as line_item_index,
        line_items.created_at,
        line_items.currency,
        line_items.state as line_item_status,
        invoices.state as header_status,
        line_items.plan_id,
        plans.name as plan_name,
        line_items.origin as plan_type,
        line_items.description as plan_category,
        line_items.quantity,
        line_items.unit_amount,
        line_items.discount as discount_amount,
        line_items.tax_rate,
        line_items.tax as tax_amount,
        line_items.amount as total_amount,
        transactions.transaction_id as payment_id,
        transactions.payment_method_object as payment_method,
        transactions.collected_at as payment_at,
        transactions.is_refunded,
        invoices.refundable_amount as refund_amount,
        transactions.created_at as refunded_at,
        line_items.subscription_id,
        subscriptions.current_period_started_at as subscription_period_started_at,
        subscriptions.current_period_ended_at as subscription_period_ended_at,
        subscriptions.state as subscription_status,
        line_items.account_id,
        concat(accounts.first_name, ' ', accounts.last_name) as account_name,
        accounts.company as account_company,
        accounts.email as account_email
    from line_items
    left join invoices
        on invoices.invoice_id = line_items.invoice_id
    left join transactions
        on transactions.invoice_id = invoices.invoice_id
    left join accounts
        on accounts.account_id = line_items.account_id
    left join subscriptions
        on subscriptions.subscription_id = line_items.subscription_id
            and subscriptions.current_period_started_at <= line_items.created_at
            and subscriptions.current_period_ended_at > line_items.created_at
    left join plans
        on plans.plan_id = line_items.plan_id
),

final as (

    select 
        invoice_id,
        line_item_id,
        line_item_index,
        created_at,
        currency,
        line_item_status,
        header_status,
        plan_id,
        plan_name,
        plan_type,
        plan_category,
        quantity,
        unit_amount,
        discount_amount,
        tax_rate,
        tax_amount,
        total_amount,
        payment_id,
        payment_method,
        payment_at,
        cast(null as {{ dbt.type_string() }}) as refund_id,
        cast(null as {{ dbt.type_float() }}) as refund_amount,
        cast(null as {{ dbt.type_timestamp() }}) as refunded_at,
        subscription_id,
        subscription_period_started_at,
        subscription_period_ended_at,
        subscription_status,
        account_id,
        account_name,
        account_company,
        account_email,
        'line_item' as source
    from enhanced

    union all

    -- Refund information is only reliable at the invoice header. Therefore the below operation creates a new line to track the refund values.
    select
        invoice_id,
        line_item_id,
        line_item_index,
        created_at,
        currency,
        line_item_status,
        header_status,
        plan_id,
        plan_name,
        cast(null as {{ dbt.type_string() }}) as plan_type,
        cast(null as {{ dbt.type_string() }}) as plan_category,
        cast(null as {{ dbt.type_float() }}) as quantity,
        cast(null as {{ dbt.type_float() }}) as unit_amount,
        cast(null as {{ dbt.type_float() }}) as discount_amount,
        tax_rate,
        cast(null as {{ dbt.type_float() }}) as tax_amount,
        cast(null as {{ dbt.type_float() }}) as total_amount,
        payment_id,
        payment_method,
        payment_at,
        payment_id as refund_id,
        refund_amount,
        refunded_at,
        subscription_id,
        subscription_period_started_at,
        subscription_period_ended_at,
        subscription_status,
        account_id,
        account_name,
        account_company,
        account_email,
        'header' as source
    from enhanced
    where is_refunded 
        and line_item_index = 1
)

select *
from final