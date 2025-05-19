# DataAnalytics-Assessment
Cowrywise Assessment – SQL Solution Guide

This document outlines the approach and SQL queries used to solve key business intelligence tasks related to customer savings behavior, inactivity detection, and customer lifetime value (CLV) estimation. These insights are valuable for operations, finance, and marketing teams.

---

#  1. High-Value Customers with Multiple Products

# Purpose

The goal of this query is to:

- Identify customers who have at least one regular savings plan and at least one fixed investment plan
- Calculate the total amount they’ve deposited across all accounts
- Generate a leaderboard-style output, sorted by the total confirmed deposits

This insight is valuable for customer segmentation, personalized outreach, and marketing prioritization.
---

# Data Tables

- `users_customuser`: Contains user profile information
- `plans_plan`: Links each user to their savings or investment plans
- `savings_savingsaccount`: Stores confirmed deposit transactions per customer

---

#  Query Breakdown

# SELECT Clause

- `owner_id`: Unique ID of the customer from `users_customuser`
- `name`: Full name (concatenation of first and last name)
- `savings_count`: Count of distinct regular savings plans (`is_regular_savings = 1`)
- `investment_count`: Count of distinct fixed investment plans (`is_fixed_investment = 1`)
- `total_deposits`: Sum of all `confirmed_amount` values across all their savings accounts

# JOINs

- Join `plans_plan` with `users_customuser` using `owner_id`
- Join `savings_savingsaccount` to pull in confirmed deposit data

# Filters

- Only consider rows where `confirmed_amount > 0` (valid deposit)

# HAVING Clause

- Ensures the customer has **both** savings and investment plans (at least one of each)

# ORDER

- Sort the results by `total_deposits` in descending order (highest contributors on top)

---

# Sample Output

| owner_id | name         | savings_count | investment_count | total_deposits |
|----------|--------------|----------------|-------------------|----------------|
| 101      | Jane Doe     | 2              | 1                 | 540,000.00     |
| 104      | David Smith  | 1              | 2                 | 325,000.00     |
| 120      | Chinedu Obi  | 3              | 1                 | 290,500.00     |

---




# 2. Transaction Frequency Analysis

This report provides an analysis of **customer activity levels** based on how frequently they transact each month. Customers are grouped into frequency tiers—**High**, **Medium**, and **Low Frequency**—based on their average monthly transaction count.

---

# Objective

The goal is to:
- Measure user engagement over time based on transaction behavior
- Classify customers into segments for tailored communication or feature targeting
- Provide **summary statistics** per frequency category

---

# Data Source

- Table: `adashi_staging.savings_savingsaccount`
- Key Fields: 
  - `owner_id`: Customer identifier
  - `transaction_date`: Timestamp of transaction

---

# Query Breakdown

# 1. `monthly_transactions` CTE
- Aggregates the number of transactions each customer made **per month**
- Output: `(owner_id, month, transactions_in_month)`

# 2. `average_transactions_per_user` CTE
- Calculates the **average number of transactions per month** for each customer
- Output: `(owner_id, avg_tx_per_month)`

# 3. `categorized_users` CTE
- Categorizes each customer based on their `avg_tx_per_month`:
  - **High Frequency**: ≥ 10 transactions/month
  - **Medium Frequency**: 3 to 9.99 transactions/month
  - **Low Frequency**: < 3 transactions/month

# 4. Final SELECT
- Groups customers by their frequency category
- Counts users and computes the **average monthly transactions** for each category

---

# 🧾 Sample Output

| frequency_category | customer_count | avg_transactions_per_month |
|--------------------|----------------|-----------------------------|
| High Frequency     | 120            | 14.3                        |
| Medium Frequency   | 480            | 5.7                         |
| Low Frequency      | 310            | 1.5                         |

# Note
I didn't need the users_customuser table, the aggregation was done with the owner_id



#  3. Inactive Plans Detection

 Scenario**:  
The Operations team needs to flag accounts with no inflow transactions for over one year**.

Task:  
Identify all *active savings or investment plans* with **no transactions in the last 365 days**.

Data Tables:
- `plans_plan`: Contains plan metadata (status, type, owner, etc.)
- `savings_savingsaccount`: Holds individual savings transactions with timestamps

Logic:
- Filter `plans_plan` for *active* plans
- Join with `savings_savingsaccount` on `plan_id`
- Get the `MAX(transaction_date)` per plan
- Compute `inactivity_days = DATEDIFF(CURRENT_DATE, last_transaction_date)`
- Filter where `inactivity_days > 365`

Expected Output:
| plan_id | owner_id | type     | last_transaction_date | inactivity_days |
|---------|----------|----------|------------------------|-----------------|
| 1001    | 305      | Savings  | 2023-08-10             | 610             |

---



4. Customer Lifetime Value (CLV) Estimation

Scenario  
The Marketing team wants to estimate **Customer Lifetime Value (CLV)** based on tenure and transaction volume.

Task:  
Calculate CLV using a simplified model:

\[
\text{CLV} = \left(\frac{\text{total_transactions}}{\text{tenure_months}}\right) \times 12 \times (\text{avg transaction value} \times 0.001)
\]

#Data Tables:
- `users_customuser`: User info including signup date
- `savings_savingsaccount`: Transaction data (amounts and dates)

Logic:
- Get account tenure in months from `users_customuser.date_joined`
- Aggregate total transactions and average transaction value from `savings_savingsaccount`
- Apply the CLV formula
- Handle zero-month tenure with `NULLIF` to avoid division errors

Expected Output:
| customer_id | name      | tenure_months | total_transactions | estimated_clv |
|-------------|-----------|----------------|---------------------|----------------|
| 1001        | John Doe  | 24             | 120                 | 600.00         |

---

# SQL Highlights

- Used `TIMESTAMPDIFF()` to calculate tenure
- Applied `COUNT()`, `AVG()`, and `SUM()` for transaction aggregation
- Used `ROUND()` for precision control
- Ensured robustness with `NULLIF` to prevent division-by-zero errors

---

# Assumptions

- Only inflow (deposit) transactions were used for transaction counts
- Plans were considered inactive only if they were explicitly marked as active in the `status_id` column
- `transaction_date` and `amount` fields exist and are reliable in `savings_savingsaccount`

---



