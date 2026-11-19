with line_item_history as (

    select * 
    from {{ ref('stg_recurly__line_item_history') }}
    where is_most_recent_record
),

invoice_history as (

    select *
    from {{ ref('stg_recurly__invoice_history') }}
    where is_most_recent_record
),

transaction_history as (

    select *
    from {{ ref('stg_recurly__transaction') }}
    where is_most_recent_record
),

-- An invoice can have several transactions, such as a voided attempt and a later successful one.
-- Keep one transaction per invoice so each line item appears once: the latest successful one, or the latest one if none succeeded.
invoice_transaction as (

    select *
    from (
        select
            *,
            row_number() over (
                partition by invoice_id {{ fivetran_utils.partition_by_source_relation(package_name='recurly') }}
                order by case when lower(status) = 'success' then 0 else 1 end, created_at desc, transaction_id desc
            ) as transaction_rank
        from transaction_history
        where invoice_id is not null
    ) as ranked
    where transaction_rank = 1
),


final as (

    select
        line_item_history.source_relation,
        line_item_history.line_item_id as balance_transaction_id,
        line_item_history.created_at,
        line_item_history.updated_at,
        line_item_history.account_id,
        line_item_history.invoice_id,
        line_item_history.invoice_number,
        line_item_history.type,
        line_item_history.state,
        line_item_history.origin,
        line_item_history.product_code,
        line_item_history.discount,
        line_item_history.tax,
        line_item_history.description,
        line_item_history.plan_code,
        line_item_history.add_on_code,
        line_item_history.has_refund,
        line_item_history.refunded_quantity,
        line_item_history.currency,
        line_item_history.amount,
        line_item_history.credit_applied,
        line_item_history.quantity,
        line_item_history.unit_amount,
        line_item_history.subtotal,
        line_item_history.started_at,
        line_item_history.ended_at,
        line_item_history.original_line_item_invoice_id,
        line_item_history.previous_line_item_id,
        invoice_history.state as invoice_state,
        invoice_history.origin as invoice_origin,
        invoice_history.type as invoice_type,
        invoice_history.created_at as invoice_created_at,
        invoice_history.due_at as invoice_due_at,
        invoice_history.closed_at as invoice_closed_at,
        invoice_transaction.transaction_id,
        invoice_transaction.created_at as transaction_created_at,
        invoice_transaction.type as transaction_type,
        invoice_transaction.origin as transaction_origin,
        invoice_transaction.status as transaction_status,
        invoice_transaction.billing_country as transaction_billing_country,
        invoice_transaction.status_message as transaction_status_message,
        invoice_transaction.payment_method_object as transaction_payment_method_object
    from line_item_history
    left join invoice_history
        on line_item_history.invoice_id = invoice_history.invoice_id
        and line_item_history.source_relation = invoice_history.source_relation
    left join invoice_transaction
        on invoice_history.invoice_id = invoice_transaction.invoice_id
        and invoice_history.source_relation = invoice_transaction.source_relation
)

select * 
from final