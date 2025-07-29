--Q1
create or alter trigger UpdateDiscount
on [Order Details]
after update
as
	begin
		update [Order Details]
		set Discount = case when i.Quantity>= 50 then 0.1 else 0 
	end
	from [Order Details] od join inserted i
		on od.OrderID=i.OrderID and od.ProductID=i.ProductID
end

--Q2
/*
����� ����� �����, ����� ���� �����.
���� ����� ��� ������ ������ ����:
 
 ����� ����� �����: �.� �� ����,
 ��� ������: �����/�����

 ���� �� ������ ������� ���� ��� INSERTED

 ��"� ����� ���� �� ������ �����:
 �� �� �����: ���� ����� ����� �����, ����� �� ����� ��� = ����� ��� �����
 �� ����� ������ ���

 
 �� �� �����: ���� ����� ����� �����, ����� �� ����� ��� = ����� ��� �����
 �� ����� ������ ���
*/

/*����� �� ����:

.1 ����� ����� ���� �����:
a. ����� ����� ��� UpdateInventoryOnBorrow ������ ���� ����� ����� ����
���� BorrowedBook.
b. ���� ������, ����� �� ����� �� ���� ������ 1 ����� Books.
.2 ����� ����� ���� �����:
a. ����� ����� ��� UpdateInventoryOnReturn ������ ���� ����� ����� �����
 .BorrowedBook
b. ���� ������, ����� �� ����� �� ���� ������ 1 ����� Boo*/
--


--Q3
/*����� ����� ����� ������� ����� ���� ����� Like:
a. ����� ����� ��� UpdateUserActivityOnLike ������ ���� ����� ����� �����
 .Likes
b. ���� ������, ����� �� ���� UserActivity ������ 1 ������ LikesCount ��
������ ���� ����.
.2 ����� ����� ���� ����� �����:
a. ����� ����� UpdateUserActivityOnComment ������ ���� ����� ����� �����
 .Comments
b. ���� ������, ����� �� ���� UserActivity ������ 1 ������ CommentsCount
�� ������ ����� ����*/

--Q4
select FirstName + ' '+ LastName fullName,DATEPART(QUARTER,orderDate) qrt,YEAR(OrderDate) orderYear,sum(Quantity*UnitPrice) sumRev
from Employees e join Orders o 
		on e.EmployeeID=o.EmployeeID
	join [Order Details] od
		on o.OrderID=od.OrderID
group by firstName + ' '+ LastName ,DATEPART(QUARTER,orderDate),YEAR(OrderDate)

--
select fullName,orderYear,
isnull([1],0) '1',
 isnull([2],0) '2',
 isnull([3],0) '3',
 isnull([4],0) '4'
from
	(select FirstName + ' '+ LastName fullName,
		DATEPART(QUARTER,orderDate) qrt,
		YEAR(OrderDate) orderYear, Quantity*UnitPrice totalSale
	from Employees e join Orders o 
			on e.EmployeeID=o.EmployeeID
		join [Order Details] od
			on o.OrderID=od.OrderID) T
pivot (sum(totalSale)
	for qrt in ([1],[2],[3],[4])) pivottTablt

--Q5
select*
from
	(select firstName + ' '+ LastName fullName, Year(OrderDate) orderYear,
		(Quantity*UnitPrice*(1-Discount)) totalSale
	from Employees e join Orders o 
				on e.EmployeeID=o.EmployeeID
			join [Order Details] od
				on o.OrderID=od.OrderID)T
pivot (sum(totalSale)
	for orderYear in ([1996],[1997],[1998])) pivottTablt
order by [1996] + [1997] + [1998] DESC

--Q6
begin transaction 
	update Products
	set UnitsInStock -= 3
	where ProductID = 1

	if (select UnitsInStock
		from Products
		where ProductID = 1) <0
		begin
			rollback transaction
			print 'NEGATIV UNITS'
		end
	else
		begin
			commit transaction
			print 'success'
		end


--Q7
begin try
	begin transaction
		update Orders
			set Freight *= 0.9
			where CustomerID = 'ALFKI'
			
	commit transaction
end try

begin catch
	if @@TRANCOUNT >0 --�� �� ����� ����������
		rollback transaction --�� ����� ������� �� ���� ���
	print ERROR_MESSAGE()
end catch

