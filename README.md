Bank Loan Portfolio & Default Risk Analysis

End-to-end analysis of a retail loan portfolio: data cleaning and feature engineering in Python (Pandas, NumPy), a composite 0–100 credit risk score, and 14 PostgreSQL queries to measure NPA %, rank default risk, check underwriting policy breaches, and uncover "silent risk" among borrowers with high credit scores.

Tools: Python · Pandas · NumPy · PostgreSQL · SQL (CTEs, window functions, JOINs, subqueries)

Business Problem

A retail bank wants to know:

How bad is the loan book? (default rate and NPA %)
Which loan purposes and borrower segments carry the most default risk?
Are underwriting DTI limits being respected, and do breaches default more?
Does a credit score alone catch risky borrowers, or does a multi-factor score see more?
Dataset
Item	Detail
Name	Loan Default Prediction Dataset
Source	Kaggle, uploaded by Nikhil Bhadoriya (nikhil1e9/loan-default), originally from Coursera's Loan Default Prediction Challenge
Size	255,347 loans, 18 columns
Target	Default (1 = defaulted, 0 = repaying)

Columns include age, income, loan amount, credit score, months employed, number of credit lines, interest rate, loan term, DTI ratio, education, employment type, marital status, mortgage, dependents, loan purpose and co-signer.

Download the dataset from Kaggle and place Loan_default.csv in the project folder. Check the dataset's license on Kaggle before redistributing it.

Project Structure
Bank-Loan-Portfolio-Default-Risk-Analysis/
├── Bank_Loan_Default_Analysis.ipynb          # cleaning, feature engineering, risk score, load to PostgreSQL
├── Bank_Loan_Default_Analysis_Queries.sql    # 14 SQL questions with queries
├── Loan_default.csv                          # raw dataset (download from Kaggle)
└── README.md
Methodology
1. Data cleaning (Python)
Checked nulls, duplicate rows and duplicate loan IDs. The data had none.
Renamed columns to snake_case (Default became default_flag, because default is a reserved word in SQL).
Converted Yes/No columns (has_mortgage, has_dependents, has_cosigner) to 1/0.
2. Feature engineering (Python)
Feature	Definition
age_group	18-29, 30-39, 40-49, 50-59, 60+
income_group	Low / Medium / High (three equal-sized groups)
borrower_segment	employment type + income group (12 segments)
emi	monthly instalment from loan amount, interest rate and term
emi_to_income	EMI divided by monthly income
3. Composite credit risk score (0–100, higher = riskier)

Each factor is scaled to 0–100, then combined with fixed weights:

risk_score = 0.35 × credit risk + 0.35 × DTI risk + 0.30 × EMI-to-income risk
Credit risk = (850 − credit score) / 550 × 100
DTI risk = (DTI − 0.1) / 0.8 × 100
EMI-to-income risk = scaled between the minimum and the 99th percentile (to limit the effect of extreme values)

Risk tiers: Low (below 33), Medium (33 to 66), High (66 and above).

4. Load into PostgreSQL

The cleaned data is loaded into a loan table with pandas.to_sql. A small underwriting_policy reference table (DTI limit by loan purpose) is created for the policy-breach queries.

SQL Questions Answered
#	Question	Concepts
Q1	Total loans, defaults and default rate	COUNT, SUM, AVG
Q2	NPA % of the portfolio	CASE WHEN
Q3	Rank loan purposes by default rate	RANK() window function
Q4	Top 5 riskiest borrower segments	GROUP BY, LIMIT
Q5	Default rate with vs without a co-signer	GROUP BY
Q6	Defaulted loans bigger than the average loan	Subquery
Q7	Loans and default rate in each risk tier	GROUP BY
Q8	Default rate by credit score band	CTE + CASE WHEN
Q9	Top 3 riskiest segments within each loan purpose	CTE + ROW_NUMBER()
Q10	DTI policy breaches per loan purpose	JOIN
Q11	Do DTI-breach loans default more?	JOIN + CASE WHEN
Q12	Silent risk: defaulters with 700+ credit score	Subquery
Q13	Default rate by risk tier among 700+ borrowers	WHERE + GROUP BY
Q14	Loan amount and default rate by age group	GROUP BY
Key Findings
Portfolio health: 29,653 of 255,347 loans defaulted, a 11.61% default rate. The amount-based NPA is 13.15%.
By loan purpose: Business loans are the riskiest at 12.33% and Home loans the safest at 10.23%.
Risk tiers separate defaults. Default rates rise steadily from Low to High:
Tier	Loans	Default rate
Low	87,082	9.04%
Medium	157,871	12.40%
High	10,394	21.19%
Borrower segments: unemployed, low-income borrowers default the most (18.5%), while full-time, high-income borrowers default the least (7.3%).
Co-signers help: loans with a co-signer default at 10.36% vs 12.87% without one.
Silent risk: 7,086 borrowers with a credit score of 700 or more still defaulted, which is 23.9% of all defaults. A credit-score-only screen would have approved all of them.
The composite score sees what credit score misses. Among borrowers with 700+ credit scores, default rates still rise with the risk tier:
Tier (700+ score only)	Borrowers	Default rate
Low	47,133	8.80%
Medium	22,205	13.09%
High	92	34.78%

The High group is only 92 borrowers, so treat that last rate as indicative only.

How to Run
Get the data: download Loan_default.csv from Kaggle and put it in the project folder.
Install the libraries:
pip install pandas numpy sqlalchemy psycopg2-binary notebook
Create a PostgreSQL database named bank_loan_portfolio (for example in pgAdmin).
Open the notebook (python -m notebook), update the file path, and set your own PostgreSQL password in the connection cell. Do not commit your real password.
Run the cells in order. The notebook builds the features and the risk score, then loads the loan and underwriting_policy tables.
Run the SQL file in pgAdmin's Query Tool, one query at a time (highlight a query and press F5).
Assumptions & Limitations
NPA % is a proxy. The dataset has no outstanding balance, so NPA % = defaulted loan amount divided by total loan amount.
The underwriting limits are illustrative. The DTI limits by loan purpose (Home 0.43, Auto 0.45, Education 0.40, Business 0.40, Other 0.36) are my own assumptions, not a real bank's policy. Replace them with real policy limits if you have them.
The score weights are chosen by judgment. The 35/35/30 weights were fixed in advance, not tuned on the default outcome, to avoid overfitting.
The data behaves like simulated data. Distributions are close to uniform and correlations are weak, so risk differences between groups are modest. Treat the results as a demonstration of method, not as findings about a real bank.
Single-factor strength varies. In this dataset the EMI-to-income ratio is a stronger default signal than DTI alone, which is why the score combines several factors.
Author

Kartik Patel LinkedIn · GitHub · kartikgpatel7@gmail.com
