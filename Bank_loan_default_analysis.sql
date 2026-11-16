/* Preview the table  */
SELECT * 
FROM loan 
LIMIT 10;

-- Q1. Total loans, defaulted loans and default rate

SELECT COUNT(*) AS total_loans,
       SUM(default_flag) AS defaulted_loans,
       ROUND(AVG(default_flag) * 100, 2) AS default_rate_pct
FROM loan;

-- Q2. NPA % of the portfolio

SELECT SUM(loan_amount) AS total_loan_amount,
       SUM(CASE WHEN default_flag = 1 THEN loan_amount ELSE 0 END) AS npa_amount,
       ROUND(SUM(CASE WHEN default_flag = 1 THEN loan_amount ELSE 0 END) * 100.0 / SUM(loan_amount), 2) AS npa_pct
FROM loan;

-- Q3. Rank loan purposes by default rate (rank 1 = riskiest)

SELECT loan_purpose,
       COUNT(*) AS total_loans,
       ROUND(AVG(default_flag) * 100, 2) AS default_rate_pct,
       RANK() OVER(ORDER BY AVG(default_flag) DESC) AS risk_rank
FROM loan
GROUP BY loan_purpose;

-- Q4. Top 5 riskiest borrower segments

SELECT borrower_segment,
       COUNT(*) AS total_loans,
       ROUND(AVG(default_flag) * 100, 2) AS default_rate_pct
FROM loan
GROUP BY borrower_segment
ORDER BY default_rate_pct DESC
LIMIT 5;

-- Q5. Default rate with and without a co-signer

SELECT has_cosigner,
       COUNT(*) AS total_loans,
       ROUND(AVG(default_flag) * 100, 2) AS default_rate_pct
FROM loan
GROUP BY has_cosigner;

-- Q6. Defaulted loans bigger than the average loan amount

SELECT COUNT(*) AS big_defaulted_loans
FROM loan
WHERE default_flag = 1
AND loan_amount >= (SELECT AVG(loan_amount)
                    FROM loan);

-- Q7. Loans and default rate in each risk tier

SELECT risk_tier,
       COUNT(*) AS total_loans,
       ROUND(AVG(default_flag) * 100, 2) AS default_rate_pct
FROM loan
GROUP BY risk_tier
ORDER BY default_rate_pct;

-- Q8. Default rate by credit score band (CTE)

WITH credit_segment AS(
SELECT loan_id,
       default_flag,
       CASE
           WHEN credit_score < 580 THEN 'Poor'
           WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
           WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
           WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
           ELSE 'Exceptional'
       END AS credit_band
FROM loan)

SELECT credit_band,
       COUNT(*) AS total_loans,
       ROUND(AVG(default_flag) * 100, 2) AS default_rate_pct
FROM credit_segment
GROUP BY credit_band
ORDER BY default_rate_pct DESC;

-- Q9. Top 3 riskiest borrower segments within each loan purpose (CTE + ROW_NUMBER)

WITH segment_risk AS(
SELECT loan_purpose,
       borrower_segment,
       COUNT(*) AS total_loans,
       ROUND(AVG(default_flag) * 100, 2) AS default_rate_pct,
       ROW_NUMBER() OVER(PARTITION BY loan_purpose ORDER BY AVG(default_flag) DESC) AS segment_rank
FROM loan
GROUP BY loan_purpose, borrower_segment
)

SELECT loan_purpose,
       borrower_segment,
       total_loans,
       default_rate_pct
FROM segment_risk
WHERE segment_rank <= 3
ORDER BY loan_purpose, segment_rank;

-- Q10. DTI policy breaches in each loan purpose (JOIN)

SELECT loan.loan_purpose,
       underwriting_policy.max_dti,
       COUNT(*) AS dti_breaches
FROM loan
JOIN underwriting_policy
ON loan.loan_purpose = underwriting_policy.loan_purpose
WHERE loan.dti_ratio > underwriting_policy.max_dti
GROUP BY loan.loan_purpose, underwriting_policy.max_dti
ORDER BY dti_breaches DESC;

-- Q11. Do DTI-breach loans default more than loans within policy? (JOIN)

SELECT CASE WHEN loan.dti_ratio > underwriting_policy.max_dti
            THEN 'Breach' 
			ELSE 'Within policy' 
			END AS dti_policy_status,
       COUNT(*) AS total_loans,
       ROUND(AVG(loan.default_flag) * 100, 2) AS default_rate_pct
FROM loan
JOIN underwriting_policy
ON loan.loan_purpose = underwriting_policy.loan_purpose
GROUP BY dti_policy_status;

-- Q12. Silent risk: defaulters with a credit score of 700 or more

SELECT COUNT(*) AS silent_defaulters,
       ROUND(COUNT(*) * 100.0 / (SELECT SUM(default_flag) FROM loan), 2) AS pct_of_all_defaults
FROM loan
WHERE credit_score >= 700
AND default_flag = 1;

-- Q13. Among 700+ credit score borrowers, default rate by risk tier

SELECT risk_tier,
       COUNT(*) AS borrowers_700_plus,
       SUM(default_flag) AS defaults,
       ROUND(AVG(default_flag) * 100, 2) AS default_rate_pct
FROM loan
WHERE credit_score >= 700
GROUP BY risk_tier
ORDER BY default_rate_pct;

-- Q14. Total loan amount and default rate by age group

SELECT age_group,
       SUM(loan_amount) AS total_loan_amount,
       ROUND(AVG(default_flag) * 100, 2) AS default_rate_pct
FROM loan
GROUP BY age_group
ORDER BY default_rate_pct DESC;