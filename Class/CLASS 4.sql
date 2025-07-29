-- OVER --
	--q1
	select COUNT(*) over() catCount, sum(UnitPrice) over() catSum
	from Products 
	where CategoryID IN (2,3)

	--with group by
	SELECT COUNT(*) CAT_COUNT,
	 SUM(unitprice) CAT_SUM
	FROM products
	WHERE CategoryID IN (2, 3)
	Group By CategoryID
	--with over
	SELECT COUNT(*) Over() CAT_COUNT,
	 SUM(unitprice) Over () CAT_SUM
	FROM products
	WHERE CategoryID IN (2, 3)
	--with partition by
	SELECT COUNT(*) Over(Partition By CategoryID) CAT_COUNT,
	 SUM(unitprice) Over (Partition By CategoryID) CAT_SUM
	FROM products
	WHERE CategoryID IN (2, 3)

	--q2 
	-- inside from
	select q1.ShipCountry, q1.ShipCity,q1.countCity,q2.countCountry
	from 
			(select ShipCountry,ShipCity, count(OrderID) countCity
			from Orders
			group by ShipCountry,ShipCity) Q1
		join 
			(select ShipCountry, count(OrderID) countCountry
			from Orders
			group by ShipCountry) Q2
		on q1.ShipCountry=q2.ShipCountry
	order by  ShipCountry,ShipCity

	-- inside select
	select ShipCountry, ShipCity, count(*) countContry,	
			(select count(*)
						from orders o
						where o.ShipCountry=o1.ShipCountry)
	from Orders o1
	order by  ShipCountry,ShipCity
	--over
	SELECT distinct shipCountry,
	 shipCity,
	 count(*) OVER(PARTITION BY ShipCountry, ShipCity) OrdersInCity,
	 count(*) OVER(PARTITION BY ShipCountry) OrdersInCountry
	FROM ORDERS
	ORDER BY ShipCountry, ShipCity
-- Rows / Range --
	--q3
	SELECT year(OrderDate) yearOrder,
	 UnitPrice,
	 sum(UnitPrice) over(partition by year(OrderDate)
	 order by year(orderDate)
	 rows between unbounded preceding and current row) Runnig_sum
	from Orders o join [Order Details] od
	 on o.OrderID = od.OrderID
	where CustomerID like 'alfki'
	--q4
	select o.OrderID, YEAR(OrderDate)y, MONTH(OrderDate)m, UnitPrice*Quantity sumRev,
		sum(UnitPrice*Quantity) over(partition by YEAR(OrderDate),MONTH(OrderDate) 
										order by OrderDate 
										rows between unbounded preceding and current row) MonthlySales
	from Orders o JOIN [Order Details] od
		on o.OrderID=od.OrderID
-- Row_Number --
	--q5
	SELECT year(OrderDate) orderYear,
	 UnitPrice,
	 ROW_NUMBER() over(partition by year(OrderDate)
	 order by OrderDate) Row_Num
	from Orders o join [Order Details] od
	 on o.OrderID = od.OrderID
	where CustomerID like 'ALFKI'
	--q6
	SELECT OrderID,
	 year(OrderDate) orderYear,
	 ShipCountry,
	 EmployeeID,
	 ROW_NUMBER() over(partition by EmployeeID
	 order by OrderID) Row_Num
	from Orders o
	where ShipCountry like 'canada' AND
	 year(OrderDate) = 1998
	--q7
	select *
	from
	 (SELECT OrderID,
	 year(OrderDate) orderYear,
	 ShipCountry,
	 EmployeeID,
	 ROW_NUMBER() over(partition by EmployeeID
	 order by OrderID) Row_Num
	 from Orders o
	 where ShipCountry like 'canada' AND
	 year(OrderDate) = 1998) orderPerEmp
	where Row_Num = 1
	--q8
	select *
	from (select YEAR(OrderDate) Y,CustomerID, ShipCountry, 
				   sum(Quantity*UnitPrice) sumRev, 
				   count(distinct o.OrderID) numOrders, 
				   count(distinct ProductID) countProd,
				   ROW_NUMBER() over(partition by YEAR(OrderDate), ShipCountry
								order by sum(Quantity*UnitPrice) desc, 
								count(distinct o.OrderID)desc, 
								count(distinct ProductID)desc) rowNum
			from Orders o join [Order Details] od
					on o.OrderID=od.OrderID
			group by YEAR(OrderDate),CustomerID, ShipCountry) yearlyScore
	where rowNum between 1 and 5 ;

-- Rank / Dense Rank --
	--q9
	SELECT ProductID, ProductName, UnitPrice,
		RANK() over(order by UnitPrice desc) priceRank
	from Products

-- NTILE --
--q10
	SELECT ProductID, ProductName, UnitPrice,
		NTILE(4) over(order by UnitPrice desc) priceRank
	from Products
	WHERE UnitPrice < 10
	order by priceRank

-- LAG / LEAD --
	--q11
	SELECT ProductID,ProductName,UnitPrice,
		LAG(UnitPrice,1) over(order by UnitPrice) 'Lag',
		LEAD(UnitPrice, 1) over(order by UnitPrice) 'Lead'
	from Products
	order by UnitPrice

-- First Value / Last Value --
	--q12
	SELECT e.EmployeeID, FirstName +' '+LastName FullName, ShipCountry,
		 sum(Quantity * UnitPrice) SumRev,
		FIRST_VALUE(sum(Quantity * UnitPrice)) over(order by sum(Quantity * UnitPrice) desc) BestSeller,
		Last_Value(sum(Quantity * UnitPrice)) over(order by sum(Quantity * UnitPrice) desc
						rows between unbounded preceding and unbounded following) WorstSeller,
		FIRST_VALUE(sum(Quantity * UnitPrice)) over(partition by e.EmployeeID
				order by sum(Quantity * UnitPrice) desc) BestSeller
	from Employees e join Orders o
		on e.EmployeeID = o.EmployeeID
	 join [Order Details] od
		on o.OrderID = od.OrderID
	group by e.EmployeeID, FirstName, LastName, ShipCountry

