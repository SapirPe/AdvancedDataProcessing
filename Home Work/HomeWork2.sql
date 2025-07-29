--Q1
select c.CategoryName, sum(Quantity) sumQuantity
from Categories c join Products p
		on c.CategoryID=p.CategoryID
	  join [Order Details] OD
		on p.ProductID=OD.ProductID
where c.CategoryName NOT like 'B%'
group by c.CategoryName
having AVG(Quantity)> (
						select  AVG(Quantity) avgQuantity
						from Categories c join Products p
								on c.CategoryID=p.CategoryID
							  join [Order Details] OD
								on p.ProductID=OD.ProductID
						)

--Q2
SELECT CategoryName, sumUnitsStock, sumQuantity
from( SELECT c.CategoryID,CategoryName,sum(UnitsInStock) sumUnitsStock
	  from Categories c join Products p
			on c.CategoryID = p.CategoryID
	  group by c.CategoryID, CategoryName
	 ) InStock
	join
	( SELECT c.CategoryID, sum(Quantity) sumQuantity
	  from Categories c join Products p
			on c.CategoryID = p.CategoryID
		join [Order Details] od
			on p.ProductID = od.ProductID
		join Orders o
			on o.OrderID = od.OrderID
	  where MONTH(OrderDate) = 4 AND YEAR(OrderDate) = 1998
	  group by c.CategoryID
	 ) Quantities
	on InStock.CategoryID = Quantities.CategoryID

--Q3
select c.CompanyName, sumRevQuarter1 'Revenue 97_1',sumRevQuarter3 'Revenue 97_3', orderQ3 + orderQ1 numOfOrdersQ1and3
		,customer.totalOrders , customerSumRev/(select sum(UnitPrice*Quantity)
												from [Order Details]) companyDonation
from Customers c join
					-- לכל חברה, סכום פדיון ברבעון 1, ומספר הזמנות ברבעון 1
					(select CustomerID, sum(UnitPrice*Quantity) sumRevQuarter1, count( distinct o.OrderID) orderQ1
						from Orders o join [Order Details] od
						on o.OrderID=od.OrderID
						where Year(OrderDate)=1997 and DATEPART(QUARTER, OrderDate)=1
						group by CustomerID 
					) Quarter1 
				on c.CustomerID=Quarter1.CustomerID
				join 
					-- לכל חברה, סכום פדיון ברבעון 3, ומספר הזמנות ברבעון 3
					(select CustomerID, sum(UnitPrice*Quantity) sumRevQuarter3, count(distinct o.OrderID) orderQ3
						from  Orders o join [Order Details] od
   						on o.OrderID=od.OrderID
						where Year(OrderDate)=1997 and DATEPART(QUARTER, OrderDate)=3
						group by CustomerID
					) Quarter3
				on Quarter1.CustomerID=Quarter3.CustomerID
				join 
					 (select CustomerID, count(distinct o.OrderID) totalOrders, sum(UnitPrice*Quantity) customerSumRev
					  from  Orders o join [Order Details] od
						 on o.OrderID = od.OrderID
					  group by CustomerID
					 )customer
				on c.CustomerID=customer.CustomerID
where customerSumRev/(select sum(UnitPrice*Quantity) totalRev
						from [Order Details]) >0.08
order by totalOrders 

--Q4
select c.CustomerID, count (o.OrderID) numOfOrders
from Customers c join Orders o
on c.CustomerID= o.CustomerID
where c.CustomerID in('QUICK', 'ALFKI')
group by c.CustomerID


select Country, count(distinct c.CustomerID) numOfCustomers, 
count(distinct o.OrderID) numOfOrders, 
AVG(Quantity) avgQuantity, 
count(distinct ProductID) numDiffProd
from Customers c join Orders o
			on c.CustomerID= o.CustomerID
	join [Order Details] od 
		on o.OrderID=od.OrderID
group by Country
having count(distinct o.OrderID)>( select MAX(C) - MIN(C)
									from (	select CustomerID, COUNT(*) C
											from Orders O
											where CustomerID IN ('ALFKI','QUICK')
											GROUP BY CustomerID
										 ) Q1
									)


