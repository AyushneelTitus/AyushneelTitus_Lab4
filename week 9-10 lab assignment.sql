-- 3)	Display the total number of customers based on gender who have placed orders of worth at least Rs.3000.

select cus_gender, count(cus_gender)
from customer
where cus_id in 
	(select o.cus_id from `order` o
	inner join supplier_pricing sp
	on o.pricing_id = sp.pricing_id 
	group by o.cus_id
	having sum(sp.supp_price) >= 3000)
group by cus_gender;

-- 4)	Display all the orders along with product name ordered by a customer having Customer_Id=2

select product.pro_name as product_name, `order`.*
from product, `order`, supplier_pricing
where `order`.cus_id=2 and product.pro_id=supplier_pricing.pro_id
	and supplier_pricing.pricing_id=`order`.pricing_id;

-- 5)	Display the Supplier details who can supply more than one product

select * from supplier where supp_id in (select supp_id from supplier_pricing group by supp_id having count(supp_id) > 1);

-- 6)	Find the least expensive product from each category and print the table with
--      category id, name, product name and price of the product

select ct.cat_id, ct.cat_name, p.pro_name, sp.supp_price as price
from category ct, product p, supplier_pricing sp
where (ct.cat_id, sp.supp_price) in 
	(select ct.cat_id, min(sp.supp_price)
	from category ct, product p, supplier_pricing sp
	where ct.CAT_ID = p.CAT_ID and p.PRO_ID = sp.PRO_ID
	group by ct.CAT_ID)
    and ct.CAT_ID = p.CAT_ID and p.PRO_ID = sp.PRO_ID;
    
-- 7)	Display the Id and Name of the Product ordered after “2021-10-05”.

select p.PRO_NAME as product_name
from product p
inner join supplier_pricing sp
on p.PRO_ID = sp.PRO_ID
inner join `order` o
on sp.PRICING_ID = o.PRICING_ID
where o.ORD_DATE > '2021-10-05';

-- 8)	Display customer name and gender whose names start or end with character 'A'.

select cus_name, cus_gender
from customer
where cus_name like 'A%' or cus_name like '%A';

-- 9)	Create a stored procedure to display supplier id, name, rating and Type_of_Service.
--      For Type_of_Service, If rating =5, print “Excellent Service”,If rating >4 print “Good Service”,
--      If rating >2 print “Average Service” else print “Poor Service”.

USE `order-directory`;
DROP procedure IF EXISTS `new_procedure`;

DELIMITER $$
USE `order-directory`$$
CREATE PROCEDURE `new_procedure` ()
BEGIN
	select s.supp_id, s.supp_name, r.rat_ratstars, 
    case
		when r.rat_ratstars = 5 then 'Excellent Service'
        when r.rat_ratstars >= 4 then 'Good Service'
        when r.rat_ratstars >= 2 then 'Average Service'
        else 'Poor Service'
	end as Type_of_Service
    from supplier s
    inner join supplier_pricing sp
    on sp.supp_id=s.supp_id
    join `order` o
    on sp.pricing_id=o.pricing_id
    join rating r
    on o.ord_id=r.ord_id;
END$$

call new_procedure;