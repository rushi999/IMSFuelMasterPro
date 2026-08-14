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

    /**
     * Initialises database settings from web.xml, system properties or
     * environment variables. Precedence: environment > JVM property > web.xml
     * context-param > built-in development defaults.
     */
    public static synchronized void init(ServletContext ctx) {
        if (ctx != null) {
            DB_URL = firstNonBlank(ctx.getInitParameter("DB_URL"), DB_URL);
            DB_USER = firstNonBlank(ctx.getInitParameter("DB_USER"), DB_USER);
            DB_PASS = firstNonBlank(ctx.getInitParameter("DB_PASS"), DB_PASS);
        }

        DB_URL = firstNonBlank(System.getProperty("IMS_DB_URL"), DB_URL);
        DB_USER = firstNonBlank(System.getProperty("IMS_DB_USER"), DB_USER);
        DB_PASS = firstNonBlank(System.getProperty("IMS_DB_PASS"), DB_PASS);

        DB_URL = firstNonBlank(System.getenv("IMS_DB_URL"), DB_URL);
        DB_USER = firstNonBlank(System.getenv("IMS_DB_USER"), DB_USER);
        DB_PASS = firstNonBlank(System.getenv("IMS_DB_PASS"), DB_PASS);
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    public static String getDbUrlForLog() {
        return DB_URL;
    }

    private static String firstNonBlank(String value, String fallback) {
        if (value == null || value.trim().length() == 0) return fallback;
        return value.trim();
    }

    public static void close(Connection conn) {
        if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignore */ }
    }
}
