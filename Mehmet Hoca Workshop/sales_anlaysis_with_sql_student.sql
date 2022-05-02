CREATE DATABASE sales_analys
use sales_analys


--1. How many rows in the sales dataset?
 select * from sales
 select * from currency_rates

 select count(*) from sales


--1.1.How many columns in the sales dataset?
--select * from sales_analys.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME= 'currency_rates'

select count(COLUMN_NAME) 
from sales_analys.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME= 'sales'


--2. What is the total number of seller?
 select COUNT(DISTINCT seller_id) from sales


--3. What is the total value of sales in EUR?
update currency_rates set [date] = convert(date,[date])

update sales set [date] = convert(date,[date])


select  round (sum(cast(a.price as float)/cast(b.rate as float)),0) 
from sales a
INNER JOIN currency_rates b ON a.currency = b.currency and a.date = b.date




--4. Which brand has the highest number of purchases during the period?
select count(*) from sales where brand =' '

update sales set brand= 'Unknown' where brand = ' '

select count(*) from sales where brand ='Unknown'

select TOP 1 brand, count(brand) as most_brand
from sales 
where brand !='Unknown'
group by brand
order by count(brand) desc

--5. How many items in the "Jewellery" category have no brand assciateed with them?
select count(distinct product_code)
from sales
where category = 'Jewellery' and
      brand = 'Unknown'



--6. How many brands have between 35 and 55 transactions (inclusive)? 
select count(c.brand)
from
(select brand
from sales
group by brand
having count(product_code) between 35 and 55
) c 


--7. How many pairs of shoes were purchased by Australian (AU) buyers?
select DISTINCT buyer_country from sales

select count(product_code)
from sales
where buyer_country = 'AU' and category = 'Shoes'



--8. Which brand has the highest average transaction value? Bring all values in Euros. 
----iþlem sayýsý olarak en fazla olan
select top 1 brand, count(brand) as total 
from sales 
where brand !='Unknown'
group by brand
order by count(brand) desc


--tutara göre en fazla olan
select top 1 brand,round(avg(cast(price as float) / cast (rate as float)),0) as avg_value
from sales a 
INNER JOIN currency_rates b ON a.currency=b.currency and a.date=b.date
group by brand
order by avg_value desc



--9. What is the total value of items purchased by GB buyers from GB sellers?

select sum(cast(price as float) / cast (rate as float)) as total_value
from sales a 
INNER JOIN currency_rates b ON a.currency=b.currency and a.date=b.date
where buyer_country ='GB' and seller_country='GB'




--10. What percentage of US sellers' transactions were purchased by US buyers?
----alýþ veriþ sayýsý olarak
select
(select count(product_code)*100
from sales 
where seller_country = 'US' and buyer_country='US')
/
(select count(product_code) 
from sales 
where seller_country = 'US')
--------
select round(
cast((select count(product_code)
from sales 
where seller_country = 'US' and buyer_country='US') as float)
/
cast((select count(product_code) 
from sales 
where seller_country = 'US')as float),2)*100

select round(cast(80658 as float)/cast(82111 as float),2)*100


--11. Which country made the highest value of international purchases?
select top 1 buyer_country, sum(cast(price as float) / cast (rate as float)) as total_value
from sales a 
INNER JOIN currency_rates b ON a.currency=b.currency and a.date=b.date
where seller_country != buyer_country
group by buyer_country
order by total_value desc


--12. Which day has the highest value of purchases?
select top 1 a.date, sum(cast(price as float) / cast (rate as float)) as total_value
from sales a 
INNER JOIN currency_rates b ON a.currency=b.currency and a.date=b.date
group by a.date
order by total_value desc



--13. Which category has 2,324 transactions on 7 August?
select category, count(product_code) as trans_num
from sales
where date = '2020-08-07'
group by category
having count(product_code) = 2324


--14. What percentage of global sales value on 4 August came from US sellers?
select round(
(select sum(cast(price as float) / cast (rate as float))*100 as total_value
from sales a 
INNER JOIN currency_rates b ON a.currency=b.currency and a.date=b.date
where a.date ='2020-08-04' and a.seller_country = 'US')
/
(select sum(cast(price as float) / cast (rate as float)) as total_value
from sales a 
INNER JOIN currency_rates b ON a.currency=b.currency and a.date=b.date
where a.date ='2020-08-04'),2) as perc_US


--15. How many sellers in the US has more than 75 sales?
select count (*) 
from
(select distinct seller_id
from sales
where seller_country = 'US'
group by seller_id
having count(seller_id) >75)  a



--16. Which seller in the US sold the most in terms of value?

select top 1 seller_id, sum(cast(price as float) / cast (rate as float)) as total_value
from sales a 
INNER JOIN currency_rates b ON a.currency=b.currency and a.date=b.date
where seller_country = 'US'
group by seller_id
order by total_value desc


--17. Which brand had the largest absolute € difference in average transaction value between domestic and international?
create view domestic as
(select brand, avg(cast(price as float) / cast (rate as float)) as avg_value
from sales a 
INNER JOIN currency_rates b ON a.currency=b.currency and a.date=b.date
where brand!='Unknown' and seller_country=buyer_country
group by brand)

create view international as
(select brand, avg(cast(price as float) / cast (rate as float)) as avg_value
from sales a 
INNER JOIN currency_rates b ON a.currency=b.currency and a.date=b.date
where brand!='Unknown' and seller_country!=buyer_country
group by brand)

select top 1 a.brand, abs(a.avg_value - b.avg_value) as diff_avg_value
from domestic a
INNER JOIN international b 
ON a.brand=b.brand 
order by diff_avg_value desc


