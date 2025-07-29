--Q1
select Country, DATEPART(QUARTER, OrderDate) QuarterOrder, sum(o.Freight) FreightAmount, 
		count(distinct c.CustomerID) numOfCustomers, count (*) countOrders
from Customers c left join Orders o
	on c.CustomerID=o.CustomerID
where c.Country like '[SF]%'
group by C.Country, DATEPART(QUARTER, OrderDate)
having sum(o.Freight)>500
order by Country


--Q2
select e.EmployeeID, LastName, FirstName, City, max(OrderDate) lastOrderDate, SUM(Freight) sumFreight
from Employees e join Orders o
	on e.EmployeeID=o.EmployeeID
where e.City in('London' ,'Seattle') and LastName like '[DB]%' 
group by e.EmployeeID, LastName, FirstName, City
order by City desc, LastName desc


--Q3
select CompanyName, OrderDate
from Shippers sh inner join orders o
	on sh.ShipperID=o.ShipVia
where MONTH(ShippedDate) not between 6 and 8


--Q4
select p.ProductName +'#'+s.CompanyName supNameAndProdName, Quantity, OD.UnitPrice*Quantity revenue,
		OrderDate, DATEDIFF(YEAR, OrderDate, GETDATE()) yearsFromOrder
from Suppliers s inner join Products p
	on s.SupplierID=p.SupplierID
	inner join [Order Details] OD 
		on p.ProductID=od.ProductID
		inner join Orders O
			on O.OrderID = OD.OrderID
where Year(OrderDate) in (1997,1998) and Quantity not between 10 and 80