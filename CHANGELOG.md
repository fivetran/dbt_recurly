# dbt_recurly v0.1.1
# Features  
- Refactored the `recurly__account_daily_overview` to prevent query timeouts, brought up in [#8](https://github.com/fivetran/dbt_recurly/issues/8).
- Created intermediate models previously present in `recurly__account_daily_overview` to optimize runtime for advanced loop functions, `int_recurly__account_partitions` and `int_recurly__account_running_totals`. 
- Changed intermediate folder materializations from ephemeral to view because of complexity of calculations. 
## Under the Hood
- Added Buildkite integration tests.  
# dbt_recurly v0.1.0

## Initial Release
This is the initial release of this package. 

__What does this dbt package do?__
- Produces modeled tables that leverage Recurly data from [Fivetran's connector](https://fivetran.com/docs/applications/recurly) in the format described [here](https://fivetran.com/docs/applications/recurly#schemainformation) and builds off the output of our [Recurly source package](https://github.com/fivetran/dbt_recurly_source).

- The above mentioned models enable you to better understand your Recurly performance metrics at different granularities. It achieves this by:
  - Providing intuitive reporting at the account, balance transaction and subscription levels.
  - Builds a daily overview of account balance activity based on account and transaction tables.
  - Generates monthly recurring revenue table at the account level.
  - Generates churn analysis table at the subscription level.
  - Aggregates all relevant metrics into each of the reporting levels above.
  - Generate a metrics table that allows you to better understand your account activity over time or at a customer level. These time-based metrics are available on a daily level.
- Generates a comprehensive data dictionary of your source and modeled Recurly data via the [dbt docs site](fivetran.github.io/dbt_recurly/)