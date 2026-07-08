# Fintech Transaction Analytics — SQL & Power BI Project

## The Question Behind the Project

A fintech platform processing thousands of transactions a month rarely fails loudly. It fails quietly — a refund rate that creeps up in one category, a handful of high-spend customers slipping into inactivity unnoticed, a fraud pattern hiding behind incomplete records, a payment channel shift nobody flagged until the support tickets piled up. None of these show up on a balance sheet until they're already expensive.

This project simulates exactly that situation: a raw, messy transactions export (~6,100 rows) with the kind of problems that hide real answers — inconsistent formatting, missing values, duplicate records, four different currencies mixed into one column, and statistical outliers sitting quietly among the totals. The work here was to clean it into something trustworthy, then use it to answer four concrete business questions a fintech operations or growth team would actually ask.

## Overview

The goal was to build a full analytics pipeline end-to-end: import raw data, clean and standardize it using SQL, and answer four business questions through a multi-page Power BI dashboard.
=======
## Overview

This project analyzes a synthetic fintech transactions dataset (~6,100 rows) designed to simulate the kind of messy, real-world data a data analyst typically encounters — inconsistent formatting, missing values, duplicate records, mixed currencies, and statistical outliers. The goal was to build a full analytics pipeline end-to-end: import raw data, clean and standardize it using SQL, and answer four business questions through a multi-page Power BI dashboard.

**Tools used:** MySQL / MySQL Workbench (data cleaning, transformation, analysis), Power BI (dashboard and visualization).

**Business questions answered:**
1. Revenue & refund leakage — What's net revenue by month, and what's the total revenue vs. refund by merchant category?
2. Customer segmentation — Which customers are high-value vs. dormant (RFM: recency, frequency, monetary)?
3. Fraud pattern detection — What transaction characteristics (amount size, payment method, country) correlate with flagged fraud?
4. Payment method & channel trends — How has e-wallet usage shifted vs. cards/bank transfer over time, and does it vary by country?

---

## Data Cleaning Process

### 1. Raw import

The raw CSV was imported into a staging table (`fintech_transactions`) with every column typed as `VARCHAR`, regardless of what the data represented (dates, amounts, flags). This was a deliberate choice — importing directly into strict types (e.g., `DECIMAL` for amount, `DATE` for transaction date) would have caused rows to be rejected or silently truncated, since the raw data contained multiple formats and non-numeric placeholders. Keeping everything as text at import time meant no data was lost before cleaning began.

### 2. Country standardization

An initial pass standardized inconsistent country values (`PH`, `PHL`, `Philippines` → `Philippines`; similar treatment for `US`/`USA`, `JP`, `SG`) using `TRIM()` and `IN()` matching.

### 3. Building the cleaned table

A single `CREATE TABLE ... AS SELECT` was used to produce `clean_transactions`, applying a `CASE WHEN` or equivalent transformation to every column:

- **Dates (`transaction_date`, `signup_date`):** The raw data contained six different date formats (e.g., `2025-07-04`, `07/04/2025`, `July 04, 2025`, `2025/07/04 14:30`). Initial attempts using `COALESCE()` with multiple `STR_TO_DATE()` calls worked in principle, but triggered strict-mode datetime errors when a format didn't match. This was resolved by switching to `REGEXP` pattern-matching to first identify which format a given value was in, then applying only the matching `STR_TO_DATE()` conversion — avoiding invalid parse attempts entirely rather than relying on silent failure.
- **Amount:** Currency symbols (₱) and thousands separators (commas) were stripped, blank/`"N/A"` values were converted to `NULL` via nested `NULLIF()`, and the result was cast to `DECIMAL(12,2)`. An early version of this column mixed numeric values with the placeholder text `'Unknown'` for missing entries — this was identified as a bug, since a column containing both numbers and text cannot be used in `SUM()`/`AVG()` correctly. The fix was to keep missing amounts as `NULL` (which SQL aggregate functions correctly skip) rather than as descriptive text.
- **Names:** Split into `first_name` and `last_name` using `SUBSTRING_INDEX()`.
- **Currency:** Initially cleaned by standardizing casing/typos in the existing `currency` column. It was later realized that currency and country were independent, randomly generated fields in this dataset — not logically linked — so a currency-follows-country rule was applied as a deliberate assumption rather than a discovered pattern, and is called out as such rather than presented as a verified relationship in the data.
- **Categorical columns** (`transaction_type`, `merchant_category`, `payment_method`, `issuing_bank`, `status`, `fraud_flag`): Standardized casing and known variants (e.g., `othr`/`Others` → `Other`, `e-wallet` → `E-Wallet`), with missing/blank values explicitly labeled `'Unknown'` rather than guessed or silently dropped.
- **Account balance:** Same numeric-NULL handling as amount, cast to `DECIMAL(12,2)`.

### 4. Duplicate detection and removal

A check for duplicate `transaction_id`s revealed two distinct issues:
- **Exact duplicate rows** — the same transaction fully repeated, likely a data entry/import artifact.
- **Conflicting duplicates** — the same `transaction_id` appearing with different amounts on the same date, a genuine data integrity problem with no way to determine which value was correct after the fact.

Both were resolved using `ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_date)`, keeping only the first occurrence per ID and discarding the rest. This is noted as a limitation: for the small number of genuinely conflicting records, the retained value was chosen arbitrarily (earliest by date), not verified as correct.

### 5. Currency mixing — a key realization

Midway through analysis, it became clear that `amount` values were being summed across four different currencies (PHP, USD, SGD, JPY) without conversion — meaning early revenue totals were mathematically meaningless (a peso amount and a dollar amount are not the same unit and cannot simply be added together). This was corrected by creating `clean_transactions_php`, converting every transaction to a common PHP baseline using fixed exchange rates. These rates are stated as an illustrative assumption for this project, not real-time or historically accurate figures.

### 6. Payment method grouping

`GCash`, `PayMaya`, and a generic `E-Wallet` label were initially treated as separate payment methods in the cleaned data. Since the business question asks about e-wallet usage as a category (not individual apps), these were consolidated into a single `E-Wallet` grouping for the payment method trend analysis.

### 7. Handling missing values

Rather than deleting rows with missing data, missing values were preserved and handled according to column type:
- Categorical columns: labeled `'Unknown'`, treated as their own reportable group.
- Numeric columns: left as `NULL`, allowing `SUM()`/`AVG()` to correctly exclude them without distorting totals or requiring rows to be dropped.

This decision was made deliberately after considering the cost of dropping rows entirely — a transaction missing one field (e.g., fraud status) still carries valid information in every other column, and removing it would discard usable data for unrelated analyses.

---

## Business Question Findings

### 1. Revenue & Refund Leakage

**The headline:** Currency mixing was the single biggest distortion in this question — early totals blended PHP, USD, SGD, and JPY as if they were the same unit before conversion. Once normalized to PHP, a handful of months (e.g. Jan 2023, mid-2025, mid-2026) showed refunds exceeding revenue outright — every one of these tied back to one or two extreme outlier transactions landing in a low-volume month, not a genuine business trend.

<img width="1310" height="725" alt="image" src="https://github.com/user-attachments/assets/6a9c8e3b-a50d-403e-b039-6dd6468cee2a" />

**Why it matters:** a refund ratio only means something once currencies are normalized. If this pattern holds beyond the data window studied here, it's the kind of leak that's cheap to catch early and expensive to catch late.

### 2. Customer Segmentation (RFM)

**The headline:** Dormant customers averaged 387 days since their last transaction — more than a year of inactivity — while High Value and Regular customers were both active within roughly the last 2–3 months (74 and 82 days respectively). High Value customers also transacted nearly twice as often as Regular customers (11.08 vs. 6.62 average transactions) and generated over double the average revenue (₱0.43M vs. ₱0.18M).

=======
Net revenue was calculated by month (using the currency-normalized `amount_php` field), separating total revenue (positive amounts) from total refunds (negative amounts). Refund-to-purchase ratio was calculated per merchant category by aggregating across the full dataset (rather than per month per category), since splitting by both dimensions simultaneously produced unstable ratios in categories with low transaction volume in a given month.

<img width="1320" height="731" alt="image" src="https://github.com/user-attachments/assets/b7a929ba-5edd-41be-ae73-519edf653881" />

*[Insert dashboard screenshot + specific findings: top refund-ratio categories, monthly revenue trend]*

### 2. Customer Segmentation (RFM)

>>>>>>> bb17ca79013126d8e9320c728f1954a5db93bb2d
Customers were segmented into **High Value**, **Regular**, and **Dormant** using:
- **Recency:** days since last transaction (dormant threshold set at 180 days / 6 months, based on common industry ranges of 3–12 months)
- **Frequency:** total transaction count (High Value threshold: 10+ transactions)
- **Monetary:** total revenue in PHP (High Value threshold: ₱100,000+)

A customer must meet all three High Value thresholds simultaneously; otherwise, they're classified Dormant (if inactive beyond 180 days) or Regular.

<<<<<<< HEAD
`[ SCREENSHOT: Page 2 — Customer Segmentation ]`

**Notable finding:** the segmentation logic is frequency-gated — a customer with very high total revenue but low transaction frequency (i.e., a small number of very large transactions) can be classified as "Regular" rather than "High Value," since the frequency threshold isn't met even though the monetary threshold is far exceeded. This suggests the current thresholds may undervalue infrequent, high-spend customers, and is worth revisiting with adjusted or weighted criteria in a future iteration.

**Why it matters:** a segmentation model is only useful if it points the business at the right people. A "whale" customer misfiled as merely Regular is a customer who might get a generic retention email instead of the white-glove attention their spend actually warrants — this is a segmentation design flaw with a direct commercial cost, not just a labeling quirk.

### 3. Fraud Pattern Detection

**The headline:** Confirmed fraud transactions averaged ₱1,277.87, roughly 75% higher than confirmed non-fraud transactions (₱729.32) — supporting a real link between transaction size and fraud risk. But the single largest and most extreme transactions in the entire dataset were *not* fraud-flagged at all, sitting instead in the "not fraud" and "unknown" groups. This means amount size alone is a weak predictor on its own — the most extreme values likely reflect data anomalies rather than confirmed fraud, and fraud itself tends to cluster in a moderately elevated (not extreme) amount range.

`[ SCREENSHOT: Page 3 — Fraud Pattern Detection ]`

**Key limitation:** approximately 23% of transactions had no recorded fraud status (`'Unknown'`). All fraud rate percentages are calculated relative to the full transaction count, meaning true fraud rates among transactions with a *known* status may differ from the reported figures. This is flagged as a data completeness gap rather than resolved by assumption.

**Why it matters:** fraud that hides in the "unknown" 23% is fraud the business can't currently price into its risk model. The pattern found in the *known* 77% is still directionally useful, but the honest conclusion is that a fifth of the picture is missing — worth surfacing to whoever owns fraud review before this analysis is treated as complete.

=======
*[Insert dashboard screenshot + specific findings: segment counts, average RFM values per segment]*

**Notable finding:** the segmentation logic is frequency-gated — a customer with very high total revenue but low transaction frequency (i.e., a small number of very large transactions) can be classified as "Regular" rather than "High Value," since the frequency threshold isn't met even though the monetary threshold is far exceeded. This suggests the current thresholds may undervalue infrequent, high-spend customers, and is worth revisiting with adjusted or weighted criteria in a future iteration.

### 3. Fraud Pattern Detection

Fraud patterns were examined across three dimensions: transaction amount (average/min/max by fraud status), payment method (fraud rate per method), and country (fraud rate per country).

*[Insert dashboard screenshot + specific findings: fraud rate leaders by payment method/country, amount comparison]*

**Key limitation:** approximately 23% of transactions had no recorded fraud status (`'Unknown'`). All fraud rate percentages are calculated relative to the full transaction count, meaning true fraud rates among transactions with a *known* status may differ from the reported figures. This is flagged as a data completeness gap rather than resolved by assumption.

>>>>>>> bb17ca79013126d8e9320c728f1954a5db93bb2d
### 4. Payment Method & Channel Trends

Payment methods were grouped into three channels — **E-Wallet** (GCash, PayMaya, generic e-wallet), **Card** (credit/debit), and **Bank Transfer** — and tracked by transaction count over time and by country.

<<<<<<< HEAD
`[ SCREENSHOT: Page 4 — Payment Method & Channel Trends ]`

**Note:** GCash, PayMaya, and a generic "E-Wallet" label were initially separate values in the raw data — these were consolidated into one E-Wallet channel so the trend reflects the category as a whole, not individual apps competing against each other in the same chart.

**Why it matters:** payment channel isn't just a UX preference — it's where fraud controls, transaction fees, and settlement speed all differ. A channel gaining share needs proportionally more attention across all three, not just more marketing.

---

## Putting It Together

Four questions, one dataset, and a consistent thread running underneath all of them: **the gap between what the raw numbers show and what's actually true is often where the real insight lives.** A refund ratio only means something once currencies are normalized. A "High Value" label only means something once the thresholds are examined for who they accidentally exclude. A fraud rate only means something once you know how much of the picture is missing. A channel trend only matters if the business is prepared to support where volume is actually heading.

None of these four findings exist in isolation — together, they sketch a platform that's generating real revenue, but with real, specific, fixable leaks: refunds concentrated in a few categories, high-value customers at risk of being misclassified or lost to dormancy, a fraud signal that's only 77% visible, and a payment mix shifting faster than support/fraud infrastructure may be built for. That's the actual value of this kind of analysis — not just answering four questions, but surfacing where a business should look next.
=======
*[Insert dashboard screenshot + specific findings: channel shift over time, country-level differences]*
>>>>>>> bb17ca79013126d8e9320c728f1954a5db93bb2d

---

## Dashboard Structure

The Power BI report is organized into pages by business question:
- **Page 1:** Revenue & Refunds — monthly trend, refund ratio by category
- **Page 2:** Customer Segmentation — segment distribution, RFM averages by segment, top customers
- **Page 3:** Fraud Pattern Detection — fraud rate by amount, payment method, country
- **Page 4:** Payment Method & Channel Trends — channel usage over time and by country

---

<<<<<<< HEAD
## Recommendations

Based on the findings above, the following actions are suggested:

**1. Revenue & Refund Leakage**
- Prioritize investigation into the merchant category(ies) with the highest refund-to-purchase ratio — a disproportionately high refund rate in one category may point to a product quality issue, a merchant-side problem, or a policy gap worth addressing before it affects more customers.
- Since a small number of extreme-value transactions can distort monthly revenue figures, consider adding an automated flag for transactions beyond a certain size threshold, so they can be reviewed before being included in standard revenue reporting.

**2. Customer Segmentation**
- Revisit the High Value threshold criteria to avoid misclassifying high-spend, low-frequency customers as "Regular." A weighted scoring approach (e.g., treating a very high monetary score as sufficient on its own, rather than requiring all three RFM thresholds simultaneously) may better capture "whale" customers who transact rarely but at high value.
- Dormant customers (identified as inactive 180+ days) represent a re-engagement opportunity — a targeted win-back campaign (promotions, personalized outreach) could recover a portion of this segment before they churn entirely.

**3. Fraud Pattern Detection**
- Address the ~23% of transactions with no recorded fraud status — this is a data collection or system-integration gap, not something to fix through analysis alone. Recommend flagging this to whoever owns the fraud review process/source system, since a reliable fraud rate calculation depends on more complete status coverage.
- Where fraud rate is shown to correlate more strongly with specific payment methods or countries, consider applying additional verification steps (e.g., step-up authentication) selectively to those higher-risk channels, rather than uniformly across all transactions.

**4. Payment Method & Channel Trends**
- If e-wallet usage is trending upward relative to cards/bank transfer, prioritize product and support investment (UX improvements, customer support coverage, fraud controls) toward that channel to match where transaction volume is actually shifting.
- Where channel usage varies meaningfully by country, consider tailoring payment method availability/promotion by market rather than offering a uniform set of options everywhere.

**General recommendation:** Several findings in this project were limited by data completeness (missing fraud status, ambiguous outlier transactions, independently-generated currency/country fields). Improving data capture at the source — particularly around fraud determination and transaction currency logic — would meaningfully increase confidence in future analysis built on this data.

---

=======
>>>>>>> bb17ca79013126d8e9320c728f1954a5db93bb2d
## Key Assumptions & Limitations

- Exchange rates used for currency conversion are fixed, illustrative values, not real-time or transaction-date-accurate rates.
- The currency-follows-country logic (used only where currency was missing) is an assumption based on typical real-world behavior, not a pattern verified within this specific dataset, since country and currency were generated independently.
- Duplicate transaction_id conflicts were resolved by keeping the earliest record; this is an arbitrary tie-break, not a verified correction.
- Fraud rate calculations include transactions with unknown fraud status in the denominator; interpret percentages with this in mind.
- One large outlier transaction (₱304,232) was investigated individually and found inconclusive as to whether it represents a data error or a legitimate/fraudulent transaction — flagged for review rather than resolved.
