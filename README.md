# FINTECH DATA ANALYSIS

I. Introduction
Financial technology companies process thousands of digital transactions every day. Hidden within these tranascations are patterns that can help businesses understand customer behavior, identify potential risks, and monitor payment activity to make better business decisions. However, these insights are only valuable if the underlying data is accurate and well prepared.

This project began with a simple question: What can a fintech transaction dataset reveal once it has been cleaned and analyzed? To answer this, I challenged myself to only use SQL in order to clean and standardize the dataset containing digital financial transactions before analyzing and making a report out of it on Power BI. The cleaning process addresses inconsistencies such as mixed date formats, unformatted country names, duplicate transaction records, missing values, and multiple currencies to create a reliable foundation for the analysis.

II. Business Questions
1.) What's net revenue by month and the total revenue vs refund of merchant categories?
2.) Which customers are high-value vs. dormant (RFM: recency, frequency, monetary)
3.) What transaction characteristics (amount size, payment method, country) correlate with flagged fraud, once fraud_flag is standardized?
4.) How has e-wallet usage shifted vs. cards/bank transfer over time, and does it vary by country?

III. Data Cleaning Process

**1.) Uploading the dataset**
I started by importing a messy fintech transaction dataset. I first used a little python in order to scout the columns and ended the whole python process there. I went back to SQL and created the tables with only VARCHAR datatypes in order for it to be uploaded smoothly into SQL.

<img width="457" height="493" alt="image" src="https://github.com/user-attachments/assets/f26cfd83-1770-4d6f-87b6-66a6a1befefa" />

This makes it so the messy data won't interfere with the uploading process. To then upload the dataset to SQL, I placed the CSV file into the program data file of MySQL and used LOAD DATA LOCAL INFILE to upload the dataset. 

<img width="958" height="246" alt="image" src="https://github.com/user-attachments/assets/66deeddf-fe1e-4220-9556-d7a347dbfbdd" />

**2.) Keeping the Original Raw Data **
Since I have no prior experience to analysis, I used my knowledge from mentors online to decide how I want to proceed. I initially decided on cleaning the table by updating the raw data itself, but I scrapped that and created a new table to work with and do it from there since we want to keep the original raw data as I was told that in the real workplace, it is a standard practice
<img width="870" height="317" alt="image" src="https://github.com/user-attachments/assets/2afb972c-3c3a-4344-a05a-90f5cc2b34bb" />

**3.) Cleaning **
I started by cleaning the table from left to right columns. 
According to what I saw by checking the missing values, transaction ID and customer IDs had none, so I selected their columns as is. 
