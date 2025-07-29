/*importent:
quarter: DATEPART(QUARTER, OrderDate)
pidyon(revenew) : sum(UnitPrice*Quantity) sumPidyon >> from orders o join [Order Details] od
isNull: isnull([colName],value to insert) 'new colName'
ROW_NUMBER() -> best >> desc
*/

--Q1
select employeeName, y, 
		coalesce([1],0) '1', isnull([2],0) '2', isnull([3],0) '3', isnull([4],0) '4'
from( 
	select FirstName + ' ' +LastName employeeName, YEAR(OrderDate) y, 
		DATEPART(QUARTER, OrderDate) qrt, UnitPrice*Quantity sumPidyon
	from Employees e join orders o
			on e.EmployeeID = o.EmployeeID 
		join [Order Details] od
			on o.OrderID=od.OrderID) T
pivot(
		sum(sumPidyon) 
		for qrt in ([1],[2],[3],[4] )
	 )pivorTable
order by employeeName, y

-- Q2
with CTE2
as(
	select e.EmployeeID, FirstName +' '+LastName fullName, Title,
			COUNT( distinct o.OrderID) totalOrders, 
			COUNT( distinct CustomerID) distinctCustomers,
			sum(UnitPrice*Quantity) revenew,
			ROW_NUMBER() over( order by COUNT( distinct o.OrderID) desc) ranking
	from Employees e left join Orders o
			on e.EmployeeID=o.EmployeeID
		left join [Order Details] od
			on o.OrderID=od.OrderID 
	group by e.EmployeeID ,FirstName +' '+LastName, Title
)

select fullName,totalOrders,distinctCustomers,revenew, revenew / (select sum(UnitPrice*Quantity)
																from [Order Details])  contribution
from CTE2
where totalOrders>0 and  
		title like 'Sales Representative' and
		ranking <=3
order by totalOrders desc

--Q3
select CustomerID, CompanyName, revenew, nuOfOrders, revenewRanking, revenew- LAG(revenew,1) over(order by revenew desc) 'diff From Proceedur Customer'
from(
		select c.CustomerID, CompanyName, sum(UnitPrice*Quantity) revenew, count(distinct o.OrderID) nuOfOrders, 
				ROW_NUMBER() over(order by sum(UnitPrice*Quantity) desc) revenewRanking
		from Customers c join Orders o
				on c.CustomerID=o.CustomerID
				join [Order Details] od
					on o.OrderID=od.OrderID
		where o.OrderDate between '1996-07-07' and '1997-07-07'
		group by c.CustomerID, CompanyName
	) t
where revenewRanking<=5


--Q4
create or alter procedure getTopCustomersByCategory @startDate Date, @endDate Date
as
	begin
		select*
		from(
				select c.CompanyName, c.CustomerID, cat.CategoryID, cat.CategoryName,  sum(od.UnitPrice *Quantity) sumRev,
						dense_rank() over(partition by (cat.CategoryID) order by sum(od.UnitPrice *Quantity) desc) catRank
				from Categories cat join Products p 
						on cat.CategoryID=p.CategoryID
					join [Order Details] od
						on p.ProductID = od.ProductID
					join Orders o
						on o.OrderID=od.OrderID
					join Customers c
						on c.CustomerID = o.CustomerID	
				where o.OrderDate between @startDate and @endDate 
				group by cat.CategoryID, cat.CategoryName, c.CompanyName, c.CustomerID )q
			where catRank<=3
			order by CategoryID, catRank
		end

execute getTopCustomersByCategory '1997-01-01', '1997-12-31'

--Q5
select c.CompanyName, sumRev1_1997, sumRev3_1997, countOrder1_1997+countOrder3_1997 countOrders, 
		countTotalOrders, tot.sumRev /(select sum(UnitPrice*Quantity)
										from [Order Details]) contribution
from Customers c join (select customerID, sum(UnitPrice*Quantity) sumRev1_1997, 
								count(distinct o.OrderID)countOrder1_1997
						from Orders o
							 join [Order Details] od
								on o.OrderID=od.OrderID
						where DATEPART(QUARTER, OrderDate) = 1 
								and Year(OrderDate) = 1997
						group by CustomerID)q1_1997
					on c.CustomerID= q1_1997.CustomerID
				join (
						select customerID, sum(UnitPrice*Quantity) sumRev3_1997, 
								count(distinct o.OrderID)countOrder3_1997
						from Orders o
								join [Order Details] od
								on o.OrderID=od.OrderID
						where DATEPART(QUARTER, OrderDate) = 3 
								and Year(OrderDate) = 1997
						group by CustomerID)q3_1997
					on q1_1997.CustomerID= q3_1997.CustomerID
				join (select CustomerID, count(distinct o.OrderID) countTotalOrders, 
								sum(UnitPrice*Quantity) sumRev
						from Orders o join [Order Details] od
								on o.OrderID=od.OrderID
						group by CustomerID) tot
					on q3_1997.CustomerID= tot.CustomerID
where tot.sumRev /(select sum(UnitPrice*Quantity)
					from [Order Details]) >0.08 
								








--Part B
--Q1
select CustomerID,
		case when sum(UnitPrice*Quantity)>10000 then 'platinum'
			when sum(UnitPrice*Quantity) between 5000 and 10000 then 'gold'
			when sum(UnitPrice*Quantity)between 1000 and 5000 then 'platinum'
			else 'bronze'
		end custumerRank
from orders o join [Order Details] od
			on o.OrderID=od.OrderID
where YEAR(OrderDate)=(YEAR(GETDATE()) -1)
group by CustomerID


--Q3
select ProductName, ROW_NUMBER() over(partition by MONTH(o.orderDate) order by sum(quantity*od.unitPrice) desc) ranking
from Products p join [Order Details] od
	on p.ProductID=od.ProductID
		join Orders o
		on o.OrderID=od.OrderID
group by ProductName, MONTH(o.orderDate)

