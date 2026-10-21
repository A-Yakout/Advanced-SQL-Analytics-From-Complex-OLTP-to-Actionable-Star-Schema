# AdventureWorks Advanced SQL Analytics: From Complex OLTP to Actionable Star Schema

This project demonstrates an end-to-end data engineering and analytics lifecycle. It extracts data from a highly normalized, complex operational database (OLTP) comprising over 60 tables and restructures it into a highly optimized Star Schema model for analytical reporting. The project heavily leverages advanced SQL capabilities to perform Exploratory Data Analysis (EDA), build complex analytical KPIs, and encapsulate business logic within SQL Views for seamless consumption by Business Intelligence tools like Power BI.

## 🛠️ Key Project Features

### 1. Exploratory Data Analysis (EDA)

A comprehensive examination of the database was conducted to understand table relationships and establish foundational metrics:

* **Dimension Exploration:** Mapped out product hierarchies (Categories and Sub-categories), geographical customer distribution, and sales force capacity.


* **Magnitude & Ranking Analysis:** Identified the top 5 highest-grossing products and the top 5 countries by units sold to guide targeted marketing decisions.


* **Measures Exploration:** Generated an aggregated summary reporting total sales revenue, order volumes, total quantity sold, and average unit prices.



### 2. Advanced Analytics

Advanced Window Functions and Common Table Expressions (CTEs) were utilized to extract deep, actionable insights:

* **Time-Intelligence & Cumulative Analysis:** Calculated running totals for sales across sequential months and reset them yearly for cumulative performance tracking.


* **Performance Analysis:** Conducted Year-Over-Year (YoY) growth tracking to flag increasing or decreasing trends, and compared individual product sales against their historical averages to classify performance as 'Above' or 'Below' average.


* **Part-to-Whole Analysis:** Determined the exact percentage each product category contributes to the company's overall revenue.


* **Data Segmentation:** Segmented the customer base into 'VIP', 'Regular', and 'New' cohorts based on their Lifetime Value (spending above or below $5000) and retention lifespan (greater or less than 12 months).



### 3. Automated Reporting via SQL Views

Rather than shifting the heavy computational lifting to the BI visualization layer, robust analytical reports were engineered directly within the database:

* **Product Report View:** Evaluates individual product performance by calculating sales recency, total lifespan, and average monthly revenue, culminating in an automated segmentation logic (High-Performer, Mid-Range, Low-Performer).


* **Customer Report View:** A comprehensive customer 360-degree view that tracks purchasing recency, lifespan loyalty, Average Order Value (AOV), and average monthly spend per customer.



## 💡 Architectural Vision: Why Encapsulate Logic in SQL Views?

A primary objective of this project is to demonstrate the strategic advantage of pushing heavy transformations and business logic down to the database layer via SQL Views, rather than relying exclusively on BI tools (like Power BI's DAX or Power Query). This architecture provides three critical advantages for a data team:

1. **Single Source of Truth:** Centralizing the logic in SQL ensures that metrics are calculated identically regardless of the downstream tool. If a Python script, a Tableau dashboard, and a Power BI report all connect to the same View, the definition of a "VIP Customer" remains perfectly consistent.


2. **Performance Optimization:** Relational databases are specifically engineered for heavy joins and aggregations. Performing these transformations at the SQL level reduces the processing burden on the BI tool, resulting in significantly faster dashboard loading times.
3. **Tool Agnosticism:** By preparing the Star Schema and analytical Views directly in SQL, the data model becomes universally accessible. The business is not locked into a single BI vendor and can seamlessly integrate the data into any analytical platform.
