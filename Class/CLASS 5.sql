--q1
with prodactsAndCategories(catName, prodName, UnitPrice)
AS(
	select c.CategoryName, ProductName, UnitPrice
	from Categories c join Products p  
		on c.CategoryID=p.CategoryID
	where UnitPrice>10
)
select*
from prodactsAndCategories

--q2
with ProdactRenking
as( 
	-- המספרים ממוספרים בסדר יורד מהיקר לזול בכל קטגוריה
	select ProductID, ProductName, CategoryID, UnitPrice,
			ROW_NUMBER() over(partition by CategoryID
						order by UnitPrice desc) ProdRank
	from Products
)
select*
from ProdactRenking
where ProdRank=1

--q3
with customersSales
AS(
	select CustomerID, sum(UnitPrice*Quantity) sumRev
	from Orders o join [Order Details] od
		on o.OrderID = od.OrderID
	group by CustomerID
)
select CustomerID, sumRev, rank() over(order by sumRev desc) salesRank
from customersSales

--q4
if DATEPART(DW,GETDATE())=6 OR  DATEPART(DW,GETDATE())=7
	begin
		print 'It is the weekend'
		print 'time to party'
	end
else
	begin
		print 'It is a weekday'
		print 'time to go to work :('
	end

--q5
declare @value int =15
if @value>10
	print 'above 10'
else
	print 'below 10'

--q6
declare @num int =0
while @num<5
begin
	print 'Hello Word'
	set @num+=1
end

--q7
declare @i int =1
while @i<10
begin
	if(@i<>7)
		print @i
	set @i+=1
	if @i=9
		break
end

--q8
declare @catNumber int,
		@catName nvarchar(15)
set @catNumber=4
label: -- שם ייחודי ללולאה
--הצגת פרטי הקטגוריה
	select*
	from Categories
	where CategoryID = @catNumber
--השמת השם של הקטגוריה
	select @catName=CategoryName
	from Categories
	where CategoryID=@catNumber

	set @catNumber+=1
	if @catName like '%a%' goto label
	else
	select 'no more categories with the letter A'


--q9
create function dbo.Fibonacci(@N int)
returns int
as
begin 
	if @N<=1
		return @N
	return  dbo.Fibonacci(@N -1) +  dbo.Fibonacci(@N -2)
end

select dbo.Fibonacci(10) as fib

--q10
create function dbo.Factorial(@Num int)
returns int
as
begin
	if @Num<=1 
		return 1
	return @Num *  dbo.Factorial(@Num -1)
end

select  dbo.Factorial(5) as fact

--q11
with EmploeeHierarchy
as(
		select EmployeeID, FirstName+' '+LastName fullName, ReportsTo, 
				1 level --שתלתי את הערך 1 בעמודה
		from Employees
		where ReportsTo is null

		union all --משרשר טבלאות אחת אחרי השניה, עם כפילויות
		
		select e.EmployeeID, e.FirstName+' '+e.LastName fullName, e.ReportsTo, eh.level +1
		from Employees e join EmploeeHierarchy eh
			on e.ReportsTo = eh.EmployeeID
)
select *
from EmploeeHierarchy
order by level, EmployeeID


--Q1
declare @price money
--שאילתת השמה:
select @price=UnitPrice
from Products
where ProductID=9

if @price>50
	print 'I like this product'
else
	print 'I do noy like this product'

--Q2
--יצירת משתנה טבלאי
declare @productPrices table(ID int identity(1,1), productName nvarchar(40))
insert into @productPrices(productName)
values('chai'), ('tofu'), ('tarte au surce')

--יצירת משתנים
declare @prod_name nvarchar(40),
		@prod_price money,
		@counter int =1,
		@total int

--חישוב כמה פעמים נצטרך לרוץ בלולאה
select @total =count(*)
from @productPrices

while @counter <= @total
	begin
		select @prod_name=productName
		from @productPrices
		where id=@counter

		select @prod_price=UnitPrice
		from Products
		where ProductName=@prod_name

		if @prod_price <20
			set @prod_price *=1.1
		else
		if @prod_price >=20 and  @prod_price <40
			set @prod_price *=1.2
		else
		if @prod_price >=40 
			set @prod_price *=1.5
		print 'The new price of product' + @prod_name +'is' + cast(@prod_price as varchar(8))

		set @counter+=1
	end



--Q3
declare @empID int =1, 
		@emName nvarchar(20)
while @empID <=9
begin
	select @emName=LastName
	from Employees
	where EmployeeID=@empID

	if @emName like '%e%'
		print @emName
	set @empID+=1
end

--Q4
with customersOrders
as
(
	select CustomerID, MIN(OrderDate) firstOrder, MAX(OrderDate) lastOrder
	from Orders
	group by CustomerID
)
select *, DATEDIFF(DAY, firstOrder, lastOrder) daysBetween
from customersOrders