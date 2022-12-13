# Feature updates
- Refactored the `recurly__account_daily_overview` to prevent query timeouts.
- Created intermediate models previously present in `recurly__account_daily_overview` to run the more advanced loop functions. 

# dbt_recurly v0.2.0
## 🚨 Breaking Changes 🚨:
[PR #7](https://github.com/fivetran/dbt_recurly/pull/7) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- `dbt_utils.surrogate_key` has also been updated to `dbt_utils.generate_surrogate_key`. Since the method for creating surrogate keys differ, we suggest all users do a `full-refresh` for the most accurate data. For more information, please refer to dbt-utils [release notes](https://github.com/dbt-labs/dbt-utils/releases) for this update.
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

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