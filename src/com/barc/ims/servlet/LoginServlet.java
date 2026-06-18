package com.barc.ims.servlet;

import com.barc.ims.util.DBConnection;
import com.barc.ims.util.PasswordUtil;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;

/**
 * LoginServlet - Authenticates users against USERS table.
 */
public class LoginServlet extends HttpServlet {

    public void init() throws ServletException {
        DBConnection.init(getServletContext());
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || password == null ||
            username.trim().isEmpty() || password.trim().isEmpty()) {
            res.sendRedirect("login.jsp?error=1");
            return;
        }

        String passHash = PasswordUtil.md5(password.trim());
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT USER_ID, FULL_NAME, ROLE, DESIGNATION " +
                "FROM USERS WHERE USERNAME=? AND PASSWORD_HASH=? AND IS_ACTIVE='Y'"
            );
            ps.setString(1, username.trim().toLowerCase());
            ps.setString(2, passHash);
            rs = ps.executeQuery();
            if (rs.next()) {
                /* Invalidate any existing session to prevent session fixation attacks */
                HttpSession oldSession = req.getSession(false);
                if (oldSession != null) oldSession.invalidate();
                HttpSession session = req.getSession(true);
                session.setAttribute("userId",      rs.getInt("USER_ID"));
                session.setAttribute("fullName",    rs.getString("FULL_NAME"));
                session.setAttribute("role",        rs.getString("ROLE"));
                session.setAttribute("designation", rs.getString("DESIGNATION"));
                session.setAttribute("username",    username.trim().toLowerCase());
                res.sendRedirect("pages/dashboard.jsp");
            } else {
                res.sendRedirect("login.jsp?error=2");
            }
        } catch (SQLException e) {
            getServletContext().log("[IMS] Login error", e);
            res.sendRedirect("login.jsp?error=3");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("logout".equals(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
            res.sendRedirect(req.getContextPath() + "/login.jsp?logout=1");
        } else {
            res.sendRedirect("login.jsp");
        }
    }
}
