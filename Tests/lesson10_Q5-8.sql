--Q5

--a:
select OrderID, CustomerID, OrderDate
from Orders
where month(OrderDate) between 4 and 5
group by OrderID, CustomerID, OrderDate

--b:
select o.OrderID, p.UnitPrice unitCost, od.UnitPrice, Quantity, SupplierID, 
		sum(Quantity*od.UnitPrice) pidyon, 
		sum(Quantity*(p.UnitPrice-od.UnitPrice)) profit, 
		sum(Quantity*(p.UnitPrice-od.UnitPrice))/sum(Quantity*od.UnitPrice) ratio
from Orders o join [Order Details] od
		on o.OrderID=od.OrderID
	join Products p
		on p.ProductID = od.ProductID
where month(OrderDate) between 4 and 5
group by o.OrderID, p.UnitPrice, od.UnitPrice, Quantity, SupplierID

--c:
select SupplierID, CompanyName, Country
from Suppliers
group by SupplierID,CompanyName, Country

--d:
select o.OrderID, p.UnitPrice unitCost, od.UnitPrice, Quantity, s.SupplierID, CompanyName, Country,
		sum(Quantity*od.UnitPrice) pidyon, 
		sum(Quantity*(p.UnitPrice-od.UnitPrice)) profit, 
		sum(Quantity*(p.UnitPrice-od.UnitPrice))/sum(Quantity*od.UnitPrice) ratio
from Orders o join [Order Details] od
		on o.OrderID=od.OrderID
	join Products p
		on p.ProductID = od.ProductID
	join Suppliers s
		on s.SupplierID = p.SupplierID
where month(OrderDate) between 4 and 5
group by o.OrderID, p.UnitPrice, od.UnitPrice, Quantity, s.SupplierID,CompanyName, Country


--Q6
--מטלה 2

--Q7 
-- אותו עיקרון כמו 6

--Q8
--a:
select CustomerID, e.EmployeeID, DATEDIFF(DAY,ShippedDate,RequiredDate) dateDiff
from Employees e join Orders o
	on e.EmployeeID=o.EmployeeID
where YEAR(OrderDate)= 1996 AND DATEDIFF(DAY,ShippedDate,RequiredDate) >35
group by CustomerID, e.EmployeeID, RequiredDate, ShippedDate

--b:
select CustomerID, e.EmployeeID, DATEDIFF(DAY,ShippedDate,RequiredDate) dateDiff
from Employees e join Orders o
	on e.EmployeeID=o.EmployeeID
where YEAR(OrderDate)= 1997 AND DATEDIFF(DAY,ShippedDate,RequiredDate) >35
group by CustomerID, e.EmployeeID, RequiredDate, ShippedDate

--d:
select FirstName +' '+LastName fullName, TitleOfCourtesy
from Employees

--e:
select TitleOfCourtesy+' '+FirstName +' '+LastName fullName, 
	Y_1996.CustomerID, Y_1996.dateDiff dateDiff_1996, Y_1997.dateDiff dateDiff_1997
from	(select CustomerID, e.EmployeeID, DATEDIFF(DAY,ShippedDate,RequiredDate) dateDiff
		from Employees e join Orders o
			on e.EmployeeID=o.EmployeeID
		where YEAR(OrderDate)= 1997 AND DATEDIFF(DAY,ShippedDate,RequiredDate) >35
		group by CustomerID, e.EmployeeID, RequiredDate, ShippedDate) Y_1996
	join (select CustomerID, e.EmployeeID, DATEDIFF(DAY,ShippedDate,RequiredDate) dateDiff
			from Employees e join Orders o
				on e.EmployeeID=o.EmployeeID
			where YEAR(OrderDate)= 1997 AND DATEDIFF(DAY,ShippedDate,RequiredDate) >35
			group by CustomerID, e.EmployeeID, RequiredDate, ShippedDate)  Y_1997
		on Y_1996.CustomerID=Y_1997.CustomerID and Y_1996.EmployeeID=Y_1997.EmployeeID
		join Employees e
			on Y_1996.EmployeeID=e.EmployeeID
--group by TitleOfCourtesy+' '+FirstName +' '+LastName,Y_1996.CustomerID, Y_1996.dateDiff , Y_1997.dateDiff 

