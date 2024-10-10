--Objective
---Database schema creation for insurance data
---Populating database with sample insurance data
---Analyzing calims data for analysis
---Creating index for better performance
---Setting up roles and pemissions for database security 

--TASK
--- Define Tables: Customers, policies, claims and policy types
--- Include fields such as CustomerID, PolicyID, ClaimID, PolicyTypeID, ClaimAmount, ClaimDate, PoliyStartDate, PlolicyEndDate
--- Insert realistic data in each table, such as different policy types, claim amount, and customer profiles
--- Analyse the total number of claims per type, determine monthly claim frequency, and average claim amount
--- Optimise by creating an index on columns used frequently with where clause or as join keys to improve performance
--- Manage the roles and permission
--- ClaimAnalyst roles should only have the read only
--- ClaimManager should have full access to claims data and the ability to update policy information 

use ClaimInsurance;

CREATE TABLE customers(
	CustomerID INT IDENTITY(1,1) PRIMARY KEY,
	FirstName VARCHAR(50),
	LastName VARCHAR(50),
	DateOfBirth DATE,
	Gender CHAR(1),
	Address VARCHAR(100),
	City VARCHAR(50),
	State VARCHAR(50),
);

CREATE TABLE policy_type(
	PolicyTypeId INT IDENTITY(1,1) PRIMARY KEY,
	PolicyTypeName VARCHAR(50),
	Description TEXT
);
CREATE TABLE policies(
	PolicyID INT IDENTITY(1,1) PRIMARY KEY,
	CustomerID INT REFERENCES customers(CustomerID),
	PolicyTypeId INT REFERENCES policy_type(PolicyTypeId),
	PolicyStartDate DATE,
	PolicyEndDate DATE, 
	Permium DECIMAL(10,2)
);

CREATE TABLE claims(
	ClaimId INT IDENTITY(1,1) PRIMARY KEY,
	PolicyID INT REFERENCES policies(PolicyID),
	ClaimDate DATE,
	ClaimAmount DECIMAL(10,2),
	ClaimDescription TEXT,
	ClaimStatus VARCHAR(20)
);


INSERT INTO policy_type (PolicyTypeName, Description)
VALUES
('Auto Insurance', 'Covers vehicle-related damages and liabilities'),
('Health Insurance', 'Covers health-related expenses and medical services'),
('Life Insurance', 'Provides financial support to beneficiaries upon the policyholder’s death'),
('Home Insurance', 'Covers home and property-related risks, including damages or theft');

INSERT INTO customers (FirstName, LastName, DateOfBirth, Gender, Address, City, State)
VALUES
('John', 'Doe', '1985-06-15', 'M', '123 Maple Street', 'Saskatoon', 'SK'),
('Jane', 'Smith', '1990-04-22', 'F', '456 Oak Avenue', 'Regina', 'SK'),
('Michael', 'Johnson', '1978-09-30', 'M', '789 Pine Road', 'Prince Albert', 'SK'),
('Emily', 'Davis', '1992-12-12', 'F', '101 Birch Lane', 'Saskatoon', 'SK'),
('Robert', 'Brown', '1965-02-20', 'M', '202 Spruce Street', 'Moose Jaw', 'SK'),
('Laura', 'Wilson', '1988-11-05', 'F', '303 Cedar Boulevard', 'Swift Current', 'SK');

INSERT INTO policies (CustomerID, PolicyTypeId, PolicyStartDate, PolicyEndDate, Permium)
VALUES
(1, 1, '2023-01-01', '2024-01-01', 1200.50),  -- John Doe - Auto Insurance
(2, 2, '2023-03-15', '2024-03-15', 800.00),   -- Jane Smith - Health Insurance
(3, 3, '2022-07-20', '2023-07-20', 1500.75),  -- Michael Johnson - Life Insurance
(4, 4, '2023-05-10', '2024-05-10', 950.00),   -- Emily Davis - Home Insurance
(5, 1, '2022-11-01', '2023-11-01', 1100.25),  -- Robert Brown - Auto Insurance
(6, 2, '2023-09-01', '2024-09-01', 700.60);   -- Laura Wilson - Health Insurance

INSERT INTO claims (PolicyID, ClaimDate, ClaimAmount, ClaimDescription, ClaimStatus)
VALUES
(1, '2023-02-15', 2500.00, 'Collision repair due to an accident', 'Approved'),  -- Auto Insurance Claim
(2, '2023-04-10', 500.00, 'Doctor visit and medications', 'Approved'),          -- Health Insurance Claim
(3, '2023-09-05', 10000.00, 'Death benefit for the policyholder', 'Approved'),  -- Life Insurance Claim
(4, '2023-06-20', 4000.00, 'Repair for water damage to the house', 'Pending'),  -- Home Insurance Claim
(5, '2023-12-01', 1500.00, 'Windshield replacement due to road debris', 'Rejected'), -- Auto Insurance Claim
(6, '2024-01-20', 300.00, 'Prescription medications', 'Approved');             -- Health Insurance Claim

--TOTAL NUMBER OF CLAIMS PER POLICY TYPE
SELECT 
    pt.PolicyTypeName, 
    COUNT(c.ClaimId) AS TotalClaim
FROM 
    policies p
INNER JOIN 
    claims c ON p.PolicyID = c.PolicyID
INNER JOIN 
    policy_type pt ON p.PolicyTypeId = pt.PolicyTypeId
GROUP BY 
    pt.PolicyTypeName
ORDER BY 
    TotalClaim DESC;

--TOTAL MONTHLY CLAIMS AND AVERAGE CLAIM AMOUNT
SELECT 
	FORMAT( ClaimDate, 'MMMM') AS ClaimMonth, 
	COUNT(*) AS ClaimFrequency,
	AVG(ClaimAmount) as AverageClaimAmount
FROM claims
GROUP BY FORMAT(ClaimDate, 'MMMM')
ORDER BY ClaimMonth;


--INDEXING COLUMN FREQUENTLY USED IN WHERE CLAUSES OR AS JOIN KEYS TO ENHANCE PERFORMANCE
CREATE INDEX idx_claims_date ON Claims(ClaimDate);

-- Manage the roles and permission
--- ClaimAnalyst roles should only have the read only
--- ClaimManager should have full access to claims data and the ability to update policy information 

CREATE ROLE ClaimAnalyst;
CREATE ROLE Claimmanager;

--GRANT SELECT ON Claims, Policies, PolicyTypes TO ClaimAnalyst;
GRANT SELECT ON Claims TO ClaimAnalyst;
GRANT SELECT ON Policies TO ClaimAnalyst;
GRANT SELECT ON policy_type TO ClaimAnalyst;


GRANT SELECT, INSERT, UPDATE, DELETE ON Claims to Claimmanager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Policies to Claimmanager;
GRANT SELECT, INSERT, UPDATE, DELETE ON policy_type to Claimmanager;

