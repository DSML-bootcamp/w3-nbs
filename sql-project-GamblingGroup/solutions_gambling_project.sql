use gambling;

-- 1. Using the customer table or tab, please write an SQL query that shows Title, First Name and Last Name and Date of Birth for each of the customers.
select title, firstname, lastname, dateofbirth
from customer;

-- 2. Using customer table or tab, please write an SQL query that shows the number of customers in each customer group (Bronze, Silver & Gold). 
-- I can see visually that there are 4 Bronze, 3 Silver and 3 Gold but if there were a million customers how would I do this in Excel?

-- EXCEL BONUS: using the COUNTIF(), to count how many times each customer_group is repeated

select 
	customergroup,
	count(custid)
from customer
group by customergroup;

-- 3. The CRM manager has asked me to provide a complete list of all data for those customers in the customer table but I need to add the currencycode of each player so she 
-- will be able to send the right offer in the right currency. Note that the currencycode does not exist in the customer table but in the account table. 
-- Please write the SQL that would facilitate this. BONUS: How would I do this in Excel if I had a much larger data set?

-- EXCEL BONUS: VLOOKUP() of cust_id to return the currency_code (on account tab)

select 
	customer.*, 
	account.currencycode
from customer
inner join account on account.custid = customer.custid;

-- 4. Now I need to provide a product manager with a summary report that shows, by product and by day how much money has been bet on a particular product. 
-- PLEASE note that the transactions are stored in the betting table and there is a product code in that table that is required to be looked up (classid & categortyid) to 
-- determine which product family this belongs to. Please write the SQL that would provide the report. BONUS: If you imagine that this was a much larger data set in Excel, 
-- how would you provide this report in Excel?

-- EXCEL BONUS: Filtering for the dates requested and using SUMIF(), to sum the bet_amt for each product

select 
	betting.betdate,
	product.product,
	product.sub_product,
	sum(betting.bet_amt) as total_product_bet
from betting
	inner join product on product.classid = betting.classid and product.categoryid = betting.categoryid
group by betting.betdate, product.product, product.sub_product
order by betting.betdate;

-- 5. You’ve just provided the report from question 4 to the product manager, now he has emailed me and wants it changed. Can you please amend the summary report so that 
-- it only summarises transactions that occurred on or after 1st November and he only wants to see Sportsbook transactions.Again, please write the SQL below that will do 
-- this. BONUS: If I were delivering this via Excel, how would I do this?

-- EXCEL BONUS: Filtering for the dates and products requested and using SUMIF() to sum the bet_amt 

select 
	betting.betdate,
	product.product,
	product.sub_product,
	sum(betting.bet_amt) as total_product_bet
from betting
	inner join product on product.classid = betting.classid and product.categoryid = betting.categoryid
where
	betting.betdate >= '11/01/2012'
    and product.product = 'Sportsbook'
group by betting.betdate, product.product, product.sub_product
order by betting.betdate;


-- 6. As often happens, the product manager has shown his new report to his director and now he also wants different version of this report. This time, he wants the all of 
-- the products but split by the currencycode and customergroup of the customer, rather than by day and product. He would also only like transactions that occurred after 
-- 1st December. Please write the SQL code that will do this.

select 
	customer.customergroup,
	account.currencycode,
	product.product,
	product.sub_product,
	sum(betting.bet_amt) as total_product_bet
from betting
	inner join product on product.classid = betting.classid and product.categoryid = betting.categoryid
    inner join account on account.accountno = betting.accountno
    inner join customer on customer.custid = account.custid
where betting.betdate >= '12/01/2012'
group by customer.customergroup, account.currencycode, product.product, product.sub_product
order by customer.customergroup, account.currencycode, product.product, product.sub_product;


-- 7. Our VIP team have asked to see a report of all players regardless of whether they have done anything in the complete timeframe or not. In our example, it is 
-- possible that not all of the players have been active. Please write an SQL query that shows all players Title, First Name and Last Name and a summary of their bet 
-- amount for the complete period of November.

select
	customer.title,
	customer.firstname,
	customer.lastname,
	sum(betting.bet_amt) as total_bet_amount
from customer
	inner join account on account.custid = customer.custid
    inner join betting on betting.accountno = account.accountno
where betting.betdate between '11/01/2012' and '11/30/2012'
group by customer.title, customer.firstname, customer.lastname
order by customer.title, customer.firstname, customer.lastname;


-- 8. Our marketing and CRM teams want to measure the number of players who play more than one product. Can you please write 2 queries, one that shows the number of 
-- products per player and another that shows players who play both Sportsbook and Vegas.

-- shows the number of products per player
select
	customer.firstname,
	customer.lastname,
	count(betting.product) as number_products
from betting
	inner join account on account.accountno = betting.accountno
    inner join customer on customer.custid = account.custid
group by customer.firstname, customer.lastname;

-- shows players who play both Sportsbook and Vegas
select
	customer.firstname,
	customer.lastname
from betting
	inner join account on account.accountno = betting.accountno
    inner join customer on customer.custid = account.custid
where betting.product in ('Sportsbook', 'Vegas')
group by customer.firstname, customer.lastname
	having count(distinct betting.product) =  2
order by customer.firstname, customer.lastname;


-- 9. Now our CRM team want to look at players who only play one product, please write SQL code that shows the players who only play at sportsbook, use the bet_amt > 0 as 
-- the key. Show each player and the sum of their bets for both products.

-- show the players who only play at sportsbook
select distinct
	customer.firstname,
	customer.lastname
from betting
	inner join account on account.accountno = betting.accountno
    inner join customer on customer.custid = account.custid
where betting.product = 'Sportsbook'
	and betting.accountno not in (select distinct accountno from betting where product != 'Sportsbook')
order by customer.firstname, customer.lastname;

-- Show each player and the sum of their bets for both SportsBook and Vegas (the two products that came from Q08)
select
	customer.firstname,
	customer.lastname,
	sum(case 
			when betting.product = 'Sportsbook'
			then betting.bet_amt
			else 0 end) 		as sportsboook_total_bet_amt,
	sum(case
			when betting.product = 'Vegas'
			then betting.bet_amt
			else 0 end) 		as vegas_total_bet_amt 
from betting
	inner join account on account.accountno = betting.accountno
    inner join customer on customer.custid = account.custid
where betting.product in ('Sportsbook', 'Vegas')
group by customer.firstname, customer.lastname
	having count(distinct betting.product) =  2
order by customer.firstname, customer.lastname;
    

-- 10. The last question requires us to calculate and determine a player’s favourite product. This can be determined by the most money staked. Please write a query that 
-- will show each players favourite product

select
	customer.firstname,
	customer.lastname,
	(select product
		from betting 
		inner join account on account.accountno = betting.accountno
		where account.custid = customer.custid
		group by betting.product 
		order by sum(betting.bet_amt) desc limit 1) 	as favorite_product,
    (select max(bet_amt)
		from betting
		inner join account on account.accountno = betting.accountno
		where account.custid = customer.custid) 		as max_amount_spent
from customer
order by max_amount_spent desc;

-- 11. Write a query that returns the top 5 students based on GPA
select student_name, gpa
from student
order by gpa desc
limit 5;


-- 12. Write a query that returns the number of students in each school. (a school should be in the output even if it has no students!)
select
	school_name,
	count(student_id) as total_students
from school
	left join student on student.school_id = school.school_id
group by school_name;

-- 13. Write a query that returns the top 3 GPA students' name from each university.

with ranked_students as (
	select student_name, school_id, gpa, rank() over (partition by school_id order by gpa desc) as ranking
	from student
	order by gpa desc	)

select 
	ranked_students.student_name,
	school.school_name,
	ranked_students.gpa,
	ranked_students.ranking
from ranked_students
	left join school on school.school_id = ranked_students.school_id
where ranked_students.ranking <= 3;

    
    







