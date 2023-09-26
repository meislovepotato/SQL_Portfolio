create table Binvestment_subset
(
    market varchar,
    funding_total_usd numeric,
    status varchar,
    country_code varchar,
    founded_year text,
    seed numeric,
    venture numeric,
    equity_crowdfunding numeric,
    undisclosed numeric,
    convertible_note numeric,
    debt_fincing numeric,
    private_equity numeric
);

-- SELECT * FROM investment_subset
-- LIMIT 5;

SELECT * FROM investment_subset
WHERE market like '%Services';

UPDATE investment_subset
SET market = 'FinancialServices'
WHERE market = 'FincialServices';

SELECT * FROM investment_subset
WHERE market = 'FinancialServices';

/* creating a copy */
CREATE TABLE cinvestment_subset as
select * FROM investment_subset 
WHERE market = 'FinancialServices';

/* clean the data & handling null */

SELECT * FROM cinvestment_subset
WHERE funding_total_usd is NULL;

DELETE FROM cinvestment_subset
WHERE funding_total_usd is NULL;

/* copy of binvestment_subset */
SELECT * FROM cinvestment_subset
limit 5;

/* Provide descriptive analytics that presents the number
of observations of companies operating in financial services,
their average seed funding, and the standard deviation
for the seed funding–both minimum and maximum. */

select market, funding_total_usd, country_code, status, founded_year,  round(avg(seed),2) as seed_avg
from cinvestment_subset
GROUP by 1,2,3,4,5
order by seed_avg DESC;

select market, funding_total_usd, country_code, status, founded_year, round(stddev(seed),3) as seed_stddev
from cinvestment_subset
GROUP by 1,2,3,4,5
order by seed_stddev DESC;

/* Aware of the reality that equity crowdfunding is a bit rare
in financial services, determine whether there has been
a previous instance where a start-up company offering
financial services received equity crowdfunding. 
->
If there was, provide details of the company such as
the country it operates in, the year it was founded, its status
(whether or not it is still operating), and the amount of equity
crowdfunding it acquired.*/

select market, status, country_code, founded_year, equity_crowdfunding
from cinvestment_subset
WHERE equity_crowdfunding > 0
ORDER by equity_crowdfunding DESC;

/* Determine whether a significant outlier in terms of total
funding (USD) exists among companies that offer financial
services. Provide details pertaining to this outlier such as its
country, status, year founded, and total funding (USD). */

SELECT market, funding_total_usd, founded_year, status, country_code, 
(funding_total_usd - avg(funding_total_usd) over()/ stddev(funding_total_usd) over()) as zscore
FROM cinvestment_subset;

SELECT * FROM
(SELECT market, funding_total_usd, founded_year, status, country_code,
(funding_total_usd - avg(funding_total_usd) over()/ stddev(funding_total_usd) over()) as zscore
FROM cinvestment_subset) as outlier
WHERE zscore > 2.576 or zscore < -2.576
ORDER by zscore DESC;
