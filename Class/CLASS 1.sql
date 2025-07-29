
--Q1
select *
from Customers c left join Orders O
on c.CustomerID=O.CustomerID
where c.Country in ('USA', 'Germany', 'France') or DATEPART(QUARTER	, OrderDate)%2=0 AND ShipRegion is null


--Q2
select P.ProductName +'?314838707' newProductName, Quantity, 
		DATEPART(QUARTER, ShippedDate) shippedQ, 
		DATEDIFF(day,OrderDate, ShippedDate) DaySince
from Orders o join [Order Details] OD on O.OrderID=OD.OrderID
			join Products p on p.ProductID=OD.ProductID
where YEAR(OrderDate) = 1997 AND Quantity not between 30 and 100

--Q3
select s.CompanyName, SUM(Quantity*UnitPrice) sumRev, count(*) cOrders
from Shippers s join Orders O
	on s.ShipperID= O.ShipVia
	join [Order Details] OD
	on O.OrderID=OD.OrderID
where YEAR(O.OrderDate)=1996 and 
	(DATEPART(QUARTER, OrderDate)=1 OR MONTH(OrderDate) in (7,8))
group by ShipperID, CompanyName
having SUM(Quantity*UnitPrice)>300 


--Q4
select c.CategoryName, 
	sum(Quantity*od.UnitPrice) sumRev,
	avg(Quantity) avgQuan,
	count(distinct p.ProductID) countProducts
from Categories c join  Products p
	on c.CategoryID=p.CategoryID
	join [Order Details] OD
	on p.ProductID=OD.ProductID
	join Orders O
	on o.OrderID=od.OrderID
where od.UnitPrice<p.UnitPrice and
YEAR(OrderDate)=1996
group by c.CategoryID, c.CategoryName


--Q6
select DATEPART(QUARTER, OrderDate) Q, MONTH(OrderDate) M,
avg(Quantity*od.UnitPrice) avgRev
from Orders O join [Order Details] OD
	on O.OrderID=OD.OrderID 
	join Products p 
	on p.ProductID=OD.ProductID	
where p.UnitPrice=od.UnitPrice
group by DATEPART(QUARTER, OrderDate), MONTH(OrderDate) 
having sum(Quantity)<5000
order by Q,M

--Q7
select ProductID,
UnitPrice,
case when UnitPrice<100 then 'cheap'
 when UnitPrice between 100 and 150 then 'regular'
  when UnitPrice>150 then 'expensive'
  end category,
  case when UnitsInStock<=10 then 'Order needed'
  else 'no order needed'
  end InventoryStatus
from Products

--Q8
select C.CustomerID, c.CompanyName,
 case when COUNT(o.OrderID) = 1 then N'רגיל'
 when COUNT(o.OrderID) between 2 and 4 then N'מתמיד'
 when COUNT(o.OrderID) > 4 then N'נאמן'
 else 'Nמבלבל מוח'
end as Category
from Customers C left join Orders O
 on C.CustomerID = O.CustomerID
group by C.CustomerID, CompanyName