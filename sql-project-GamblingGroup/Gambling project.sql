USE gambling_project;

/* Question 1 */
SELECT 
Title,
FirstName,
LastName,
DateOfBirth
FROM 
gambling_project.customer;

/* Que 2  (Excel q: with pivot table)*/
SELECT
CustomerGroup AS "Customer_group",
COUNT(CustID) AS " No_of_customers"
FROM 
gambling_project.customer
GROUP BY 
CustomerGroup;

/* Question 3 (Excel q: vlookup aka the devil*/
SELECT customer.*, 
account.CurrencyCode
FROM
gambling_project.customer
INNER JOIN gambling_project.account ON 
customer.CustId = account.CustId;

/* Question 4 (Excel q: keep the date in spearate sheets, and then sumifs or pivot table, obs pivot table */
SELECT 
gambling_project.betting.BetDate AS betting_date,
gambling_project.product.product,
SUM(gambling_project.betting.Bet_Amt) AS total_amount_bet
FROM 
gambling_project.betting
INNER JOIN 
gambling_project.product ON 
betting.ClassId = product.CLASSID 
AND 
betting.CategoryId = product.CATEGORYID
GROUP BY 
gambling_project.betting.BetDate, 
gambling_project.product.product
ORDER BY 
gambling_project.betting.BetDate, 
gambling_project.product.product;

/*Question 5 (Excel q: filter the data on pivot table for
 transactions that occured ion after Nov and for 
 Sportsbook and then calculate the totoals */
SELECT 
betting.BetDate AS betting_date,
gambling_project.product.product,
SUM(betting.Bet_Amt) AS total_amount_bet
FROM 
gambling_project.betting
JOIN
gambling_project.product ON 
betting.ClassId = gambling_project.product.classid 
AND 
betting.CategoryId = gambling_project.product.categoryid
WHERE 
STR_TO_DATE(betting.BetDate, '%d/%m/%Y') >= '2012-11-01'
AND gambling_project.product.product = 'Sportsbook'
GROUP BY 
betting.BetDate, 
gambling_project.product.product;

/* Question 6 (Excel q: ) */
SELECT 
betting.Product,
account.CurrencyCode,
customer.CustomerGroup,
SUM(betting.Bet_Amt) AS total_amount_bet
FROM 
betting
JOIN 
product ON
betting.ClassId = product.classid
AND betting.CategoryId = product.categoryid
JOIN
account ON
 betting.AccountNo = account.AccountNo
JOIN
customer ON 
account.CustId = customer.CustId
WHERE 
 STR_TO_DATE(betting.BetDate, "%d/%m/%Y") > '2012-12-01'
GROUP BY 
betting.Product, 
account.CurrencyCode, 
customer.CustomerGroup
ORDER BY 
betting.Product, 
account.CurrencyCode, 
customer.CustomerGroup;

/* Question 7 */
SELECT 
customer.Title,
customer.FirstName,
customer.LastName,
COALESCE(SUM(betting.Bet_Amt), 0) AS total_bet_amount
FROM 
customer
LEFT JOIN 
gambling_project.account ON
customer.CustId = account.CustId
LEFT JOIN 
betting ON 
account.AccountNo = betting.AccountNo
AND STR_TO_DATE(betting.BetDate, '%d/%m/%Y') >= '2012-11-01' 
AND STR_TO_DATE(betting.BetDate, '%d/%m/%Y') < '2012-12-01'
GROUP BY 
customer.Title,
customer.FirstName,
customer.LastName
ORDER BY 
customer.FirstName, 
customer.LastName;

/* Question 8 */
SELECT 
AccountNo, 
COUNT(DISTINCT Product) AS num_products
FROM 
betting
GROUP BY 
AccountNo;

SELECT 
AccountNo
FROM 
betting
WHERE 
Product IN ('Sportsbook', 'Vegas')
GROUP BY 
AccountNo
HAVING 
COUNT(DISTINCT Product) = 2;

/*Question 9 */
SELECT 
account.AccountNo,
customer.Title,
customer.FirstName,
customer.LastName,
SUM(CASE WHEN betting.Product = 'Sportsbook' THEN betting.Bet_Amt ELSE 0 END) AS sportsbook_bet_amount,
SUM(CASE WHEN betting.Product = 'Vegas' THEN betting.Bet_Amt ELSE 0 END) AS vegas_bet_amount
FROM 
betting
JOIN 
account ON 
betting.AccountNo = account.AccountNo
JOIN 
customer ON 
account.CustId = customer.CustId
WHERE 
betting.Bet_Amt > 0
GROUP BY 
account.AccountNo,
customer.Title,
customer.FirstName,
customer.LastName
HAVING 
SUM(CASE WHEN betting.Product = 'Sportsbook' THEN 1 ELSE 0 END) > 0
OR SUM(CASE WHEN betting.Product != 'Sportsbook' AND betting.Product != 'Vegas' THEN 1 ELSE 0 END) = 0;

/* Question 10 */
SELECT 
customer.Title,
customer.FirstName,
customer.LastName,
MAX(ranked_products.Product) AS Favorite_Product,
MAX(ranked_products.total_amount_bet) AS Max_Bet_Amount
FROM 
customer
JOIN 
account ON 
customer.CustId = account.CustId
JOIN 
betting ON 
account.AccountNo = betting.AccountNo
JOIN 
    (
        SELECT 
            account.CustId,
            product.Product,
            SUM(betting.Bet_Amt) AS total_amount_bet
        FROM 
            account
        JOIN 
            betting ON account.AccountNo = betting.AccountNo
        JOIN 
            product ON betting.ClassId = product.ClassId 
            AND betting.CategoryId = product.CategoryId
        GROUP BY 
            account.CustId, product.Product
    ) AS ranked_products 
ON 
account.CustId = ranked_products.CustId
GROUP BY 
customer.Title,
customer.FirstName,
customer.LastName
ORDER BY 
customer.Title,
customer.FirstName,
customer.LastName;

/* Question 11 */
SELECT 
student_name, 
GPA
FROM 
table_student
ORDER BY 
GPA DESC
LIMIT 5;

/* Question 12 */
SELECT 
table_school.school_id, 
table_school.school_name, 
table_school.city, 
COUNT(table_student.student_id) AS num_students
FROM 
table_school
LEFT JOIN table_student ON 
table_school.school_id = table_student.school_id
GROUP BY 
table_school.school_id, 
table_school.school_name, 
table_school.city;

/* Question 13 */
SELECT
    s.student_name,
    s.GPA,
    sc.school_name
FROM
    table_student s
JOIN
    table_school sc ON s.school_id = sc.school_id
WHERE
    (
        SELECT
            COUNT(*)
        FROM
            table_student s2
        WHERE
            s2.school_id = s.school_id
            AND s2.GPA >= s.GPA
    ) <= 3
ORDER BY   sc.school_name DESC;
