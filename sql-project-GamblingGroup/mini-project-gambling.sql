/* Gambling Group */
USE gambling_project;

/*changing the columns id names*/ 
ALTER TABLE accounts CHANGE ï»¿Account_No account_no VARCHAR(50);
ALTER TABLE accounts ADD PRIMARY KEY (account_no);
ALTER TABLE accounts CHANGE CustId customer_id INT;

ALTER TABLE bets CHANGE ï»¿bet_id bet_id INT;
ALTER TABLE bets ADD PRIMARY KEY (bet_id);
ALTER TABLE bets CHANGE `Class_ id` CLASS_ID VARCHAR(50);
ALTER TABLE bets CHANGE Category_id CATEGORY_ID INT ;
ALTER TABLE bets CHANGE Account_no account_no VARCHAR(50);

/*missing class id and category id in bets table*/
ALTER TABLE bets 
	ADD CONSTRAINT fk_account_number FOREIGN KEY (account_no) references accounts(account_no),
    ADD CONSTRAINT fk_class_id FOREIGN KEY (CLASS_ID) REFERENCES products(CLASS_ID);
    ADD CONSTRAINT fk_category_id FOREIGN KEY (CATEGORY_ID) REFERENCES products(CATEGORY_ID);

ALTER TABLE customers CHANGE `ï»¿Cust_ id` customer_id INT ;
ALTER TABLE customers ADD PRIMARY KEY (customer_id);

ALTER TABLE products CHANGE ï»¿CLASS_ID CLASS_ID varchar(50);
ALTER TABLE products ADD PRIMARY KEY (CLASS_ID);


/* question 1*/
SELECT 
	Title, 
    First_name,
    Last_name,
    Date_of_birth
FROM customers ;

/*question 2*/
Select 
	Customer_group,
    Count(distinct customer_id)
from customers
GROUP BY customer_group;

/*question 3*/
SELECT 
	cu.customer_id,
    Title,
    First_name,
    Last_name,
    Country_code,
    CurrencyCode
from customers cu left join accounts ac on cu.customer_id = ac.customer_id;

/*question 4*/
SELECT 
	pd.product,
    pd.sub_product,
    count(distinct bet_id) as 'Number of bets'
FROM bets b left join products pd on b.CLASS_ID = pd.CLASS_ID AND b.CATEGORY_ID = pd.CATEGORY_ID
group by pd.product, pd.sub_product ;

/* all of the information is already in bets table*/
SELECT 
    bet_date,
    Product,
    sum(bet_amt) as total_bet
FROM bets 
group by bet_date, Product;

/*joining bets and product table */
SELECT 
	bet_date, 
    pd.product,
    sum(bet_amt) as total_bet_amt
FROM bets b
	left join products pd on b.CLASS_ID = pd.CLASS_ID
group by bet_date, pd.product;

SELECT 
	bet_date, 
    pd.product,
	b.product
FROM bets b
	left join products pd on b.CLASS_ID = pd.CLASS_ID
group by bet_date, pd.product, b.product;

/*Question 5 */
SELECT 
	bet_date, 
    pd.product,
	sum(bet_amt) as total_bet_amt
FROM bets b left join products pd on b.CLASS_ID = pd.CLASS_ID
WHERE str_to_date(bet_date, '%d/%m/%Y') >= '2012-11-01' AND pd.product like '%Sportsbook%' 
GROUP by bet_date, pd.product, b.product
;

SELECT 
    MONTH(STR_TO_DATE(bet_date, '%d/%m/%Y')) AS bet_month,
    pd.product,
    sum(bet_amt) as total_bet_amt
FROM bets b
LEFT JOIN products pd ON b.CLASS_ID = pd.CLASS_ID
WHERE STR_TO_DATE(bet_date, '%d/%m/%Y') >= '2012-11-01' AND pd.product like '%Sportsbook%' 
GROUP BY bet_month, pd.product
ORDER BY bet_month ASC;

/* question 6*/
SELECT 
	c.Customer_group,
    pd.product,
    ac.CurrencyCode,
    sum(bet_amt) as total_bet_amt
FROM bets b 
	LEFT JOIN products pd ON b.CLASS_ID = pd.CLASS_ID AND b.CATEGORY_ID = pd.CATEGORY_ID
	left join accounts ac on b.account_no = ac.account_no	
    left join customers c on ac.customer_id = c.customer_id
WHERE str_to_date(bet_date, '%d/%m/%Y') >= '2012-12-01'
GROUP by pd.product, ac.CurrencyCode, c.Customer_group
;

SELECT 
	c.Customer_group,
    pd.product,
    ac.CurrencyCode,
    sum(bet_amt) as total_bet_amt
FROM bets b 
	LEFT JOIN products pd ON b.CLASS_ID = pd.CLASS_ID AND b.CATEGORY_ID = pd.CATEGORY_ID
	left join accounts ac on b.account_no = ac.account_no	
    left join customers c on ac.customer_id = c.customer_id
WHERE str_to_date(bet_date, '%d/%m/%Y') >= '2012-12-01'
GROUP by pd.product, ac.CurrencyCode, c.Customer_group
;

/*question 7 */ 
Select 
	Title, 
    First_name,
    Last_name,
    sum(bet_amt) as total_bet_amt
from accounts ac 
	left join customers cu on ac.customer_id = cu.customer_id
    left join bets b on ac.account_no = b.account_no
WHERE str_to_date(bet_date, '%d/%m/%Y') >= '2012-11-01' AND str_to_date(bet_date, '%d/%m/%Y') <= '2012-11-30'
GROUP BY title, First_name, Last_name
;

/*question 8 */ /*need to review it */
Select 
	p.product,
    count(distinct cu.customer_id) AS 'Number of Customers',
    count(distinct ac.account_no) AS 'Number of Accounts'
from accounts ac 
	left join customers cu on ac.customer_id = cu.customer_id
    left join bets b on ac.account_no = b.account_no
    left join products p on b.CLASS_ID = p.CLASS_ID
WHERE b.bet_amt > 0
GROUP BY p.product;

SELECT 
    cu.customer_id,
    cu.Title,
    cu.First_name,
    cu.Last_name,
    COUNT(DISTINCT p.product) AS number_of_products
FROM accounts ac
    LEFT JOIN customers cu ON ac.customer_id = cu.customer_id
    LEFT JOIN bets b ON ac.account_no = b.account_no
    LEFT JOIN products p ON b.CLASS_ID = p.CLASS_ID
WHERE 
    b.bet_amt > 0 AND (p.product LIKE '%Sportsbook%' OR p.product LIKE '%Vegas%')
GROUP BY cu.customer_id, cu.Title, cu.First_name, cu.Last_name
HAVING COUNT(DISTINCT p.product) = 2;

/*question 9*/

SELECT 
    cu.Title,
    cu.First_name, 
    cu.Last_name, 
    ac.account_no,
    p.product,
    SUM(b.bet_amt) AS total_bet_amt
FROM 
    accounts ac
    LEFT JOIN customers cu ON ac.customer_id = cu.customer_id
    LEFT JOIN bets b ON ac.account_no = b.account_no
    LEFT JOIN products p ON b.CLASS_ID = p.CLASS_ID
WHERE 
    p.product LIKE '%Sportsbook%' 
    AND b.bet_amt > 0
    AND ac.account_no NOT IN (
        SELECT DISTINCT b1.account_no
        FROM bets b1
        LEFT JOIN products p1 ON b1.CLASS_ID = p1.CLASS_ID
        WHERE p1.product NOT LIKE '%Sportsbook%'
    )
GROUP BY cu.Title, cu.First_name, cu.Last_name, ac.account_no, p.product;


/* Question 10 */ /*need to review it */

SELECT 
    main.customer_id,
    main.First_name,
    main.Last_name,
    main.product AS favorite_product,
    main.total_bet_amt AS maximum_bet
FROM (
    SELECT 
        cu.customer_id,
        cu.First_name,
        cu.Last_name,
        p.product,
        SUM(b.bet_amt) AS total_bet_amt,
        RANK() OVER (PARTITION BY cu.customer_id ORDER BY SUM(b.bet_amt) DESC) AS player_rank
    FROM 
        bets b 
        INNER JOIN accounts ac ON b.account_no = ac.account_no
        INNER JOIN customers cu ON ac.customer_id = cu.customer_id
        INNER JOIN products p ON b.CLASS_ID = p.CLASS_ID
    WHERE 
        b.bet_amt > 0
    GROUP BY 
        cu.customer_id, 
        cu.First_name, 
        cu.Last_name, 
        p.product
) AS main
WHERE main.player_rank = 1;


/*question 11*/
CREATE DATABASE schools;
 
USE schools;

Select * 
from students stu
ORDER BY stu.GPA DESC
Limit 5;

/*question 12*/
SELECT 
	ss.ï»¿school_id,
    ss.school_name,
    count(distinct stu.ï»¿student_id) as 'Number of students'
FROM schools ss
	left join students stu on stu.school_id = ss.ï»¿school_id
group by ss.ï»¿school_id, ss.school_name;

/*question 13*/
SELECT 
    ï»¿student_id,
    student_name,
    GPA,
    u.school_name
FROM (
    SELECT 
        s.ï»¿student_id,
        s.student_name,
        s.GPA,
        s.school_id,
        ROW_NUMBER() OVER (PARTITION BY s.school_id ORDER BY s.GPA DESC) AS student_rank
    FROM 
        students s
) AS ranked_students
INNER JOIN schools u ON ranked_students.school_id = u.ï»¿school_id
WHERE 
    ranked_students.student_rank <= 3
ORDER BY 
    ranked_students.school_id, ranked_students.student_rank;


