-- Create Client Table
CREATE TABLE client(
	client_id INT PRIMARY KEY,
	birth_date DATE,
	gender VARCHAR(10)
);

-- Create Bank Account Table
CREATE TABLE account(
	account_id INT PRIMARY KEY,
	district_id INT,
	frequency VARCHAR(50),
	date DATE
);

-- Create Customer-Account Relationship Table
CREATE TABLE disp(
	disp_id INT PRIMARY KEY,
	client_id INT,
	account_id INT,
	type VARCHAR(20)
);

-- Create Loan Information Table
CREATE TABLE loan(
	loan_id INT PRIMARY KEY,
	account_id INT,
	date DATE,
	amount NUMERIC,
	duration INT,
	payments NUMERIC,
	status VARCHAR(10)
);

-- Create Transaction History Table
CREATE TABLE trans(
	trans_id INT PRIMARY KEY,
	account_id INT,
	date DATE,
	type VARCHAR(10),
	operation VARCHAR(50),
	amount NUMERIC,
	balance NUMERIC
);

-- Create Staging Table for Raw Customer Data
CREATE TABLE client_staging (
    client_id INT,
    birth_number VARCHAR(20),
    district_id INT
);

--===============================
-- Database Relationships
--===============================
--Add Relationships
ALTER TABLE disp
ADD CONSTRAINT fk_client
FOREIGN KEY (client_id) REFERENCES client(client_id);

ALTER TABLE disp
ADD CONSTRAINT fk_account
FOREIGN KEY (account_id) REFERENCES account(account_id);

ALTER TABLE loan
ADD CONSTRAINT fk_loan_account
FOREIGN KEY (account_id) REFERENCES account(account_id);

ALTER TABLE trans
ADD CONSTRAINT fk_trans_account
FOREIGN KEY(account_id)REFERENCES account(account_id);

--=================================================
-- Customer Data Transformation
--=================================================
INSERT INTO client (client_id, birth_date, gender)
SELECT 
	client_id,
	--Extract DOB 
	TO_DATE(
		CASE 
			WHEN SUBSTRING(birth_number,3,2)::INT>50
			THEN SUBSTRING(birth_number, 1,2)||
				LPAD((SUBSTRING(birth_number, 3, 2)::INT - 50)::TEXT, 2, '0') ||
				SUBSTRING(birth_number, 5, 2)
			ELSE birth_number
		END,
		'YYMMDD'
	)AS birth_date,

--Extract Gender
	CASE
		WHEN SUBSTRING (birth_number,3,2):: INT>50 THEN 'Female'
		ELSE 'Male'
	END AS gender
FROM client_staging;

SELECT * FROM client;

-- Standardize customer demographic information
-- to ensure accurate age calculations and customer analysis.
UPDATE client c
SET birth_date = MAKE_DATE(
    1900 + SUBSTRING(cs.birth_number, 1, 2)::INT,
    CASE
        WHEN SUBSTRING(cs.birth_number, 3, 2)::INT > 50
            THEN SUBSTRING(cs.birth_number, 3, 2)::INT - 50
        ELSE SUBSTRING(cs.birth_number, 3, 2)::INT
    END,
    SUBSTRING(cs.birth_number, 5, 2)::INT
)
FROM client_staging cs
WHERE c.client_id = cs.client_id;

SELECT
MIN(birth_date) AS oldest_birth_date,
MAX(birth_date) AS newest_birth_date
FROM client;

--Validate the transformed customer records
SELECT client_id, birth_date
FROM client
LIMIT 10;

--===============================
--Data Cleaning
--===============================

-- Check for Missing Loan Amounts
SELECT * FROM loan WHERE amount IS NULL;

-- Identify Invalid Negative Transaction Amounts
SELECT * FROM trans WHERE amount<0;

-- Check for Duplicate Customers
SELECT client_id, COUNT(*) FROM client
GROUP BY client_id
HAVING COUNT(*) > 1;

--=======================
--Executive Overview
--=======================

-- Calculate Total Number of Customers
SELECT COUNT(*) AS total_customers FROM client;

-- Calculate Total Number of Bank Accounts
SELECT COUNT(*) AS total_accounts
FROM account;

-- Calculate Total Number of Loans Issued
SELECT COUNT(*) AS total_loans FROM loan;

-- Calculate Total Number of Transactions
SELECT COUNT(*) AS total_transactions FROM trans;

--Calculate Average Loans
SELECT ROUND(AVG(amount),2) AS average_loan_amount FROM loan;

-- Calculate Total Number of Defaulted Loans
SELECT COUNT(*) AS default_loans FROM loan WHERE status = 'D';

-- Analyze Monthly Transaction Amount Trend
SELECT DATE_TRUNC('month', date) AS month, SUM(amount) AS total_amount
FROM trans
GROUP BY month
ORDER BY month;

-- Analyze Loan Portfolio Distribution by Loan Status
SELECT status,
COUNT(*) AS loan_count
FROM loan
GROUP BY status
ORDER BY loan_count DESC;

-- Analyze Customer Distribution by Gender
SELECT gender,
COUNT(*) AS total_customers
FROM client
GROUP BY gender;

--===========================
--Customer Analysis
--===========================

-- Calculate Total Male Customers
SELECT COUNT(*) AS male_customers
FROM client
WHERE gender = 'Male';

-- Calculate Total Female Customers
SELECT COUNT(*) AS female_customers
FROM client
WHERE gender = 'Female';

-- Calculate Average Customer Age
SELECT
    ROUND(
        AVG(DATE_PART('year', AGE(CURRENT_DATE, birth_date)))::numeric,
        1
    ) AS average_age
FROM client;

-- Calculate Average Spending
SELECT
    ROUND(AVG(total_spending),2) AS average_spending
FROM (
    SELECT
        d.client_id,
        SUM(t.amount) AS total_spending
    FROM trans t
    JOIN disp d
        ON t.account_id = d.account_id
    WHERE d.type = 'OWNER'
    GROUP BY d.client_id
) customer_spending;

-- Analyze Average Customer Spending by Age Group
WITH customer_spending AS (
    SELECT
        d.client_id,
        SUM(t.amount) AS total_spending
    FROM trans t
    JOIN disp d
        ON t.account_id = d.account_id
    WHERE d.type = 'OWNER'
    GROUP BY d.client_id
)
SELECT
    CASE
        WHEN DATE_PART('year', AGE(CURRENT_DATE, c.birth_date)) BETWEEN 18 AND 30 THEN '18-30'
        WHEN DATE_PART('year', AGE(CURRENT_DATE, c.birth_date)) BETWEEN 31 AND 45 THEN '31-45'
        WHEN DATE_PART('year', AGE(CURRENT_DATE, c.birth_date)) BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group,

    ROUND(AVG(cs.total_spending),2) AS average_spending

FROM client c
JOIN customer_spending cs
ON c.client_id = cs.client_id

GROUP BY age_group
ORDER BY age_group;

-- Customer Count by Age Group
SELECT
    CASE
        WHEN DATE_PART('year', AGE(CURRENT_DATE, birth_date)) BETWEEN 18 AND 30 THEN '18-30'
        WHEN DATE_PART('year', AGE(CURRENT_DATE, birth_date)) BETWEEN 31 AND 45 THEN '31-45'
        WHEN DATE_PART('year', AGE(CURRENT_DATE, birth_date)) BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group,

    COUNT(*) AS customer_count

FROM client

GROUP BY age_group
ORDER BY age_group;

-- Customer Distribution by Segment
SELECT
    segment,
    COUNT(*) AS total_customers
FROM (
    SELECT
        d.client_id,
        CASE
            WHEN SUM(t.amount) > 500000 THEN 'High Value'
            WHEN SUM(t.amount) > 100000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS segment
    FROM trans t
    JOIN disp d
        ON t.account_id = d.account_id
    WHERE d.type = 'OWNER'
    GROUP BY d.client_id
) customer_segment

GROUP BY segment
ORDER BY total_customers DESC;

-- Identify Top 10 Customers by Total Spending
SELECT
    d.client_id,
    SUM(t.amount) AS total_spending
FROM trans t
JOIN disp d
    ON t.account_id = d.account_id
WHERE d.type = 'OWNER'
GROUP BY d.client_id
ORDER BY total_spending DESC
LIMIT 10;

-- Rank Customers Based on Total Spending
SELECT client_id, total_spending,
    RANK() OVER (ORDER BY total_spending DESC) AS spending_rank
FROM (
    SELECT
        d.client_id,
        SUM(t.amount) AS total_spending
    FROM trans t
    JOIN disp d
        ON t.account_id = d.account_id
    WHERE d.type = 'OWNER'
    GROUP BY d.client_id
) customer_summary
ORDER BY spending_rank;


--===========================
--Loan Analysis
--===========================

-- Calculate Total Loan Amount
SELECT SUM(amount) AS total_loan_amount
FROM loan;

--Calculate Average Loan
SELECT ROUND(AVG(amount),2) AS average_loan_amount
FROM loan;

-- Calculate Total Number of Defaulted Loans
SELECT COUNT(*) AS default_loans
FROM loan
WHERE status ='D';

--Total Loan Amount by Status
SELECT status AS loan_status,
    SUM(amount) AS total_loan_amount
FROM loan
GROUP BY status
ORDER BY total_loan_amount DESC;

-- Identify Top 10 Borrowers by Total Loan Amount
SELECT d.client_id AS customer_id,
    SUM(l.amount) AS total_loan_amount
FROM loan l
JOIN disp d
    ON l.account_id = d.account_id
WHERE d.type = 'OWNER'
GROUP BY d.client_id
ORDER BY total_loan_amount DESC
LIMIT 10;

-- Analyze Loan Amount by Loan Duration Group
SELECT
    CASE
        WHEN duration <= 12 THEN '0-12 Months'
        WHEN duration <= 24 THEN '13-24 Months'
        WHEN duration <= 48 THEN '25-48 Months'
        ELSE '48+ Months'
    END AS duration_Group,
    SUM(amount) AS total_loan_amount
FROM loan
GROUP BY duration_group
ORDER BY
    MIN(duration);

--====================================
--Transaction Analysis
--====================================

--Total Transaction Amount
SELECT SUM(amount) AS total_transaction_amount
FROM trans;

--Calculate Average Transaction
SELECT ROUND(AVG(amount),2) AS average_transaction_amount
FROM trans;

--Calculate Transaction Count
SELECT COUNT(*) AS transaction_count
FROM trans;

-- Calculate Number of Active Customer Accounts
SELECT
COUNT(DISTINCT account_id) AS active_accounts
FROM trans;

-- Analyze Monthly Transaction Amount Trend
SELECT DATE_TRUNC('month', date) AS month,
    SUM(amount) AS total_amount
FROM trans
GROUP BY DATE_TRUNC('month', date)
ORDER BY month;

-- Analyze Transaction Distribution by Transaction Type
SELECT type,
    COUNT(*) AS transaction_count
FROM trans
GROUP BY type
ORDER BY transaction_count DESC;

-- Analyze Transaction Amount by Operation
SELECT operation,
SUM(amount) AS total_transaction_amount
FROM trans
GROUP BY operation
ORDER BY total_transaction_amount DESC;

-- Analyze Annual Transaction Amount Trend
SELECT DATE_TRUNC('year', date) AS year,
    SUM(amount) AS total_transaction_amount
FROM trans
GROUP BY DATE_TRUNC('year', date)
ORDER BY year;

--======================================
--Business Insights using Advanced SQL
--======================================

-- Identify active borrowing customers with their loan and transaction activity.
SELECT
    d.client_id,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    COUNT(DISTINCT t.trans_id) AS total_transactions
FROM disp d
JOIN loan l
    ON d.account_id = l.account_id
JOIN trans t
    ON d.account_id = t.account_id
WHERE d.type = 'OWNER'
GROUP BY d.client_id
ORDER BY total_transactions DESC;