-- CREATE SCHEMA fintech;
-- CREATE TABLE fintech_transactions (
-- 	transaction_id VARCHAR(20),
--     customer_id VARCHAR(20),
--     customer_name VARCHAR(20),
--     email VARCHAR(100),
--     signup_date VARCHAR(20),
--     transaction_date VARCHAR(20),
--     amount VARCHAR(20),
--     currency VARCHAR(20),
--     transaction_type VARCHAR(20),
--     merchant_category VARCHAR(20),
--     payment_method VARCHAR(20),
--     issuing_bank VARCHAR(20),
--     country VARCHAR(50),
--     status VARCHAR(20),
--     fraud_flag VARCHAR(20),
--     account_balance_after VARCHAR(20)
-- ); 
-- SET GLOBAL local_infile = 1;
-- SET SQL_SAFE_UPDATES = 0;
-- LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fintech_transactions_messy.csv'
-- INTO TABLE fintech_transactions
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;
-- SHOW VARIABLES LIKE 'local_infile';

SELECT DISTINCT country
FROM fintech_transactions;

UPDATE fintech_transactions SET country = 'Philippines' WHERE TRIM(country) IN ('PHL', 'PH', 'Philippines');
UPDATE fintech_transactions SET country = 'United States' WHERE TRIM(country) IN ('USA', 'US', 'United States');
UPDATE fintech_transactions SET country = 'Japan' WHERE TRIM(country) IN ('JP', 'Japan');
UPDATE fintech_transactions SET country = 'Singapore' WHERE TRIM(country) IN ('SG', 'Singapore');

SELECT DISTINCT transaction_type
FROM fintech_transactions;

DROP TABLE IF EXISTS clean_transactions;

CREATE TABLE clean_transactions AS
SELECT
    transaction_id,
    customer_id,
    SUBSTRING_INDEX(TRIM(customer_name), ' ', 1) AS first_name,
    SUBSTRING_INDEX(TRIM(customer_name), ' ', -1) AS last_name,

    CASE
        WHEN transaction_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%Y-%m-%d')
        WHEN transaction_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%m/%d/%Y')
        WHEN transaction_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%d-%m-%Y')
        WHEN transaction_date REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%M %d, %Y')
        WHEN transaction_date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%Y/%m/%d %H:%i')
        WHEN transaction_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%d/%m/%y')
        ELSE NULL
    END AS transaction_date,

    -- broken out pieces of transaction_date
    YEAR(
        CASE
            WHEN transaction_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%Y-%m-%d')
            WHEN transaction_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%m/%d/%Y')
            WHEN transaction_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%d-%m-%Y')
            WHEN transaction_date REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%M %d, %Y')
            WHEN transaction_date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%Y/%m/%d %H:%i')
            WHEN transaction_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%d/%m/%y')
            ELSE NULL
        END
    ) AS transaction_year,

    MONTH(
        CASE
            WHEN transaction_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%Y-%m-%d')
            WHEN transaction_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%m/%d/%Y')
            WHEN transaction_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%d-%m-%Y')
            WHEN transaction_date REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%M %d, %Y')
            WHEN transaction_date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%Y/%m/%d %H:%i')
            WHEN transaction_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%d/%m/%y')
            ELSE NULL
        END
    ) AS transaction_month,

    DAY(
        CASE
            WHEN transaction_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%Y-%m-%d')
            WHEN transaction_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%m/%d/%Y')
            WHEN transaction_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%d-%m-%Y')
            WHEN transaction_date REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN STR_TO_DATE(transaction_date, '%M %d, %Y')
            WHEN transaction_date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%Y/%m/%d %H:%i')
            WHEN transaction_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(transaction_date, '%d/%m/%y')
            ELSE NULL
        END
    ) AS transaction_day,

    CASE
        WHEN signup_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%Y-%m-%d')
        WHEN signup_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(signup_date, '%m/%d/%Y')
        WHEN signup_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(signup_date, '%d-%m-%Y')
        WHEN signup_date REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN STR_TO_DATE(signup_date, '%M %d, %Y')
        WHEN signup_date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%Y/%m/%d %H:%i')
        WHEN signup_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%d/%m/%y')
        ELSE NULL
    END AS signup_date,

    -- broken out pieces of signup_date
    YEAR(
        CASE
            WHEN signup_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%Y-%m-%d')
            WHEN signup_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(signup_date, '%m/%d/%Y')
            WHEN signup_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(signup_date, '%d-%m-%Y')
            WHEN signup_date REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN STR_TO_DATE(signup_date, '%M %d, %Y')
            WHEN signup_date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%Y/%m/%d %H:%i')
            WHEN signup_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%d/%m/%y')
            ELSE NULL
        END
    ) AS signup_year,

    MONTH(
        CASE
            WHEN signup_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%Y-%m-%d')
            WHEN signup_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(signup_date, '%m/%d/%Y')
            WHEN signup_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(signup_date, '%d-%m-%Y')
            WHEN signup_date REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN STR_TO_DATE(signup_date, '%M %d, %Y')
            WHEN signup_date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%Y/%m/%d %H:%i')
            WHEN signup_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%d/%m/%y')
            ELSE NULL
        END
    ) AS signup_month,

    DAY(
        CASE
            WHEN signup_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%Y-%m-%d')
            WHEN signup_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(signup_date, '%m/%d/%Y')
            WHEN signup_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(signup_date, '%d-%m-%Y')
            WHEN signup_date REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN STR_TO_DATE(signup_date, '%M %d, %Y')
            WHEN signup_date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%Y/%m/%d %H:%i')
            WHEN signup_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(signup_date, '%d/%m/%y')
            ELSE NULL
        END
    ) AS signup_day,

    CAST(NULLIF(NULLIF(REPLACE(REPLACE(TRIM(amount), '₱', ''), ',', ''), ''), 'N/A') AS DECIMAL(12,2)) AS amount,

    TRIM(country) AS country,

    CASE
        WHEN TRIM(country) = 'Philippines' THEN 'PHP'
        WHEN TRIM(country) = 'United States' THEN 'USD'
        WHEN TRIM(country) = 'Japan' THEN 'JPY'
        WHEN TRIM(country) = 'Singapore' THEN 'SGD'
        ELSE 'Unknown'
    END AS clean_currency,

    CASE
        WHEN transaction_type IS NULL OR TRIM(transaction_type) = '' THEN 'Unknown'
        ELSE LOWER(transaction_type)
    END AS transaction_type,

    CASE
        WHEN TRIM(merchant_category) IS NULL OR TRIM(merchant_category) = '' THEN 'Unknown'
        WHEN UPPER(TRIM(merchant_category)) IN ('OTHERS', 'OTHR') THEN 'Other'
        WHEN UPPER(TRIM(merchant_category)) = 'GROCERIES' THEN 'Groceries'
        ELSE TRIM(merchant_category)
    END AS merchant_category,

    CASE
        WHEN TRIM(payment_method) IS NULL OR TRIM(payment_method) = '' THEN 'Unknown'
        WHEN UPPER(TRIM(payment_method)) = 'CASH' THEN 'Cash'
        WHEN UPPER(TRIM(payment_method)) = 'E-WALLET' THEN 'E-Wallet'
        WHEN UPPER(TRIM(payment_method)) = 'DEBIT CARD' THEN 'Debit Card'
        ELSE TRIM(payment_method)
    END AS payment_method,

    CASE
        WHEN TRIM(issuing_bank) IS NULL OR TRIM(issuing_bank) = '' THEN 'Unknown'
        ELSE TRIM(issuing_bank)
    END AS issuing_bank,

    CASE
        WHEN TRIM(status) IS NULL OR TRIM(status) = '' THEN 'Unknown'
        WHEN UPPER(TRIM(status)) = 'COMPLETED' THEN 'Completed'
        ELSE TRIM(status)
    END AS status,

    CASE
        WHEN TRIM(fraud_flag) IN ('No', '0', 'FALSE') THEN '0'
        WHEN TRIM(fraud_flag) IN ('1', 'Yes', 'TRUE') THEN '1'
        ELSE 'Unknown'
    END AS fraud_flag,

    CAST(NULLIF(TRIM(account_balance_after), '') AS DECIMAL(12,2)) AS account_balance

FROM fintech_transactions;

CREATE TABLE clean_transactions_deduped AS
SELECT * FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_date) AS rn
    FROM clean_transactions
) ranked
WHERE rn = 1;

SELECT signup_date
FROM fintech_transactions
WHERE TRIM(signup_date) = '' OR TRIM(signup_date);

SELECT DISTINCT amount
FROM fintech_transactions
WHERE TRIM(amount) NOT REGEXP '^-?[0-9]+(\.[0-9]+)?$';

SELECT DISTINCT currency
FROM fintech_transactions;

SELECT DISTINCT transaction_type
FROM fintech_transactions;

SELECT email
FROM fintech_transactions
WHERE email NOT LIKE '%@%' AND 'Unknown';

SELECT DISTINCT TRIM(merchant_category)
FROM fintech_transactions;

SELECT TRIM
FROM fintech_transactions
WHERE customer_id = 'CUST1342';

SELECT DISTINCT TRIM(payment_method)
FROM fintech_transactions;

SELECT DISTINCT TRIM(issuing_bank)
FROM fintech_transactions;

SELECT DISTINCT TRIM(country)
FROM fintech_transactions;

SELECT DISTINCT TRIM(status)
FROM fintech_transactions;

SELECT DISTINCT TRIM(fraud_flag)
FROM fintech_transactions;

SELECT DISTINCT TRIM(account_balance_after)
FROM fintech_transactions;

SELECT *
FROM clean_transactions;

/* 
Revenue & refund leakage — What's net revenue by month, and which merchant categories have the highest refund-to-purchase ratio?
Customer segmentation — Which customers are high-value vs. dormant (RFM: recency, frequency, monetary), and does signup cohort predict transaction volume?
Fraud pattern detection — What transaction characteristics (amount size, payment method, country) correlate with flagged fraud, once fraud_flag is standardized?
Payment method & channel trends — How has e-wallet usage shifted vs. cards/bank transfer over time, and does it vary by country?
Data quality / reconciliation audit — Quantify the messiness: % missing per column, duplicate transaction_ids with conflicting values, outliers beyond 3 standard deviations — then explain how you cleaned it.
*/

-- 1. Revenue to Refund ratio
-- What's net revenue by month, and which merchant categories have the highest refund-to-purchase ratio?
-- Separate total revenue and refunds based on sums of negative amount and positive
SELECT DISTINCT merchant_category
FROM clean_transactions_php;

SELECT
	transaction_month,
    transaction_year,
    merchant_category,
	ROUND(SUM(CASE WHEN amount_php > 0 THEN amount_php ELSE 0 END), 2) as Total_Revenue,
	ROUND(ABS(SUM(CASE WHEN amount_php < 0 THEN amount_php ELSE 0 END)), 2) as Total_Refunds,
	ROUND(ABS(SUM(CASE WHEN amount_php < 0 THEN amount_php ELSE 0 END)) / NULLIF(SUM(CASE WHEN amount_php > 0 THEN amount_php ELSE 0 END), 0), 4) AS refund_ratio
FROM clean_transactions_php
GROUP BY transaction_month, transaction_year, merchant_category
ORDER BY transaction_year ASC, transaction_month ASC;
-- Adjusted based on changes in currency of PHP and sorted in ascending order based on month and year

-- 2. Customer Segmentation
-- Which customers are high-value vs. dormant (RFM: recency, frequency, monetary), and does signup cohort predict transaction volume?
SELECT
	customer_id,
    DATEDIFF (curdate(), MAX(transaction_date)) AS last_transaction,
    COUNT(*) as transaction_frequency,
    ROUND(SUM(CASE WHEN amount_php >= 0 THEN amount_php ELSE 0 END ), 2) AS Total_Revenue,
    ROUND(SUM(CASE WHEN amount_php < 0 THEN amount_php ELSE 0 END ), 2) AS Total_Refund,
    CASE 
		WHEN DATEDIFF (curdate(), MAX(transaction_date)) <= 180 AND COUNT(*) >= 10 AND ROUND(SUM(CASE WHEN amount_php > 0 THEN amount_php ELSE 0 END), 2) >= 100000 THEN 'High Value'
		WHEN DATEDIFF (curdate(), MAX(transaction_date)) > 180 THEN 'Dormant'
        ELSE 'Regular'
	END AS customer_segment
FROM clean_transactions_php
GROUP BY customer_id;
-- I separated each category for RFM by categorizing each customer into regular, dormant, or high value.
-- the logic goes as follows, I looked it up and found that in most, it ranges for 3 to 12 months of inactiviity to be considered dormant
-- so I put 6 as a safe example and made it so no matter how much a person has transacted and spent, more than 6 months of inactivity would
-- consider them as dormant customers. On the other hand, people who are active within 180 days or 6 months and spent a total of more than
-- 100k with more than 10 transactions are considered high value. Lastly, customers who are active but have yet to reach the quota for high value
-- are considered just regular

CREATE TABLE clean_transactions_php AS
SELECT
    *,
    ROUND(
        amount * CASE clean_currency
            WHEN 'PHP' THEN 1
            WHEN 'USD' THEN 58.50
            WHEN 'SGD' THEN 43.20
            WHEN 'JPY' THEN 0.39
            ELSE NULL
        END, 2
    ) AS amount_php
FROM clean_transactions_deduped;
-- I realized that adding up all total amounts would be ridiculous since all currencies are different, so I created
-- a new table converting all into PHP as one currency

SELECT *
FROM clean_transactions_php;

-- 3. Fraud pattern detection
-- What transaction characteristics (amount size, payment method, country) correlate with flagged fraud, once fraud_flag is standardized?

-- querying by amount size
-- Took the average of all types of transactions, the minimum, and the maximum
SELECT
	fraud_flag,
    ROUND(AVG(amount), 2) AS avg_amount,
	ROUND(MIN(amount), 2) AS min_amount,
    ROUND(MAX(amount), 2) AS max_amount,
    COUNT(*) as transaction_id
FROM clean_transactions_php
GROUP BY fraud_flag;

-- querying by payment method
-- Found amount and percentage of fraud counts per transactions of each payment_method   
SELECT
    payment_method,
    SUM(CASE WHEN fraud_flag = '1' THEN fraud_flag ELSE 0 END) AS fraud_counts,
    COUNT(*) AS Transactions,
    ROUND(SUM(CASE WHEN fraud_flag = '1' THEN fraud_flag ELSE 0 END) / COUNT(*) * 100,  2)  AS fraud_pct_per_payment_method
FROM clean_transactions_php
GROUP BY payment_method;

-- querying by country
-- same idea as the payment method query
SELECT
	country,
    COUNT(*) as Transactions,
    SUM(CASE WHEN fraud_flag = '1' THEN fraud_flag ELSE 0 END) AS fraud_count,
    ROUND(SUM(CASE WHEN fraud_flag = '1' THEN fraud_flag ELSE 0 END) / COUNT(*) * 100, 2) AS fraud_pct_per_country
FROM clean_transactions_php
GROUP BY country;

-- 4. Payment method & channel trends 
-- How has e-wallet usage shifted vs. cards/bank transfer over time, and does it vary by country?

SELECT DISTINCT payment_method
FROM clean_transactions_php;

SELECT
	transaction_year,
    transaction_month,
	CASE WHEN payment_method IN ('Debit Card', 'Credit Card') THEN 'Card'
		WHEN payment_method IN ('Bank Transfer') THEN 'Bank Transfer'
    ELSE payment_method
    END AS payment_channel,
    country,
    COUNT(*) AS 'Total Transaction'
FROM clean_transactions_php
GROUP BY transaction_year, transaction_month, payment_channel, country
ORDER BY transaction_year, transaction_month;

-- realized that gcash, paymaya, and ewallet were separated payment methods in the dataset so i updated the latest clean table
-- UPDATE clean_transactions_php
-- SET payment_method = 
-- 	CASE WHEN payment_method IN ('GCash', 'PayMaya', 'E-Wallet') THEN 'E-Wallet'
--     ELSE payment_method
-- END
-- WHERE payment_method IN ('GCash', 'PayMaya', 'E-Wallet');

-- SET SQL_SAFE_UPDATES = 0; 

-- 5 Data quality / reconciliation audit 
-- Quantify the messiness: % missing per column, duplicate transaction_ids with conflicting values, outliers beyond 3 standard deviations 
-- then explain how you cleaned it.

-- Indicate how many unknowns/nulls are in the dataset
SELECT
    -- String columns: evaluate the 'Unknown' text directly
    ROUND(AVG(transaction_id = 'Unknown'), 4) * 100 AS pct_missing_transaction_id,
    ROUND(AVG(customer_id = 'Unknown'), 4) * 100 AS pct_missing_customer_id,
    ROUND(AVG(first_name = 'Unknown'), 4) * 100 AS pct_missing_first_name,
    ROUND(AVG(last_name = 'Unknown'), 4) * 100 AS pct_missing_last_name,
    ROUND(AVG(country = 'Unknown'), 4) * 100 AS pct_missing_country,
    ROUND(AVG(clean_currency = 'Unknown'), 4) * 100 AS pct_missing_clean_currency,
    ROUND(AVG(transaction_type = 'Unknown'), 4) * 100 AS pct_missing_transaction_type,
    ROUND(AVG(merchant_category = 'Unknown'), 4) * 100 AS pct_missing_merchant_category,
    ROUND(AVG(payment_method = 'Unknown'), 4) * 100 AS pct_missing_payment_method,
    ROUND(AVG(issuing_bank = 'Unknown'), 4) * 100 AS pct_missing_issuing_bank,
    ROUND(AVG(status = 'Unknown'), 4) * 100 AS pct_missing_status,
    ROUND(AVG(fraud_flag = 'Unknown'), 4) * 100 AS pct_missing_fraud_flag,

    -- Date and Numeric columns: evaluate IS NULL directly (avoids Error 1525)
    ROUND(AVG(transaction_date IS NULL), 4) * 100 AS pct_missing_transaction_date,
    ROUND(AVG(transaction_year IS NULL), 4) * 100 AS pct_missing_transaction_year,
    ROUND(AVG(transaction_month IS NULL), 4) * 100 AS pct_missing_transaction_month,
    ROUND(AVG(transaction_day IS NULL), 4) * 100 AS pct_missing_transaction_day,
    ROUND(AVG(signup_date IS NULL), 4) * 100 AS pct_missing_signup_date,
    ROUND(AVG(signup_year IS NULL), 4) * 100 AS pct_missing_signup_year,
    ROUND(AVG(signup_month IS NULL), 4) * 100 AS pct_missing_signup_month,
    ROUND(AVG(signup_day IS NULL), 4) * 100 AS pct_missing_signup_day,
    ROUND(AVG(amount IS NULL), 4) * 100 AS pct_missing_amount,
    ROUND(AVG(account_balance IS NULL), 4) * 100 AS pct_missing_account_balance,
    ROUND(AVG(amount_php IS NULL), 4) * 100 AS pct_missing_amount_php
FROM clean_transactions_php;

-- REMOVED DUPLICATE ROWS WITH 
-- CREATE TABLE clean_transactions_deduped AS
-- SELECT * FROM (
--     SELECT *,
--            ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_date) AS rn
--     FROM clean_transactions
-- ) ranked
-- WHERE rn = 1;

-- After creating tables, I found some more data that needed to be merged together such as currencies into one currency format for
-- less redundancy for reporting and visual purposes.alter

-- THIS QUERY WAS THE FIRST "CLEAN TRANSACTION" TABLE BEFORE I STARTED REMOVING DUPLICATES
SELECT transaction_id, COUNT(*) AS occurrences
FROM clean_transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

SELECT
    ROUND(AVG(amount_php), 2) AS mean_amount,
    ROUND(STDDEV(amount_php), 2) AS stddev_amount
FROM clean_transactions_php;

SELECT
    COUNT(*) AS total_outliers,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM clean_transactions_php WHERE amount_php IS NOT NULL) * 100, 2) AS pct_outliers
FROM clean_transactions_php
WHERE amount_php > (SELECT AVG(amount_php) + 3 * STDDEV(amount_php) FROM clean_transactions_php)
   OR amount_php < (SELECT AVG(amount_php) - 3 * STDDEV(amount_php) FROM clean_transactions_php);
