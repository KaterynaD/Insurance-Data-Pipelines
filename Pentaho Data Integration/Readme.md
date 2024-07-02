# Pentaho Data Integration V 9.4, SQL, Stored Procedures in 
- AWS Aurora (Source)
- MS SQL Server (Staging and Transformations)
- AWS Redshift (Load To and some additional transformations)

The original data warehouse structure and ETL processes were created by 4Sight (a third-party vendor). It appears that it was initially designed for a tiny insurance company and later adapted to be more generalized for any insurance company. The basic solution was substantially enhanced and tailored to meet the specific requirements of CSE.

I did not receive any support or assistance from the vendor.

# At the start of my work for CSE...

- Incremental daily load took an astonishing 17 hours to complete.
- The original ETL was designed around a different insurance source system. Despite attempts to adjust staging queries, some crucial information was lost in the data warehouse.
- There were no conditions implemented to verify if the data in the source system were ready for processing. Consequently, in case of any issues during the daily cycle, the only approach was to intervene in the middle of the night to halt a scheduled process or restore from backups and restart the following day.
- The database structure and ETL processes were intended to be agnostic to any specific database platform. And, instead of utilizing SQL, T-SQL or PL/SQL stored procedures, JavaScript and Pentaho Spoon "lookups" were employed. This approach resulted in slow performance and excessive memory consumption. Notably, the AWS EC2 instance used for our ETL tasks was the largest in the company. 
- Numerous dimensions, metrics, columns, lookups, and JavaScript functions within the ETL were redundant and remained unused.
- Essential attributes of the CSE business model were absent. Consequently, only basic financial metrics could be provided.
- The existing implementation of SCD type 2 did not make sense. The information within these dimensions was static in CSE.

# Enhancements and Adjustments
- A source system log check in a Pentaho Job to prevent false starts, along with a specialized schedule to verify source system readiness.
- Comprehensive cleanup of the existing ETL process, removing unnecessary lookups, calculations, and other artifacts.
- Parallel operations were added as well as implemented structural and database optimizations such as adding indexes and temporary tables.
- ETL process now completes in 2 hours, where 1 hour is dedicated to loading data into Redshift.
- Unneeded SCD type 2 was removed and instead additional SCD2 dimensions were added in the structure. It allowed to build large number of data feeds  and Tableau dashboards related to the quality of risk portfolio.
- New metrics were added derived from complex calculations performed across Aurora, Microsoft SQL Server, and Redshift.
- 2 more, similar, but smaller, DW and ETLs for other companies' data sets based on text files.

**_Recognizing the limits of further improvement within Pentaho Data Integration, I developed a new ELT process using Redshift/Matillion. Data movement from Aurora to Redshift is facilitated by Fivetran._**

# ETL Steps

- Set Variables
- Test Database Connections
- Set Load Date
- Evaluate Start/No Start Automatic Load
- Set Incremental Load date range 
- Load Staging from AWS Aurora
- Load Dimensions in MS SQL
- Load Policy Facts in MS SQL
- Load Claim Facts in MS SQL
- Export Data to Redshift
- Update Log tables for automatic incremental load
- Start Tableau dashboards refresh

![image](https://github.com/KaterynaD/Insurance-Data-Pipelines/assets/16999229/737c4696-0334-4e8c-8d00-5d48f14f7908)
