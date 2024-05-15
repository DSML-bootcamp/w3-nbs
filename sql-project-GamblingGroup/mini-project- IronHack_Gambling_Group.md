# Business Challenge: The IronHack Gambling Database Adventure

## Introduction

Welcome to the IronHack Gambling Database Adventure! This challenge is inspired by a real-life job interview scenario from IronHack Gambling. It's designed to test your SQL skills in a fun and engaging way. Imagine you're applying for a data analyst role at IronHack Gambling, and you've been given this challenge to showcase your expertise.

## Scenario

You have been given access to four critical database tables of the IronHack Gambling Data Warehouse: `Betting`, `Product`, `Customer`, and `Account`. These tables are central to 75% of all queries at IronHack Gambling. For this challenge, a snapshot of data involving 10 players and their transactions is provided. Your task is to demonstrate your SQL prowess by retrieving and manipulating this data to provide valuable insights.

## Challenge Format

- The challenge starts with simple queries and gradually increases in complexity.
- For each question, write your SQL query to find the answer.
- Although the original data is in Excel, focus only on writing SQL queries as if the data were in a SQL database.

## Questions

- **Question 01**:  Using the customer table or tab, please write an SQL query that shows Title, First Name and Last Name and Date of Birth for each of the customers. You won’t need to do anything in Excel for this one.

### Answer: 
SELECT Title, FirstName, LastName, DateOfBirth
FROM Customer
;


- **Question 02**:  Using customer table or tab, please write an SQL query that shows the number of customers in each customer group (Bronze, Silver & Gold). I can see visually that there are 4 Bronze, 3 Silver and 3 Gold but if there were a million customers how would I do this in Excel?

### Answer: 
SELECT CustomerGroup ,count (distinct CustId) as num_customers
FROM Customer
GROUP BY CustomerGroup
;

In excel, create a pivot table using CustomerGroup as rows and Count of CustId as values.


- **Question 03**: The CRM manager has asked me to provide a complete list of all data for those customers in the customer table but I need to add the currencycode of each player so she will be able to send the right offer in the right currency. Note that the currencycode does not exist in the customer table but in the account table. Please write the SQL that would facilitate this. How would I do this in Excel if I had a much larger data set?

### Answer:
SELECT c.*, a.CurrencyCode
FROM customer c
JOIN account a ON c.CustId = a.CustId;

In excel: create a 'currency_code' column in Customer tab and use vlookup using custId as a key to grab the currency info.

- **Question 04**: Now I need to provide a product manager with a summary report that shows, by product and by day how much money has been bet on a particular product. PLEASE note that the transactions are stored in the betting table and there is a product code in that table  that is required to be looked up (classid & categortyid) to determine which product family this belongs to. Please write the SQL that would provide the report. If you imagine that this was a much larger data set in Excel, how would you provide this report in Excel?

### Answer:
SELECT b.BetDate, p.product, sum(b.Bet_Amt) as bet_amount
FROM betting b
LEFT JOIN  product p
ON b.ClassId = p.ClassId AND b.CategoryId = p.CategoryId
GROUP BY b.BetDate, p.product
;


- **Question 05**: You’ve just provided the report from question 4 to the product manager, now he has emailed me and wants it changed. Can you please amend the summary report so that it only summarises transactions that occurred on or after 1st November and he only wants to see Sportsbook transactions.Again, please write the SQL below that will do this. If I were delivering this via Excel, how would I do this?

### Answer:
SELECT b.BetDate, p.product, sum(b.Bet_Amt) as bet_amount
FROM betting b
LEFT JOIN  product p
ON b.ClassId = p.ClassId AND b.CategoryId = p.CategoryId
WHERE b.BetDate >= '24/11/01' AND p.product = 'Sportsbook' 
GROUP BY b.BetDate, p.product
;

- **Question 06**: As often happens, the product manager has shown his new report to his director and now he also wants different version of this report. This time, he wants the all of the products but split by the currencycode and customergroup of the customer, rather than by day and product. He would also only like transactions that occurred after 1st December. Please write the SQL code that will do this.

### Answer:
SELECT p.product, a.CurrencyCode, c.CustomerGroup, SUM(b.Bet_Amt) as bet_amount
FROM betting b
LEFT JOIN product p ON b.ClassId = p.ClassId AND b.CategoryId = p.CategoryId
LEFT JOIN account a ON b.AccountNo = a.AccountNo
LEFT JOIN (
    SELECT ac.CustId, ac.AccountNo, c.CustomerGroup
    FROM account ac
    LEFT JOIN customer c ON ac.CustId = c.CustId
) as c ON a.CustId = c.CustId
WHERE b.BetDate >= '24/12/01'
GROUP BY p.product, a.CurrencyCode, c.CustomerGroup
;

- **Question 07**: Our VIP team have asked to see a report of all players regardless of whether they have done anything in the complete timeframe or not. In our example, it is possible that not all of the players have been active. Please write an SQL query that shows all players Title, First Name and Last Name and a summary of their bet amount for the complete period of November.

### Answer:
SELECT c.Title, c.FirstName, c.LastName, sum(b.Bet_Amt) as bet_amount
FROM customer c
LEFT JOIN (
        SELECT a.CustId, sum(b.Bet_Amt) as bet_amt
        FROM betting b
        LEFT JOIN account a ON b.AccountNo = a.AccountNo
        WHERE b.BetDate BETWEEN '24/11/01'AND '24/11/30'
        GROUP BY a.CustId
) as b ON c.CustId = b.CustId
GROUP BY c.Title, c.FirstName, c.LastName
;


- **Question 08**: Our marketing and CRM teams want to measure the number of players who play more than one product. Can you please write 2 queries, one that shows the number of products per player and another that shows players who play both Sportsbook and Vegas.

### Answer:
#Query 1 - number of products per player
SELECT AccountNo, count(distinct Product) as product_qty
FROM betting
GROUP BY AccountNo
;

#Query 2 - players who play both Sportsbook and Vegas
SELECT AccountNo
FROM betting
WHERE Product IN ('Sportsbook','Vegas')
GROUP BY AccountNo
HAVING count(distinct classId) = 2;



- **Question 09**: Now our CRM team want to look at players who only play one product, please write SQL code that shows the players who only play at sportsbook, use the bet_amt > 0 as the key. Show each player and the sum of their bets for both products. 
#Only Play at Sportsbook
### Answer:
SELECT AccountNo
FROM betting
WHERE Product = 'Sportsbook'
GROUP BY AccountNo
HAVING count(distinct classId) = 1;

#sum of bets of question 8
#Query 2 - players who play both Sportsbook and Vegas
SELECT AccountNo, sum(b.Bet_Amt) as bet_sum
FROM betting
WHERE Product IN ('Sportsbook','Vegas')
GROUP BY AccountNo
HAVING count(distinct classId) = 2;

- **Question 10**: The last question requires us to calculate and determine a player’s favourite product. This can be determined by the most money staked. Please write a query that will show each players favourite product

### Answer

SELECT AccountNo, product, max(bet_amount) as max_amount
FROM (
	SELECT b.AccountNo, p.product, sum(b.Bet_Amt) as bet_amount
    FROM betting b
    JOIN product p ON b.ClassId = p.ClassId AND b.CategoryId = p.CategoryId
    GROUP BY b.AccountNo, p.Product
) as bet_amount_product

GROUP BY AccountNo, product
;

Looking at the abstract data on the "Student_School" tab into the Excel spreadsheet, please answer the below questions:

- **Question 11**: Write a query that returns the top 5 students based on GPA

### Answer

SELECT student_name
FROM student
GROUP BY student_name
ORDER BY GPA DESC
LIMIT 5;

- **Question 12**: Write a query that returns the number of students in each school. (a school should be in the output even if it has no students!)
### Answer

SELECT s.student_name, sc.school_name
FROM s.student
LEFT JOIN school_name sc
ON s.school_id = sc.school_id
GROUP BY student_name
;

- **Question 13**: Write a query that returns the top 3 GPA students' name from each university.
### Answer

SELECT s.student_name, s.school_id
FROM student s
WHERE (
    SELECT COUNT(*)
    FROM student s2
    WHERE s2.school_id = s.school_id AND s2.GPA >= s.GPA
) <= 3;


## How to Participate

- Write or type your SQL answers for each question in this document.
- Feel free to use a separate editor to draft your queries before pasting them here.
- Ensure your queries are well-formatted and easy to understand.

## Submission

- Once you have completed the challenge, submit your answers before the following class.
- Showcase your SQL skills and data manipulation expertise.

## Good luck!

Embark on this SQL adventure, and show us the full extent of your data analysis capabilities!

---
