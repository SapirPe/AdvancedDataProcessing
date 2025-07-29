grant select, insert on dbo.employees to user1

deny delete on dbo.employees to user1


--TDE Certificate

--יצירת מפתח ראשי
use master --המחשב שלי, הראש
go

create master key encryption by password = 'MyStrongPassword'
go

-- יצירת תעודה
create certificate TDE_Certificate with subject = 'TDE Certificate'
go

--יצירת מפתח הצפנה למסד הנתונים
use Northwind
go

create database encryption key
with algorithm = AES_256
encryption by server encryption TDE_Certificate
go

--הפעלת הצפנה
alter database Northwind
set encryption on
go




--------

--יצירת מפתח ראשי
use master --המחשב שלי, הראש
go

create master key encryption by password = 'AnotherStrongPassword'
go

-- יצירת תעודה
create certificate MyCert with subject = 'Encryption Certificate'
go

--יצירת מפתח סימטרי המשתמש בתעודהה
create symmetric key CreditCardKey
with algorithm = AES_256
encryption by certificate MyCert
go

--הצפנת נתון בעת הכנסת רשומה
--פתיחת תעודה להכנסת נתונים
open symmetric key CreditCardKey decryption by certificate MyCert 
--הכנסת נתונים:
insert into SensitivData(CustomerID, EncryptedCreditCard)
values ('ALFKI', ENCRYPTBYKEY(KEY_GUID('CreditCardKey'), '1234567891234'))

close symmetric key CreditCardKey
go

--הפענוח של הנתון
open symmetric key CreditCardKey decryption by certificate MyCert 

select customerID,
		convert(varchar(20)DECRYPTBYKEY(EncryptedCreditCard)) as CC
from SensitivData

close symmetric key CreditCardKey
go

declare @username nvarchar(50) = 'UserInput'
declare @sql nvarchar(4000) = N'select * from users where username = @username'

exec sp_executesql @sql, N'@user nvarchar(50)', @user = @username
