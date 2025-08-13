# dbt_recurly v1.0.0

[PR #37](https://github.com/fivetran/dbt_recurly/pull/37) includes the following updates:

## Breaking Changes

### Source Package Consolidation
- Removed the dependency on the `fivetran/recurly_source` package.
  - All functionality from the source package has been merged into this transformation package for improved maintainability and clarity.
  - If you reference `fivetran/recurly_source` in your `packages.yml`, you must remove this dependency to avoid conflicts.
  - Any source overrides referencing the `fivetran/recurly_source` package will also need to be removed or updated to reference this package.
  - Update any recurly_source-scoped variables to be scoped to only under this package. See the [README](https://github.com/fivetran/dbt_recurly/blob/main/README.md) for how to configure the build schema of staging models.
- As part of the consolidation, vars are no longer used to reference staging models, and only sources are represented by vars. Staging models are now referenced directly with `ref()` in downstream models.

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
  - Removed all `dbt_utils.unique_combination_of_columns` tests.
  - Removed all `accepted_values` tests.
  - Moved `loaded_at_field: _fivetran_synced` under the `config:` block in `src_recurly.yml`.

### Under the Hood
- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`.

# dbt_recurly v0.7.0

[PR #34](https://github.com/fivetran/dbt_recurly/pull/34) includes the following updates:

## Breaking Change for dbt Core < 1.9.6

> *Note: This is not relevant to Fivetran Quickstart users.*

Migrated `freshness` from a top-level source property to a source `config` in alignment with [recent updates](https://github.com/dbt-labs/dbt-core/issues/11506) from dbt Core ([Recurly Source v0.4.0](https://github.com/fivetran/dbt_recurly_source/releases/tag/v0.4.0)). This will resolve the following deprecation warning that users running dbt >= 1.9.6 may have received:

```
[WARNING]: Deprecated functionality
Found `freshness` as a top-level property of `recurly` in file
`models/src_recurly.yml`. The `freshness` top-level property should be moved
into the `config` of `recurly`.
```

**IMPORTANT:** Users running dbt Core < 1.9.6 will not be able to utilize freshness tests in this release or any subsequent releases, as older versions of dbt will not recognize freshness as a source `config` and therefore not run the tests.

If you are using dbt Core < 1.9.6 and want to continue running Recurly freshness tests, please elect **one** of the following options:
  1. (Recommended) Upgrade to dbt Core >= 1.9.6
  2. Do not upgrade your installed version of the `recurly` package. Pin your dependency on v0.6.0 in your `packages.yml` file.
  3. Utilize a dbt [override](https://docs.getdbt.com/reference/resource-properties/overrides) to overwrite the package's `recurly` source and apply freshness via the previous release top-level property route. This will require you to copy and paste the entirety of the previous release `src_recurly.yml` file and add an `overrides: recurly_source` property.

## Under the Hood
- Updates to ensure integration tests use latest version of dbt.

# dbt_recurly v0.6.0
This release includes the following changes:

## Schema/Data Changes
**1 total change • 0 possible breaking changes**
| **Data Model** | **Change type** | **Old name** | **New name** | **Notes** |
| ---------------- | --------------- | ------------ | ------------ | --------- |
| [`recurly__line_item_enhanced`](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__line_item_enhanced) | Modified Model | | | Now enabled by default. |

## Features
- Enabled the `recurly__line_item_enhanced` model by default. Previously, this model required opting in via the `recurly__standardized_billing_model_enabled` variable. This change ensures the model is available by default for Quickstart users. ([#33](https://github.com/fivetran/dbt_recurly/pull/33))
  - Users can still disable the model by setting the variable to `false` in `dbt_project.yml`.

## Documentation
- Added Quickstart model counts to README. ([#32](https://github.com/fivetran/dbt_recurly/pull/32))
- Corrected references to connectors and connections in the README. ([#32](https://github.com/fivetran/dbt_recurly/pull/32))

# dbt_recurly v0.5.1
[PR #30](https://github.com/fivetran/dbt_recurly/pull/30) includes the following breaking changes:

## Under the Hood
- Updated `quickstart.yml` to list only the relevant `public_models`.

# dbt_recurly v0.5.0
[PR #29](https://github.com/fivetran/dbt_recurly/pull/29) includes the following breaking changes:

## Breaking Changes
- Removed unused fields from `stg_recurly__subscription_history` in the upstream `dbt_recurly_source` package (see [release notes](https://github.com/fivetran/dbt_recurly_source/releases/tag/v0.3.0)):
  - `converted_at`
  - `has_started_with_gift`
- While this change does not directly affect fields in this package’s models, it is classified as a breaking change due to modifications in `stg_recurly__subscription_history`.
- These fields were removed as they are slated for future deprecation in the Fivetran Connector and are not explicitly referenced in the final models.

# dbt_recurly v0.4.0

[PR #26](https://github.com/fivetran/dbt_recurly/pull/26) includes the following breaking changes:

## Feature Updates
- Addition of the `recurly__line_item_enhanced` model. This model constructs a comprehensive, denormalized analytical table that enables reporting on key revenue, subscription, customer, and product metrics from your billing platform. It’s designed to align with the schema of the `*__line_item_enhanced` model found in Recurly, Recharge, Stripe, Shopify, and Zuora, offering standardized reporting across various billing platforms. To see the kinds of insights this model can generate, explore example visualizations in the [Fivetran Billing Model Streamlit App](https://fivetran-billing-model.streamlit.app/). Visit the app for more details.
  -  This model is currently disabled by default. You may enable it by setting the `recurly__standardized_billing_model_enabled` as `true` in your `dbt_project.yml`.

## Under the Hood:
- Added consistency test within integration_tests for the `recurly__line_item_enhanced` model.
- Included auto-releaser GitHub Actions workflow to automate future releases.
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request templates.

# dbt_recurly v0.3.2
## 🪲 Bug Fixes 🔧
- Created a `unique_combination_of_columns` test on the `balance_transaction_id` and `transaction_id` columns in `recurly__balance_transactions` to account for line items with multiple transactions. Also modified relevant seed files to test these changes ([PR #21](https://github.com/fivetran/dbt_recurly/pull/21)).
- Updated `current_timestamp` macros in `int_recurly__account_cumulatives` and `recurly__account_overview` models to `current_timestamp_backcompat`, in accordance with the dbt-utils update from the v0.3.0 release ([#20](https://github.com/fivetran/dbt_recurly/issues/20)).

# dbt_recurly v0.3.1
## Documentation Update
- Corrected the yaml variable names in [step 4 of the README doc](https://github.com/fivetran/dbt_recurly#step-4-disable-models-for-non-existent-sources) to reflect the proper names used within the package. ([#18](https://github.com/fivetran/dbt_recurly/pull/18))

## Contributors
- [@benigls](https://github.com/benigls) ([#18](https://github.com/fivetran/dbt_recurly/pull/18))

# dbt_recurly v0.3.0
## 🚨 Breaking Change and 🎉 Feature
- Intermediate models now materialize in their own schema named `recurly_int`. This is to reduce noise in the schema for the final model outputs. ([#15](https://github.com/fivetran/dbt_recurly/pull/15))
  - **Note:** Before running this new version, we recommend that you manually remove any `int_recurly...` tables from the original output schema. 
## 🔧 Bug Fixes
- Updated how `date_week` is determined in model `int_recurly__account_rolling_totals`. ([#15](https://github.com/fivetran/dbt_recurly/pull/15))

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

# Features  
- Refactored the `recurly__account_daily_overview` to prevent query timeouts, brought up in [#8](https://github.com/fivetran/dbt_recurly/issues/8).
- Created intermediate models previously present in `recurly__account_daily_overview` to optimize runtime for advanced loop functions, `int_recurly__account_partitions` and `int_recurly__account_running_totals`. 
- Changed intermediate folder materializations from ephemeral to table because of complexity of calculations. 

## Under the Hood
- Updated the condition for involuntary churn to include `tax_location_invalid` in addition to `non-payment` types. ([#10](https://github.com/fivetran/dbt_recurly/pull/10))

## Contributors
- [@suelai](https://github.com/suelai) ([#10](https://github.com/fivetran/dbt_recurly/pull/10))

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
