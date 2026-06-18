package com.barc.ims.servlet;

import com.barc.ims.dao.TankDAO;
import com.barc.ims.model.TankMaster;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.*;

/**
 * TankServlet - Loads tank data and forwards to dashboard.
 */
public class TankServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            List<TankMaster> tanks = new TankDAO().getAllTanks();
            req.setAttribute("tanks", tanks);
            req.getRequestDispatcher("/pages/dashboard.jsp").forward(req, res);
        } catch (Exception e) {
            req.setAttribute("errorMsg", "Could not load tank data: " + e.getMessage());
            req.getRequestDispatcher("/pages/dashboard.jsp").forward(req, res);
        }
    }
}
