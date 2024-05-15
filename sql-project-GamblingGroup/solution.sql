USE gambling;

-- Question 01: Using the customer table or tab, please write an SQL query that shows Title, First Name and Last Name and Date of Birth
-- for each of the customers.
SELECT title, firstname, lastname, dateofbirth
FROM customer;

-- Question 02: Using customer table or tab, please write an SQL query that shows the number of customers in each customer group
-- (Bronze, Silver & Gold). I can see visually that there are 4 Bronze, 3 Silver and 3 Gold but if there were a million customers
-- how would I do this in Excel?
SELECT customergroup, COUNT(customergroup)
FROM customer
GROUP BY customergroup;

-- Question 03: The CRM manager has asked me to provide a complete list of all data for those customers in the customer table
-- but I need to add the currencycode of each player so she will be able to send the right offer in the right currency.
-- Note that the currencycode does not exist in the customer table but in the account table.
-- Please write the SQL that would facilitate this. BONUS: How would I do this in Excel if I had a much larger data set?
SELECT customer.custid, account.currencycode
FROM customer 
INNER JOIN account ON customer.custid = account.custid;

-- Question 04: Now I need to provide a product manager with a summary report that shows, by product and by day
-- how much money has been bet on a particular product. PLEASE note that the transactions are stored in the betting table
--  and there is a product code in that table that is required to be looked up (classid & categortyid) to determine
-- which product family this belongs to. Please write the SQL that would provide the report.
-- BONUS: If you imagine that this was a much larger data set in Excel, how would you provide this report in Excel?
SELECT
    product.product,
    DATE(betting.betdate) AS bet_date,
    SUM(betting.betamt) AS total_bet_amount
FROM
    betting
INNER JOIN
    product ON betting.classid = product.classid AND betting.categoryid = product.categoryid
GROUP BY
    product.product,
    DATE(betting.betdate)
ORDER BY
    SUM(betting.betamt) DESC;

-- Question 05: You’ve just provided the report from question 4 to the product manager, now he has emailed me and wants it changed.
-- Can you please amend the summary report so that it only summarises transactions that occurred on or after 1st November and
--  he only wants to see Sportsbook transactions.Again, please write the SQL below that will do this.
-- BONUS: If I were delivering this via Excel, how would I do this?
SELECT
    product.product,
    DATE(betting.betdate) AS bet_date,
    SUM(betting.betamt) AS total_bet_amount
FROM
    betting
INNER JOIN
    product ON betting.classid = product.classid AND betting.categoryid = product.categoryid
WHERE
    betting.betdate >= '2012-11-01'
    AND product.product = 'Sportsbook'
GROUP BY
    product.product,
    DATE(betting.betdate)
ORDER BY
    product.product,
    bet_date;

-- Question 06: As often happens, the product manager has shown his new report to his director and now he also wants different version
-- of this report. This time, he wants the all of the products but split by the currencycode and customergroup of the customer,
-- rather than by day and product. He would also only like transactions that occurred after 1st December.
-- Please write the SQL code that will do this.
SELECT
    product.product,
    account.currencycode,
    customer.customergroup,
    SUM(betting.betamt) AS total_bet_amount
FROM
    betting
INNER JOIN
    account ON betting.accountno = account.accountno
INNER JOIN
    customer ON account.custid = customer.custid
INNER JOIN
    product ON betting.classid = product.classid AND betting.categoryid = product.categoryid
WHERE
    betting.betdate > '2012-12-01'
GROUP BY
    product.product,
    account.currencycode,
    customer.customergroup
ORDER BY
    SUM(betting.betamt) DESC;

-- Question 07: Our VIP team have asked to see a report of all players regardless of whether they have done anything in the complete timeframe
-- or not. In our example, it is possible that not all of the players have been active. Please write an SQL query that shows
-- all players Title, First Name and Last Name and a summary of their bet amount for the complete period of November.
SELECT
    customer.title,
    customer.firstname,
    customer.lastname,
    SUM(betting.betamt) AS total_bet_amount
FROM
    betting
INNER JOIN
    account ON betting.accountno = account.accountno
INNER JOIN
    customer ON account.custid = customer.custid
WHERE
    betting.betdate BETWEEN '2012-11-01' AND '2012-11-30'
GROUP BY
    customer.title,
    customer.firstname,
    customer.lastname
ORDER BY
    total_bet_amount DESC;

-- Question 08: Our marketing and CRM teams want to measure the number of players who play more than one product.
-- Can you please write 2 queries, one that shows the number of products per player and
-- another that shows players who play both Sportsbook and Vegas.
SELECT
    customer.custid,
    customer.title,
    customer.firstname,
    customer.lastname,
    COUNT(DISTINCT product.product) AS num_products
FROM
    betting
INNER JOIN
    account ON betting.accountno = account.accountno
INNER JOIN
    customer ON account.custid = customer.custid
INNER JOIN
    product ON betting.classid = product.classid AND betting.categoryid = product.categoryid
GROUP BY
    customer.custid,
    customer.title,
    customer.firstname,
    customer.lastname
ORDER BY
    num_products DESC;

SELECT
    customer.custid,
    customer.title,
    customer.firstname,
    customer.lastname,
    product.product
FROM
    customer
INNER JOIN
    account ON customer.custid = account.custid
INNER JOIN
    betting ON account.accountno = betting.accountno
INNER JOIN
    product ON betting.classid = product.classid AND betting.categoryid = product.categoryid
WHERE
    product.product IN ('Sportsbook', 'Vegas')
GROUP BY
    customer.custid,
    customer.title,
    customer.firstname,
    customer.lastname,
    product.product;

-- Question 09: Now our CRM team want to look at players who only play one product, please write SQL code that
-- shows the players who only play at sportsbook, use the bet_amt > 0 as the key. Show each player and the sum of their bets for both products.
SELECT
    customer.custid,
    customer.title,
    customer.firstname,
    customer.lastname,
    SUM(betting.betamt) AS total_bet_amount
FROM
    customer
INNER JOIN
    account ON customer.custid = account.custid
INNER JOIN
    betting ON account.accountno = betting.accountno
INNER JOIN
    product ON betting.classid = product.classid AND betting.categoryid = product.categoryid
WHERE
    product.product = 'Sportsbook'
    AND betting.betamt > 0
GROUP BY
    customer.custid,
    customer.title,
    customer.firstname,
    customer.lastname
ORDER BY
    total_bet_amount DESC;

-- Question 10: The last question requires us to calculate and determine a player’s favourite product.
-- This can be determined by the most money staked. Please write a query that will show each players favourite product
SELECT
    customer.custid,
    customer.title,
    customer.firstname,
    customer.lastname,
    product.product AS favorite_product,
    max_bet.max_bet_amount
FROM
    customer
INNER JOIN
    account ON customer.custid = account.custid
INNER JOIN
    betting ON account.accountno = betting.accountno
INNER JOIN
    product ON betting.classid = product.classid AND betting.categoryid = product.categoryid
INNER JOIN
    (
        SELECT
            betting.accountno,
            MAX(betting.betamt) AS max_bet_amount
        FROM
            betting
        GROUP BY
            betting.accountno
    ) AS max_bet ON betting.accountno = max_bet.accountno AND betting.betamt = max_bet.max_bet_amount
GROUP BY
    customer.custid,
    customer.title,
    customer.firstname,
    customer.lastname,
    product.product,
    max_bet.max_bet_amount
ORDER BY
    max_bet.max_bet_amount DESC;

-- Question 11: Write a query that returns the top 5 students based on GPA
SELECT student_id, student_name, gpa
FROM student_school
ORDER BY gpa DESC;

-- Question 12: Write a query that returns the number of students in each school.
-- (a school should be in the output even if it has no students!)
SELECT
    schools.school_id,
    schools.school_name,
    COALESCE(COUNT(student_school.student_id), 0) AS num_students
FROM
    (
        SELECT DISTINCT
            school_id,
            school_name
        FROM
            student_school
    ) AS schools
LEFT JOIN
    student_school ON schools.school_id = student_school.school_id
GROUP BY
    schools.school_id,
    schools.school_name
ORDER BY
    num_students DESC;

-- Question 13: Write a query that returns the top 3 GPA students' name from each university.
SELECT
    student_school.student_name,
    student_school.school_name,
    student_school.gpa
FROM
    student_school
WHERE
    LENGTH(student_school.school_name)>0 AND
    (
        SELECT COUNT(DISTINCT student_school.gpa)
        FROM student_school 
        WHERE student_school.school_name = student_school.school_name
            AND student_school.gpa > student_school.gpa
    ) < 3
ORDER BY
    student_school.school_name,
    student_school.gpa DESC;