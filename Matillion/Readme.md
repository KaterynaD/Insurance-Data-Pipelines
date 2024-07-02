Implementing ELT with Fivetran and Matillion will eventually replace Pentaho Data Integration ETL, improve performance and simplify data load managment.

# Data Flow:
Fivetran extracts data from AWS Aurora and loads to Redshift. Matillion is used mostly as an orchestration tool and to load staging and dimension tables with simple or no transformations at all. Redshift Stored Procedures are used to populate SCD2 and fact tables.

# ELT Steps
Each step executes if there is a corresponding flag set in the variables. 
Emails are sent thru out the flow to alert about major phases are complete.
Webhook is set up to send failure notifications.

- Truncate Staging tables (first load or development)
- Truncate Dimension tables (first load or development)
- Truncate Fact tables (first load or development)
- Load Default in Dimension tables (first load or development)
- Load Staging tables (some data preprocessing to simplify further load)
- Load Dimensions
- Load Policy Facts


![image](https://github.com/KaterynaD/Insurance-Data-Pipelines/assets/16999229/f4e829e0-01b1-4b43-b46a-f7ff9f52ed20)

![image](https://github.com/KaterynaD/Insurance-Data-Pipelines/assets/16999229/f5d0c8a6-aeef-4549-b3d9-cf2ac15cbb38)


![image](https://github.com/KaterynaD/Insurance-Data-Pipelines/assets/16999229/ee65154a-f243-4d21-bebf-8c22cd4cd810)

![image](https://github.com/KaterynaD/Insurance-Data-Pipelines/assets/16999229/a9f30ce4-1691-4aad-b102-f8867ea4ca62)

![image](https://github.com/KaterynaD/Insurance-Data-Pipelines/assets/16999229/1ec24a82-f97a-499d-aa5b-0abfa9fe26e0)

