--Q1
select CompanyName, ContactName,Y, 
		ISNULL([1],0)'1', ISNULL([2],0)'2', ISNULL([3],0)'3', ISNULL([4],0)'4'
from (select CompanyName, ContactName, YEAR(OrderDate) Y, 
		DATEPART(QUARTER, OrderDate) q, Quantity*UnitPrice totalSales
		from Customers c join orders o 
			on c.CustomerID=o.CustomerID
			join [Order Details] od
				on o.OrderID=od.OrderID)src
pivot(avg(totalSales)
	for q in ([1],[2],[3],[4]))T

--Q2
with Top5ProfitProducts
as
(
		select p.ProductID, ProductName, sum(Quantity) sumQuan, 
			count( distinct CustomerID) countCustomers, 
			sum(Quantity*od.UnitPrice) sumRev,
			ROW_NUMBER() over(order by sum(Quantity*od.UnitPrice) desc) rowNum
		from orders o left join [Order Details] OD
				on O.OrderID=OD.OrderID
			left join Products p
				on p.ProductID=od.ProductID
		group by p.ProductID, ProductName
)

select *, round(sumRev/(select sum(Quantity*UnitPrice) from [Order Details])*100,2) contribution
from Top5ProfitProducts
where sumQuan>0 and rowNum<=5
order by sumRev DESC

--Q3
select*, avgMonthlyRev- LEAD(avgMonthlyRev,1) over(order by rowNum) diff
from(
	select e.EmployeeID, FirstName + ' ' + LastName fullName,
			MONTH(OrderDate) orderMonth,
			avg(Quantity*od.UnitPrice) avgMonthlyRev, 
			count(distinct O.OrderID) countOrders,
			ROW_NUMBER() over(order by AVG(Quantity*od.UnitPrice) desc) rowNum
	from Employees e join orders o  
				on e.EmployeeID=o.EmployeeID
			join [Order Details] OD
				on O.OrderID=OD.OrderID
	where OrderDate between '1996-07-07' and '1997-07-07'
	group by e.EmployeeID, FirstName + ' ' + LastName, MONTH(OrderDate))a
where rowNum<=5

--Q4
create or alter procedure GetEmployeeOrderSummery @empID int
as
begin
	select o.OrderID, OrderDate, CompanyName, 
		count(distinct ProductID) numOfProd, 
		sum(Quantity*od.UnitPrice) sumRev,
		Rank() over(order by sum(Quantity*od.UnitPrice) desc) orderRank
	from Customers c join Orders o
			on c.CustomerID = o.CustomerID
		join [Order Details] od
			on o.OrderID=od.OrderID
	where o.EmployeeID = @empID
	group by o.OrderID, OrderDate, CompanyName 
end
exec GetEmployeeOrderSummery 2


--Q5
select CompanyName, sumRev_1998_2,sumRev_1997_3, countOrder_1998_2+countOrder_1997_3 totalOrdersInQuarters_2_3,
		totalOrders, 
		totRev/(select count(Quantity*UnitPrice) 
								from Orders o join [Order Details] od
										on o.OrderID=od.OrderID) teruma
from Customers c join (select o.CustomerID, sum(Quantity*UnitPrice) sumRev_1998_2, 
											count(distinct o.OrderID) countOrder_1998_2
						from orders o join [Order Details] od
								on o.OrderID=od.OrderID
						where year(o.OrderDate)=1998 and  DATEPART(QUARTER, o.OrderDate) =2
						group by o.CustomerID
						)Q_2_1998
				 on c.CustomerID=Q_2_1998.CustomerID
				 join
					(select o.CustomerID, sum(Quantity*UnitPrice) sumRev_1997_3, 
										  count(distinct o.OrderID) countOrder_1997_3
						from orders o join [Order Details] od
							on o.OrderID=od.OrderID
						where year(o.OrderDate)=1997 and  DATEPART(QUARTER, o.OrderDate) =3
						group by o.CustomerID
					) Q_3_1997
				 on Q_2_1998.CustomerID=Q_3_1997.CustomerID
				 join (
						 select o.customerID, sum(Quantity*UnitPrice) totRev, count(distinct o.orderID) totalOrders
						 from orders o join [Order Details] od
							on o.OrderID=od.OrderID
						group by o.customerID
						) Q_all
				on Q_3_1997.CustomerID=Q_all.CustomerID
where totRev/
			(select sum(Quantity*UnitPrice) 
			from Orders o join [Order Details] od
				on o.OrderID=od.OrderID) 
			<0.02

