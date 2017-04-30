create view [Orders Qry] AS
SELECT Orders.OrderID, Orders.CustomerID, Orders.EmployeeID, Orders.OrderDate, Orders.RequiredDate, 
	Orders.ShippedDate, Orders.ShipVia, Orders.Freight, Orders.ShipName, Orders.ShipAddress, Orders.ShipCity, 
	Orders.ShipRegion, Orders.ShipPostalCode, Orders.ShipCountry, 
	Customers.CompanyName, Customers.Address, Customers.City, Customers.Region, Customers.PostalCode, Customers.Country
FROM Customers INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GO
/****** Object:  View [Quarterly Orders]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Quarterly Orders] AS
SELECT DISTINCT Customers.CustomerID, Customers.CompanyName, Customers.City, Customers.Country
FROM Customers RIGHT JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.OrderDate BETWEEN '19970101' And '19971231'
GO
/****** Object:  View [Invoices]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Invoices] AS
SELECT Orders.ShipName, Orders.ShipAddress, Orders.ShipCity, Orders.ShipRegion, Orders.ShipPostalCode, 
	Orders.ShipCountry, Orders.CustomerID, Customers.CompanyName AS CustomerName, Customers.Address, Customers.City, 
	Customers.Region, Customers.PostalCode, Customers.Country, 
	(FirstName + ' ' + LastName) AS Salesperson, 
	Orders.OrderID, Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Shippers.CompanyName As ShipperName, 
	"Order Details".ProductID, Products.ProductName, "Order Details".UnitPrice, "Order Details".Quantity, 
	"Order Details".Discount, 
	(CONVERT(money,("Order Details".UnitPrice*Quantity*(1-Discount)/100))*100) AS ExtendedPrice, Orders.Freight
FROM 	Shippers INNER JOIN 
		(Products INNER JOIN 
			(
				(Employees INNER JOIN 
					(Customers INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID) 
				ON Employees.EmployeeID = Orders.EmployeeID) 
			INNER JOIN "Order Details" ON Orders.OrderID = "Order Details".OrderID) 
		ON Products.ProductID = "Order Details".ProductID) 
	ON Shippers.ShipperID = Orders.ShipVia
GO
/****** Object:  View [Product Sales for 1997]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Product Sales for 1997] AS
SELECT Categories.CategoryName, Products.ProductName, 
Sum(CONVERT(money,("Order Details".UnitPrice*Quantity*(1-Discount)/100))*100) AS ProductSales
FROM (Categories INNER JOIN Products ON Categories.CategoryID = Products.CategoryID) 
	INNER JOIN (Orders 
		INNER JOIN "Order Details" ON Orders.OrderID = "Order Details".OrderID) 
	ON Products.ProductID = "Order Details".ProductID
WHERE (((Orders.ShippedDate) Between '19970101' And '19971231'))
GROUP BY Categories.CategoryName, Products.ProductName
GO
/****** Object:  StoredProcedure [SalesByCategory]    Script Date: 08/12/2011 11:46:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SalesByCategory]
    @CategoryName nvarchar(15), @OrdYear nvarchar(4) = '1998'
AS
IF @OrdYear != '1996' AND @OrdYear != '1997' AND @OrdYear != '1998' 
BEGIN
	SELECT @OrdYear = '1998'
END

SELECT ProductName,
	TotalPurchase=ROUND(SUM(CONVERT(decimal(14,2), OD.Quantity * (1-OD.Discount) * OD.UnitPrice)), 0)
FROM [Order Details] OD, Orders O, Products P, Categories C
WHERE OD.OrderID = O.OrderID 
	AND OD.ProductID = P.ProductID 
	AND P.CategoryID = C.CategoryID
	AND C.CategoryName = @CategoryName
	AND SUBSTRING(CONVERT(nvarchar(22), O.OrderDate, 111), 1, 4) = @OrdYear
GROUP BY ProductName
ORDER BY ProductName
GO
/****** Object:  StoredProcedure [CustOrdersOrders]    Script Date: 08/12/2011 11:46:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [CustOrdersOrders] @CustomerID nchar(5)
AS
SELECT OrderID, 
	OrderDate,
	RequiredDate,
	ShippedDate
FROM Orders
WHERE CustomerID = @CustomerID
ORDER BY OrderID
GO
/****** Object:  StoredProcedure [CustOrderHist]    Script Date: 08/12/2011 11:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [CustOrderHist] @CustomerID nchar(5)
AS
SELECT ProductName, Total=SUM(Quantity)
FROM Products P, [Order Details] OD, Orders O, Customers C
WHERE C.CustomerID = @CustomerID
AND C.CustomerID = O.CustomerID AND O.OrderID = OD.OrderID AND OD.ProductID = P.ProductID
GROUP BY ProductName
GO
/****** Object:  StoredProcedure [CustOrdersDetail]    Script Date: 08/12/2011 11:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [CustOrdersDetail] @OrderID int
AS
SELECT ProductName,
    UnitPrice=ROUND(Od.UnitPrice, 2),
    Quantity,
    Discount=CONVERT(int, Discount * 100), 
    ExtendedPrice=ROUND(CONVERT(money, Quantity * (1 - Discount) * Od.UnitPrice), 2)
FROM Products P, [Order Details] Od
WHERE Od.ProductID = P.ProductID and Od.OrderID = @OrderID
GO
/****** Object:  StoredProcedure [Ten Most Expensive Products]    Script Date: 08/12/2011 11:46:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Ten Most Expensive Products] AS
SET ROWCOUNT 10
SELECT Products.ProductName AS TenMostExpensiveProducts, Products.UnitPrice
FROM Products
ORDER BY Products.UnitPrice DESC
GO
/****** Object:  View [Current Product List]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Current Product List] AS
SELECT Product_List.ProductID, Product_List.ProductName
FROM Products AS Product_List
WHERE (((Product_List.Discontinued)=0))
--ORDER BY Product_List.ProductName
GO
/****** Object:  View [Order Details Extended]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Order Details Extended] AS
SELECT "Order Details".OrderID, "Order Details".ProductID, Products.ProductName, 
	"Order Details".UnitPrice, "Order Details".Quantity, "Order Details".Discount, 
	(CONVERT(money,("Order Details".UnitPrice*Quantity*(1-Discount)/100))*100) AS ExtendedPrice
FROM Products INNER JOIN "Order Details" ON Products.ProductID = "Order Details".ProductID
--ORDER BY "Order Details".OrderID
GO
/****** Object:  View [Products Above Average Price]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Products Above Average Price] AS
SELECT Products.ProductName, Products.UnitPrice
FROM Products
WHERE Products.UnitPrice>(SELECT AVG(UnitPrice) From Products)
--ORDER BY Products.UnitPrice DESC
GO
/****** Object:  View [Products by Category]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Products by Category] AS
SELECT Categories.CategoryName, Products.ProductName, Products.QuantityPerUnit, Products.UnitsInStock, Products.Discontinued
FROM Categories INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE Products.Discontinued <> 1
--ORDER BY Categories.CategoryName, Products.ProductName
GO
/****** Object:  View [Alphabetical list of products]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Alphabetical list of products] AS
SELECT Products.*, Categories.CategoryName
FROM Categories INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE (((Products.Discontinued)=0))
GO
/****** Object:  View [Order Subtotals]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Order Subtotals] AS
SELECT "Order Details".OrderID, Sum(CONVERT(money,("Order Details".UnitPrice*Quantity*(1-Discount)/100))*100) AS Subtotal
FROM "Order Details"
GROUP BY "Order Details".OrderID
GO
/****** Object:  View [Customer and Suppliers by City]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Customer and Suppliers by City] AS
SELECT City, CompanyName, ContactName, 'Customers' AS Relationship 
FROM Customers
UNION SELECT City, CompanyName, ContactName, 'Suppliers'
FROM Suppliers
--ORDER BY City, CompanyName
GO
/****** Object:  View [Sales Totals by Amount]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Sales Totals by Amount] AS
SELECT "Order Subtotals".Subtotal AS SaleAmount, Orders.OrderID, Customers.CompanyName, Orders.ShippedDate
FROM 	Customers INNER JOIN 
		(Orders INNER JOIN "Order Subtotals" ON Orders.OrderID = "Order Subtotals".OrderID) 
	ON Customers.CustomerID = Orders.CustomerID
WHERE ("Order Subtotals".Subtotal >2500) AND (Orders.ShippedDate BETWEEN '19970101' And '19971231')
GO
/****** Object:  View [Sales by Category]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Sales by Category] AS
SELECT Categories.CategoryID, Categories.CategoryName, Products.ProductName, 
	Sum("Order Details Extended".ExtendedPrice) AS ProductSales
FROM 	Categories INNER JOIN 
		(Products INNER JOIN 
			(Orders INNER JOIN "Order Details Extended" ON Orders.OrderID = "Order Details Extended".OrderID) 
		ON Products.ProductID = "Order Details Extended".ProductID) 
	ON Categories.CategoryID = Products.CategoryID
WHERE Orders.OrderDate BETWEEN '19970101' And '19971231'
GROUP BY Categories.CategoryID, Categories.CategoryName, Products.ProductName
--ORDER BY Products.ProductName
GO
/****** Object:  StoredProcedure [Sales by Year]    Script Date: 08/12/2011 11:46:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Sales by Year] 
	@Beginning_Date DateTime, @Ending_Date DateTime AS
SELECT Orders.ShippedDate, Orders.OrderID, "Order Subtotals".Subtotal, DATENAME(yy,ShippedDate) AS Year
FROM Orders INNER JOIN "Order Subtotals" ON Orders.OrderID = "Order Subtotals".OrderID
WHERE Orders.ShippedDate Between @Beginning_Date And @Ending_Date
GO
/****** Object:  StoredProcedure [Employee Sales by Country]    Script Date: 08/12/2011 11:46:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Employee Sales by Country] 
@Beginning_Date DateTime, @Ending_Date DateTime AS
SELECT Employees.Country, Employees.LastName, Employees.FirstName, Orders.ShippedDate, Orders.OrderID, "Order Subtotals".Subtotal AS SaleAmount
FROM Employees INNER JOIN 
	(Orders INNER JOIN "Order Subtotals" ON Orders.OrderID = "Order Subtotals".OrderID) 
	ON Employees.EmployeeID = Orders.EmployeeID
WHERE Orders.ShippedDate Between @Beginning_Date And @Ending_Date
GO
/****** Object:  View [Summary of Sales by Quarter]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Summary of Sales by Quarter] AS
SELECT Orders.ShippedDate, Orders.OrderID, "Order Subtotals".Subtotal
FROM Orders INNER JOIN "Order Subtotals" ON Orders.OrderID = "Order Subtotals".OrderID
WHERE Orders.ShippedDate IS NOT NULL
--ORDER BY Orders.ShippedDate
GO
/****** Object:  View [Summary of Sales by Year]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Summary of Sales by Year] AS
SELECT Orders.ShippedDate, Orders.OrderID, "Order Subtotals".Subtotal
FROM Orders INNER JOIN "Order Subtotals" ON Orders.OrderID = "Order Subtotals".OrderID
WHERE Orders.ShippedDate IS NOT NULL
--ORDER BY Orders.ShippedDate
GO
/****** Object:  View [Category Sales for 1997]    Script Date: 08/12/2011 11:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Category Sales for 1997] AS
SELECT "Product Sales for 1997".CategoryName, Sum("Product Sales for 1997".ProductSales) AS CategorySales
FROM "Product Sales for 1997"
GROUP BY "Product Sales for 1997".CategoryName
GO
/****** Object:  Default [DF_Order_Details_UnitPrice]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Order Details] ADD  CONSTRAINT [DF_Order_Details_UnitPrice]  DEFAULT (0) FOR [UnitPrice]
GO
/****** Object:  Default [DF_Order_Details_Quantity]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Order Details] ADD  CONSTRAINT [DF_Order_Details_Quantity]  DEFAULT (1) FOR [Quantity]
GO
/****** Object:  Default [DF_Order_Details_Discount]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Order Details] ADD  CONSTRAINT [DF_Order_Details_Discount]  DEFAULT (0) FOR [Discount]
GO
/****** Object:  Default [DF_Orders_Freight]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Orders] ADD  CONSTRAINT [DF_Orders_Freight]  DEFAULT (0) FOR [Freight]
GO
/****** Object:  Default [DF_Products_UnitPrice]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products] ADD  CONSTRAINT [DF_Products_UnitPrice]  DEFAULT (0) FOR [UnitPrice]
GO
/****** Object:  Default [DF_Products_UnitsInStock]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products] ADD  CONSTRAINT [DF_Products_UnitsInStock]  DEFAULT (0) FOR [UnitsInStock]
GO
/****** Object:  Default [DF_Products_UnitsOnOrder]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products] ADD  CONSTRAINT [DF_Products_UnitsOnOrder]  DEFAULT (0) FOR [UnitsOnOrder]
GO
/****** Object:  Default [DF_Products_ReorderLevel]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products] ADD  CONSTRAINT [DF_Products_ReorderLevel]  DEFAULT (0) FOR [ReorderLevel]
GO
/****** Object:  Default [DF_Products_Discontinued]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products] ADD  CONSTRAINT [DF_Products_Discontinued]  DEFAULT (0) FOR [Discontinued]
GO
/****** Object:  Check [CK_Birthdate]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Employees]  WITH NOCHECK ADD  CONSTRAINT [CK_Birthdate] CHECK  (([BirthDate] < getdate()))
GO
ALTER TABLE [Employees] CHECK CONSTRAINT [CK_Birthdate]
GO
/****** Object:  Check [CK_Discount]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Order Details]  WITH NOCHECK ADD  CONSTRAINT [CK_Discount] CHECK  (([Discount] >= 0 and [Discount] <= 1))
GO
ALTER TABLE [Order Details] CHECK CONSTRAINT [CK_Discount]
GO
/****** Object:  Check [CK_Quantity]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Order Details]  WITH NOCHECK ADD  CONSTRAINT [CK_Quantity] CHECK  (([Quantity] > 0))
GO
ALTER TABLE [Order Details] CHECK CONSTRAINT [CK_Quantity]
GO
/****** Object:  Check [CK_UnitPrice]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Order Details]  WITH NOCHECK ADD  CONSTRAINT [CK_UnitPrice] CHECK  (([UnitPrice] >= 0))
GO
ALTER TABLE [Order Details] CHECK CONSTRAINT [CK_UnitPrice]
GO
/****** Object:  Check [CK_Products_UnitPrice]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products]  WITH NOCHECK ADD  CONSTRAINT [CK_Products_UnitPrice] CHECK  (([UnitPrice] >= 0))
GO
ALTER TABLE [Products] CHECK CONSTRAINT [CK_Products_UnitPrice]
GO
/****** Object:  Check [CK_ReorderLevel]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products]  WITH NOCHECK ADD  CONSTRAINT [CK_ReorderLevel] CHECK  (([ReorderLevel] >= 0))
GO
ALTER TABLE [Products] CHECK CONSTRAINT [CK_ReorderLevel]
GO
/****** Object:  Check [CK_UnitsInStock]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products]  WITH NOCHECK ADD  CONSTRAINT [CK_UnitsInStock] CHECK  (([UnitsInStock] >= 0))
GO
ALTER TABLE [Products] CHECK CONSTRAINT [CK_UnitsInStock]
GO
/****** Object:  Check [CK_UnitsOnOrder]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products]  WITH NOCHECK ADD  CONSTRAINT [CK_UnitsOnOrder] CHECK  (([UnitsOnOrder] >= 0))
GO
ALTER TABLE [Products] CHECK CONSTRAINT [CK_UnitsOnOrder]
GO
/****** Object:  ForeignKey [FK_CustomerCustomerDemo]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [CustomerCustomerDemo]  WITH CHECK ADD  CONSTRAINT [FK_CustomerCustomerDemo] FOREIGN KEY([CustomerTypeID])
REFERENCES [CustomerDemographics] ([CustomerTypeID])
GO
ALTER TABLE [CustomerCustomerDemo] CHECK CONSTRAINT [FK_CustomerCustomerDemo]
GO
/****** Object:  ForeignKey [FK_CustomerCustomerDemo_Customers]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [CustomerCustomerDemo]  WITH CHECK ADD  CONSTRAINT [FK_CustomerCustomerDemo_Customers] FOREIGN KEY([CustomerID])
REFERENCES [Customers] ([CustomerID])
GO
ALTER TABLE [CustomerCustomerDemo] CHECK CONSTRAINT [FK_CustomerCustomerDemo_Customers]
GO
/****** Object:  ForeignKey [FK_Employees_Employees]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Employees]  WITH NOCHECK ADD  CONSTRAINT [FK_Employees_Employees] FOREIGN KEY([ReportsTo])
REFERENCES [Employees] ([EmployeeID])
GO
ALTER TABLE [Employees] CHECK CONSTRAINT [FK_Employees_Employees]
GO
/****** Object:  ForeignKey [FK_EmployeeTerritories_Employees]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [EmployeeTerritories]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeTerritories_Employees] FOREIGN KEY([EmployeeID])
REFERENCES [Employees] ([EmployeeID])
GO
ALTER TABLE [EmployeeTerritories] CHECK CONSTRAINT [FK_EmployeeTerritories_Employees]
GO
/****** Object:  ForeignKey [FK_EmployeeTerritories_Territories]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [EmployeeTerritories]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeTerritories_Territories] FOREIGN KEY([TerritoryID])
REFERENCES [Territories] ([TerritoryID])
GO
ALTER TABLE [EmployeeTerritories] CHECK CONSTRAINT [FK_EmployeeTerritories_Territories]
GO
/****** Object:  ForeignKey [FK_Order_Details_Orders]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Order Details]  WITH NOCHECK ADD  CONSTRAINT [FK_Order_Details_Orders] FOREIGN KEY([OrderID])
REFERENCES [Orders] ([OrderID])
GO
ALTER TABLE [Order Details] CHECK CONSTRAINT [FK_Order_Details_Orders]
GO
/****** Object:  ForeignKey [FK_Order_Details_Products]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Order Details]  WITH NOCHECK ADD  CONSTRAINT [FK_Order_Details_Products] FOREIGN KEY([ProductID])
REFERENCES [Products] ([ProductID])
GO
ALTER TABLE [Order Details] CHECK CONSTRAINT [FK_Order_Details_Products]
GO
/****** Object:  ForeignKey [FK_Orders_Customers]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Orders]  WITH NOCHECK ADD  CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([CustomerID])
REFERENCES [Customers] ([CustomerID])
GO
ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_Customers]
GO
/****** Object:  ForeignKey [FK_Orders_Employees]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Orders]  WITH NOCHECK ADD  CONSTRAINT [FK_Orders_Employees] FOREIGN KEY([EmployeeID])
REFERENCES [Employees] ([EmployeeID])
GO
ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_Employees]
GO
/****** Object:  ForeignKey [FK_Orders_Shippers]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Orders]  WITH NOCHECK ADD  CONSTRAINT [FK_Orders_Shippers] FOREIGN KEY([ShipVia])
REFERENCES [Shippers] ([ShipperID])
GO
ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_Shippers]
GO
/****** Object:  ForeignKey [FK_Products_Categories]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products]  WITH NOCHECK ADD  CONSTRAINT [FK_Products_Categories] FOREIGN KEY([CategoryID])
REFERENCES [Categories] ([CategoryID])
GO
ALTER TABLE [Products] CHECK CONSTRAINT [FK_Products_Categories]
GO
/****** Object:  ForeignKey [FK_Products_Suppliers]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Products]  WITH NOCHECK ADD  CONSTRAINT [FK_Products_Suppliers] FOREIGN KEY([SupplierID])
REFERENCES [Suppliers] ([SupplierID])
GO
ALTER TABLE [Products] CHECK CONSTRAINT [FK_Products_Suppliers]
GO
/****** Object:  ForeignKey [FK_Territories_Region]    Script Date: 08/12/2011 11:46:03 ******/
ALTER TABLE [Territories]  WITH CHECK ADD  CONSTRAINT [FK_Territories_Region] FOREIGN KEY([RegionID])
REFERENCES [Region] ([RegionID])
GO
ALTER TABLE [Territories] CHECK CONSTRAINT [FK_Territories_Region]
GO