# Recurly dbt package ([Docs](https://fivetran.github.io/dbt_recurly/))

# 📣 What does this dbt package do?
- Materializes [Recurly staging tables]((https://fivetran.github.io/dbt_recurly/#!/overview/github_source/models/?g_v=1)) which leverages data in the format described by [this ERD](https://fivetran.com/docs/applications/recurly#schemainformation).

These staging tables clean, test, and prepare your Recurly data from [Fivetran's connector]()

This package models Recurly data from [Fivetran's connector](https://fivetran.com/docs/applications/recurly) for analysis by doing the following:

  - Name columns for consistency across all packages and easier analysis
  - Adds freshness tests to source data
  - Adds column-level testing where applicable. For example,  all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your Recurly data through the [dbt docs site](https://fivetran.github.io/dbt_recurly/).
- These tables are designed to work simultaneously with our [Recurly transformation package](https://github.com/fivetran/dbt_recurly)

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran Recurly connector syncing data into your destination. 
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, **Databricks** destination.


## Step 2: Install the package
Include the following recurly_source package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/recurly_source
    version: [">=0.1.0", "<0.2.0"]

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
# dbt_project.yml

...
config-version: 2

vars:
  credit_payment_history: false # Disable if you do not have the credit_payment_history table
  subscription_add_on_history: false # Disable if you do not have the subscription_add_on_history table
  subscription_change_history: false # Disable if you do not have the subscription_change_history table

```   
## (Optional) Step 5: Additional configurations
<details><summary>Expand to view configurations</summary>

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
    - package: fivetran/fivetran_utils
      version: [">=0.3.0", "<0.4.0"]

    - package: dbt-labs/dbt_utils
      version: [">=0.8.0", "<0.9.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
          
# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/recurly/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_recurly/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Opinionated Decisions
In creating this package, which is meant for a wide range of use cases, we had to take opinionated stances on a few different questions we came across during development. We've consolidated significant choices we made in the [DECISIONLOG.md](https://github.com/fivetran/dbt_recurly/blob/main/DECISIONLOG.md), and will continue to update as the package evolves. We are always open to and encourage feedback on these choices, and the package in general.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_recurly_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to just say hi? Book a time during our office hours [on Calendly](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com.