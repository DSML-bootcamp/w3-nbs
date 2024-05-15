--Q1

SELECT Title, FirstName, LastName, DATEOFBIRTH
FROM customer;

--- Q2

select CustomerGroup, Count(*) as customer_count
from customer
group by CustomerGroup;

--- Q3

SELECT c.*, a.CurrencyCode
FROM customer c
INNER JOIN account a ON c.CustID = a.CustID;

---- Q4


SELECT
    g.betdate AS Day,
    p.product AS Product,
    p.classid AS Class_ID,
    p.categoryid AS Category_ID,
    SUM(g.Bet_Amt) AS Total_Bet_Amount
FROM
    gambling g
JOIN
    product p ON g.product = p.product
    

GROUP BY
    g.betdate,
    p.product,
    p.classid,
    p.categoryid 
ORDER BY
    g.betdate,
    p.product;
    
    ---- Q5

SELECT
    g.betdate AS Day,
    p.product AS Product,
    p.classid AS Class_ID,
    p.categoryid AS Category_ID,
    SUM(g.Bet_Amt) AS Total_Bet_Amount
FROM
    gambling g
JOIN
    product p ON g.product = p.product

WHERE
    g.betdate >= '2012-11-01' 
    AND p.product = 'Sportsbook' 

GROUP BY
    g.betdate,
    p.product,
    p.classid,
    p.categoryid 
ORDER BY
    g.betdate,
    p.product;



    
    --- Q6

    
SELECT
    g.product AS Product,
    a.CurrencyCode AS CurrencyCode,
    c.CustomerGroup AS CustomerGroup,
    SUM(g.Bet_Amt) AS Total_Bet_Amount
FROM
    gambling g
JOIN
    Account a ON g.AccountNo = a.AccountNo
JOIN
    customer c ON a.CustId = c.CustId
WHERE
    g.betdate >= '2012-12-01'  
GROUP BY
    g.product,
    a.CurrencyCode,
    c.CustomerGroup
ORDER BY
    g.product,
    a.CurrencyCode,
    c.CustomerGroup;


---    Q7


Select
    c.Title, c.FirstName, c.LastName, 
    a.CustId,
    COALESCE(SUM(CASE WHEN g.betdate >= '2012-11-01' AND g.betdate < '2012-12-01' THEN g.Bet_Amt ELSE 0 END), 0) AS BetAmt_Nov
From Customer c

Join
  Account a ON c.CustId = a.CustId

Join
    Gambling g on a.AccountNo = g.AccountNo

GROUP BY c.Title, c.FirstName, c.LastName, a.CustId
ORDER BY c.Title, c.FirstName;
    


---    Q8.1


SELECT
    AccountNo,
    COUNT(DISTINCT product) AS num_products
FROM
    gambling
 
GROUP BY
    AccountNo
HAVING
    num_products > 1;

    ---    Q8.2

SELECT
     AccountNo, COUNT(DISTINCT product) AS num_products
FROM
    gambling
WHERE
    product IN ('Sportsbook', 'Vegas')
GROUP BY
    AccountNo
HAVING
    COUNT(DISTINCT product) = 2;

    ---Q.9
SELECT
    AccountNo,
    COUNT(DISTINCT product) AS num_products
FROM
    gambling
WHERE
    product IN ('Sportsbook') AND Bet_Amt > 0 
 
GROUP BY
    AccountNo
HAVING
    num_products = 1;


----Q10
WITH PlayerTotalBet as (

  SELECT
        AccountNo,
        product,
        SUM(bet_amt) AS total_bet_amount
    FROM
        gambling
    GROUP BY
        AccountNo,
        product
)

Select AccountNo,
       product,
       MAX(total_bet_amount) AS max_bet_amount
From PlayerTotalBet
Group By AccountNo, product;




---  Q11


SELECT
    student_id,
    student_name,
    city,
    school_id,
    School,
    GPA
FROM
    STUDENT_SCHOOL
WHERE
    GPA IS NOT NULL
ORDER BY
    GPA DESC
LIMIT 5;


--Q12

SELECT
    school_id,
    COUNT(STUDENT_NAME) AS Students_count
FROM
    STUDENT_SCHOOl
GROUP BY
    School_id;


---Q13

