-- CS3810: Principles of Database Systems
-- Instructor: Thyago Mota
-- Students: Emily Boyer &  Michael Runnels
-- Description: IPPS database

DROP DATABASE IF EXISTs ipps;

CREATE DATABASE ipps;
\c ipps;

-- create tables
CREATE TABLE States (
    FIPS INT PRIMARY KEY,
    Rndrng_Prvdr_State_Abrvtn CHAR(2)
);

CREATE TABLE Providers (
    Rndrng_Prvdr_CCN INT NOT NULL,
    Rndrng_Prvdr_Org_Name VARCHAR(100),
    Rndrng_Prvdr_St VARCHAR(100),
    Rndrng_Prvdr_Zip5 INT,
    Rndrng_Prvdr_State_FIPS INT,
    FOREIGN KEY(Rndrng_Prvdr_State_FIPS) REFERENCES States(FIPS)
);

CREATE TABLE RUCAs (
    Rndrng_Prvdr_RUCA FLOAT PRIMARY KEY,
    Rndrng_Prvdr_RUCA_Desc VARCHAR(100)

);

CREATE TABLE Cities (
    Zip5 INT PRIMARY KEY,
    City VARCHAR(100),
    RUCA FLOAT,
    FOREIGN KEY(RUCA) REFERENCES RUCAs(Rndrng_Prvdr_RUCA)
);

CREATE TABLE DRGs (
    DRG INT PRIMARY KEY,
    DRG_Desc VARCHAR(100)
);

CREATE TABLE Discharges_and_Charges (
    Rndrng_CCN INT,
    DRG_Cd INT,
    Tot_Dschrgs INT,
    Avg_Submtd_Cvrd_Chrg FLOAT,
    Avg_Tot_Pymt_Amt FLOAT,
    Avg_Mdcr_Pymt_Amt FLOAT,
    PRIMARY KEY(Rndrng_CCN, DRG_Cd)
);

-- create user with appropriate access to the tables
CREATE USER ipps_admin WITH PASSWORD '135791';
-- Grant privileges on the ipps table to the ipps_admin user
-- COMMIT;
GRANT ALL PRIVILEGES ON TABLE States TO ipps_admin;
GRANT ALL PRIVILEGES ON TABLE Providers TO ipps_admin;
GRANT ALL PRIVILEGES ON TABLE RUCAs TO ipps_admin;
GRANT ALL PRIVILEGES ON TABLE Cities TO ipps_admin;
GRANT ALL PRIVILEGES ON TABLE DRGs TO ipps_admin;
GRANT ALL PRIVILEGES ON TABLE Discharges_and_Charges TO ipps_admin;

-- queries

-- a) List all diagnosis in alphabetical order.
SELECT DISTINCT DRG_Desc
FROM DRGs
ORDER BY DRG_Desc;

-- b) List the names and correspondent states (including Washington D.C.) of all of the providers in alphabetical order (state first, provider name next, no repetition).
SELECT DISTINCT S.Rndrng_Prvdr_State_Abrvtn AS state,
                P.Rndrng_Prvdr_Org_Name AS provider_name
FROM Providers P
LEFT JOIN States S
ON P.Rndrng_Prvdr_State_FIPS = S.FIPS
ORDER BY state, provider_name;

-- c) List the total number of providers.
SELECT COUNT(DISTINCT P.Rndrng_Prvdr_CCN) AS total_number_of_providers
FROM Providers P;

-- d) List the total number of providers per state (including Washington D.C.) in alphabetical order (also printing out the state).  
SELECT S.Rndrng_Prvdr_State_Abrvtn as state,
       COUNT(DISTINCT P.Rndrng_Prvdr_CCN) AS total_number_of_providers
FROM States S
LEFT JOIN Providers P
ON P.Rndrng_Prvdr_State_FIPS = S.FIPS
GROUP BY state
ORDER BY state;

-- e) List the providers names in Denver (CO) or in Lakewood (CO) in alphabetical order  
SELECT DISTINCT P.Rndrng_Prvdr_Org_Name AS provider_name
FROM Providers P
LEFT JOIN Cities C
ON P.Rndrng_Prvdr_Zip5 = C.Zip5
WHERE C.City = 'Lakewood' OR C.City = 'Denver'
ORDER BY provider_name;

-- f) List the number of providers per RUCA code (showing the code and description)
SELECT C.RUCA AS RUCA_Code,
       R.Rndrng_Prvdr_RUCA_Desc AS RUCA_Description,
       COUNT(DISTINCT P.Rndrng_Prvdr_CCN) AS total_number_of_providers
FROM Providers P
LEFT JOIN Cities C ON P.Rndrng_Prvdr_Zip5 = C.Zip5
LEFT JOIN RUCAs R ON C.RUCA = R.Rndrng_Prvdr_RUCA
GROUP BY C.RUCA, R.Rndrng_Prvdr_RUCA_Desc
ORDER BY RUCA_Code;

-- g) Show the DRG description for code 308
SELECT D.DRG_Desc as DRG_description
FROM DRGs D
WHERE D.DRG = 308;

-- h) List the top 10 providers (with their correspondent state) that charged (as described in Avg_Submtd_Cvrd_Chrg) the most for the DRG code 308. Output should display the provider name, their city, state, and the average charged amount in descending order.  
SELECT P.Rndrng_Prvdr_Org_Name AS provider_name,
       C.City AS city,
       S.Rndrng_Prvdr_State_Abrvtn AS state,
       AVG(DC.Avg_Submtd_Cvrd_Chrg) AS avg_charged_amount
FROM Providers P
JOIN Discharges_and_Charges DC ON P.Rndrng_Prvdr_CCN = DC.Rndrng_CCN
JOIN States S ON P.Rndrng_Prvdr_State_FIPS = S.FIPS
JOIN Cities C ON P.Rndrng_Prvdr_Zip5 = C.Zip5
WHERE DC.DRG_Cd = 308
GROUP BY P.Rndrng_Prvdr_Org_Name, C.City, S.Rndrng_Prvdr_State_Abrvtn
ORDER BY avg_charged_amount DESC
LIMIT 10;


-- i) List the average charges (as described in Avg_Submtd_Cvrd_Chrg) of all providers per state for the DRG code 308. Output should display the state and the average charged amount per state in descending order (of the charged amount) using only two decimals.
SELECT S.Rndrng_Prvdr_State_Abrvtn AS state,
       ROUND(AVG(DC.Avg_Submtd_Cvrd_Chrg), 2) AS avg_charged_amount
FROM Providers P
JOIN Discharges_and_Charges DC ON P.Rndrng_Prvdr_CCN = DC.Rndrng_CCN
JOIN States S ON P.Rndrng_Prvdr_State_FIPS = S.FIPS
WHERE DC.DRG_Cd = 308
GROUP BY S.Rndrng_Prvdr_State_Abrvtn
ORDER BY avg_charged_amount DESC;

-- j) Which provider and clinical condition pair had the highest difference between the amount charged (as described in Avg_Submtd_Cvrd_Chrg) and the amount covered by Medicare only (as described in Avg_Mdcr_Pymt_Amt)?

SELECT P.Rndrng_Prvdr_Org_Name AS provider_name,
       D.DRG_Desc AS clinical_condition,
       (MAX(DC.Avg_Submtd_Cvrd_Chrg) - MAX(DC.Avg_Mdcr_Pymt_Amt)) AS charge_difference
FROM Providers P
JOIN Discharges_and_Charges DC ON P.Rndrng_Prvdr_CCN = DC.Rndrng_CCN
JOIN DRGs D ON DC.DRG_Cd = D.DRG
GROUP BY P.Rndrng_Prvdr_Org_Name, D.DRG_Desc
ORDER BY charge_difference DESC
LIMIT 1;