select YEAR(OrderDate) Y, MONTH(OrderDate) M, SUM(Quantity*UnitPrice) sumRev
from orders o join [Order Details] od
on o.OrderID = od.OrderID
group by GROUPING sets(
			(YEAR(OrderDate),MONTH(OrderDate)),
			(YEAR(OrderDate)),
			(MONTH(OrderDate)),
			()
			)

--coalesce

select FirstName + '' +LastName fullName, City, coalesce(Region, 'לא מוקצה') region
from Employees



--coalesce

select CustomerID, coalesce(Region, city, 'אזור לא ידוע') region
from Customers


--Q1
select year(OrderDate) Y, ShipCountry, CustomerID, sum(UnitPrice*Quantity) sumRev,
	GROUPING(year(OrderDate)) isSummaryShipYearCustomer,
	GROUPING(ShipCountry) isSummaryYear,
	GROUPING(CustomerID) isYearShip
from orders o join [Order Details] od
		on o.OrderID= od.OrderID
group by rollup (YEAR(OrderDate), ShipCountry, CustomerID)
order by isSummaryShipYearCustomer,isSummaryYear,isYearShip

--Q3

select EmployeeID,
CustomerID,
sum(Quantity*UnitPrice) sumRev,
case when GROUPING(EmployeeID)=1 and GROUPING(CustomerID)=1 then 'Total'
	 when GROUPING(EmployeeID)=1 then 'Customer Summery' -- Employee null= customer not null
	 when GROUPING(CustomerID)=1 then 'Emploee Summery'
	 else 'Details'
	 end Summery
from Orders o join [Order Details] od
			on o.OrderID=od.OrderID
group by GROUPING sets((EmployeeID,CustomerID),
						(EmployeeID),
						(CustomerID),
						())

--Q4
select CustomerID, coalesce (Address, 'unknown')+','+coalesce (City, 'unknown')+','
					+coalesce (Region, 'unknown')+','+coalesce(Country, 'unknown') fullAddress
from Customers


--Q5
--select
--from orders o join [Order Details] od
--on o.OrderID=od.OrderID
--join Products on


--functions
--1
create function dbo.GetEmploeeAge (@birthdate datetime)
returns int
as --התחלת החישובים
	begin  --תתחיל
		return datediff(YEAR, @birthdate, getDate())
	end

--2
create function dbo.GetCustomerOrders(@customerID nvarchar(5))
returns table 
as return (
			select *
			from orders
			where CustomerID= @customerID
			)

--3
create function dbo.GetLowStockProducts()
returns @GetLowStockProducts table --טבלה חדשה שיצרתי
				(productID int, productName nvarchar(40), unitsInStock smallint) --העמודות בטבלה החדשה
as 
	begin insert into @GetLowStockProducts 
								select productID, ProductName, UnitsInStock
								from Products
								where UnitsInStock<10
		return 
	end
		
		
--Q1
create function dbo.GetTopCustomersByYear( @year datetime)
returns table
as return (
			select  top 1 c.CustomerID, CompanyName, count(*) countOrders
			from customers c join orders o 
			on c.CustomerID=o.CustomerID
			where year(OrderDate) = @year
			group by c.CustomerID, CompanyName
			order by countOrders desc
			) 
