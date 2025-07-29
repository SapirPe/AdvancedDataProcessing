--Q1
select coalesce(ShipCountry, 'Ship_Total')ShipCountry, 
		coalesce(cast(CategoryID as varchar), 'Category_Total')CategoryID,
		coalesce(cast(YEAR(OrderDate) as varchar), 'Year_Total') orderYear
,		sum(Quantity*od.UnitPrice) sumSales
from orders o join [Order Details] od
		on o.OrderID=od.OrderID
	join Products p 
		on p.ProductID=od.ProductID
group by rollup (ShipCountry, CategoryID, YEAR(OrderDate))

--Q2
select CustomerID, p.ProductID, SUM(od.UnitPrice*Quantity) sumSales
from orders o join [Order Details] od
		on o.OrderID=od.OrderID
	join Products p 
		on p.ProductID=od.ProductID
group by cube (CustomerID, p.ProductID)

--Q3
create function dbo.PriceAfterDiscount (@unitPrice money, @quantity smallint, @discount real)
returns money
as --התחלת החישובים
	begin  --תתחיל
		return @quantity*@unitPrice*(1-@discount)
	end

select OrderID, ProductID, dbo.PriceAfterDiscount(UnitPrice, Quantity, Discount) 'final price'
from [Order Details]
order by [final price] desc



--Q4
create function dbo.convertMoney(@unitPrice money, @quantity smallint,@currencyRate money)
returns money
as --התחלת החישובים
	begin  --תתחיל
		return @unitPrice*@quantity*@currencyRate
	end

select coalesce(ShipCountry, 'Total Year')ShipCountry, 
	   coalesce(cast(YEAR(OrderDate) as varchar), 'Total Country') orderYear,
	   sum(dbo.convertMoney(unitPrice , quantity ,0.96))
from orders o join [Order Details] od
	on o.OrderID=od.OrderID
where o.ShipCountry in ('Austria','Belgium','Finland','France','Germany','Ireland','Italy','Portugal','Spain')
group by GROUPING sets((ShipCountry, YEAR(o.OrderDate)),
					   (ShipCountry),
					   (YEAR(o.OrderDate)))
order by ShipCountry, orderYear

