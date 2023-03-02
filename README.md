<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_recurly/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Recurly Transformation dbt package ([Docs](https://fivetran.github.io/dbt_recurly/))

# 📣 What does this dbt package do?
- Produces modeled tables that leverage Recurly data from [Fivetran's connector](https://fivetran.com/docs/applications/recurly) in the format described by [this ERD](https://fivetran.com/docs/applications/recurly#schemainformation) and build off the output of our [Recurly source package](https://github.com/fivetran/dbt_recurly_source).


- Enables you to better understand your Recurly data. The package achieves this by performing the following: 
    - Enhance the balance transaction entries with useful fields from related tables. 
    - Create customized analysis tables to examine churn by subscriptions and monthly recurring revenue by account. 
    - Generate a metrics tables allow you to better understand your account activity over time or at a customer level. These time-based metrics are available on a daily level.
- Generates a comprehensive data dictionary of your source and modeled Recurly data through the [dbt docs site](https://fivetran.github.io/dbt_recurly/).

The following table provides a detailed list of all models materialized within this package by default. 
> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_recurly/#!/overview?g_v=1).
 
| **model**                         | **description**                                                                                                                                                                                                                             |
|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [recurly__account_daily_overview](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__account_daily_overview)    |  Each record is a day in an account and its accumulated balance totals based on all line item transactions up to that day.                            |
| [recurly__account_overview](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__account_overview)    |  Each record represents an account, enriched with metrics about their associated transactions.                                                                                                     |
| [recurly__balance_transactions](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__balance_transactions)      | Each record represents a specific line item charge, credit, or other balance change that accumulates into the final invoices.                                                                                                  |
| [recurly__churn_analysis](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__churn_analysis)    | Each record represents a subscription and their churn status and details.                                                                                                                           |
| [recurly__monthly_recurring_revenue](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__monthly_recurring_revenue) | Each record represents an account and MRR generated on a monthly basis. |
| [recurly__subscription_overview](https://fivetran.github.io/dbt_recurly/#!/model/model.recurly.recurly__subscription_overview)       | Each record represents a subscription, enriched with metrics about time, revenue, state, and period.                                                                                         |

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran Recurly connector syncing data into your destination. 
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, **Databricks** destination.

### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

## Step 2: Install the package
Include the following recurly_source package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/recurly
    version: [">=0.3.0", "<0.4.0"]
```
## Step 3: Define database and schema variables
By default, this package runs using your destination and the `recurly` schema. If this is not where your recurly data is (for example, if your recurly schema is named `recurly_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    recurly_database: your_destination_name
    recurly_schema: your_schema_name 
```

## Step 4: Disable models for non-existent sources
Your Recurly connector may not be syncing all tabes that this package references. This might be because you are excluding those tables. If you are not using those tables, you can disable the corresponding functionality in the package by specifying the variable in your dbt_project.yml. By default, all packages are assumed to be true. You only have to add variables for tables you want to disable, like so:

```yml
vars:
  recurly__using_credit_payment_history: false # Disable if you do not have the credit_payment_history table
  recurly__using_subscription_add_on_history: false # Disable if you do not have the subscription_add_on_history table
  recurly__using_subscription_change_history: false # Disable if you do not have the subscription_change_history table

```   
## (Optional) Step 5: Additional configurations
<details><summary>Expand to view configurations</summary>

### Passing Through Additional Fields
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
### Change the build schema
By default, this package builds the recurly staging models within a schema titled (`<target_schema>` + `_recurly`) in your destination. If this is not where you would like your recurly staging data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    recurly:
      +schema: my_new_schema_name # leave blank for just the target_schema
```

### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_recurly_source/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    <default_source_table_name>_identifier: your_table_name 
```

  
</details>

## (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand to view details</summary>
<br>
    
Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>
    
# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
```yml
packages:
    - package: fivetran/recurly_source
      version: [">=0.2.0", "<0.3.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
          
# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/recurly/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_recurly/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_recurly_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to just say hi? Book a time during our office hours [on Calendly](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com.
