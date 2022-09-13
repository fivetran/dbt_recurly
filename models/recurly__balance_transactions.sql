with line_item_history as (

    select * 
    from {{ var('line_item_history')}}
),

invoice_history as (

    select * 
    from {{ var('invoice_history')}}
),

transaction_history as (

    select * 
    from {{ var('transaction')}}
)


select 
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
    transaction_history.transaction_id,
    transaction_history.type as transaction_type,
    transaction_history.origin as transaction_origin,
    transaction_history.status as transaction_status, 
    transaction_history.billing_country as transaction_billing_country, 
    transaction_history.status_message as transaction_status_message,
    transaction_history.payment_method_object as transaction_payment_method_object

from line_item_history 
left join invoice_history
    on line_item_history.invoice_id = invoice_history.invoice_id
left join transaction_history 
    on invoice_history.invoice_id = transaction_history.invoice_id