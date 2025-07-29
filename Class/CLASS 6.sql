--Q1
create or alter procedure orderByYearReported @year int
as
	--גוף:
	select count(distinct o.OrderID) numOrders,
			count(distinct o.CustomerID) numCustomers,
			sum(Quantity) sumQuan,
			sum(Quantity*UnitPrice) sumRev
	from Orders o inner join [Order Details] od
			on o.OrderID=od.OrderID
	where YEAR(OrderDate) = @year --שם המשתנה
 --קודם להריץ את הפרוסידר לראות שנשמר טוב

exec orderByYearReported 1997


--Q2
create or alter procedure GetCustomerOrderByYear @customerId nchar(5), @year int
as
	select o.OrderID, OrderDate, count(ProductID) numOfProducts
	from  Orders o inner join [Order Details] od
			on o.OrderID=od.OrderID
	where o.CustomerID like @customerId  and YEAR(o.OrderDate) =@year
	group by  o.OrderID, OrderDate

exec GetCustomerOrderByYear alfki, 1998


--Q3
create or alter procedure CreatNewOrder @customerId nchar(5), @req_date date
as
	if not exists( --נרצה לבדוק את הקיים
			select*
			from Customers
			where CustomerID= @customerId 
	)
	print 'No Such Customer!'
	else
		insert into Orders(CustomerID, OrderDate, RequiredDate) --כל שאר העמודות יהיו ריקות
		values(@customerId, GETDATE(), @req_date)

exec CreatNewOrder alfki, '2025-06-01'
exec CreatNewOrder shark, '2025-06-01'


--Q4
create or alter procedure DeleteNewOrder @customerId nchar(5), @req_date date
as
	if not exists( --נרצה לבדוק את הקיים
			select*
			from Customers
			where CustomerID= @customerId 
	)
	print 'No Such Customer!'
	else
		delete from Orders
		where CustomerID=@customerId and 
				cast(OrderDate as date)= cast(GETDATE() as date) and RequiredDate = @req_date

exec DeleteNewOrder alfki, '2025-06-01'
exec DeleteNewOrder shark, '2025-06-01'


--Q5
create or alter procedure ShippedByDate @startDate date, @endDate date
as
	if @startDate is null or @endDate is null
		begin
			print 'Null Values Are Not Allowed!'
			return 
		end
	select ShippedDate, OrderID
	from Orders
	where ShippedDate between @startDate and @endDate

exec ShippedByDate null, '1996-12-31'


--Q6
create or alter procedure GetProductDetails @prodID int, 
											@unitPrice money output, 
											@catID int output
as
	select @unitPrice=UnitPrice,
			@catID=CategoryID
	from Products
	where ProductID=@prodID

	if @@ROWCOUNT =0
		return -1
	else
		return 0


--Q7
create or alter proc GetCheaperProduct @prodID int
as
	declare @unitPrice money, 
			@catID int, 
			@result int
		
	exec @result= GetProductDetails @prodID, @unitPrice output, @catID output -- מחזיר 0 או מינוס 1
	
	if @result<0
		begin
			print 'product nut found'
			return
		end
	select ProductID, ProductName, UnitPrice
	from Products
	where CategoryID=@catID and
		UnitPrice<@unitPrice
	order by UnitPrice

exec GetCheaperProduct 1
exec GetCheaperProduct 100

--Q8
create or alter proc GetCheaperProductInStock @prodID int,
											  @stock int
as
	declare @res table(ID int, pName nvarchar(40), price money)
	insert into @res
	exec GetCheaperProduct @prodID

		select ID, pName, price, UnitsInStock
		from @res r join Products p
			on r.ID=p.ProductID
		where UnitsInStock>=@stock

exec GetCheaperProductInStock 1,50


-------------
