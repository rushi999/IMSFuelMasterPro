package com.barc.ims.servlet;

import com.barc.ims.dao.FuelEntryDAO;
import com.barc.ims.model.FuelEntry;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.http.*;

/**
 * FuelEntryServlet v3
 * Properly maps ALL form fields to FuelEntry model.
 * Fixed: rcavNo, remarks, vehicleType, tankId, orgName,
 *        driverBadge, driverContact, entryTime all now saved.
 */
public class FuelEntryServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        int userId = (session != null && session.getAttribute("userId") != null)
            ? (Integer) session.getAttribute("userId") : 0;
        String issuedBy = (session != null && session.getAttribute("fullName") != null)
            ? (String) session.getAttribute("fullName") : "System";

        FuelEntry entry = new FuelEntry();

        /* ── Category & identifiers ── */
        entry.setEntryCategory(get(req, "entryCategory"));
        entry.setVehicleNo(get(req, "vehicleNo"));
        entry.setVehicleType(get(req, "vehicleType"));
        entry.setFuelType(get(req, "fuelType"));

        /* ── Tank ID ── */
        try {
            String tankIdStr = get(req, "tankId");
            if (!tankIdStr.isEmpty())
                entry.setTankId(Integer.parseInt(tankIdStr));
        } catch (Exception e) { /* leave 0, SP will auto-pick */ }

        /* ── Driver details ── */
        entry.setDriverName(get(req, "driverName"));
        entry.setDriverBadge(get(req, "driverBadge"));
        entry.setDriverContact(get(req, "driverContact"));

        /* ── Department / Organisation ── */
        entry.setDepartment(get(req, "department"));
        entry.setOrgName(get(req, "orgName"));

        /* ── Fuel quantity ── */
        try {
            String q = get(req, "qtyIssued");
            if (!q.isEmpty()) entry.setQtyIssued(Double.parseDouble(q));
        } catch (Exception e) {}

        /* ── Odometer (accepts decimal values) ── */
        double prevOdoDouble = 0, currOdoDouble = 0;
        try {
            String prev = get(req, "prevOdometer");
            if (!prev.isEmpty()) {
                prevOdoDouble = Double.parseDouble(prev);
                entry.setPrevOdometer((long) prevOdoDouble);
            }
        } catch (Exception e) {}
        try {
            String curr = get(req, "currOdometer");
            if (!curr.isEmpty()) {
                currOdoDouble = Double.parseDouble(curr);
                entry.setCurrOdometer((long) currOdoDouble);
            }
        } catch (Exception e) {}

        /* ── Admin fields ── */
        entry.setRcavNo(get(req, "rcavNo"));
        entry.setAuthOfficer(get(req, "authOfficer"));
        entry.setRemarks(get(req, "remarks"));
        entry.setIssuedBy(issuedBy);
        entry.setCreatedBy(userId);

        /* ── Date & Time ── */
        try {
            String dateStr = get(req, "entryDate");
            if (!dateStr.isEmpty())
                entry.setEntryDate(new SimpleDateFormat("yyyy-MM-dd").parse(dateStr));
            else
                entry.setEntryDate(new Date());
        } catch (Exception e) {
            entry.setEntryDate(new Date());
        }
        entry.setEntryTime(get(req, "entryTime"));

        /* ── Supply type (Loose) ── */
        entry.setSupplyType(get(req, "supplyType"));

        /* ── Validation ── */
        if (entry.getFuelType() == null || entry.getFuelType().isEmpty()) {
            req.getSession().setAttribute("errorMsg",
                "Fuel type is required. Please select a tank.");
            res.sendRedirect(req.getContextPath() +
                "/pages/fuel_entry.jsp?tab=" + entry.getEntryCategory());
            return;
        }
        if (entry.getQtyIssued() <= 0) {
            req.getSession().setAttribute("errorMsg",
                "Quantity must be greater than zero.");
            res.sendRedirect(req.getContextPath() +
                "/pages/fuel_entry.jsp?tab=" + entry.getEntryCategory());
            return;
        }

        /* ── Odometer validation: curr must be > prev (if both provided) ── */
        if (entry.getPrevOdometer() > 0 && entry.getCurrOdometer() > 0
                && entry.getCurrOdometer() <= entry.getPrevOdometer()) {
            req.getSession().setAttribute("errorMsg",
                "Current odometer reading (" + entry.getCurrOdometer()
                + ") must be greater than previous reading (" + entry.getPrevOdometer() + ").");
            res.sendRedirect(req.getContextPath() +
                "/pages/fuel_entry.jsp?tab=" + entry.getEntryCategory());
            return;
        }

        /* ── Save ── */
        try {
            FuelEntryDAO dao = new FuelEntryDAO();
            String status = dao.saveFuelEntry(entry);

            if ("SUCCESS".equals(status)) {
                String reqNo = "REQ-" +
                    new SimpleDateFormat("yyyy").format(new Date()) +
                    "-" + String.format("%04d", entry.getEntryId());
                req.getSession().setAttribute("successMsg",
                    "Entry saved. Req No: " + reqNo +
                    (entry.getRcavNo() != null && !entry.getRcavNo().isEmpty()
                        ? " | RCAV: " + entry.getRcavNo() : ""));
                res.sendRedirect(req.getContextPath() +
                    "/pages/fuel_entry.jsp?saved=1");
            } else {
                req.getSession().setAttribute("errorMsg", status);
                res.sendRedirect(req.getContextPath() +
                    "/pages/fuel_entry.jsp?tab=" + entry.getEntryCategory());
            }
        } catch (Exception e) {
            getServletContext().log("[IMS] FuelEntry error", e);
            req.getSession().setAttribute("errorMsg",
                "System error: " + e.getMessage());
            res.sendRedirect(req.getContextPath() + "/pages/fuel_entry.jsp");
        }
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.sendRedirect(req.getContextPath() + "/pages/fuel_entry.jsp");
    }

    /** Null-safe request parameter getter */
    private String get(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return (v != null) ? v.trim() : "";
    }
}
