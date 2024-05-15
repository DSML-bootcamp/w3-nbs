USE `Gambling_BBDD`;

#Question 1
SELECT Title, FirstName, LastName, DateOfBirth
FROM customer;

#Question 2
SELECT CustomerGroup, COUNT(*) AS NumberOfCustomers
FROM customer
GROUP BY CustomerGroup
LIMIT 100;

#Question 3
SELECT c.*, a.CurrencyCode
FROM Customer c
JOIN Account a ON c.CustId = a.CustId;

#Question 4
SELECT p.product, b.BetDate, SUM(b.Bet_Amt) AS TotalBetAmount
FROM Betting b
JOIN product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
GROUP BY p.product, b.BetDate
ORDER BY p.product, b.BetDate;


#Question 5
SELECT 
    p.product,
    b.BetDate,
    SUM(b.Bet_Amt) AS TotalBetAmount
FROM 
    Betting b
JOIN 
    product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE b.BetDate >= '2012-11-01' AND p.product = 'Sportsbook'
GROUP BY 
    p.product, b.BetDate
ORDER BY 
    p.product, b.BetDate;

#Question 6
SELECT p.product, a.CurrencyCode, c.CustomerGroup, SUM(b.Bet_Amt) AS TotalBetAmount
FROM Betting b
JOIN product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
JOIN Account a ON b.AccountNo = a.Accountno
JOIN Customer c ON a.CustId = c.CustId
WHERE b.BetDate >= '2012-12-01'
GROUP BY p.product, a.CurrencyCode, c.CustomerGroup
ORDER BY p.product, a.CurrencyCode, c.CustomerGroup;

#Question 7
SELECT c.Title, c.FirstName, c.LastName, COALESCE(SUM(b.Bet_Amt), 0) AS TotalBetAmount
FROM Customer C
LEFT JOIN Account a ON c.CustId = a.CustId
LEFT JOIN Betting b ON a.AccountNo = b.AccountNo AND b.BetDate >= '2022-11-01' AND b.BetDate < '2022-12-01'
GROUP BY 
    c.Title, c.FirstName, c.LastName
ORDER BY 
    c.LastName, c.FirstName;


SELECT c.Title, c.FirstName, c.LastName, COUNT(DISTINCT p.product) AS NumberOfProducts
FROM Customer c
JOIN Account a ON c.CustId = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo
JOIN product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
GROUP BY c.Title, c.FirstName, c.LastName
ORDER BY NumberOfProducts DESC;

#Question 8
SELECT c.Title, c.FirstName, c.LastName
FROM Customer c
JOIN Account a ON c.CustId = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo
JOIN product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE p.product IN ('Sportsbook', 'Vegas')
GROUP BY c.Title, c.FirstName, c.LastName
HAVING COUNT(DISTINCT p.product) > 1;

#Question 9
SELECT c.Title, c.FirstName, c.LastName, SUM(CASE WHEN p.product = 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) AS SportsbookBetAmount
FROM Customer c 
JOIN Account a ON c.CustId = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo AND b.Bet_Amt > 0
JOIN product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE p.product = 'Sportsbook'
    AND NOT EXISTS (
        SELECT 1
        FROM Betting b2
        JOIN product p2 ON b2.ClassId = p2.CLASSID AND b2.CategoryId = p2.CATEGORYID
        WHERE b2.AccountNo = b.AccountNo AND p2.product != 'Sportsbook' AND b2.Bet_Amt > 0
    )
GROUP BY
    c.Title, c.FirstName, c.LastName;

#Question 10
WITH PlayerBets AS (
    SELECT c.Title, c.FirstName, c.LastName, p.product, SUM(b.Bet_Amt) AS TotalBetAmount,
        ROW_NUMBER() OVER (PARTITION BY c.CustId ORDER BY SUM(b.Bet_Amt) DESC) AS RowNumber
    FROM Customer c
    JOIN Account a ON c.CustId = a.CustId
    JOIN Betting b ON a.AccountNo = b.AccountNo
    JOIN product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
    GROUP BY c.CustId, c.Title, c.FirstName, c.LastName, p.product
)
SELECT Title, FirstName, LastName, product AS FavoriteProduct, TotalBetAmount
FROM PlayerBets
WHERE RowNumber = 1;

#Question 11
SELECT student_id, student_name, city, school_id, GPA, school_name, school_city
FROM student_school
ORDER BY GPA DESC
LIMIT 5;

#Question 12
SELECT school_name, COALESCE(COUNT(student_id), 0) AS NumberOfStudents
FROM student_school
GROUP BY school_name;

#Question 13
