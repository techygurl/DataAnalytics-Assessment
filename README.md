# SQL Data Analysis Queries for Customer Accounts

This repository contains a collection of SQL queries designed for analyzing customer savings and investment behavior using tables such as `users_customuser`, `plans_plan`, and `savings_savingsaccount`, `withdrawals_withdrawal `

---

## 📁 Table Structure References

- **users_customuser**: customer demographic and contact information
- **plans_plan**: records of plans created by customers
- **savings_savingsaccount**: records of deposit transactions
- **withdrawals_withdrawal**: records of withdrawal transactions

.

---

## Query Summaries & Explanations

### 1. Customers with Funded Savings & Investment Plans

**Query Objective:**  
Find users with at least one **funded savings plan** and one **active and funded investment plan**, sorted by total deposits.

**Approach:**
- Join `users_customuser` with `savings_savingsaccount` where `amount > 0`.
- Join with `plans_plan` where:
  - `is_a_fund = TRUE`
  - `is_deleted = FALSE`
  - `is_archived = FALSE`
  - `amount > 0`
- Group by user and sum deposits.

**Key Output Fields:**
- `owner_id`, `name`, `savings_count`, `investment_count`, `total_deposits`

---

### 2. Categorizing Users by Monthly Transaction Frequency

**Query Objective:**  
Classify users into:
- **High Frequency** (≥10 txns/month)
- **Medium Frequency** (3–9 txns/month)
- **Low Frequency** (≤2 txns/month)

**Approach:**
- Count all user transactions and active months.
- Divided to get average transactions/month.
- Used `CASE` logic to classify frequency category.
- Aggregate by category.

**Key Output Fields:**
- `frequency_category`, `customer_count`, `avg_transactions_per_month`

---

### 3. Identify Inactive Accounts

**Query Objective:**  
Find savings or investment accounts with **no activity in the past year**.

**Approach:**
- Get latest transaction date for savings from `savings_savingsaccount`.
- Get latest activity for investments using `GREATEST()` across key plan date fields.
- Filter where `last_transaction_date` is more than 365 days ago.

**Key Output Fields:**
- `plan_id`, `owner_id`, `type`, `last_transaction_date`, `inactivity_days`

---

### 4. Estimate Customer Lifetime Value (CLV)

**Query Objective:**  
Estimate **CLV** using average transaction value and user tenure.

**Approach:**
- Calculate tenure in months using `TIMESTAMPDIFF()`.
- Filter for successful, confirmed transactions.
- Compute CLV using formula:

  \[
  (total_transactions / tenure_months) * 12 * (avg_transaction_value_naira * 0.001),  -- annualized value 
            2)
  \]

**Key Output Fields:**
- `customer_id`, `name`, `tenure_months`, `total_transactions`, `estimated_clv`

---

## ⚠️ Challenges & Resolutions

### 1. **Large Query Payloads**
- **Issue:** SQL server displayed `payload size exceeds the limit` errors.
- **Fix:** I used my SQL workbench instead & Optimized joins and filtered early with `amount > 0` or `status = 'successful'`.

### 2. **NULL Values in Name Column**
- **Issue:** `u.name` returned many NULLs.
- **Cause:** Data in `name` field was missing or improperly populated.
- **Fix:** Used fallback columns like `first_name` + `last_name` or email .
---

##  Prerequisites

- MySQL Workbench or any compatible SQL environment.
- A dataset with a matching schema.

---

## 👨‍💻 for Cowrywise assessment

Feel free to adapt or extend these queries for deeper analysis or integration into dashboards.

---

