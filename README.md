# Starbucks-Customer-Engagement-Analysis

---

#### Project Overview

The **Starbucks Customer Engagement Analysis** project aims to analyze customer demographics and interactions with marketing offers to derive actionable insights. By examining the customer data, we aim to uncover patterns in customer behavior, preferences, and demographics that can inform Starbucks' marketing strategies. The project utilizes SQL-based data cleaning, transformation, and analysis techniques to process three key datasets: Portfolio, Profile, and Transcript.

#### Datasets

1. **Portfolio Data (`portfolio_raw`)**
   - Contains details about marketing offers such as offer type, reward, difficulty, duration, and delivery channels.
   
2. **Profile Data (`profile`)**
   - Provides customer demographic information, including age, gender, income, and membership details.

3. **Transcript Data (`transcript_raw`)**
   - Tracks customer interactions with marketing offers, recording events like offer received, offer viewed, offer completed, and transactional amounts.

#### Data Processing Steps

1. **Portfolio Data Transformation**
   - **Channel Extraction**: Decomposed the `channels` JSON array into individual binary columns (`channel_web`, `channel_email`, `channel_mobile`, `channel_social`).
   - **Offer Type Standardization**: Cleaned the `offer_type` column by trimming whitespace and converting text to uppercase.
   - **Table Creation**: Created the `portfolio_proc` table, which includes cleaned and processed data ready for analysis.

2. **Profile Data Transformation**
   - **Gender Normalization**: Standardized gender entries, replacing invalid values with 'U' for Unknown.
   - **Date Conversion**: Converted the `became_member_on` column to `DATE` format and derived a new `become_member_year` column.
   - **Income Cleaning**: Transformed the `income` column to replace empty strings with `NULL` and converted the data to a numerical format.
   - **Outlier Removal**: Excluded customers aged 118 as they provided no valuable data.
   - **Table Creation**: Created the `profile_proc` table with cleaned demographic data.

3. **Transcript Data Transformation**
   - **JSON Unpacking**: Extracted relevant fields from the `value` column, such as `offer_id`, `amount`, and `reward`, and converted them into individual columns.
   - **Datetime Conversion**: Converted the `time` column (hours since membership) into a `DATETIME` format by referencing the membership date from the `profile_proc` table.
   - **Table Creation**: Created the `transcript_proc` table to facilitate customer behavior analysis.

#### Data Analysis

1. **Demographic Analysis**
   - **Gender Distribution**: Analyzed the percentage distribution of genders among the customer base.
   - **Age Distribution**: Grouped customers into age brackets and analyzed their distribution.
   - **Income Distribution**: Categorized customers into income groups and analyzed their distribution.

2. **Offer Analysis**
   - **Offer Type Distribution**: Analyzed the distribution of offers across different types (BOGO, Discount) and examined the most challenging offers based on difficulty and reward.
   - **Customer Engagement**: Analyzed the percentage of customers who completed the entire offer journey (offer received, viewed, completed) and examined the demographics of these engaged customers.

3. **Event Analysis**
   - **Customer Journey Tracking**: Aggregated events to track customer interactions with offers and identified customers who experienced the full offer process.
   - **Offer Completion Rates**: Analyzed which types of offers had the highest completion rates and examined the demographics of customers more likely to complete offers.

#### Project Structure

- **SQL Scripts**: Contains SQL queries used for data cleaning, transformation, and analysis.
- **Processed Tables**: Includes the processed tables (`portfolio_proc`, `profile_proc`, `transcript_proc`) that were used for analysis.

#### How to Run the Project

1. **Set Up the Environment**:
   - Install a SQL database and load the raw datasets (`portfolio_raw`, `profile`, `transcript_raw`).
   - Execute the SQL scripts provided to create the processed tables.

2. **Run the Analysis**:
   - Use the SQL scripts provided to perform demographic and behavioral analyses.

3. **Explore the Results**:
   - Review the results from the analysis scripts to gain insights into customer demographics and behaviors.

#### Conclusion

The **Starbucks Customer Engagement Analysis** project provides a comprehensive understanding of Starbucks customers' demographics, behaviors, and responses to marketing offers. Through detailed data processing and analysis, this project offers valuable insights that can help optimize marketing strategies and improve customer engagement.

---
