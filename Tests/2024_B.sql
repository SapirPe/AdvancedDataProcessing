--Q1
select CompanyName, Y, ISNULL([1],0) '1' ,ISNULL([2],0) '2',ISNULL([3],0) '3',
					ISNULL([4],0) '4',ISNULL([5],0) '5',ISNULL([6],0)'6',
					ISNULL([7],0) '7',ISNULL([8],0) '8',ISNULL([9],0)'9',
					ISNULL([10],0) '10',ISNULL([11],0) '11',ISNULL([12],0)'12'
from(
		select CompanyName, year(OrderID) Y,month(OrderID) M, OrderID
		from Shippers s join orders o	
			on s.ShipperID=o.ShipVia)src
pivot(count(OrderID)
for M in([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]))pvt
order by CompanyName, Y

--Q2
with SuppliersProductsSates
as(
	select s.SupplierID, CompanyName, count(distinct od.ProductID) countProd, 
		sum(Quantity) sumQan, 
		sum(Quantity*od.UnitPrice) sumRev,
		ROW_NUMBER() over( order by sum(Quantity*od.UnitPrice) desc) rowNum
	from Suppliers s left join Products p
			on s.SupplierID = p.SupplierID
		left join [Order Details] od
			on p.ProductID =od.ProductID
	group by s.SupplierID, CompanyName		
	)
select *,sumRev/(select sum(Quantity*UnitPrice)
				from [Order Details] ) teruma
from SuppliersProductsSates
where countProd >0 and rowNum <=3
order by rowNum

--Q3
SELECT EmployeeID, EmployeeName, TotalSalesValue,EmployeeRank,LargestOrderID,LargestOrderValue,EarliestOrderDate
FROM (
		 SELECT e.EmployeeID,
			 e.LastName +' ' + e.FirstName AS EmployeeName,
			 SUM(od.UnitPrice * od.Quantity) AS TotalSalesValue,
			 DENSE_RANK() OVER (ORDER BY SUM(od.UnitPrice * od.Quantity) DESC) AS EmployeeRank,
			 ROW_NUMBER() OVER (PARTITION BY e.EmployeeID ORDER BY SUM(od.UnitPrice * od.Quantity) DESC,o.OrderDate) AS RowNum,
			 FIRST_VALUE(o.OrderID) OVER (PARTITION BY e.EmployeeID ORDER BY SUM(od.UnitPrice *od.Quantity) DESC, o.OrderDate) AS LargestOrderID,
			 FIRST_VALUE(SUM(od.UnitPrice * od.Quantity)) OVER (PARTITION BY e.EmployeeID ORDER BY
			 SUM(od.UnitPrice * od.Quantity) DESC, o.OrderDate) AS LargestOrderValue,
			 FIRST_VALUE(o.OrderDate) OVER (PARTITION BY e.EmployeeID ORDER BY SUM(od.UnitPrice *od.Quantity) DESC) AS EarliestOrderDate
		 FROM Employees e JOIN Orders o
				ON e.EmployeeID = o.EmployeeID
			JOIN [Order Details] od
				ON o.OrderID = od.OrderID
		 WHERE o.OrderDate BETWEEN '1996-07-30' AND '1997-07-30'
		 GROUP BY e.EmployeeID, e.LastName, e.FirstName, o.OrderID, o.OrderDate
		) AS RankedEmployees
WHERE RowNum = 1
ORDER BY EmployeeRank

---Q3 תומר אמר שיוסי טעה במה שיוסי פתר למעלה.
--פתרון תומר:

select distinct q2.EmployeeID,
		q2.fullname,
		q2.sumQ,
		firstVal,
		topVal,
		topVdate,
		rowNum
from
		(select e.EmployeeID,
			   FirstName+' '+LastName fullname,
			   sum(Quantity*UnitPrice) sumQ ,
			   ROW_NUMBER() over (order by sum(Quantity*UnitPrice) desc) rowNum
		from Employees e join Orders o on e.EmployeeID = o.EmployeeID join [Order Details] od on o.OrderID = od.OrderID
		where DATEDIFF(DAY,OrderDate,1997-07-30)< 365
		group by e.EmployeeID,FirstName,LastName) q2
		join
		(select distinct e.EmployeeID,
			   FirstName+' '+LastName fullname,
			   o.orderid,
			   FIRST_VALUE(o.OrderID) over (partition by e.EmployeeID
											order by sum(Quantity*UnitPrice) desc) firstVal,
			   FIRST_VALUE(sum(Quantity*UnitPrice)) over (partition by e.EmployeeID
											order by sum(Quantity*UnitPrice) desc) topVal,
				FIRST_VALUE(o.orderdate) over (partition by e.EmployeeID
											order by sum(Quantity*UnitPrice) desc) topVdate,
			   sum(Quantity*UnitPrice) sumQ 
		from Employees e join Orders o on e.EmployeeID = o.EmployeeID join [Order Details] od on o.OrderID = od.OrderID
		where DATEDIFF(DAY,OrderDate,1997-07-30)< 365  
group by e.EmployeeID,FirstName,LastName,o.OrderID,o.orderdate) q1 on q2.EmployeeID = q1.EmployeeID
order by rowNum


--Q4
CREATE PROCEDURE GetProductSalesSummary
 @StartDate DATE,
 @EndDate DATE
AS
BEGIN
	 SELECT p.ProductID, p.ProductName,
			SUM(od.Quantity) AS TotalQuantitySold,
			SUM(od.UnitPrice * od.Quantity) AS TotalSalesValue,
			DENSE_RANK() OVER (ORDER BY SUM(od.UnitPrice * od.Quantity) DESC) AS ProductRank,
			AVG(od.UnitPrice * od.Quantity) AS AvgSalesValuePerOrder
	 FROM Products p LEFT JOIN [Order Details] od
				ON p.ProductID = od.ProductID
			LEFT JOIN Orders o
				ON od.OrderID = o.OrderID
	 WHERE o.OrderDate BETWEEN @StartDate AND @EndDate
	 GROUP BY p.ProductID, p.ProductName;
END;

exec GetProductSalesSummary '1997-01-01', '1997-12-31'


--Q5
select Country, 
COUNT(distinct c.CustomerID) countCus,
count(distinct o.OrderID) countOrder
,AVG(Quantity) avgQuan,
count(distinct od.ProductID)
from customers c join Orders o
	on c.CustomerID=o.CustomerID
	join [Order Details] od
	on o.OrderID = od.OrderID
group by Country
having count(distinct(o.OrderID)) > (select max(c) - min(c)
									from (select CustomerID, count(*) c
											from orders
											where CustomerID in ('ALFKI', 'QUICK')
											GROUP BY CustomerID) q1
									)
			

