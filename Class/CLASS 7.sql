--Q1
create or alter trigger UpdateProductQuantity
on [Order Details]
after insert
as
	begin
	--����� �� ������ ���
		declare @quantity smallint, 
				@prodId int
	--����� ������� �� ������ ������� ����� ������
		select @quantity = inserted.Quantity,
			   @prodId = inserted.ProductID
		from inserted

	--����� >������ ����� ������
		update Products
		set UnitsInStock = UnitsInStock - @quantity
		where ProductID = @prodId
	end

--Q2
create or alter trigger UpdateProductQuantity
on [Order Details]
after insert
as
	begin
	--����� �� ������ ���
		declare @quantity smallint, 
				@prodId int
	--����� ������� �� ������ ������� ����� ������
		select @quantity = inserted.Quantity,
			   @prodId = inserted.ProductID
		from inserted

	--����� >������ ����� ������
	if @quantity> (select ProductID
					from Products
					where ProductID = @prodId)
		rollback
	else
		begin
			update Products
			set UnitsInStock = UnitsInStock - @quantity
			where ProductID = @prodId
		end
	end

--Q3
--������� �������
select Year(OrderDate) orderYear,CompanyName,count(OrderID) countOrers
from Shippers sh join Orders o
	on sh.ShipperID=o.ShipVia
group by Year(OrderDate), CompanyName, ShipperID
order by orderYear

--pivot
select*
from
	(select Year(OrderDate) orderYear,CompanyName, OrderID
	from Shippers sh join Orders o
		on sh.ShipperID=o.ShipVia) T
pivot (count(OrderID)
		for CompanyName in ([Speedy Express],[UPS], [United Package], [Federal Shipping])) pivotTable
order by orderYear

--Q4
select p.ProductID, ProductName, DATEPART(QUARTER,orderDate) qrt, count(o.OrderID)
from Orders o join [Order Details] od
			on o.OrderID=od.OrderID
			join Products p 
			on p.ProductID=od.ProductID
where YEAR(OrderDate) =1997
group by p.ProductID, ProductName, DATEPART(QUARTER,orderDate) 

--PIVOT
select*
from(
		select p.ProductID, ProductName, datepart(QUARTER,orderDate) qrt, o.OrderID
		from Orders o join [Order Details] od
			on o.OrderID=od.OrderID
			join Products p 
			on p.ProductID=od.ProductID
		where YEAR(OrderDate) =1997)T
pivot (count(orderID)
	for qrt in ([1],[2],[3],[4])) pivottTablt
order by ProductID

--Q4
select*
from 
	(select p.ProductID, ProductName, 
			sum(case when month(OrderDate) between 1 and 3 then 1 end) qrt1,
			sum(case when month(OrderDate) between 4 and 6 then 2 end) qrt2,
			sum(case when month(OrderDate) between 7 and 9 then 3 end) qrt3,
			sum(case when month(OrderDate) between 10 and 12 then 4 end) qrt4
	from Orders o join [Order Details] od
				on o.OrderID=od.OrderID
				join Products p 
				on p.ProductID=od.ProductID
	where YEAR(OrderDate) =1997
	group by p.ProductID, ProductName) X
unpivot (countProducts --�� ������ ������
		for qrt in ([qrt1],[qrt2],[qrt3],[qrt4])) unPiv


--Q5
begin transaction
--����� ������ 1 100 ���
update accounts --����
set balance -=100
where accountID=1
--����� ������ 2 100 ���
update accounts --����
set balance +=100
where accountID=2

rollback transaction
commit transaction

--Q6
begin transaction
--����� ������ �����
insert into Orders(CustomerID, OrderDate)
	values('ALFKI',GETDATE())
save transaction savepoint1

--������ 5 ������ ������ �� ���� 1
update Products
set UnitsInStock-=5
where ProductID=1

rollback transaction savepoint1

commit transaction


--Q7
begin try
		begin transaction
		--����� ����� ���� ����� ������
		insert into Orders --�� ������ ��� ����� ������
						(CustomerID, EmployeeID,OrderDate,RequiredDate,ShipVia,Freight,ShipName,
						ShipAddress,ShipCity,ShipRegion,ShipPostalCode,ShipCountry)
		values('alfki',1,GETDATE(),DATEDIFF(day,7,GETDATE()),1,10.00,
				'Ship Name','Ship Address','Ship City','Ship Region',123456,'USA')
		--����� ���� ����� ������
		declare @newOrderId int= scope_identity() --����� ���� ���� ����� �� ������ �������
		--����� ����� ����� ���� �����
		insert into [Order Details]
						(OrderID,ProductID,UnitPrice,Quantity,Discount)
		values('New OrderID',1,(select UnitPrice --�� ������ ��� ����� �� ���� ������� �� ���� ���� 1
								from Products
								where ProductID=1),2,0)
		--����� ����
		update Products
		set UnitsInStock -= 2
		where ProductID = 1

		commit transaction
end try

begin catch
--�������� ��������� ������ �����
	if @@TRANCOUNT >0 --�� �� ����� ����������
		rollback transaction --�� ����� ������� �� ���� ���
	
	declare @ErorMessage nvarchar(4000), --����
			@ErorSeverity int, --��� �����
			@ErorState int --���

	select @ErorMessage = ERROR_MESSAGE(),
			@ErorSeverity = ERROR_SEVERITY(),
		 @ErorState = ERROR_STATE()
RAISERROR (@ErorMessage,@ErorSeverity,@ErorState)



end catch
