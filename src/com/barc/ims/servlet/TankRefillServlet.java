package com.barc.ims.servlet;

import com.barc.ims.dao.TankDAO;
import com.barc.ims.dao.TankRefillDAO;
import com.barc.ims.model.TankMaster;
import com.barc.ims.model.TankRefill;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.*;

/**
 * TankRefillServlet - Handles Tank Master page: view tanks + log refills.
 * GET  /TankRefillServlet          → show tank master page
 * POST /TankRefillServlet          → save refill entry
 */
public class TankRefillServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (req.getSession(false) == null ||
            req.getSession(false).getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp"); return;
        }
        try {
            TankDAO       tankDao   = new TankDAO();
            TankRefillDAO refillDao = new TankRefillDAO();

            List tanks   = tankDao.getAllTanks();
            List refills = refillDao.getRecentRefills(-1, 30);

            req.setAttribute("tanks",      tanks);
            req.setAttribute("refills",    refills);
            req.setAttribute("activePage", "tank_master");
            req.setAttribute("pageTitle",  "Tank Master");
            req.getRequestDispatcher("/pages/tank_master.jsp").forward(req, res);
        } catch (Exception e) {
            req.setAttribute("errorMsg", "Error loading tank data: " + e.getMessage());
            req.getRequestDispatcher("/pages/tank_master.jsp").forward(req, res);
        }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        int userId = (session != null && session.getAttribute("userId") != null)
            ? (Integer) session.getAttribute("userId") : 0;

        TankRefill r = new TankRefill();
        try {
            r.setTankId(Integer.parseInt(req.getParameter("tankId")));
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", "Please select a tank.");
            res.sendRedirect(req.getContextPath() + "/TankRefillServlet"); return;
        }
        try {
            double qty = Double.parseDouble(req.getParameter("refillQty"));
            if (qty <= 0) throw new Exception("Invalid qty");
            r.setRefillQty(qty);
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", "Please enter a valid refill quantity.");
            res.sendRedirect(req.getContextPath() + "/TankRefillServlet"); return;
        }
        r.setSupplier(req.getParameter("supplier"));
        r.setChallanNo(req.getParameter("challanNo"));
        r.setRemarks(req.getParameter("remarks"));
        r.setEnteredBy(userId);
        try {
            String dateStr = req.getParameter("refillDate");
            if (dateStr != null && !dateStr.isEmpty())
                r.setRefillDate(new SimpleDateFormat("yyyy-MM-dd").parse(dateStr));
            else
                r.setRefillDate(new Date());
        } catch (Exception e) {
            r.setRefillDate(new Date());
        }

        try {
            TankRefillDAO dao = new TankRefillDAO();
            String result = dao.saveRefill(r);
            if ("SUCCESS".equals(result)) {
                req.getSession().setAttribute("successMsg",
                    "Tank refill logged successfully. Dashboard updated.");
            } else {
                req.getSession().setAttribute("errorMsg", result);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg",
                "Error saving refill: " + e.getMessage());
        }
        res.sendRedirect(req.getContextPath() + "/TankRefillServlet");
    }
}
