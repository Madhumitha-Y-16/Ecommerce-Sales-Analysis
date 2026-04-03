select count(*) from orders;

-- 1.How has the company’s revenue, profit, and profit margin evolved over time?

SELECT 
    YEAR(order_date) AS year,
    SUM(sales) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY YEAR(order_date)
ORDER BY year;

-- Which product categories contribute most to revenue and profitability, and are there any categories with declining margins?

SELECT 
    category,
    SUM(sales) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY category
ORDER BY total_profit DESC;

-- What is the relationship between discount levels and profitability, and at what point do discounts negatively impact margins?

SELECT 
    discount,
    COUNT(*) AS total_orders,
    ROUND(AVG(profit),2) AS avg_profit
FROM orders
GROUP BY discount
ORDER BY discount;

-- Which product sub-categories consistently generate losses despite contributing to overall revenue?

SELECT 
    sub_category,
    SUM(sales) AS total_revenue,
    SUM(profit) AS total_profit
FROM orders
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY total_revenue DESC;

-- Which customer segments contribute most to revenue and profitability, and how do their margins compare?

SELECT 
    segment,
    SUM(sales) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY segment;

-- How does performance vary across regions in terms of revenue generation and profitability?

SELECT 
    region,
    SUM(sales) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY region
ORDER BY profit_margin;

-- What proportion of total revenue is contributed by the top 20% of customers?

WITH customer_sales AS (
    SELECT 
        customer_id,
        SUM(sales) AS total_revenue
    FROM orders
    GROUP BY customer_id
),
ranked_data AS (
    SELECT 
        customer_id,
        total_revenue,
        NTILE(5) OVER (ORDER BY total_revenue DESC) AS bucket,
        RANK() OVER (ORDER BY total_revenue DESC) AS customer_rank,
        ROUND(total_revenue * 100 / SUM(total_revenue) OVER (), 2) AS contribution_pct
    FROM customer_sales
)
SELECT 
    bucket,
    customer_rank,
    customer_id,
    total_revenue,
    contribution_pct
FROM ranked_data
ORDER BY customer_rank;

-- How does cumulative profit evolve over time?

SELECT 
    order_date,
    SUM(profit) AS daily_profit,
    SUM(SUM(profit)) OVER (ORDER BY order_date) AS cumulative_profit
FROM orders
GROUP BY order_date
ORDER BY order_date;

-- Which orders contribute most to overall losses, and what are the key characteristics of these loss-making transactions?

SELECT 
    category,
    sub_category,
    region,
    discount,
    COUNT(*) AS loss_orders,
    ROUND(AVG(profit),2) AS avg_loss
FROM orders
WHERE profit < 0
GROUP BY category, sub_category, region, discount
ORDER BY avg_loss;