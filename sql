# MSSQL
訂票機制





--訂單資料表
DROP TABLE IF EXISTS subscription
--產品資料表
DROP TABLE IF EXISTS products
GO
--產品資料表
CREATE TABLE products
(product_id int primary key ,
 product_name varchar(100),
 stock int)
GO

CREATE TABLE subscription
(sub_id int identity primary key, 
 product_id int constraint fk_product_id foreign key references products(product_id) , 
 amount int)
GO
--驗證
insert into products(product_id,product_name,stock) values(100,'iPHONE6',100)
insert into products(product_id,product_name,stock) values(200,'iPHONE7',100)
GO
SELECT * FROM products
GO


/*
--新增訂單，自動修改庫存
insert into subscription(sub_id,product_id,amount) values(1,100,40)
insert into subscription(sub_id,product_id,amount) values(2,100,10)
GO

*/




Create  proc [dbo].[buyNewPhone]
 @type int,
 @amount int
  as 
  begin 
  Begin Transaction [roll_back]
  Create Table #tempTable(
  stock int
  )
  
  declare @stock int
  declare @usageAfter int
  --declare @usage int
  select @stock = sum(stock) 
  FROM [Farmdata].[dbo].products
         where    product_id = @type
  --select @usage = sum(amount) 
  --FROM [Farmdata].[dbo].subscription
  --       where    product_id like N'%'+@type+'%'
		 
  insert into subscription(product_id,amount) values(@type,@amount)
  update products 
      set stock=@stock-@amount 
	  OUTPUT INSERTED.stock 
	  into #tempTable
	  where    product_id =@type
	  select @usageAfter = stock FROM #tempTable
  if(@usageAfter<0)
      begin 
        Rollback  Transaction [roll_back] 
      end
  else
      begin 
        Commit  Transaction [roll_back] 
      end
end
GO
exec [buyNewPhone]  100,30
