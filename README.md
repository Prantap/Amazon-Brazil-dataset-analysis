# Amazon-Brazil-dataset-analysis
This is a dataset from Amazon Brazil's data to identify trends, customer behaviours, and preferences that could be leveraged in the Indian market. This analysis will help Amazon India make informed decisions, enhance customer experience, and seize new opportunities.

Overview of the Schema
The schema consists of seven interconnected tables that provide insights into the operations of Amazon Brazil:

- Customers: Holds customer information, including unique identifiers and locations, to study customer demographics and behavior.
- Orders: Captures details about each order, such as order status and timestamps, essential for tracking the order lifecycle.
- Order Items: Lists each item in an order with details like price, seller, and shipping information.
- Product: Contains product specifications, such as category, size, and weight, for product-level analysis.
- Seller: Provides data about sellers, including their location and unique identifiers, to evaluate seller performance.
- Payments: Records transaction details, such as payment type and value, to understand payment preferences and financial performance.


Analysis I – Foundational SQL Insights
The first stage of the analysis focuses on data exploration and aggregation techniques to understand payment patterns, product pricing, and sales distribution.

Key tasks performed in this section include:

- Standardizing financial reporting by calculating the average payment value for each payment type and rounding the values for simplified reporting.
- Analyzing payment method distribution by calculating the percentage of total orders attributed to each payment type.
- Identifying products within a specific price range that contain the keyword “Smart” in their product name, helping highlight potentially targeted promotional items.
- Detecting seasonal sales performance by identifying the months with the highest total sales values.
- Examining product pricing variability by identifying categories with significant differences between minimum and maximum prices.
- Assessing payment stability by determining which payment methods show the most consistent transaction amounts using statistical variance measures.
- Detecting potential data quality issues in product records, particularly cases where product category names are missing or incomplete.

Analysis II – Customer and Revenue Insights
The second stage of the project focuses on customer behavior and product category performance, using joins and segmentation techniques.

This section includes analyses such as:
- Segmenting orders into different value ranges (low, medium, and high) and evaluating the popularity of payment methods across these segments.
- Analyzing product categories to determine minimum, maximum, and average pricing levels, helping understand price positioning across categories.
- Identifying customers who have placed multiple orders, which helps highlight repeat purchasing behavior.
- Creating customer purchase segments (New, Returning, and Loyal customers) based on order frequency using temporary tables.
- Evaluating revenue contribution by product category through table joins to identify the top-performing categories.

Analysis III – Advanced Sales and Customer Analytics
The final section focuses on advanced SQL techniques, including subqueries, CTEs, and window functions to uncover deeper business insights.

Key analyses performed include:
- Evaluating seasonal sales performance by grouping order data into seasonal segments (Spring, Summer, Autumn, Winter) based on purchase dates.
- Identifying products whose total quantity sold exceeds the overall average, helping detect high-performing products.
- Analyzing monthly revenue trends for the year 2018 to identify periods of peak and low sales activity and visualizing the trend using Excel.
- Developing a customer loyalty segmentation model using CTEs to classify customers into Occasional, Regular, and Loyal groups based on purchase frequency.
- Ranking customers according to average order value to identify the top 20 high-value customers for potential rewards programs.
- Calculating monthly cumulative sales for each product using recursive CTEs to understand long-term sales performance.
- Evaluating month-over-month sales growth for each payment method to understand how payment preferences influence revenue trends.
