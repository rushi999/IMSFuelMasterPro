package com.barc.ims.util;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * Application bootstrap listener.
 *
 * Keeps database configuration centralised and makes the WAR deployable on a
 * fresh Tomcat by initialising DBConnection before any servlet handles traffic.
 */
public class AppContextListener implements ServletContextListener {

    public void contextInitialized(ServletContextEvent event) {
        ServletContext context = event.getServletContext();
        DBConnection.init(context);
        context.log("[IMS] Application initialised. Database URL: " + DBConnection.getDbUrlForLog());
    }

    public void contextDestroyed(ServletContextEvent event) {
        event.getServletContext().log("[IMS] Application stopped.");
    }
}
