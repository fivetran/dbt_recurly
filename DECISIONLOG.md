# Decision Log

In creating this package, which is meant for a wide range of use cases, we had to take opinionated stances on a few different questions we came across during development. We've consolidated significant choices we made here, and will continue to update as the package evolves.

## Keeping the `coupon_id` name in `stg_recurly__coupon_redemption_history` after its meaning changed

Recurly's October 10, 2026 API change moves the unique coupon code ID that `coupon_id` used to hold into a new `unique_coupon_code_id` column; `coupon_id` now only holds the bulk coupon ID. We added `unique_coupon_code_id` to capture the new column, but kept `coupon_id`'s name as-is rather than renaming it (for example, to `bulk_coupon_id`).

We considered renaming it, since `coupon_id` no longer means what it used to. We chose not to because a rename would break the 1:1 naming match with Recurly's own source column, which matters for a staging model. Instead, we documented the change in place: `coupon_id`'s description now explains that it held the unique coupon code ID before October 10, 2026, and only the bulk coupon ID after.

If further refinements are needed, customers can submit a feature request by clicking the [New Issue button in our package issue page](https://github.com/fivetran/dbt_recurly/issues).
