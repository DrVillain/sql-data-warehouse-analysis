# 📈 Key Findings

This document summarizes insights uncovered through the exploratory and advanced analysis scripts in `scripts/exploratory/` and `scripts/analysis/`.

---

## Overview

- **Reporting period:** 2010-12-29 to 2014-01-28 (37 months)
- **Total sales:** 29,356,250
- **Total orders:** 27,659
- **Total customers:** 18,484
- **Total products:** 295
- **Average selling price:** 486

---

## 1. Change Over Time

*From: `scripts/analysis/advanced_analysis.sql` — Section 1*

- Sales trend by month/year: Sales started small in late 2010 (43,419 in the first partial month) and grew steadily through 2011–2012, generally ranging between 350,000–740,000/month. Growth accelerated sharply starting in 2013, with monthly sales climbing past 1,000,000 by March 2013 and reaching 1,780,000–1,874,000 by late 2013 — roughly a 3-4x increase over the 2011–2012 monthly average. January 2014 shows a steep drop to 45,642, consistent with the dataset's reporting period ending mid-month (2014-01-28) rather than a genuine decline.
- Customer acquisition trend: Active customers per month followed the same pattern — climbing from 14 in the first partial month to the 150-350 range through 2011-2012, then jumping sharply in 2013 to 627 in January and peaking at 2,133 by December 2013. This mirrors the sales acceleration, suggesting the growth in revenue was driven largely by a growing customer base rather than existing customers spending more.

## 2. Cumulative Trends

*From: Section 2 — running total & moving average*

- Running total sales trajectory: Growth was gradual through 2011-2012, with the running total climbing from 43,419 to roughly 13,000,000 by the end of 2012. The pace picked up considerably in 2013, adding over 16,000,000 in that single year alone to close near 29,350,000 by January 2014 — consistent with the acceleration seen in the monthly change-over-time figures.
- Moving average price trend: Notably, the moving average selling price moved in the opposite direction of total sales — starting around 3,100-3,210 through 2011 and declining steadily each year, dropping to roughly 2,500 by the end of 2012, around 1,900-2,400 through 2013, and reaching a low of 1,745 by January 2014. This means the revenue growth was driven by selling more units/orders at a lower average price point, rather than by increasing prices.

## 3. Product Performance (Year-over-Year)

*From: Section 3*

**Note:** 2010 (Dec only) and 2014 (Jan only) are partial months, not full years — this creates artificial swings for products with sales in those edge periods, so the biggest raw jumps/drops in the data are reporting-window artifacts rather than real performance.

- **Cleanest signal:** Only 9 products have a full 2011-2013 history (Mountain-200 and Road-250/550-W variants). All 9 show the same pattern: low 2011 sales followed by a sharp jump in 2012, consistent with the overall revenue acceleration seen in Sections 1-2 — 2011 looks like a launch/ramp-up year rather than a down year.
- Of those 9, 7 kept growing into 2013; only **Road-250 Black-52** and **Road-250 Black-58** dipped slightly (-26,477 and -13,980) after their 2012 jump — the only real signs of slowdown in the reliable data.

## 4. Category Contribution (Part-to-Whole)

*From: Section 4*

| Category | Total Sales | % of Total |
|----------|------------|------------|
| Bikes | 28,316,272 | 96.46% |
| Accessories | 700,262 | 2.39% |
| Clothing | 339,716 | 1.16% |

**Takeaway:** Bikes overwhelmingly dominate revenue, accounting for 96.46% of total sales — Accessories and Clothing together make up less than 4% combined. This is a heavily concentrated revenue base with almost no diversification across categories.

## 5. Product Cost Segmentation

*From: Section 5*

| Cost Range | # of Products |
|------------|--------------|
| Below 100 | 110 |
| 100–500 | 101 |
| 500–1000 | 45 |
| Above 1000 | 39 |

## 6. Customer Segmentation (VIP / Regular / New)

*From: Section 5 (customer tiers)*

| Tier | # of Customers | % of Total |
|------|----------------|------------|
| VIP | 1,655 | 8.95% |
| Regular | 2,198 | 11.89% |
| New | 14,631 | 79.15% |

**Takeaway:** Nearly 4 out of 5 customers (79%) fall into the "New" tier (under 12 months of activity), while VIP and Regular combined make up just under 21% of the customer base. This suggests either strong ongoing customer acquisition, a high drop-off rate before customers become long-term, or both — worth cross-referencing with the top-10-customer revenue figures below to see how much of total revenue that small VIP segment actually drives.

## 7. Top & Bottom Performers

*From: `scripts/exploratory/exploratory_analysis.sql` — Ranking Analysis*

**Top 5 products by revenue:**
1. Mountain-200 Black-46 — 1,373,454
2. Mountain-200 Black-42 — 1,363,128
3. Mountain-200 Silver-38 — 1,339,394
4. Mountain-200 Silver-46 — 1,301,029
5. Mountain-200 Black-38 — 1,294,854

**Bottom 5 products by revenue:**
1. Racing Socks-L — 2,430
2. Racing Socks-M — 2,682
3. Patch Kit/8 Patches — 6,382
4. Bike Wash - Dissolver — 7,272
5. Touring Tire Tube — 7,440

**Top 10 customers by revenue:** Kaitlyn Henderson (13,294), Nichole Nara (13,294), Margaret He (13,268), Randall Dominguez (13,265), Adriana Gonzalez (13,242), Rosa Hu (13,215), Brandi Gill (13,195), Brad She (13,172), Francisco Sara (13,164), Maurice Shan (12,914). Revenue across the top 10 is tightly clustered (12,914-13,294) — no single "whale" customer dominates; the top spenders are all within about 3% of each other.

**3 customers with fewest orders:** Corey Xie, Caleb Turner, and Beth Blanco each placed just 1 order. Since the query uses `ROW_NUMBER()` to break ties, these 3 are simply the first 3 (by customer_key) among what is likely a much larger group of one-time customers — not necessarily the only 3 with a single order.

## 8. Geographic & Demographic Distribution

*From: Magnitude Analysis*

- Top countries by customer count: United States (7,482 — 40.5%), Australia (3,591 — 19.4%), United Kingdom (1,913 — 10.3%), France (1,810 — 9.8%), Germany (1,780 — 9.6%), Canada (1,571 — 8.5%), n/a (337 — 1.8%). The customer base is concentrated in two markets — the US and Australia together account for roughly 60% of all customers.
- Top countries by items sold: United States (20,473), Australia (13,345), Canada (7,620), United Kingdom (6,906), Germany (5,625), France (5,558), n/a (871). The overall ranking mirrors customer count, but Canada and the UK swap positions relative to the customer-count ranking — Canada moves up despite having fewer customers than the UK. On an items-per-customer basis, Canada actually leads (~4.85 items/customer) versus the US (~2.74), Australia (~3.72), and UK (~3.61) — suggesting Canadian customers buy more per person even though the US and Australia have far larger customer bases.
- Gender distribution: Nearly even split — Male 9,341 (50.5%), Female 9,128 (49.4%), n/a 15 (0.1%). Gender shows no meaningful skew, unlike the geographic and product-category breakdowns.

---

## Summary

Revenue growth over the reporting period was driven almost entirely by acquiring more customers and orders at a lower average price point, not by higher prices or a handful of big spenders — the top 10 customers are all clustered within 3% of each other. That growth is heavily concentrated on two fronts: **Bikes account for 96% of total revenue** despite being a minority of the product catalog by count, and the **US and Australia together make up ~60% of the customer base**. With 79% of customers still in the "New" tier, the clearest opportunity is converting more of that base into Regular/VIP customers, while any diversification strategy should focus on growing Accessories/Clothing and underrepresented markets like Canada — which already shows the highest items-per-customer of any country.
