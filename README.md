# **FINTECH DATA ANALYSIS**

# **I. Introduction**
Financial technology companies process thousands of digital transactions every day. Hidden within these tranascations are patterns that can help businesses understand customer behavior, identify potential risks, and monitor payment activity to make better business decisions. However, these insights are only valuable if the underlying data is accurate and well prepared. \n

This project began with a simple question: What can a fintech transaction dataset reveal once it has been cleaned and analyzed? To answer this, I challenged myself to only use SQL in order to clean and standardize the dataset containing digital financial transactions before analyzing and making a report out of it on Power BI. The cleaning process addresses inconsistencies such as mixed date formats, unformatted country names, duplicate transaction records, missing values, and multiple currencies to create a reliable foundation for the analysis.

# **II. Business Questions**

1.) What's net revenue by month and the total revenue vs refund of merchant categories?
2.) Which customers are high-value vs. dormant (RFM: recency, frequency, monetary)
3.) What transaction characteristics (amount size, payment method, country) correlate with flagged fraud, once fraud_flag is standardized?
4.) How has e-wallet usage shifted vs. cards/bank transfer over time, and does it vary by country?

# **III. Data Cleaning Process**

**1.) Uploading the dataset**

I started by importing a messy fintech transaction dataset. I first used a little python in order to scout the columns and ended the whole python process there. I went back to SQL and created the tables with only VARCHAR datatypes in order for it to be uploaded smoothly into SQL.

<img width="457" height="493" alt="image" src="https://github.com/user-attachments/assets/f26cfd83-1770-4d6f-87b6-66a6a1befefa" />

This makes it so the messy data won't interfere with the uploading process. To then upload the dataset to SQL, I placed the CSV file into the program data file of MySQL and used LOAD DATA LOCAL INFILE to upload the dataset. 

<img width="958" height="246" alt="image" src="https://github.com/user-attachments/assets/66deeddf-fe1e-4220-9556-d7a347dbfbdd" />

**2.) Keeping the Original Raw Data**

Since I have no prior experience to analysis, I used my knowledge from mentors online to decide how I want to proceed. I initially decided on cleaning the table by updating the raw data itself, but I scrapped that and created a new table to work with and do it from there since we want to keep the original raw data as I was told that in the real workplace, it is a standard practice
<img width="870" height="317" alt="image" src="https://github.com/user-attachments/assets/2afb972c-3c3a-4344-a05a-90f5cc2b34bb" />

**3.) Cleaning**

**a.) Identification Columns**
I started by cleaning the table from left to right columns. 
According to what I saw by checking the missing values, transaction ID and customer IDs had none, so I selected their columns as is.

**b.) Customer Names**

<img width="136" height="136" alt="image" src="https://github.com/user-attachments/assets/1144701f-9638-48a8-aef2-9cacf6eb7066" />

I noticed that the customer names were joined together as one. I decided that since if I work in a real company, they might need these names sorted by either only first or last name so I standardized this by making a separate column for first and last names

<img width="467" height="53" alt="image" src="https://github.com/user-attachments/assets/3ae6c18b-e728-4d52-8279-fdf13534388a" />

**c.) Transaction and Signup Dates**

<img width="217" height="153" alt="image" src="https://github.com/user-attachments/assets/e0c419c3-107f-4f68-880f-b5bee10f9aaa" />
<img width="833" height="186" alt="image" src="https://github.com/user-attachments/assets/a7c3f62a-f4fb-41a4-ac90-1129e19e23e2" />

It can be seen from the first few columns that the dates have no format whatsoever, since the months and years are crucial to be separated for the data later on, I first fixed the whole date format by using STR_TO_DATE with 1 line per each date format since there are different types of date within the messy data

<img width="1026" height="231" alt="image" src="https://github.com/user-attachments/assets/57c8b0fe-0853-4c86-a3ed-05c8d2779658" />

I then created separate columns for year, months, and days by doing the same thing, just specified for the columns to be made

<img width="890" height="467" alt="image" src="https://github.com/user-attachments/assets/e0bbdc38-2647-4c8e-b48e-f63609953021" />
<img width="906" height="236" alt="image" src="https://github.com/user-attachments/assets/9b58b70b-2edb-4017-a933-410af3e788cf" />

<img width="823" height="455" alt="image" src="https://github.com/user-attachments/assets/988940de-f4b5-4685-9cd7-90c04f75d734" />
<img width="837" height="226" alt="image" src="https://github.com/user-attachments/assets/34aa3977-a3ed-4bbd-9684-e9d92b453929" />

**d.) Amount and Country**

<img width="72" height="136" alt="image" src="https://github.com/user-attachments/assets/6a788dda-f7b6-4b77-bca2-b55a4321346d" />

SELECT DISTINCT comes into play here by checking categories. I didnt go with TRIM(column_name) in order to see if there are similar variations of one country. Before that, I checked the amount format and it shows a messy format with peso signs and even an N/A cell for missing values so to clean it, I deleted the currency sign, the columns, and the N/A to keep the missing values as null so it doesn't mess up the numbers column.

<img width="707" height="40" alt="image" src="https://github.com/user-attachments/assets/0cfce63b-5931-433a-b9c6-25ced623863d" />

By selecting distinct currencies, we can see that it shows distinct variations of one currency when selected

<img width="103" height="263" alt="image" src="https://github.com/user-attachments/assets/9cad3c42-67d3-465e-84cf-fe35b00f0d02" />

So I cleaned it by standardizing and making one single format of currency with its matching currency

**e.) Transaction type, merchant category, and payment method, etc**

I used the same format as the currency in order to clean the columns that only needed a fill for empty cells or trimming.

<img width="572" height="397" alt="image" src="https://github.com/user-attachments/assets/91662843-0fde-466a-abbb-d248ac73badc" />

Initially in the dataset, I didn't realize that Gcash and PayMaya should have been condensed into E-Wallet, so this came later on.

<img width="497" height="342" alt="image" src="https://github.com/user-attachments/assets/62620679-5fa6-47d5-996d-453d37d34d87" />

**c.) Fraud Flag**

I checked the distinct fraud flag categories, with initially 0 as Not fraud and 1 being the fraud transactions.

<img width="410" height="370" alt="image" src="https://github.com/user-attachments/assets/e1f58e2f-2134-47e0-85a9-d5bfecd9ea4d" />

There were values showing FALSE/No and TRUE/Yes, which I ultimately condensed into either 1s or 0s only

<img width="397" height="107" alt="image" src="https://github.com/user-attachments/assets/52d4d300-808e-4ff1-b834-4fa8edc3ddaf" />

**d.) Removing Duplicates**
I also forgot to remove duplicates here so I did it after the previous clean table was created

<img width="620" height="153" alt="image" src="https://github.com/user-attachments/assets/cf1567be-305e-4b88-a7e0-7d4f33c6cb4a" />

**e.) Condensing amount into one currency**

Later on in my analysis, I also realized that it is impossible to come up with a joint total revenue and total refund amount if all the currencies combine into one. Considering the exchange rates, I decided to convert all into PHP for a more standardized data.

<img width="746" height="313" alt="image" src="https://github.com/user-attachments/assets/0bc16f01-9621-42e8-b50d-92050b42ba33" />

I did this by creating a new column for the converted amount and miltiplying the original amount by its modern conversion rate into PHP.

# ** IV. Business Question Queries**

**1.) What's net revenue by month and the total revenue vs refund of merchant categories?**

 <img width="902" height="515" alt="image" src="https://github.com/user-attachments/assets/4597b0bf-4e5c-449b-8595-6c194903c98e" />
 <img width="1163" height="648" alt="image" src="https://github.com/user-attachments/assets/b2e442ad-4c04-4878-a049-b0d4a84febef" />
 <img width="1153" height="648" alt="image" src="https://github.com/user-attachments/assets/12db96b2-6049-423f-a794-74eec8d6ee64" />
 <img width="1166" height="648" alt="image" src="https://github.com/user-attachments/assets/e7f0bc0b-74a7-4d86-ac2c-9b7d422f67c2" />
 <img width="1163" height="652" alt="image" src="https://github.com/user-attachments/assets/91768598-d004-462c-9a6e-e053f42ad03e" />


 I selected the month, year, and the merchant category along with total revenues and refunds and grouped them along.

 **2.) Which customers are high-value vs. dormant (RFM: recency, frequency, monetary)**

 <img width="1231" height="423" alt="image" src="https://github.com/user-attachments/assets/e4baffe8-60fa-4643-bf60-14f88c060ba3" />

Since the dataset did not come with factors such as identifying these 3 cases, I took it upon myself to give a sample threshold for how to identify customers who are either high value, dormant, or regular.

**Regulars:** customers who are active but haven't passed the 100k transaction in php and more than 10 transactions

**Dormat:** customers who are inactive for more than 180 days regardless of amount transacted

**High Value:** customers who have been actively transacting for not less more than 30 days, have made 10 transactions or more, and have passed the 100k PHP amount in total transactions.

**3.) What transaction characteristics (amount size, payment method, country) correlate with flagged fraud, once fraud_flag is standardized?**

I queried the amount by size and took the average of all types of transactions.

<img width="501" height="373" alt="image" src="https://github.com/user-attachments/assets/da5a0173-7505-4213-b8be-b2e79f7be926" />

I then queried the payment methods by gathering how many fraud amounts and total transactions exist per payment method, along with taking the average percentage of fraud counts per payment method.

<img width="1032" height="477" alt="image" src="https://github.com/user-attachments/assets/32bcb144-fc0a-44a4-b82b-0602c1c682ce" />

Lastly, I took the country query by using the same method as payment.

<img width="1046" height="497" alt="image" src="https://github.com/user-attachments/assets/44ac904f-7223-429f-ba85-c39a0d486106" />


**4.) How has e-wallet usage shifted vs. cards/bank transfer over time, and does it vary by country?**

In order to decide if usage has shifted throughout the years, I took the transaction year and month per payment channel and included the origin country for each transaction made in order to verify if it varies per country
<img width="900" height="525" alt="image" src="https://github.com/user-attachments/assets/e587cfc4-de63-425a-9040-4c86e01a4da4" />

# ** V. Findings**

**1.) What's net revenue by month and the total revenue vs refund of merchant categories?**

The net revenue per month merchant category has an average of 234.45k
<img width="332" height="197" alt="image" src="https://github.com/user-attachments/assets/d258d118-6a04-4967-93e3-2f4dfc4e8184" />

The The total revenue counting per merchant category comes at a total of 178.86 Million PHP in total all while the total refunds come at a 66.06M cost.

<img width="1168" height="657" alt="image" src="https://github.com/user-attachments/assets/b9e3f580-f0da-4a25-8f19-4063389ca80f" />

**2.) Which customers are high-value vs. dormant (RFM: recency, frequency, monetary)**

**Regulars:** customers who are active but haven't passed the 100k transaction in php and more than 10 transactions

**Dormat:** customers who are inactive for more than 180 days regardless of amount transacted

**High Value:** customers who have been actively transacting for not less more than 30 days, have made 10 transactions or more, and have passed the 100k PHP amount in total transactions.

**RECENCY**

According to the data, dormant customers have an average of 387 days of inactivity while high value customers usually transact within 73 days. 

<img width="412" height="308" alt="image" src="https://github.com/user-attachments/assets/ccacb809-138f-436d-8919-c89b5b441bb3" />

**FREQUENCY**

High value customers are proven to have more than 10 transactions while dormant customers only average below 6.

<img width="402" height="311" alt="image" src="https://github.com/user-attachments/assets/47485365-c86a-403c-b43d-7f8113239546" />

**MONETARY**

The average revenue from high value customers come at around 430k, which is significantly higher than those who are inactive only averaging 175k.

<img width="410" height="338" alt="image" src="https://github.com/user-attachments/assets/7a6e5505-6a08-4239-baa7-05079cd08e2b" />

It is also important to note that there are only 73 (8.12%) high value customers while majority (485, 53.95%) make up the regulars. The volume of dormant users consume a 37.93% of the customer population which is not a good look for the company as it makes up around a third of the customer base.

<img width="392" height="337" alt="image" src="https://github.com/user-attachments/assets/98984b6d-f495-49b4-982d-48fdfda43e3f" />


Dashboard:

<img width="1178" height="663" alt="image" src="https://github.com/user-attachments/assets/0573541a-8907-4581-91f1-14de99192c8e" />

**3.) What transaction characteristics (amount size, payment method, country) correlate with flagged fraud, once fraud_flag is standardized?**

**AMOUNT SIZE**

The average fraud amount transacted is at 30.5k PHP, having the highest average among unknown and non fraud transactions. The second being unknown, and lowest average being the non fraud transactions.

<img width="635" height="251" alt="image" src="https://github.com/user-attachments/assets/873f6e55-21c0-4078-be01-c0e89ca9d56d" />

**PAYMENT METHOD**

It was found that users who transact with cash have the most amount of fraud transaction percentage, with the lowest being bank transfers.

<img width="573" height="217" alt="image" src="https://github.com/user-attachments/assets/4e1e4f28-175f-4122-93c3-e6475bbec612" />

**COUNTRY**

The country with the highest fraud transactions is the United States and coming in second, not falling far behind is Japan.

<img width="572" height="198" alt="image" src="https://github.com/user-attachments/assets/311fe8c7-167b-4625-87aa-4fe89af6e40d" />

**4.) How has e-wallet usage shifted vs. cards over time, and does it vary by country?**

<img width="1155" height="648" alt="image" src="https://github.com/user-attachments/assets/11224773-b88f-4fcd-a207-575f7a0d85a6" />


For the years 2023, 2024, and 2025, E wallet usage has never seen more usage than card overall, but it does vary per country. 

Lets take a look at the years 2023 and 2024

<img width="1155" height="323" alt="image" src="https://github.com/user-attachments/assets/f531fa44-15d0-46c7-91aa-9015b67539b8" />

In 2023 and 2024, E wallet has seen a decline in usage compared to card in Japan similar to the Philippines and Singapore. The only country where E wallet has thrived better than its previous year is Singapore. That being said, not a single country managed to surpass card usage by e wallet during those years.

<img width="1142" height="312" alt="image" src="https://github.com/user-attachments/assets/53af464c-cc89-46c0-a9f7-59f851a3e75f" />

In 2025, only Japan managed to have more e wallet usage than card as the rest of the countries still have more card usage overall than e wallet. Similarly in 2026, only one country which is the Philippines has more e wallet usage than card, but if we look at the first half of 2026, we can see a massive difference on their usage with Philippines scoring over 30 more than card. 

Overall, E-Wallet still has not seen more average use than Card, but it varies by country as seen with Japan and the Philippines' usage overtime.

**V. Recommendations**

- 
