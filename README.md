🏦 Banking Customer Analysis | Dashboard
📌 Project Overview
This project analyzes a banking customer dataset to generate business insights using SQL (PostgreSQL) and Power BI.

The objective is to transform raw banking data into meaningful business intelligence by analyzing customer demographics, loan portfolios, and transaction behavior through SQL queries and interactive dashboards.

Note: This project uses a publicly available banking dataset from Kaggle for educational and portfolio purposes. The analysis, SQL queries, and Power BI dashboard were developed to simulate real-world banking business scenarios.

🎯 Business Problem
Banks generate large volumes of customer, loan, and transaction data every day. Without proper analysis, it becomes difficult to identify customer behavior, monitor loan performance, and make informed business decisions.

This project addresses the following business questions:

How many customers, accounts, loans, and transactions does the bank have?
What is the overall loan portfolio performance?
Which customers contribute the highest transaction value?
Which customer age groups spend the most?
How are transactions distributed over time?
What is the default loan count?
Which loan duration categories contribute the highest loan amount?
🛠 Tools & Technologies
PostgreSQL
pgAdmin 4
SQL
Power BI
Power Query
DAX
Microsoft Excel
📂 Project Structure
Banking-Customer-Analytics-SQL-PowerBI
│
├── SQL
│     Banking_Analysis.sql
│
├── Dashboard
│     Banking Dashboard.pbix
│
├── Dataset
│     client.csv
│     account.csv
│     disp.csv
│     loan.csv
│     trans.csv
│
├── Images
│     Executive_Overview.png
│     Customer_Analysis.png
│     Loan_Analysis.png
│     Trans_analysis.png
│
└── README.md
🗄 Database Design
The project consists of the following tables:

Client
Account
Disp (Customer-Account Relationship)
Loan
Transaction
Client_Staging
Relationships were created using Primary Keys and Foreign Keys to build a normalized banking database.

🧹 Data Preparation
Before analysis, the data was cleaned and transformed using SQL.

Data Cleaning
Checked missing values
Validated negative transaction amounts
Checked duplicate customer IDs
Data Transformation
Extracted customer Date of Birth from Birth Number
Derived Gender from Birth Number
Standardized customer demographic information
📊 Dashboard Pages
1️⃣ Executive Overview
Provides a high-level summary of the banking business.

KPIs
Total Customers
Total Accounts
Total Loans
Total Transactions
Average Loan Amount
Default Loans
Visuals
Monthly Transaction Trend
Loan Portfolio by Status
Customer Gender Distribution
2️⃣ Customer Analysis
Customer behavior and demographic analysis.

KPIs
Male Customers
Female Customers
Average Age
Average Spending
Visuals
Average Spending by Age Group
Customer Count by Age Group
Customer Distribution by Segment
Top 10 Customers by Spending
3️⃣ Loan Analysis
Loan portfolio performance.

KPIs
Total Loan Amount
Average Loan Amount
Default Loans
Visuals
Loan Amount by Status
Top 10 Borrowers
Loan Amount by Duration Group
4️⃣ Transaction Analysis
Transaction behavior analysis.

KPIs
Total Transaction Amount
Average Transaction Amount
Transaction Count
Active Accounts
Visuals
Monthly Transaction Trend
Annual Transaction Trend
Transaction Distribution by Type
Transaction Amount by Operation
💡 SQL Concepts Used
INNER JOIN
GROUP BY
ORDER BY
Aggregate Functions
CASE Statements
Common Table Expressions (CTEs)
Window Functions (RANK)
DATE Functions
Data Cleaning
Data Transformation
Foreign Keys
Primary Keys
📈 Business Insights
Identified the highest spending customers.
Segmented customers into High, Medium, and Low Value groups.
Analyzed customer spending by age group.
Evaluated loan portfolio distribution.
Measured default loan count.
Identified top loan borrowers.
Tracked monthly and yearly transaction trends.
Analyzed transaction behavior by operation and transaction type.
📷 Dashboard Preview
Executive Overview
Executive Overview

Customer Analysis
Customer Analysis

Loan Analysis
Loan Analysis

Transaction Analysis
Trans Analysis

ER Diagram
ER Diagram

🚀 Key Skills Demonstrated
SQL Query Writing
PostgreSQL Database Design
Data Cleaning
Data Transformation
Business Analysis
Data Modeling
Power BI Dashboard Development
DAX Measures
Data Visualization
Banking Domain Analytics
