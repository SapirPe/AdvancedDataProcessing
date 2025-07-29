--לכל לקוח כמה רכישות ביצע
select CustomerID,count(OrderID) NumOrder
from Orders 
group by CustomerID
--אם לא משתמשים בטבלה לא נביא אותה בכלל!

--שלב 2: יצירת טבלה זמנית שנוכל לשמור כמה הזמנות היו מכל כמות
select CustomerID,count(OrderID) NumOrder
into #temp1 --תוצר של חישוב- אפשר לעשות פעולות מתמטיות
from Orders 
group by CustomerID

select NumOrder, count(CustomerID) NumCustomers
from #temp1
group by NumOrder





select ProductName,CategoryName,sum(Quantity*od.UnitPrice) sumRev
from Categories C join Products P
on c.CategoryID=p.CategoryID
join [Order Details] OD 
on p.ProductID = OD.ProductID
where p.ProductID in(
						select ProductID
						from Orders o join [Order Details] OD
						on o.OrderID=OD.OrderID
						where OrderDate<(
											select dateadd(MONTH,3,min(OrderDate))
											from Orders
										 )
					  )
					  group by p.ProductID,ProductName,CategoryName


select CompanyName
from Suppliers s join Products p
	on s.SupplierID=p.SupplierID
	where ProductID in (
						--כל מוצר כמה פעמים נמכר,תחזיר רק מי שנמכר יותר מ30 פעמים בשנה
						select distinct p.ProductID
						from Products p join [Order Details] OD
							on p.ProductID=OD.ProductID
							join orders o
							on o.OrderID = od.OrderID
						group by p.ProductID, YEAR(OrderDate)
						having count(*) >30 --ספירה כמה פעמים המוצרים חוזרים בהזמנות השונות
)

select QW.ManagerName,
		QW.EmployeeID, 
		e1.FirstName +''+ e1.LastName FullName1,
		e1.EmployeeID, 
		e2.FirstName +''+ e2.LastName FullName2,
		e2.EmployeeID
from Employees e1 join Employees e2 
	on e1.EmployeeID>e2.EmployeeID --כל העובדים
	join
		(select EmployeeID, FirstName +''+ LastName ManagerName
		from Employees e)QW
		on QW.EmployeeID=e2.ReportsTo --רק מנהלים
where e1.ReportsTo=e2.ReportsTo

--Q4
select c.CategoryName, ProductName, AVG(UnitPrice) avgUp
from Categories c join Products p
on c.CategoryID=p.CategoryID
where p.ProductName like '[DMB]%' or p.ProductID like '314838707'
group by c.CategoryID, c.CategoryName, p.ProductName
having AVG(UnitPrice)>(
						select AVG(UnitPrice) avgPriceForSeafood
						from Categories c join Products p
						on c.CategoryID=p.CategoryID
						where c.CategoryName like 'Seafood')

--Q5
select c.CustomerID, c.CompanyName, c.Country, QF.sumFreight, 
		Q_REV.sumRev,QF.C_D,QF.sumFreight/Q_REV.sumRev YAHAS
from Customers c join
					(select CustomerID, SUM(Freight) sumFreight, COUNT(orderID) C_D
					 from Orders o
					 group by o.CustomerID) QF
				on c.CustomerID=QF.CustomerID
				join
					(select o.CustomerID, SUM(Quantity*UnitPrice) sumRev
					from orders o join [Order Details] OD
							on o.OrderID=OD.OrderID
					group by o.CustomerID) Q_REV
				on QF.CustomerID=Q_REV.CustomerID
where QF.sumFreight / Q_REV.sumRev >0.07


--Q6
select c.CompanyName, count(*) totalOrders,avg(Freight), 
		avg(Freight)/(
						select avg(Freight)
						from Customers c join Orders o
						on c.CustomerID=o.CustomerID
						where c.CompanyName like 'the big cheese') Ratio
from Customers c join Orders o
on c.CustomerID=o.CustomerID
group by c.CustomerID, CompanyName
having AVG(Freight)<66
order by Ratio desc



