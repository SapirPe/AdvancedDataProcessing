--Q1
create or alter procedure GetTopCustomersByCategory @start_date date, @end_date date
as
begin
	select*
	from(
		--לכל לקוח: סכום פדיון ממוצרי הקטגוריה, ודירוג המכירות שלו בקטגוריה
		select c.CustomerID, CompanyName, cat.CategoryID, CategoryName, sum(od.UnitPrice*Quantity) sumRev, 
			dense_rank () over(partition by cat.CategoryID order by sum(od.UnitPrice*Quantity) desc) denseRankSumRev
		from Customers c join Orders o
					on c. CustomerID=o.CustomerID
				join [Order Details] od
					on o.OrderID=od.OrderID
				join Products p
					on p.ProductID=od.ProductID
				join Categories cat
					on cat.CategoryID=p.CategoryID
		where cast(OrderDate as date) between @start_date and @end_date 
		group by c.CustomerID, CompanyName, cat.CategoryID, CategoryName) Q1
	where denseRankSumRev<=3
	order by CategoryID, denseRankSumRev
END


EXEC GetTopCustomersByCategory '1997-01-01', '1997-12-30'

--Q2
create or alter procedure GetEmployeeOrderSummery @empID int
as
	select o.OrderID, OrderDate, CompanyName, count(distinct ProductID) countProducts, sum(od.UnitPrice*Quantity ) sumRev,
	RANK() over(order by sum(od.UnitPrice*Quantity) desc) revRank
	from  Customers c join Orders o 
			on c.CustomerID=o.CustomerID
		join [Order Details] od
			on o.OrderID=od.OrderID
	where EmployeeID=@empID
	group by O.OrderID, OrderDate, CompanyName
	order by revRank

EXEC GetEmployeeOrderSummery 2

--Q3
create or alter procedure CalculateCustomerRevenue @year int, @minRev money
as
	select c. CustomerID, CompanyName, sum(od.UnitPrice*(1-Discount)*Quantity) sumRev
	from Customers c join Orders o 
			on c.CustomerID=o.CustomerID
		join [Order Details] od
			on o.OrderID=od.OrderID
	where YEAR(OrderDate)=@year 
	group by c. CustomerID, CompanyName
	having sum(od.UnitPrice*(1-Discount)*Quantity) >=@minRev
	order by sumRev desc

EXEC CalculateCustomerRevenue 1997, 5000
