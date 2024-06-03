/*Question 01: Using the customer table or tab, 
please write an SQL query that shows Title, 
First Name and Last Name and Date of Birth for each of the customers.*/
USE gambling;

SELECT customer.Title, customer.FirstName, customer.LastName, customer.DateOFBirth
FROM customer;

/*Question 02: Using customer table or tab, please write an SQL query that shows the number of customers in each customer group (Bronze, Silver & Gold). 
I can see visually that there are 4 Bronze, 3 Silver and 3 Gold but if there were a million customers how would I do this in Excel?*/

SELECT COUNT(customer.CustId), customer.CustomerGroup
FROM customer
GROUP BY customer.CustomerGroup;


/*Question 03: The CRM manager has asked me to provide a complete list of all data 
for those customers in the customer table but I need to add the currencycode of each 
player so she will be able to send the right offer in the right currency. 
Note that the currencycode does not exist in the customer table but in the account table. 
Please write the SQL that would facilitate this. BONUS: How would I do this in Excel if I had a much larger data set?*/



/*cheeeck left joooin !!! the join is in rows not in columns; u get for sure all the rows in costumers thos who dont match put empty in */
/*if we have customer id that not match in account : null value in currencycode*/

SELECT customer.*, account.CurrencyCode
FROM customer
INNER JOIN account
ON customer.CustId = account.CustId;


SELECT customer.*, account.CurrencyCode
FROM customer
LEFT JOIN account
ON customer.CustId = account.CustId;


/*Question 04: Now I need to provide a product manager with a summary report that shows, 
by product and by day how much money has been bet on a particular product. 
PLEASE note that the transactions are stored in the betting table and there is a 
product code in that table that is required to be looked up (classid & categortyid) 
to determine which product family this belongs to. Please write the SQL that would provide the report. 
BONUS: If you imagine that this was a much larger data set in Excel, how would you provide this report in Excel?*/


SELECT betting.Product, betting.BetDate AS bet_date, SUM(betting.Bet_Amt) AS Total_Bet_Amount
FROM betting
JOIN product
ON betting.ClassId = product.CLASSID 
GROUP BY betting.Product, betting.BetDate
ORDER BY betting.Product, betting.BetDate;

/*many to many relation several times the product we replicate rows with joins*/

SELECT betting.Product, betting.BetDate AS bet_date, SUM(betting.Bet_Amt) AS Total_Bet_Amount
FROM betting
JOIN product
ON betting.ClassId = product.CLASSID AND betting.categoryid = product.categoryid
GROUP BY betting.Product, betting.BetDate
ORDER BY betting.Product, betting.BetDate;



GROUP BY betting.Product, product.sub_product,betting.BetDate
ORDER BY betting.Product, betting.BetDate;

JOIN product
on classid 
bproductt, sub_product, date
order by betting product desc, DATE(STRTO DATE bla bla lba)


/*Question 05: You’ve just provided the report from question 4 to the product manager, 
now he has emailed me and wants it changed. Can you please amend the summary report so that 
it only summarises transactions that occurred on or after 1st November and he only wants to see 
Sportsbook transactions.Again, please write the SQL below that will do this. BONUS: If I were delivering this via Excel, 
how would I do this?*/   


SELECT betting.Product, betting.BetDate AS bet_date, SUM(betting.Bet_Amt) AS Total_Bet_Amount
FROM betting
WHERE MONTH(STR_TO_DATE(betting.BetDate, '%m/%d/%Y')) >= '11' AND betting.Product = 'Sportsbook'
GROUP BY betting.Product, betting.BetDate;


/*Question 06: As often happens, the product manager has shown his new report to his director 
and now he also wants different version of this report. This time, he wants the all of the products 
but split by the currencycode and customergroup of the customer, rather than by day and product. 
He would also only like transactions that occurred after 1st December. Please write the SQL code that will do this.*/

SELECT betting.Product, account.CurrencyCode, customer.CustomerGroup
FROM betting
JOIN product
ON betting.ClassId = product.CLASSID
JOIN account
ON betting.AccountNo = account.AccountNo
JOIN customer
ON account.CustId = customer.CustId
WHERE MONTH(STR_TO_DATE(betting.BetDate, '%m/%d/%Y')) >= '12'
GROUP BY betting.Product, account.CurrencyCode, customer.CustomerGroup
ORDER BY betting.Product, account.CurrencyCode, customer.CustomerGroup;



/*check left joins*/


/*Question 07: Our VIP team have asked to see a report of all players regardless of whether they have 
done anything in the complete timeframe or not. In our example, it is possible that not all of the players 
have been active. Please write an SQL query that shows all players Title, First Name and Last Name and a summary 
of their bet amount for the complete period of November.*/

/* the coalescence function returns the non values in a list*/

SELECT customer.Title, customer.FirstName, customer.LastName, COALESCE(SUM(betting.Bet_Amt), 0) AS Total_Bet
FROM customer
LEFT JOIN account
ON customer.CustId = account.CustId
LEFT JOIN betting
ON account.AccountNo = betting.AccountNo
GROUP BY  customer.Title, customer.FirstName, customer.LastName;

/*< or the first day or smaller*/

/*if inner join taking data that existfrom account join in customer */

/*Question 08: Our marketing and CRM teams want to measure the number of 
players who play more than one product. Can you please write 2 queries, 
one that shows the number of products per player and another that shows 
players who play both Sportsbook and Vegas.*/

/*Number of products per playwe*/
SELECT account.CustId, COUNT(DISTINCT betting.Product) AS Number_products
FROM account
JOIN betting
ON account.AccountNo = betting.AccountNo
JOIN product
ON betting.ClassId = product.CLASSID
GROUP BY account.CustId
ORDER BY Number_products;


/*Players who play both Sportsbook and Vegas*/
SELECT Title, FirstName, LastName
FROM customer INNER JOIN account
ON customer.CustId = account.CustId
INNER JOIN betting
ON account.AccountNo = betting.AccountNo
WHERE betting.Product IN ('Sportsbook', 'Vegas')
GROUP BY Title, FirstName, LastName
HAVING COUNT(DISTINCT product) = 2     /*HAVING filtra las filas dentro de cada uno de los grupos definidos por GROUP BY*/
ORDER BY Title, FirstName, LastName;  







/*Question 09: Now our CRM team want to look at players who only play one product, 
please write SQL code that shows the players who only play at sportsbook, use the bet_amt > 0 as the key. 
Show each player and the sum of their bets for both products.*/

/*subquery */



SELECT 
    a.CustId,
    SUM(CASE WHEN p.Product = 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) AS Sportsbook_Bet_Amount,  /*calculate the amout if sportb; if the product its not sportb it giveyou a 0*/
    SUM(CASE WHEN p.Product <> 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) AS Other_Products_Bet_Amount /*calculate the amount for other than not sportb*/
FROM 
    account a
JOIN 
    betting b ON a.AccountNo = b.AccountNo
JOIN 
    product p ON b.ClassId = p.ClassId AND b.CategoryId = p.CategoryId
WHERE 
    b.Bet_Amt > 0
GROUP BY 
    a.CustId
HAVING 
    SUM(CASE WHEN p.Product = 'Sportsbook' THEN 1 ELSE 0 END) > 0   /* if product is sportsb returns 1 if not 0*/
    AND SUM(CASE WHEN p.Product <> 'Sportsbook' THEN 1 ELSE 0 END) = 0; /*if amoutit belongs to to a product diff than sportb returns 1 otherwise 0 */



/*Question 10: The last question requires us to calculate and determine a player’s favourite product. 
This can be determined by the most money staked. Please write a query that will show each players favourite product*/


SELECT c.Title, c.FirstName, c.LastName, b.Product, b.BetTotal
FROM customer c 
INNER JOIN account a 
ON c.CustId = a.CustId 
INNER JOIN 
    (SELECT 
        a.CustId, 
        b.Product, 
        SUM(b.Bet_Amt) AS BetTotal 
    FROM 
        account a 
    INNER JOIN 
        betting b ON a.AccountNo = b.AccountNo 
    GROUP BY 
        a.CustId, 
        b.Product) b ON c.CustId = b.CustId
INNER JOIN 
    (SELECT 
        CustId, 
        MAX(BetTotal) AS MaxBetTotal 
    FROM 
        (SELECT 
            a.CustId, 
            b.Product, 
            SUM(b.Bet_Amt) AS BetTotal 
        FROM 
            account a 
        INNER JOIN 
            betting b ON a.AccountNo = b.AccountNo 
        GROUP BY 
            a.CustId, 
            b.Product) sub 
    GROUP BY 
        CustId) max_bet ON b.CustId = max_bet.CustId AND b.BetTotal = max_bet.MaxBetTotal
ORDER BY 
    c.FirstName;








WITH PlayerProductRank AS (
    SELECT 
        a.CustId,
        p.Product,
        SUM(b.Bet_Amt) AS Total_Bet_Amount,
        RANK() OVER (PARTITION BY a.CustId ORDER BY SUM(b.Bet_Amt) DESC) AS Product_Rank
    FROM 
        account a
    JOIN 
        betting b ON a.AccountNo = b.AccountNo
    JOIN 
        product p ON b.ClassId = p.ClassId AND b.CategoryId = p.CategoryId
    GROUP BY 
        a.CustId, p.Product
)
SELECT 
    CustId,
    Product AS Favorite_Product,
    Total_Bet_Amount
FROM 
    PlayerProductRank
WHERE 
    Product_Rank = 1;




/*Question 11: Write a query that returns the top 5 students based on GPA*/
USE studet_school;

SELECT student_id, student_name, GPA
FROM student
ORDER BY GPA DESC
LIMIT 5;


/*Question 12: Write a query that returns the number of students in each school. 
(a school should be in the output even if it has no students!)*/
/* LEFT JOIN ensured that schols are includet in the output*/
USE studet_school;
SELECT school.school_id, school.school_name AS school_name, COUNT(student.student_id) AS student_count
FROM school
LEFT JOIN student
ON school.school_id = student.school_id
GROUP BY school_id, school_name;


/*Question 13: Write a query that returns the top 3 GPA students' name from each university.*/
/*find the top n rows of every group: rank the student scholid by gpa*/
/*school left join student because in student dont appear all the schoolid possibles*/

SELECT school_name, student_id, GPA 
FROM ( SELECT school_name, student_id, GPA, 
ROW_NUMBER() OVER (PARTITION BY sc.school_id ORDER BY GPA DESC) AS row_num    /* used to return the sequential number for each row within its partition*/
FROM school sc 
LEFT JOIN student st 
ON sc.school_id = st.school_id ) AS ranked_data
WHERE row_num <= 3;


