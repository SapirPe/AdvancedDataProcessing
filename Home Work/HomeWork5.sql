--Q1
with EmployeeRank 
as(
	select LastName+' '+ FirstName as 'employeeName',Title,
			count(distinct o.OrderID) countOrders,
			count(distinct o.CustomerID) countCustomers,
			sum(UnitPrice*Quantity) sumSales,
			rank() over(order by sum(UnitPrice*Quantity) desc) employeeRank			
	from Employees e join Orders o
			on e.EmployeeID = o.EmployeeID
		join [Order Details] od
			on o.OrderID= od.OrderID

	group by e.EmployeeID, FirstName, LastName, Title
)
select *, sumSales/(select SUM(UnitPrice*Quantity) totalRev
			from [Order Details]
			)employeeRev
from  EmployeeRank er 
where EmployeeRank<=3
order by countOrders desc



--Q2

with EmployeeRank 
as(
	select e.EmployeeID, LastName+' '+ FirstName as 'employeeName', count(*) countOrders,
			DENSE_RANK() over(order by count(*) desc ) denseRankOrders,
			ROW_NUMBER() over(order by count(*) desc ) RowNum,
			LAG(LastName+' '+ FirstName,1, 0) over(order by count(*)) 'nextRankEmploee' ,
			LEAD(LastName+' '+ FirstName,1, 0) over(order by count(*)) 'previousRankEmploee'
	from Employees e join Orders o
			on e.EmployeeID=o.EmployeeID
	group by e.EmployeeID, FirstName, LastName
  )
select EmployeeID,employeeName,countOrders,denseRankOrders,
		ROUND((countOrders* 100 / (select count(*)
									from Orders)) , 2) orderPrecentage,
		previousRankEmploee, nextRankEmploee
from EmployeeRank
where RowNum<=3