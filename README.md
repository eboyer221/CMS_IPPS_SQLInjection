[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/SVKhkr7L)
# Introduction

The Centers for Medicare and Medicaid Services (CMS) is a U.S. agency that administers the Medicare program and works in partnership with state governments to administer Medicaid. CMS makes health related data available to the public through its website [data.cms.gov](https://data.cms.gov). In this assignment you will use their IPPS dataset that contains hospital charge data. More specifically, the IPPS dataset contains information about 2021 charges of top 536 groups of similar clinical conditions (diagnosis) by different health providers in the U.S. and the correspondent amounts covered by health insurance.  What is interesting about the IPPS dataset is that it shows how the same treatment for a clinical condition can result in very different costs for patients depending on the health care provider. 

# Data Model 

The IPPS dataset has 151,989 rows and 15 columns.  The goal of this assignment is for you to normalize this dataset into a Postgres database called **ipps**. The **ipps** database has to be designed so that all of its tables are normalized up to 3NF (third normal form). All Data Definition Language (DDL) SQL statements (CREATE DATABASE and CREATE TABLE statements) and DCL (Data Control Language) statements (CREATE USER, GRANT statements) should be submitted in a file named **ipps.sql**. In summary, all ipps' tables of your database should be normalized up to 3NF, have primary keys, and appropriate foreign keys with referential integrity constraints in place. You should also create a user named **ipps** with full control of all tables in the **ipps** database.  

The attributes used in your **ipps** database MUST preserve the column names of the **ipps** dataset. The link [here](https://data.cms.gov/resources/medicare-inpatient-hospitals-by-provider-and-service-data-dictionary-0) has a detailed description of each of the columns and their meaning of the **ipps** dataset. 

# Data Load Script

In order to load the **ipps** dataset into your (normalized) **ipps** database you are asked to write a data load script in Python. This program should be named **ipps.py** and it is the second deliverable of this assignment. Data access secrets (user and password) should be protected in the code using a **config.ini** file. SQL statements should be written as **prepared statements** to follow good coding practices. Also, you MUST use the **psycopg2** module to connect to the database. 

Please note that you are not allowed to pre-process or modify the CSV file using an external program, like a spreadsheet application, for example.  To be clear: I will test your data load program using the **ipps** dataset. The CSV file should be the MUP_IHP_RY23_P03_V10_DY21_PRVSVC.csv.  

# Queries 
 
Your final task in this project is to answer the following queries using SQL. Write your answers to all queries updating the **ipps.sql** file.  

* List all diagnosis in alphabetical order.    
* List the names and correspondent states (including Washington D.C.) of all of the providers in alphabetical order (state first, provider name next, no repetition).    
* List the total number of providers.   
* List the total number of providers per state (including Washington D.C.) in alphabetical order (also printing out the state).    
* List the providers names in Denver (CO) or in Lakewood (CO) in alphabetical order  
* List the number of providers per RUCA code (showing the code and description) 
* Show the DRG description for code 308 
* List the top 10 providers (with their correspondent state) that charged (as described in Avg_Submtd_Cvrd_Chrg) the most for the DRG code 308. Output should display the provider name, their city, state, and the average charged amount in descending order.   
* List the average charges (as described in Avg_Submtd_Cvrd_Chrg) of all providers per state for the DRG code 308. Output should display the state and the average charged amount per state in descending order (of the charged amount) using only two decimals.    
* Which provider and clinical condition pair had the highest difference between the amount charged (as described in Avg_Submtd_Cvrd_Chrg) and the amount covered by Medicare only (as described in Avg_Mdcr_Pymt_Amt)?   

# Grading 

```
+25 Normalization
+10 Tables Creation
+5 Users Creation and Access 
+35 Data Load Script
+25 Queries
-5 didn't identify your name and of your teammate in the source files
-5 have secrets hard-coded in the python script
-5 didn't use prepared statement when writing insert statements
```