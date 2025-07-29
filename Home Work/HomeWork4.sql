--Q1
select *, NTILE(4) over(partition by CategoryID order by UnitPrice desc) priceGroup
from (select ProductID, ProductName, CategoryID, UnitPrice,
			rank() over(partition by CategoryID order by UnitPrice desc) RankInCategory
		from Products)ProdCategoryRank
where RankInCategory <= 3

--Q2
select OrderID, ProductID, UnitPrice,
		LAG(UnitPrice,1,0) over( partition by ProductID order by UnitPrice) previocPrice,
		UnitPrice -LAG(UnitPrice,1,0) over( partition by ProductID order by UnitPrice)  priceDifference,
		Lead(UnitPrice,1,0) over(partition by ProductID order by UnitPrice) price_nextOrder,
		Lead(UnitPrice,1,0) over(partition by ProductID order by UnitPrice) -UnitPrice nextPriceDifference
from [Order Details] 

--Q3
select CustomerID, OrderID,OrderDate,
		Last_Value(OrderDate) over(partition by CustomerID order by OrderDate desc
						rows between unbounded preceding and unbounded following ) lastOrder,
		FIRST_VALUE(OrderDate) over(partition by CustomerID order by OrderDate desc) firstOrder,
		DATEDIFF(DAY,Last_Value(OrderDate) over(partition by CustomerID order by OrderDate desc
						rows between unbounded preceding and unbounded following),
						FIRST_VALUE(OrderDate) over(partition by CustomerID order by OrderDate desc)) daysBetweenOrders
from Orders

--Q4
select *
from (
		select CategoryID, CustomerID ,sum(Quantity * od.UnitPrice) sumRev,
			RANK() over(partition by CategoryID order by sum(Quantity * od.UnitPrice) desc) custumerRank 
		from Orders o join [Order Details] od
				on o.OrderID=od.OrderID
			 join Products p
				on p.ProductID=od.ProductID
		group by CustomerID, CategoryID
	  )custumerRevRank --לכל קטגוריה דירוג של סכום מכירות לפי לקוח
where custumerRank=1

--Q5

select *, sumRev-LAG(sumRev,1,0) over(order by custumerRank) 'revDiff'
from (
		select c.CustomerID, CompanyName, 
			sum(Quantity * od.UnitPrice) sumRev,count(distinct o.OrderID) countOrders,
			RANK() over(order by sum(Quantity * od.UnitPrice) desc) custumerRank
		from Customers c join Orders o 
				on c.CustomerID=o.CustomerID
			join [Order Details] od
				on o.OrderID=od.OrderID				
		where OrderDate between '1996-07-07' and '1997-07-07'
		group by c.CustomerID, CompanyName
		)rankingCustomers
where custumerRank<=5

