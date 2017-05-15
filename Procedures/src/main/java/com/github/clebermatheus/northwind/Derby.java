package com.github.clebermatheus.northwind;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/*
 *
 * Procedures criadas a partir do http://www.calsql.com/2015/09/northwind-database-practice-queries.html
 * 
 */

public class Derby {
	public static void getAllOrdersByCategoryName(String categoryName,
			ResultSet[] data) throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "SELECT DISTINCT O.* FROM Orders O ";
		sql += "INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID ";
		sql += "INNER JOIN Products P ON P.ProductID = OD.ProductID ";
		sql += "INNER JOIN Categories C ON C.CategoryID = P.CategoryID ";
		sql += "WHERE (C.CategoryName = ? AND O.shippedDate IS NOT NULL)";
		PreparedStatement ps1 = connection.prepareStatement(sql);
		ps1.setString(1, categoryName);
		data[0] = ps1.executeQuery();

		connection.close();
	}

	public static void getQtdOrdensProcessadas(ResultSet[] data)
			throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "SELECT P.ProductName, count(O.OrderID) OrdensProcessadas FROM Orders O ";
		sql += "INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID ";
		sql += "INNER JOIN Products P ON P.ProductID = OD.ProductID ";
		sql += "WHERE (O.shippedDate IS NOT NULL) ";
		sql += "GROUP BY O.OrderID";
		PreparedStatement ps = connection.prepareStatement(sql);
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void getMesesSemOrders(ResultSet[] data) throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select distinct P.ProductID, P.ProductName, month(O.OrderDate) Meses_Sem_Order, year(O.OrderDate) Anos_Sem_Order from Products P ";
		sql += "INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID ";
		sql += "INNER JOIN Orders O ON O.OrderID = OD.OrderID ";
		//sql += "WHERE (month(O.OrderDate) <> 1 or month(O.OrderDate) <> 2 or month(O.OrderDate) <> 3 or month(O.OrderDate) <> 4 or month(O.OrderDate) <> 5 or month(O.OrderDate) <> 6 or month(O.OrderDate) <> 7 or month(O.OrderDate) <> 8 or month(O.OrderDate) <> 9 or month(O.OrderDate) <> 10 or month(O.OrderDate) <> 11 or month(O.OrderDate) <> 12) ";
		sql += "WHERE (O.shippedDate is not null) ";
		sql += "ORDER BY 1,2, 4";
		PreparedStatement ps = connection.prepareStatement(sql);
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void get3MoreOrders(ResultSet[] data) throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select P.ProductName, COUNT(O.OrderID) QTD_ORDERS from Products P ";
		sql += "INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID ";
		sql += "INNER JOIN Orders O ON O.OrderID = OD.OrderID ";
		sql += "GROUP BY P.ProductName ORDER BY COUNT(O.OrderID) DESC FETCH NEXT 3 ROWS ONLY";
		PreparedStatement ps = connection.prepareStatement(sql);
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void getMesesSemOrdersPChai(ResultSet[] data)
			throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select distinct P.ProductID, P.ProductName, month(O.OrderDate) Meses_Sem_Order, year(O.OrderDate) Anos_Sem_Order from Products P ";
		sql += "INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID ";
		sql += "INNER JOIN Orders O ON O.OrderID = OD.OrderID ";
		//sql += "WHERE (month(O.OrderDate) <> 1 or month(O.OrderDate) <> 2 or month(O.OrderDate) <> 3 or month(O.OrderDate) <> 4 or month(O.OrderDate) <> 5 or month(O.OrderDate) <> 6 or month(O.OrderDate) <> 7 or month(O.OrderDate) <> 8 or month(O.OrderDate) <> 9 or month(O.OrderDate) <> 10 or month(O.OrderDate) <> 11 or month(O.OrderDate) <> 12) ";
		sql += " WHERE (O.shippedDate IS NOT NULL) ";
		sql += " AND (P.ProductName = ? )";
		sql += "ORDER BY P.ProductID, P.ProductName, year(O.OrderDate)";
		PreparedStatement ps = connection.prepareStatement(sql);
		ps.setString(1, "Chai");
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void getMesesEAnosSemOrders(ResultSet[] data)
			throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select distinct P.ProductID, P.ProductName, month(O.OrderDate) Meses_Sem_Order, year(O.OrderDate) Anos_Sem_Order from Products P ";
		sql += "INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID ";
		sql += "INNER JOIN Orders O ON O.OrderID = OD.OrderID ";
		sql += "WHERE (month(O.OrderDate) <> 1 or month(O.OrderDate) <> 2 or month(O.OrderDate) <> 3 or month(O.OrderDate) <> 4 or month(O.OrderDate) <> 5 or month(O.OrderDate) <> 6 or month(O.OrderDate) <> 7 or month(O.OrderDate) <> 8 or month(O.OrderDate) <> 9 or month(O.OrderDate) <> 10 or month(O.OrderDate) <> 11 or month(O.OrderDate) <> 12) ";
		sql += "ORDER BY P.ProductID, P.ProductName, year(O.OrderDate)";
		PreparedStatement ps = connection.prepareStatement(sql);
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void getListEmployeesWChai(ResultSet[] data) throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select distinct E.EmployeeID, E.FirstName, E.LastName from Employees E ";
		sql += "INNER JOIN Orders O ON O.EmployeeID = E.EmployeeID ";
		sql += "INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID ";
		sql += "INNER JOIN Products P ON P.ProductID = OD.ProductID ";
		sql += "WHERE P.ProductName = ? AND O.ShippedDate IS NOT NULL ";
		sql += "ORDER BY E.EmployeeID ASC";
		PreparedStatement ps = connection.prepareStatement(sql);
		ps.setString(1, "Chai");
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void getListEmployeesMoreOrders(ResultSet[] data)
			throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select E.EmployeeID, E.FirstName, E.LastName, count(O.OrderID) QTD_ORDERS from Employees E ";
		sql += "INNER JOIN Orders O ON O.EmployeeID = E.EmployeeID ";
		sql += "WHERE month(O.OrderDate) = ? AND O.ShippedDate IS NOT NULL ";
		sql += "GROUP BY E.EmployeeID, E.FirstName, E.LastName ";
		sql += "ORDER BY count(O.OrderID) DESC";
		PreparedStatement ps = connection.prepareStatement(sql);
		ps.setInt(1, 3);
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void getListEmployeesHasOrdersOwnCity(ResultSet[] data)
			throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select distinct E.EmployeeID, E.FirstName, E.LastName, O.ShipCity from Employees E ";
		sql += "INNER JOIN Orders O ON O.EmployeeID = E.EmployeeID AND E.City = O.ShipCity ";
		sql += "WHERE O.ShippedDate IS NOT NULL ";
		sql += "ORDER BY E.EmployeeID ASC";
		PreparedStatement ps = connection.prepareStatement(sql);
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void getListEmployeesHasOrdersNotOwnCity(ResultSet[] data)
			throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select distinct E.EmployeeID, E.FirstName, E.LastName, O.ShipCity from Employees E ";
		sql += "INNER JOIN Orders O ON O.EmployeeID = E.EmployeeID AND E.City <> O.ShipCity ";
		sql += "WHERE O.ShippedDate IS NOT NULL ";
		sql += "ORDER BY E.EmployeeID ASC";
		PreparedStatement ps = connection.prepareStatement(sql);
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void getShippersHasOrderWSeafood(ResultSet[] data)
			throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select distinct S.ShipperID, S.CompanyName from Shippers S ";
		sql += "INNER JOIN Orders O ON S.ShipperID = O.ShipVia ";
		sql += "INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID ";
		sql += "INNER JOIN Products P ON P.ProductID = OD.ProductID ";
		sql += "INNER JOIN Categories C ON C.CategoryID = P.CategoryID ";
		sql += "WHERE C.CategoryName = ? AND O.ShippedDate IS NOT NULL ";
		sql += "ORDER BY S.ShipperID ASC";
		PreparedStatement ps = connection.prepareStatement(sql);
		ps.setString(1, "Seafood");
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void getCategoryHasEmployeesInUSA(ResultSet[] data)
			throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select C.CategoryID, C.CategoryName, count(O.OrderID) QTD_ORDERS from Categories C ";
		sql += "INNER JOIN Products P ON P.CategoryID = C.CategoryID ";
		sql += "INNER JOIN OrderDetails OD ON OD.ProductID = P.ProductID ";
		sql += "INNER JOIN Orders O ON O.OrderID = OD.OrderID ";
		sql += "INNER JOIN Employees E ON E.EmployeeID = O.EmployeeID AND E.Country = O.ShipCountry ";
		sql += "WHERE E.Country = ? AND O.ShippedDate IS NOT NULL ";
		sql += "GROUP BY C.CategoryID, C.CategoryName ";
		sql += "ORDER BY count(O.OrderID) DESC";
		PreparedStatement ps = connection.prepareStatement(sql);
		ps.setString(1, "USA");
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void getSupplierAndShipperNameFromCategory(ResultSet[] data)
			throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "select distinct S.SupplierID, S.CompanyName, SH.CompanyName from Suppliers S ";
		sql += "INNER JOIN Products P ON S.SupplierID = P.SupplierID ";
		sql += "INNER JOIN Categories C ON P.CategoryID = C.CategoryID ";
		sql += "INNER JOIN OrderDetails OD ON OD.ProductID = P.ProductID ";
		sql += "INNER JOIN Orders O ON O.OrderID = OD.OrderID ";
		sql += "INNER JOIN Shippers SH ON SH.ShipperID = O.ShipVia ";
		sql += "WHERE C.CategoryName = ? ";
		sql += "ORDER BY S.SupplierID ASC";
		PreparedStatement ps = connection.prepareStatement(sql);
		ps.setString(1, "Seafood");
		data[0] = ps.executeQuery();

		connection.close();
	}

	public static void updateBonusInEmployees() throws Exception {
		Connection connection = DriverManager
				.getConnection("jdbc:default:connection");

		String sql = "update Employees E set bonus = (select count(O.OrderID) from Orders O where O.EmployeeID = E.EmployeeID)";
		PreparedStatement ps = connection.prepareStatement(sql);
		ps.executeUpdate();

		connection.close();
	}
}
