[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/SVKhkr7L)
# Introduction

The Centers for Medicare and Medicaid Services (CMS) is a U.S. agency that administers the Medicare program and works in partnership with state governments to administer Medicaid. CMS makes health related data available to the public through its website [data.cms.gov](https://data.cms.gov). In this assignment you will use their IPPS dataset that contains hospital charge data. More specifically, the IPPS dataset contains information about 2021 charges of top 536 groups of similar clinical conditions (diagnosis) by different health providers in the U.S. and the correspondent amounts covered by health insurance.  What is interesting about the IPPS dataset is that it shows how the same treatment for a clinical condition can result in very different costs for patients depending on the health care provider. 

# Data Model 

The IPPS dataset has 151,989 rows and 15 columns.  The goal is to normalize this dataset into a Postgres database called **ipps**. The **ipps** database has to be designed so that all of its tables are normalized up to 3NF (third normal form). All Data Definition Language (DDL) SQL statements (CREATE DATABASE and CREATE TABLE statements) and DCL (Data Control Language) statements (CREATE USER, GRANT statements) will be contained in a file named **ipps.sql**. In summary, all ipps' tables of the database will be normalized up to 3NF, have primary keys, and appropriate foreign keys with referential integrity constraints in place. 

The attributes used in the **ipps** database preserve the column names of the **ipps** dataset. The link [here](https://data.cms.gov/resources/medicare-inpatient-hospitals-by-provider-and-service-data-dictionary-0) has a detailed description of each of the columns and their meaning of the **ipps** dataset. 

# Data Load Script

A data load script in Python is used to load the **ipps** dataset into the (normalized) **ipps** database. This program should is named **ipps.py**. SQL statements are written as **prepared statements**. The **psycopg2** module is used to connect to the database. 

# Queries 
 
The following queries are contained in the **ipps.sql** file.  

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
