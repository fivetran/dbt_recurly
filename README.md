<!--section="recurly_transformation_model"-->
# Recurly dbt Package

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_recurly/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0,_<3.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/data-models/quickstart-management#quickstartmanagement">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

This dbt package transforms data from Fivetran's Recurly connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 47
- Connector documentation
  - [Recurly connector documentation](https://fivetran.com/docs/connectors/applications/recurly)
  - [Recurly ERD](https://fivetran.com/docs/connectors/applications/recurly#schemainformation)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_recurly)
  - [dbt Docs](https://fivetran.github.io/dbt_recurly/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_recurly/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_recurly/blob/main/CHANGELOG.md)

## What does this dbt package do?
This package enables you to enhance balance transaction entries with useful fields, create customized analysis tables to examine churn and monthly recurring revenue, and generate metrics tables for account activity analysis. It creates enriched models with metrics focused on transactions, subscriptions, and customer behavior.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_recurly
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| [recurly__account_daily_overview](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__account_daily_overview) | Provides daily account snapshots with transaction counts, invoices, charges, credits, discounts, taxes, and rolling balance totals to track account financial health and payment activity evolution over time. <br></br>**Example Analytics Questions:**<ul><li>How does the rolling_account_balance evolve day-by-day for each account?</li><li>What are the daily trends in daily_charges versus daily_credits by account?</li><li>Which accounts have the highest rolling_transactions and rolling_invoices counts?</li></ul>|
| [recurly__account_overview](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__account_overview) | Consolidates account profiles with comprehensive transaction metrics including total invoices, charges, credits, balances, discounts, taxes, and monthly totals to understand account financial performance and relationships. <br></br>**Example Analytics Questions:**<ul><li>Which accounts have the highest total_balance and total_charges?</li><li>How do charges_this_month and credits_this_month compare to historical totals?</li><li>What is the time between first_charge_date and most_recent_charge_date by account segment?</li></ul>|
| [recurly__balance_transactions](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__balance_transactions) | Chronicles individual balance transactions including charges, credits, discounts, taxes, and refunds by type and state with product details to provide granular visibility into invoice components and balance calculations. <br></br>**Example Analytics Questions:**<ul><li>Which transaction types have the highest total amount and discount values?</li><li>How do charges versus credits accumulate by account_id and invoice_id?</li><li>What is the distribution of transactions by state (pending, completed, etc.) and type?</li></ul>|
| [recurly__churn_analysis](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__churn_analysis) | Analyzes subscription churn with activation dates, cancellation dates, expiration info, subscription states, churn reasons, and period details to identify retention risks and understand cancellation drivers. <br></br>**Example Analytics Questions:**<ul><li>What are the most common expiration_reason and churn_reason values by subscription?</li><li>How long do subscriptions last (activated_at to canceled_at) before churning by plan_name?</li><li>Which subscription states and churn_reason_type combinations have the highest cancellation rates?</li></ul>|
| [recurly__monthly_recurring_revenue](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__monthly_recurring_revenue) | Tracks monthly recurring revenue (MRR) by account and MRR type (new, expansion, contraction, churn) comparing current month MRR to previous month MRR to measure subscription business health and revenue trends. <br></br>**Example Analytics Questions:**<ul><li>What is the current_month_mrr by account and how does it compare to previous_month_mrr?</li><li>How does MRR break down by mrr_type (new, expansion, contraction, churn)?</li><li>Which accounts show the strongest MRR growth from previous to current month?</li></ul>|
| [recurly__subscription_overview](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__subscription_overview) | Provides detailed subscription profiles with activation dates, cancellation dates, expiration info, subscription states, billing periods, renewal settings, pricing, and trial details to monitor subscription lifecycle and financial contribution. <br></br>**Example Analytics Questions:**<ul><li>Which subscriptions have the longest subscription_period and highest subtotal values?</li><li>How do subscriptions with has_auto_renew = true compare to false in terms of lifetime?</li><li>What is the average trial_interval_days and how many convert after trial_ends_at?</li></ul>|
| [recurly__line_item_enhanced](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__line_item_enhanced) | This model constructs a comprehensive, denormalized analytical table that enables reporting on key revenue, subscription, customer, and product metrics from your billing platform. It's designed to align with the schema of the `*__line_item_enhanced` model found in Recurly, Recharge, Stripe, Shopify, and Zuora, offering standardized reporting across various billing platforms. To see the kinds of insights this model can generate, explore example visualizations in the [Fivetran Billing Model Streamlit App](https://fivetran-billing-model.streamlit.app/). Visit the app for more details. |

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.

---

## Visualizations
Many of the above reports are now configurable for [visualization via Streamlit](https://github.com/fivetran/streamlit_recurly). Check out some [sample reports here](https://fivetran-billing-model.streamlit.app/).

<p align="center">
<a href="https://fivetran-billing-model.streamlit.app/">
    <img src="https://raw.githubusercontent.com/fivetran/dbt_recurly/main/images/streamlit_example.png" alt="Streamlit Billing Model App" width="75%">
</a>
</p>

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Recurly connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_recurly/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

<!--section-end-->

### Install the package
Include the following recurly package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/recurly
    version: [">=1.3.0", "<1.4.0"]
```

> All required sources and staging models are now bundled into this transformation package. Do not include `fivetran/recurly_source` in your `packages.yml` since this package has been deprecated.

#### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Define database and schema variables

#### Option A: Single connection
By default, this package runs using your [destination](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile) and the `recurly` schema. If this is not where your Recurly data is (for example, if your Recurly schema is named `recurly_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  recurly:
    recurly_database: your_database_name
    recurly_schema: your_schema_name
```

#### Option B: Union multiple connections
If you have multiple Recurly connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. For each source table, the package will union all of the data together and pass the unioned table into the transformations. The `source_relation` column in each model indicates the origin of each record.

To use this functionality, you will need to set the `recurly_sources` variable in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
  recurly:
    recurly_sources:
      - database: connection_1_destination_name # Required
        schema: connection_1_schema_name # Required
        name: connection_1_source_name # Required only if following the step in the following subsection

      - database: connection_2_destination_name
        schema: connection_2_schema_name
        name: connection_2_source_name
```

##### Recommended: Incorporate unioned sources into DAG
> *If you are running the package through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore), the below step is necessary in order to synchronize model runs with your Recurly connections. Alternatively, you may choose to run the package through Fivetran [Quickstart](https://fivetran.com/docs/transformations/quickstart), which would create separate sets of models for each Recurly source rather than one set of unioned models.*

By default, this package defines one single-connection source, called `recurly`, which will be disabled if you are unioning multiple connections. This means that your DAG will not include your Recurly sources, though the package will run successfully.

To properly incorporate all of your Recurly connections into your project's DAG:
1. Define each of your sources in a `.yml` file in your project. Utilize the following template for the `source`-level configurations, and, **most importantly**, copy and paste the table and column-level definitions from the package's `src_recurly.yml` [file](https://github.com/fivetran/dbt_recurly/blob/main/models/staging/src_recurly.yml).

```yml
# a .yml file in your root project

version: 2

sources:
  - name: <name> # ex: Should match name in recurly_sources
    schema: <schema_name>
    database: <database_name>
    loader: fivetran
    config:
      loaded_at_field: _fivetran_synced
      freshness: # feel free to adjust to your liking
        warn_after: {count: 72, period: hour}
        error_after: {count: 168, period: hour}

    tables: # copy and paste from recurly/models/staging/src_recurly.yml - see https://support.atlassian.com/bitbucket-cloud/docs/yaml-anchors/ for how to use anchors to only do so once
```

> **Note**: If there are source tables you do not have (see [Disable models for non-existent sources](#disable-models-for-non-existent-sources)), you may still include them, as long as you have set the right variables to `False`.

2. Set the `has_defined_sources` variable (scoped to the `recurly` package) to `True`, like such:
```yml
# dbt_project.yml
vars:
  recurly:
    has_defined_sources: true
```

### Disable models for non-existent sources
Your Recurly connection may not sync every table that this package expects. This might be because you are excluding those tables. If you are not using those tables, you can disable the corresponding functionality in the package by specifying the variable in your dbt_project.yml. By default, all packages are assumed to be true. You only have to add variables for tables you want to disable, like so:

```yml
vars:
  recurly__using_credit_payment_history: false # Disable if you do not have the credit_payment_history table
  recurly__using_subscription_add_on_history: false # Disable if you do not have the subscription_add_on_history table
  recurly__using_subscription_change_history: false # Disable if you do not have the subscription_change_history table

```   
### (Optional) Additional configurations
<details open><summary>Expand to view configurations</summary>

#### Enabling Standardized Billing Model
This package contains the `recurly__line_item_enhanced` model which constructs a comprehensive, denormalized analytical table that enables reporting on key revenue, subscription, customer, and product metrics from your billing platform. It's designed to align with the schema of the `*__line_item_enhanced` model found in Recurly, Recharge, Stripe, Shopify, and Zuora, offering standardized reporting across various billing platforms. To see the kinds of insights this model can generate, explore example visualizations in the [Fivetran Billing Model Streamlit App](https://fivetran-billing-model.streamlit.app/). This model is enabled by default. To disable it, set the `recurly__standardized_billing_model_enabled` variable to `false` in your `dbt_project.yml`:

```yml
vars:
  recurly__standardized_billing_model_enabled: false # true by default.
```

#### Passing Through Additional Fields
This package includes all source columns defined in the macros folder. You can add more columns using our pass-through column variables. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables:

```yml
vars:
    recurly_account_pass_through_columns: 
      - name: "new_custom_field"
        alias: "custom_field"
        transform_sql: "cast(custom_field as string)"
      - name: "another_one"
    recurly_subscription_pass_through_columns:
      - name: "this_field"
        alias: "cool_field_name"
```
#### Change the build schema
By default, this package builds the Recurly staging models within a schema titled (<target_schema> + `_recurly_source`) and the Recurly transformation models within a schema titled (<target_schema> + `_recurly`) in your destination. If this is not where you would like your recurly staging data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    recurly:
      +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
      staging:
        +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_recurly/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    <default_source_table_name>_identifier: your_table_name 
```

</details>

### (Optional) Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand to view details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt/setup-guide#transformationsfordbtcoresetupguide).
</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```

<!--section="recurly_maintenance"-->
## How is this package maintained and can I contribute?

### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/recurly/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_recurly/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_recurly_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).