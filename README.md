# Bank-Loan-Portfolio-Default-Risk-Analysis

## 📌 Project Overview

This project analyzes a retail bank loan portfolio using Python, SQL and PostgreSQL to measure default risk, build a credit risk score, and find borrowers that a credit score alone would miss.

The analysis is based on 255,347 loan records containing borrower demographics, income and credit details, loan terms, loan purpose, co-signer information and the final default outcome.

The goal is to turn raw loan data into risk insights that support lending decisions, underwriting policy checks and portfolio monitoring.

---

## 🎯 Business Objectives

- Measure portfolio health through the default rate and NPA %.
- Identify the loan purposes and borrower segments with the highest default risk.
- Build a composite 0–100 credit risk score and group loans into Low, Medium and High risk tiers.
- Check how many loans breach underwriting DTI limits and whether breaches default more.
- Uncover "silent risk": borrowers with strong credit scores (700+) who still defaulted.
- Show why a multi-factor score gives a fuller risk picture than a credit score alone.

---

## 📊 Dataset Information

- **Records:** 255,347 loans
- **Features:** 18 original columns, plus 7 engineered columns
- **Source:** Loan Default Prediction Dataset on Kaggle (`nikhil1e9/loan-default`), originally from Coursera's Loan Default Prediction Challenge
- **Target:** `Default` (1 = defaulted, 0 = repaying)

### Key Variables

| Category | Features |
| --- | --- |
| Borrower Profile | Age, Education, Marital Status, Dependents |
| Financial Profile | Income, Credit Score, DTI Ratio, Months Employed, Credit Lines, Mortgage |
| Loan Details | Loan Amount, Interest Rate, Loan Term, Loan Purpose, Co-signer |
| Outcome | Default |
| Engineered Features | Age Group, Income Group, Borrower Segment, EMI, EMI-to-Income, Risk Score, Risk Tier |

> The dataset is not included in this repository. Download `Loan_default.csv` from Kaggle and place it in the project folder.

---

## 🛠️ Tech Stack

- **Python:** data cleaning, feature engineering and the risk score
- **Pandas:** data manipulation and transformation
- **NumPy:** numerical calculations and risk tier logic
- **SQLAlchemy:** database connection and data loading
- **PostgreSQL:** data storage and SQL analysis
- **SQL:** business queries using CTEs, window functions, JOINs and subqueries
- **Jupyter Notebook:** analysis and data preparation workflow

---

## 🔄 Project Workflow

### 1. Data Cleaning & Preparation

- Inspected the data using `df.info()` and `df.describe()`
- Checked for null values, duplicate rows and duplicate loan IDs (none found)
- Standardized column names to snake_case
- Renamed `Default` to `default_flag`, because `default` is a reserved word in SQL
- Converted Yes/No columns to 1/0

**Created new features including:**

- `age_group`
- `income_group`
- `borrower_segment` (employment type + income group)
- `emi` and `emi_to_income`

### 2. Credit Risk Scoring

Each risk factor was scaled to 0–100 and combined into one score, where a higher score means higher risk:

```
risk_score = 0.35 × credit risk + 0.35 × DTI risk + 0.30 × EMI-to-income risk
```

Loans were then grouped into tiers: **Low** (below 33), **Medium** (33 to 66) and **High** (66 and above).

### 3. Database Integration

- Loaded the cleaned dataset into PostgreSQL using `to_sql`
- Created an `underwriting_policy` reference table with DTI limits by loan purpose

### 4. SQL Analysis

Wrote 14 queries answering business questions, including:

- Default rate and NPA % of the portfolio
- Ranking loan purposes and borrower segments by default risk
- Top 3 riskiest segments within each loan purpose
- DTI policy breaches using a JOIN to the underwriting table
- Silent risk among borrowers with 700+ credit scores

---

## 📈 Key Insights

- 29,653 of 255,347 loans defaulted, a **11.61% default rate**.
- The amount-based **NPA % is 13.15%**.
- Business loans were the riskiest purpose at 12.33%, and Home loans the safest at 10.23%.
- Default rates rose steadily across the risk tiers: **9.04% (Low), 12.40% (Medium) and 21.19% (High)**.
- Unemployed, low-income borrowers had the highest default rate (18.5%), and full-time, high-income borrowers the lowest (7.3%).
- Loans with a co-signer defaulted less (10.36%) than loans without one (12.87%).
- **7,086 borrowers with a credit score of 700 or more still defaulted**, which is 23.9% of all defaults.
- Among 700+ credit score borrowers, default rates still rose with the risk tier: 8.80% (Low) and 13.09% (Medium). The High tier has only 92 borrowers, so its 34.78% rate is indicative only.
- 60.9% of loans exceeded the illustrative DTI limits, and those loans defaulted slightly more (12.09%) than loans within the limits (10.88%).

---

## ⚠️ Assumptions & Limitations

- **NPA % is a proxy.** The data has no outstanding balance, so it is calculated as defaulted loan amount divided by total loan amount.
- **The DTI limits are illustrative.** The limits by loan purpose are my own assumptions, not a real bank's policy.
- **The score weights are chosen by judgment** and were not tuned on the default outcome.
- **The dataset behaves like simulated data.** Distributions are close to uniform and relationships are weak, so the results demonstrate the method rather than describe a real bank.

---

## 📁 Project Structure

```
Bank-Loan-Portfolio-Default-Risk-Analysis/
├── Bank_Loan_Default_Analysis.ipynb          # cleaning, features, risk score, load to PostgreSQL
├── Bank_Loan_Default_Analysis_Queries.sql    # 14 SQL business questions with queries
└── README.md
```

---

## ▶️ How to Run

1. Download `Loan_default.csv` from Kaggle and place it in the project folder.
2. Install the libraries: `pip install pandas numpy sqlalchemy psycopg2-binary notebook`
3. Create a PostgreSQL database named `bank_loan_portfolio`.
4. Open the notebook, set your own PostgreSQL password in the connection cell, and run all cells in order.
5. Open pgAdmin's Query Tool on the database and run the queries from the SQL file one at a time.

---

## 👤 Author

**Kartik Patel**
[LinkedIn](https://www.linkedin.com/in/kartik-patel-160aa2287) · [GitHub](https://github.com/cartik7) · kartikgpatel7@gmail.com

---

**⭐ If you found this project useful, consider giving it a star.**
