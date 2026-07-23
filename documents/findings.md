📈 Key Findings
This document summarizes insights uncovered through the exploratory and advanced analysis scripts in `scripts/exploratory/` and `scripts/analysis/`. Fill in the `\[ ]` placeholders with your actual query results.
---
Overview
Reporting period: `\[2010-12-29]` to `\[2014-01-28]` (`\[37]` months)
Total sales: `\[29356250]`
Total orders: `\[27659]`
Total customers: `\[18484]`
Total products: `\[total products]`
Average selling price: `\[295]`
---
1. Change Over Time
From: `scripts/analysis/dw_ada.sql` — Section 1
Sales trend by month/year: `\[e.g. steady growth, seasonal spikes in Q4, etc.]`
Customer acquisition trend: `\[e.g. new customers per month growing/flat/declining]`
2. Cumulative Trends
From: Section 2 — running total & moving average
Running total sales trajectory: `\[e.g. consistent growth, plateaued after month X]`
Moving average price trend: `\[e.g. average selling price rising/falling over time]`
3. Product Performance (Year-over-Year)
From: Section 3
Products consistently above average: `\[list]`
Products consistently below average: `\[list]`
Biggest YoY increase: `\[product] (+\[amount])`
Biggest YoY decrease: `\[product] (-\[amount])`
4. Category Contribution (Part-to-Whole)
From: Section 4
Category	Total Sales	% of Total
`\[category]`	`\[amount]`	`\[%]`
`\[category]`	`\[amount]`	`\[%]`
`\[category]`	`\[amount]`	`\[%]`
Takeaway: `\[e.g. top 2 categories account for X% of total revenue]`
5. Product Cost Segmentation
From: Section 5
Cost Range	# of Products
Below 100	`\[count]`
100–500	`\[count]`
500–1000	`\[count]`
Above 1000	`\[count]`
6. Customer Segmentation (VIP / Regular / New)
From: Section 5 (customer tiers)
Tier	# of Customers	% of Total
VIP	`\[count]`	`\[%]`
Regular	`\[count]`	`\[%]`
New	`\[count]`	`\[%]`
Takeaway: `\[e.g. VIP customers make up X% of the base but drive Y% of revenue]`
7. Top & Bottom Performers
From: `scripts/exploratory/exploratory\_analysis.sql` — Ranking Analysis
Top 5 products by revenue:
`\[product]` — `\[amount]`
`\[product]` — `\[amount]`
`\[product]` — `\[amount]`
`\[product]` — `\[amount]`
`\[product]` — `\[amount]`
Bottom 5 products by revenue:
`\[product]` — `\[amount]`
`\[product]` — `\[amount]`
`\[product]` — `\[amount]`
`\[product]` — `\[amount]`
`\[product]` — `\[amount]`
Top 10 customers by revenue: `\[summary or list]`
3 customers with fewest orders: `\[summary or list]`
8. Geographic & Demographic Distribution
From: Magnitude Analysis
Top countries by customer count: `\[list]`
Top countries by items sold: `\[list]`
Gender distribution: `\[e.g. split between Male/Female/n-a]`
---
Summary
`\[2-3 sentence takeaway pulling together the most important pattern(s) found across the analysis — e.g. which segment or category is most valuable, and what that might suggest for a business decision.]`
