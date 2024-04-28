--********************************************************************--
-- Summmary:
-- This sql file is to create a dynamic database, meaning that it will first check to see  if the database exist.  
-- If database does exist, then it will delete the database and recreate the database.
-- If database does not exist, then it will create a new database.
-- This will enable a programmable/modifiable database that is easy to use for portfolio demonstration.

-- This sql script relies on an Northwind Database.
-- If this is the first time setting up the environment to run this sql script, Create Northwind Demo Database.sql should be run first.

-- Functionalities:
-- Create Tables containing products, categories, and inventories.
-- Create a result with average inventory for 12 months


--********************************************************************--

--[ Create the Database ]--
--********************************************************************--
Use Master;
go
If exists (Select * From sysdatabases Where name='DatabaseGenesis')
  Begin
  	Use [master];
	  Alter Database DatabaseGenesis Set Single_User With Rollback Immediate; -- Kick everyone out of the DB
		Drop Database DatabaseGenesis;
  End
go
Create Database DatabaseGenesis;
go
Use DatabaseGenesis
go

--[ Create the Tables ]--
--********************************************************************--
Create Table dbo.Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table dbo.Customers
([CustomerID] [int] IDENTITY(1,1) NOT NULL
,[CompanyName] [nvarchar](100) NOT NULL
,[ContactName] [nvarchar](100) NOT NULL
,[Address] [nvarchar](100) NOT NULL
,[City] [nvarchar](100) NOT NULL
,[State] [nvarchar](100) NOT NULL
,[Phone] [nvarchar](100) NOT NULL
);
go

Create Table dbo.Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[InventoryCount] [int] NOT NULL
,[ProductID] [int] NOT NULL
);
go

Create Table dbo.Products
([ProductID] [int] IDENTITY(1,1) NOT NULL
,[ProductName] [nvarchar](100) NOT NULL
,[ProductPrice] [money] NULL
,[CategoryID] [int] NOT NULL
);
go


--[ Add Addtional Constaints ]--
--********************************************************************--
ALTER TABLE dbo.Categories
	ADD CONSTRAINT pkCategories PRIMARY KEY CLUSTERED (CategoryID),
		CONSTRAINT uCategoryName UNIQUE NonCLUSTERED (CategoryName);
go

ALTER TABLE dbo.Products
	ADD CONSTRAINT pkProducts PRIMARY KEY CLUSTERED (ProductID),
		CONSTRAINT uProductName UNIQUE NonCLUSTERED (ProductName),
		CONSTRAINT fkProductsCategories  
			FOREIGN KEY (CategoryID)
			REFERENCES dbo.Categories (CategoryID),
		CONSTRAINT pkProductsProductPriceMoreThanZero CHECK (ProductPrice > 0);
go

ALTER TABLE dbo.Inventories
	ADD CONSTRAINT pkInventories PRIMARY KEY CLUSTERED (InventoryID),
		CONSTRAINT fkInventoriesProducts
		FOREIGN KEY (ProductID)
		REFERENCES dbo.Products (ProductID),
		CONSTRAINT ckInventoriesMoreThanZero CHECK (InventoryCount >= 0),
		CONSTRAINT dfInventoriesCountIsZero DEFAULT (0)
			FOR [InventoryCount];
go

--[ Create the Views ]--
--********************************************************************--
Create View vCategories
As
  Select[CategoryID],[CategoryName] 
  From Categories;
;
go

Create View vProducts
As
  Select [ProductID],[ProductName],[CategoryID],[ProductPrice] 
  From Products;
;
go

Create View vInventories
As
  Select [InventoryID],[InventoryDate],[ProductID],[InventoryCount] 
  From Inventories
;
go

--[Insert Data ]--
--********************************************************************--
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, ProductPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Inventories
(InventoryDate, ProductID, [InventoryCount])
Select '20160101' as InventoryDate, ProductID, UnitsInStock + 1
From Northwind.dbo.Products
UNION
Select '20160201' as InventoryDate, ProductID, UnitsInStock + 5
From Northwind.dbo.Products
UNION
Select '20160302' as InventoryDate, ProductID, UnitsInStock + 7
From Northwind.dbo.Products
UNION
Select '20160402' as InventoryDate, ProductID, UnitsInStock + 2
From Northwind.dbo.Products
UNION
Select '20160502' as InventoryDate, ProductID, UnitsInStock + 3
From Northwind.dbo.Products
UNION
Select '20160602' as InventoryDate, ProductID, UnitsInStock + 8
From Northwind.dbo.Products
UNION
Select '20160702' as InventoryDate, ProductID, UnitsInStock + 10
From Northwind.dbo.Products
UNION
Select '20160802' as InventoryDate, ProductID, UnitsInStock + 15
From Northwind.dbo.Products
UNION
Select '20160902' as InventoryDate, ProductID, UnitsInStock + 21
From Northwind.dbo.Products
UNION
Select '20161002' as InventoryDate, ProductID, UnitsInStock + 22
From Northwind.dbo.Products
UNION
Select '20161102' as InventoryDate, ProductID, UnitsInStock + 17
From Northwind.dbo.Products
UNION
Select '20161202' as InventoryDate, ProductID, UnitsInStock + 13
From Northwind.dbo.Products
go

-- Show all of the data in the Categories, Products, and Inventories Tables using Views.
Select * from vCategories;
go
Select * from vProducts;
go
Select * from vInventories;
go

-- Use average function to show an average of all dairy product inventory counts
Select vProducts.ProductName, Avg(Inventories.InventoryCount) As AvgAmountInInventory
From vProducts
Join Inventories
On vProducts.ProductID = Inventories.ProductID
Where Month(Inventories.InventoryDate) in (1,2,3,4,5,6,7,8,9,10,11,12)
And Inventories.ProductID In (Select ProductID from Products Where CategoryID = 4)
Group By vProducts.ProductName
Having Avg(Inventories.InventoryCount) >= 10
Order By vProducts.ProductName
