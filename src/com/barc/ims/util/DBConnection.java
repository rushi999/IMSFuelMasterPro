package com.barc.ims.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.servlet.ServletContext;

/**
 * DBConnection - Oracle 10g JDBC Connection Utility
 * IMS Fuel Master Pro | BARC Transport Section
 * JDK 1.7 Compatible
 */
public class DBConnection {

    private static String DB_URL  = "jdbc:oracle:thin:@localhost:1521:ORCL";
    private static String DB_USER = "ims_fuel";
    private static String DB_PASS = "ims_fuel123";

    static {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            System.err.println("[IMS-DB] Oracle JDBC driver not found: " + e.getMessage());
        }
    }

    /** Call once from a ServletContextListener or startup servlet */
    public static void init(ServletContext ctx) {
        if (ctx.getInitParameter("DB_URL")  != null) DB_URL  = ctx.getInitParameter("DB_URL");
        if (ctx.getInitParameter("DB_USER") != null) DB_USER = ctx.getInitParameter("DB_USER");
        if (ctx.getInitParameter("DB_PASS") != null) DB_PASS = ctx.getInitParameter("DB_PASS");
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    public static void close(Connection conn) {
        if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignore */ }
    }
}
