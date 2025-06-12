CREATE DATABASE shark_tank_india;
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sharktank_india.csv"
INTO TABLE shark_tank
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

USE shark_tank_india;

-- QUESTION 1 ->
-- You Team must promote shark Tank India season 4, The senior come up with the idea to show highest funding domain wise so that 
-- new startups can be attracted, and you were assigned the task to show the same.
select * from (select industry,total_deal_amount_in_lakhs,row_number() 
over(partition by industry order by total_deal_amount_in_lakhs desc) as rnk
from shark_tank 
) as t where rnk<=1;

-- QUESTION 2 ->
-- You have been assigned the role of finding the domain where female as pitchers have female to male pitcher ratio >70%
-- SOLUTION ->
select * from (SELECT industry,sum(Male_Presenters) as sum_of_males ,
sum(Female_Presenters) as sum_of_females,
round((sum(Female_Presenters)/sum(Male_Presenters))*100,2)
as ratio from shark_tank_india.shark_tank
group by industry having sum(Female_Presenters)> 0 and sum(Male_Presenters)>0) as t where ratio>=70;

-- QUESTION 3 -> 3.	You are working at marketing firm of Shark Tank India, you have got the task to 
-- determine volume of per season sale pitch made, pitches who received offer and pitches that were converted.
-- Also show the percentage of pitches converted and percentage of pitches entertained.
SELECT Season_Number,COUNT(*)  as 'total_pitches',
count(case when Received_Offer='Yes' then 1 end) as total_received_offer,
count(case when Accepted_Offer='Yes' then 1 end) as total_Accepted_offer ,
round((count(case when Accepted_Offer='Yes' then 1 end))/(count(*) )* 100,2) 
as conversion_rate,
round((count(case when Received_Offer='Yes' then 1 end))/(count(*) )* 100,2) 
as pitches_entertained_percentage
from shark_tank_india.shark_tank group by Season_Number;

-- QUESTION 4 -> 4.	As a venture capital firm specializing in investing in startups featured on a renowned entrepreneurship TV show,
--  you are determining the season with the highest average monthly sales and identify the top 5 industries with the highest average 
--  monthly sales during that season to optimize investment decisions?
-- SOLUTION->
-- 			select * from(select Season_Number,industry,round(avg(Monthly_Sales_in_lakhs),2) as average_monthly_sales ,
-- 			row_number() over(order by avg(Monthly_Sales_in_lakhs) desc) as rnk
-- 			from shark_tank_india.shark_tank where Season_Number=(select Season_number 
-- 			from (SELECT Season_number,round(avg(Monthly_Sales_in_lakhs),2) as average_monthly_sales,
-- 			row_number() over(order by avg(Monthly_Sales_in_lakhs) desc) as rnk from shark_tank_india.shark_tank
-- 			group by Season_number) as t where rnk=1) group by industry,Season_Number) as m where rnk<=5

set @season:=(select Season_Number from shark_tank_india.shark_tank 
group by Season_Number order by avg(Monthly_Sales_in_lakhs)
desc limit 1 );
select @season;
select industry , round(avg(Monthly_Sales_in_lakhs),2) as average_monthly_sales
from shark_tank_india.shark_tank where Season_Number=@season group by industry 
order by average_monthly_sales desc limit 5;

-- QUESTION 5-> 5.	As a data scientist at our firm, your role involves solving real-world challenges like 
--  identifying industries with consistent increases in funds raised over multiple seasons. This requires focusing
--  on industries where data is available across all three seasons. Once these industries are pinpointed, your task
--  is to delve into the specifics, analyzing the number of pitches made, offers received, 
--  and offers converted per season within each industry.
-- SOLUTION
select industry,Season_Number,count(Pitch_Number) as total_pitch,count(case when Received_Offer='Yes' then 1 end) as offer_received,
(count(case when Accepted_Offer='Yes' then 1 end)) as accepted from shark_tank_india.shark_tank
where industry in  (select industry from (SELECT 
        industry,
        ROUND(SUM(CASE WHEN Season_Number = 1 AND Accepted_Offer = 'Yes' THEN Total_Deal_Amount_in_lakhs END), 2) AS season1,
        ROUND(SUM(CASE WHEN Season_Number = 2 AND Accepted_Offer = 'Yes' THEN Total_Deal_Amount_in_lakhs END), 2) AS season2,
        ROUND(SUM(CASE WHEN Season_Number = 3 AND Accepted_Offer = 'Yes' THEN Total_Deal_Amount_in_lakhs END), 2) AS season3
    FROM 
        shark_tank_india.shark_tank
    GROUP BY 
        industry
) AS t 
WHERE 
    season1 IS NOT NULL AND 
    season2 IS NOT NULL AND 
    season3 IS NOT NULL AND
    season1 < season2 AND 
    season2 < season3)
group by Season_Number,industry
order by industry;

-- QUESTION 6-> Every shark wants to know in how much year their investment will be returned, 
-- so you must create a system for them, where shark will enter the name of the startup’s and the 
-- based on the total deal and equity given in how many years their principal amount will be returned
-- and make their investment decisions.

-- SOLUTION

use shark_tank_india
delimiter //
create procedure investment_return_time(in startup varchar(100))
begin 
    case 
	  when 
			(select Accepted_offer='Yes' and Yearly_Revenue_in_lakhs='Not Mentioned' 
			from shark_tank where Startup_Name=startup)
			  then select 'investment return time not be calculate';
			
		when 
			(select Accepted_offer='No'
			from shark_tank where Startup_Name=startup)
			   then select 'can not be calculated because offer is not accepted';
		
        else 
           select `Startup_Name`,`Yearly_Revenue_in_lakhs`,`Total_Deal_Amount_in_lakhs`,
           `Total_Deal_Equity_in_per`,
           `Total_Deal_Amount_in_lakhs`/((`Total_Deal_Equity_in_per`*`Yearly_Revenue_in_lakhs`)/100)
            as years from shark_tank
           where Startup_name=startup;
  end case;
  end
 // delimiter;
call investment_return_time('BoozScooters');

-- QUESTION 7 -> 7.	In the world of startup investing, we're curious to know which big-name investor, often referred to as "sharks," 
--  tends to put the most money into each deal on average.This comparison helps us see who's the most generous with their investments
--  and how they measure up against their fellow investors.
select  'Average deal' as sharkname, 
       round(avg(case when Namita_Investment_Amount_in_lakhs>0 THEN Namita_Investment_Amount_in_lakhs END),2) as Namita,
       round(avg(case when Vineeta_Investment_Amount_in_lakhs>0 THEN Vineeta_Investment_Amount_in_lakhs END),2) as Vineeta,
       round(avg(case when Anupam_Investment_Amount_in_lakhs>0 THEN Anupam_Investment_Amount_in_lakhs END),2) as Anupam,
       round(avg(case when Aman_Investment_Amount_in_lakhs>0 THEN Aman_Investment_Amount_in_lakhs END),2) as Aman,
       round(avg(case when Peyush_Investment_Amount_in_lakhs>0 THEN Peyush_Investment_Amount_in_lakhs END),2) as Peyush,
       round(avg(case when Ashneer_Investment_Amount>0 THEN Ashneer_Investment_Amount END),2) as Ashneer,
       round(avg(case when Amit_Investment_Amount_in_lakhs>0 THEN Amit_Investment_Amount_in_lakhs END),2) as Amit from shark_tank

-- QUESTION 8 -> Develop a stored procedure that accepts inputs for the season number and the name of a shark.
--  The procedure will then provide detailed insights into the total investment made by that specific
--  shark across different industries during the specified season. Additionally, it will calculate the
--  percentage of their investment in each sector relative to the total investment in that year, giving 
--  a comprehensive understanding of the shark's investment distribution and impact.
-- SOLUTION
use shark_tank_india;
delimiter //
create procedure details(in season int,in shark varchar(100))
begin 
     case
         when shark='Namita'
         then set @total=(select round(sum(Namita_Investment_Amount_in_lakhs),2) 
         from shark_tank where Season_Number=season);
         select Industry,round(sum(Namita_Investment_Amount_in_lakhs),2) as sum,
         round((sum(Namita_Investment_Amount_in_lakhs)/@total)*100,2) as `%`
         from shark_tank where Season_Number=season and
         Namita_Investment_Amount_in_lakhs>0
         group by Industry;
         
		 when shark='Vineeta'
         then set @total=(select round(sum(Vineeta_Investment_Amount_in_lakhs),2) 
         from shark_tank where Season_Number=season);
         select Industry,round(sum(Vineeta_Investment_Amount_in_lakhs),2) as sum,
         round((sum(Vineeta_Investment_Amount_in_lakhs)/@total)*100,2) as `%`
         from shark_tank where Season_Number=season and
         Vineeta_Investment_Amount_in_lakhs>0
         group by Industry;
         
		 when shark='Anupam'
         then set @total=(select round(sum(Vineeta_Investment_Amount_in_lakhs),2) 
         from shark_tank where Season_Number=season);
         select Industry,round(sum(Anupam_Investment_Amount_in_lakhs),2) as sum,
         round((sum(Anupam_Investment_Amount_in_lakhs)/@total)*100,2) as `%`
         from shark_tank where Season_Number=season and
         Anupam_Investment_Amount_in_lakhs>0
         group by Industry;
         
		 when shark='Aman'
         then set @total=(select round(sum(Aman_Investment_Amount_in_lakhs),2) 
         from shark_tank where Season_Number=season);
         select Industry,round(sum(Aman_Investment_Amount_in_lakhs),2) as sum,
         round((sum(Aman_Investment_Amount_in_lakhs)/@total)*100,2) as `%`
         from shark_tank where Season_Number=season and
         Aman_Investment_Amount_in_lakhs>0
         group by Industry;
         
		 when shark='Peyush'
         then set @total=(select round(sum(Peyush_Investment_Amount_in_lakhs),2) 
         from shark_tank where Season_Number=season);
         select Industry,round(sum(Peyush_Investment_Amount_in_lakhs),2) as sum,
         round((sum(Peyush_Investment_Amount_in_lakhs)/@total)*100,2) as `%`
         from shark_tank where Season_Number=season and
         Peyush_Investment_Amount_in_lakhs>0
         group by Industry;
         
		 when shark='Amit'
         then set @total=(select round(sum(Amit_Investment_Amount_in_lakhs),2) 
         from shark_tank where Season_Number=season);
         select Industry,round(sum(Amit_Investment_Amount_in_lakhs),2) as sum,
         round((sum(Amit_Investment_Amount_in_lakhs)/@total)*100,2) as `%`
         from shark_tank where Season_Number=season and
         Amit_Investment_Amount_in_lakhs>0
         group by Industry;
         
		 when shark='Ashneer'
         then set @total=(select round(sum(Ashneer_Investment_Amount),2) 
         from shark_tank where Season_Number=season);
         select Industry,round(sum(Ashneer_Investment_Amount),2) as sum,
         round((sum(Ashneer_Investment_Amount)/@total)*100,2) as `%`
         from shark_tank where Season_Number=season and
         Ashneer_Investment_Amount>0
         group by Industry;
         
         else 
            select 'this is incorrect input';
	end case;
end //
delimiter;
drop procedure details
call details(1,'Aman');

-- QUESTION 9 -> 9.	In the realm of venture capital, we're exploring which shark possesses the most 
-- diversified investment portfolio across various industries. By examining their investment patterns 
-- and preferences, we aim to uncover any discernible trends or strategies that may shed light on their 
-- decision-making processes and investment philosophies.

-- SOLUTION ->
select  'Namita' as shark,count(distinct Industry) as 'total industries',
count(distinct concat(Pitchers_city,' ,', Pitchers_state)) as 'unique locations' FROM shark_tank
where Namita_Investment_Amount_in_lakhs>0
union all
select  'Vineeta' as shark,count(distinct Industry) as 'total industries',
count(distinct concat(Pitchers_city,' ,', Pitchers_state)) as 'unique locations' FROM shark_tank
where Vineeta_Investment_Amount_in_lakhs>0
union all
select  'Aman' as shark,count(distinct Industry) as 'total industries',
count(distinct concat(Pitchers_city,' ,', Pitchers_state)) as 'unique locations' FROM shark_tank
where Aman_Investment_Amount_in_lakhs>0
union all
select  'Peyush' as shark,count(distinct Industry) as 'total industries',
count(distinct concat(Pitchers_city,' ,', Pitchers_state)) as 'unique locations' FROM shark_tank
where Peyush_Investment_Amount_in_lakhs>0
union all
select  'Amit' as shark,count(distinct Industry) as 'total industries',
count(distinct concat(Pitchers_city,' ,', Pitchers_state)) as 'unique locations' FROM shark_tank
where Amit_Investment_Amount_in_lakhs>0
union all
select  'Anupam' as shark,count(distinct Industry) as 'total industries',
count(distinct concat(Pitchers_city,' ,', Pitchers_state)) as 'unique locations' FROM shark_tank
where Anupam_Investment_Amount_in_lakhs>0
union all
select  'Ashneer' as shark,count(distinct Industry) as 'total industries',
count(distinct concat(Pitchers_city,' ,', Pitchers_state)) as 'unique locations' FROM shark_tank
where Ashneer_Investment_Amount>0 order by `total industries` desc;



















