package com.barc.ims.servlet;

import com.barc.ims.dao.*;
import com.barc.ims.model.*;
import com.barc.ims.util.DBConnection;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;

/**
 * MasterServlet v2 - Unit / Vehicle / Driver master + AJAX search endpoints
 *
 * AJAX endpoints:
 *   ?action=searchVehicle&q=MH04        → search unit vehicles, returns vehicle + drivers
 *   ?action=searchBarcVehicle&q=MH04    → search BARC vehicles
 *   ?action=driversByUnit&unitId=1      → all drivers for a unit
 *   ?action=vehiclesByUnit&unitId=1     → all vehicles for a unit
 *   ?action=allUnits                    → all unit master records
 *   ?action=generateRCAV               → generate next RCAV number
 */
public class MasterServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action  = req.getParameter("action");
        String section = req.getParameter("section");

        /* ── AJAX JSON endpoints ── */
        if ("searchVehicle".equals(action))      { jsonSearchVehicle(req, res);     return; }
        if ("searchBarcVehicle".equals(action))  { jsonSearchBarcVehicle(req, res); return; }
        if ("driversByUnit".equals(action))      { jsonDriversByUnit(req, res);     return; }
        if ("vehiclesByUnit".equals(action))     { jsonVehiclesByUnit(req, res);    return; }
        if ("allUnits".equals(action))           { jsonAllUnits(req, res);          return; }
        if ("generateRCAV".equals(action))       { jsonGenerateRCAV(req, res);      return; }

        /* ── Page loads ── */
        try {
            if ("vehicle".equals(section))      loadVehiclePage(req, res);
            else if ("driver".equals(section))  loadDriverPage(req, res);
            else                                loadUnitPage(req, res);
        } catch (Exception e) {
            req.setAttribute("errorMsg", "Error: " + e.getMessage());
            req.getRequestDispatcher("/pages/units_master.jsp").forward(req, res);
        }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action  = req.getParameter("action");
        String section = req.getParameter("section");
        try {
            if ("vehicle".equals(section))      saveOrDeleteVehicle(req, res, action);
            else if ("driver".equals(section))  saveOrDeleteDriver(req, res, action);
            else                                saveOrDeleteUnit(req, res, action);
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", "Error: " + e.getMessage());
            res.sendRedirect(req.getContextPath() + "/pages/units_master.jsp");
        }
    }

    /* ════════════════════════════════════════════════════════
       UNIT MASTER
       ════════════════════════════════════════════════════════ */
    private void loadUnitPage(HttpServletRequest req, HttpServletResponse res) throws Exception {
        UnitMasterDAO dao = new UnitMasterDAO();
        req.setAttribute("units", dao.getAll());
        String editId = req.getParameter("editId");
        if (editId != null && !editId.isEmpty())
            req.setAttribute("editUnit", dao.getById(Integer.parseInt(editId)));
        req.setAttribute("activePage", "units_master");
        req.setAttribute("pageTitle",  "Unit Master");
        req.setAttribute("masterSection", "unit");
        req.getRequestDispatcher("/pages/units_master.jsp").forward(req, res);
    }

    private void saveOrDeleteUnit(HttpServletRequest req, HttpServletResponse res, String action)
            throws Exception {
        if ("delete".equals(action)) {
            new UnitMasterDAO().delete(Integer.parseInt(req.getParameter("unitId")));
            req.getSession().setAttribute("successMsg", "Unit deleted.");
            res.sendRedirect(req.getContextPath() + "/pages/units_master.jsp"); return;
        }
        UnitMaster u = new UnitMaster();
        String idStr = req.getParameter("unitId");
        if (idStr != null && !idStr.isEmpty()) u.setUnitId(Integer.parseInt(idStr));
        u.setOrgName(req.getParameter("orgName"));
        u.setUnitCode(req.getParameter("unitCode"));
        u.setUnitType(req.getParameter("unitType"));
        u.setContactPerson(req.getParameter("contactPerson"));
        u.setDesignation(req.getParameter("designation"));
        u.setPhoneExt(req.getParameter("phoneExt"));
        u.setStatus(req.getParameter("status"));
        u.setNotes(req.getParameter("notes"));
        new UnitMasterDAO().save(u);
        req.getSession().setAttribute("successMsg", "Unit saved successfully.");
        res.sendRedirect(req.getContextPath() + "/pages/units_master.jsp");
    }

    /* ════════════════════════════════════════════════════════
       VEHICLE MASTER
       ════════════════════════════════════════════════════════ */
    private void loadVehiclePage(HttpServletRequest req, HttpServletResponse res) throws Exception {
        VehicleMasterDAO vDao = new VehicleMasterDAO();
        UnitMasterDAO    uDao = new UnitMasterDAO();
        String filterUnit = req.getParameter("filterUnit");
        int unitId = -1;
        if (filterUnit != null && !filterUnit.isEmpty())
            try { unitId = Integer.parseInt(filterUnit); } catch (Exception e) {}
        req.setAttribute("vehicles",      unitId > 0 ? vDao.getByUnitId(unitId) : vDao.getAll());
        req.setAttribute("units",         uDao.getAll());
        req.setAttribute("filterUnit",    unitId);
        String editId = req.getParameter("editId");
        if (editId != null && !editId.isEmpty())
            req.setAttribute("editVehicle", vDao.getById(Integer.parseInt(editId)));
        req.setAttribute("activePage",    "units_master");
        req.setAttribute("pageTitle",     "Vehicle Master");
        req.setAttribute("masterSection", "vehicle");
        req.getRequestDispatcher("/pages/vehicle_master.jsp").forward(req, res);
    }

    private void saveOrDeleteVehicle(HttpServletRequest req, HttpServletResponse res, String action)
            throws Exception {
        if ("delete".equals(action)) {
            new VehicleMasterDAO().delete(Integer.parseInt(req.getParameter("vehicleId")));
            req.getSession().setAttribute("successMsg", "Vehicle set to Scrapped.");
            res.sendRedirect(req.getContextPath() + "/MasterServlet?section=vehicle"); return;
        }
        VehicleMaster v = new VehicleMaster();
        String idStr = req.getParameter("vehicleId");
        if (idStr != null && !idStr.isEmpty()) v.setVehicleId(Integer.parseInt(idStr));
        try { v.setUnitId(Integer.parseInt(req.getParameter("unitId"))); } catch (Exception e) {}
        v.setVehicleNo(req.getParameter("vehicleNo"));
        v.setVehicleType(req.getParameter("vehicleType"));
        v.setMake(req.getParameter("make"));
        v.setModel(req.getParameter("model"));
        try { v.setYearMfg(Integer.parseInt(req.getParameter("yearMfg"))); } catch (Exception e) {}
        v.setFuelType(req.getParameter("fuelType"));
        try { v.setEngineCc(Integer.parseInt(req.getParameter("engineCc"))); } catch (Exception e) {}
        v.setChassisNo(req.getParameter("chassisNo"));
        v.setStatus(req.getParameter("status"));
        v.setNotes(req.getParameter("notes"));
        new VehicleMasterDAO().save(v);
        req.getSession().setAttribute("successMsg", "Vehicle saved successfully.");
        res.sendRedirect(req.getContextPath() + "/MasterServlet?section=vehicle");
    }

    /* ════════════════════════════════════════════════════════
       DRIVER MASTER
       ════════════════════════════════════════════════════════ */
    private void loadDriverPage(HttpServletRequest req, HttpServletResponse res) throws Exception {
        DriverMasterDAO dDao = new DriverMasterDAO();
        UnitMasterDAO   uDao = new UnitMasterDAO();
        String filterUnit = req.getParameter("filterUnit");
        int unitId = -1;
        if (filterUnit != null && !filterUnit.isEmpty())
            try { unitId = Integer.parseInt(filterUnit); } catch (Exception e) {}
        req.setAttribute("drivers",       unitId > 0 ? dDao.getByUnitId(unitId) : dDao.getAll());
        req.setAttribute("units",         uDao.getAll());
        req.setAttribute("filterUnit",    unitId);
        String editId = req.getParameter("editId");
        if (editId != null && !editId.isEmpty())
            req.setAttribute("editDriver", dDao.getById(Integer.parseInt(editId)));
        req.setAttribute("activePage",    "units_master");
        req.setAttribute("pageTitle",     "Driver Master");
        req.setAttribute("masterSection", "driver");
        req.getRequestDispatcher("/pages/driver_master.jsp").forward(req, res);
    }

    private void saveOrDeleteDriver(HttpServletRequest req, HttpServletResponse res, String action)
            throws Exception {
        if ("delete".equals(action)) {
            new DriverMasterDAO().delete(Integer.parseInt(req.getParameter("driverId")));
            req.getSession().setAttribute("successMsg", "Driver set to Inactive.");
            res.sendRedirect(req.getContextPath() + "/MasterServlet?section=driver"); return;
        }
        DriverMaster d = new DriverMaster();
        String idStr = req.getParameter("driverId");
        if (idStr != null && !idStr.isEmpty()) d.setDriverId(Integer.parseInt(idStr));
        try { d.setUnitId(Integer.parseInt(req.getParameter("unitId"))); } catch (Exception e) {}
        d.setDriverName(req.getParameter("driverName"));
        d.setEmployeeNo(req.getParameter("employeeNo"));
        d.setLicenceNo(req.getParameter("licenceNo"));
        d.setLicenceType(req.getParameter("licenceType"));
        try {
            String exp = req.getParameter("licenceExpiry");
            if (exp != null && !exp.isEmpty())
                d.setLicenceExpiry(new SimpleDateFormat("yyyy-MM-dd").parse(exp));
        } catch (Exception e) {}
        d.setContactNo(req.getParameter("contactNo"));
        d.setAddress(req.getParameter("address"));
        d.setStatus(req.getParameter("status"));
        d.setNotes(req.getParameter("notes"));
        new DriverMasterDAO().save(d);
        req.getSession().setAttribute("successMsg", "Driver saved successfully.");
        res.sendRedirect(req.getContextPath() + "/MasterServlet?section=driver");
    }

    /* ════════════════════════════════════════════════════════
       AJAX: Search Unit Vehicle — returns vehicle + unit drivers list
       Called from fuel_entry.jsp Other DAE Units section
       ════════════════════════════════════════════════════════ */
    private void jsonSearchVehicle(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        String q = req.getParameter("q");
        PrintWriter out = res.getWriter();
        if (q == null || q.trim().isEmpty()) { out.print("[]"); return; }
        try {
            List vehicles = new VehicleMasterDAO().search(q);
            if (vehicles == null || vehicles.isEmpty()) {
                out.print("[]"); return;
            }
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < vehicles.size(); i++) {
                VehicleMaster v = (VehicleMaster) vehicles.get(i);
                if (i > 0) sb.append(",");
                /* Also fetch all drivers for this vehicle's unit */
                List drivers = new DriverMasterDAO().getByUnitId(v.getUnitId());
                sb.append("{");
                sb.append("\"vehicleId\":").append(v.getVehicleId()).append(",");
                sb.append("\"vehicleNo\":\"").append(esc(v.getVehicleNo())).append("\",");
                sb.append("\"orgName\":\"").append(esc(v.getOrgName())).append("\",");
                sb.append("\"unitCode\":\"").append(esc(v.getUnitCode())).append("\",");
                sb.append("\"vehicleType\":\"").append(esc(v.getVehicleType())).append("\",");
                sb.append("\"fuelType\":\"").append(esc(v.getFuelType())).append("\",");
                sb.append("\"make\":\"").append(esc(v.getMake())).append("\",");
                sb.append("\"model\":\"").append(esc(v.getModel())).append("\",");
                sb.append("\"unitId\":").append(v.getUnitId()).append(",");
                /* Last odometer reading from FUEL_ENTRY */
                long lastOdo = 0;
                try { lastOdo = new FuelEntryDAO().getLastOdometer(v.getVehicleNo()); } catch (Exception ex) {}
                sb.append("\"lastOdometer\":").append(lastOdo).append(",");
                /* Embed drivers array */
                sb.append("\"drivers\":[");
                for (int j = 0; j < drivers.size(); j++) {
                    DriverMaster d = (DriverMaster) drivers.get(j);
                    if (j > 0) sb.append(",");
                    sb.append("{");
                    sb.append("\"driverId\":").append(d.getDriverId()).append(",");
                    sb.append("\"driverName\":\"").append(esc(d.getDriverName())).append("\",");
                    sb.append("\"employeeNo\":\"").append(esc(d.getEmployeeNo())).append("\",");
                    sb.append("\"contactNo\":\"").append(esc(d.getContactNo())).append("\",");
                    sb.append("\"licenceNo\":\"").append(esc(d.getLicenceNo())).append("\"");
                    sb.append("}");
                }
                sb.append("]}");
            }
            sb.append("]");
            out.print(sb.toString());
        } catch (Exception e) {
            out.print("{\"error\":\"" + esc(e.getMessage()) + "\"}");
        }
    }

    /* ════════════════════════════════════════════════════════
       AJAX: Search BARC Vehicle — returns vehicle + BARC driver info
       Called from fuel_entry.jsp BARC section
       Note: BARC vehicles have a single assigned driver in BARC_VEHICLE_MASTER
       ════════════════════════════════════════════════════════ */
    private void jsonSearchBarcVehicle(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        String q = req.getParameter("q");
        PrintWriter out = res.getWriter();
        if (q == null || q.trim().isEmpty()) { out.print("[]"); return; }
        java.sql.Connection conn = null;
        java.sql.PreparedStatement ps = null;
        java.sql.ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT * FROM BARC_VEHICLE_MASTER " +
                "WHERE (UPPER(VEHICLE_NO) LIKE ? OR UPPER(DEPARTMENT) LIKE ?) " +
                "AND IS_ACTIVE='Y' AND ROWNUM<=20 ORDER BY VEHICLE_NO"
            );
            String qq = "%" + q.toUpperCase().trim() + "%";
            ps.setString(1, qq); ps.setString(2, qq);
            rs = ps.executeQuery();
            StringBuilder sb = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                first = false;
                String vno = rs.getString("VEHICLE_NO");
                long lastOdo = 0;
                try { lastOdo = new FuelEntryDAO().getLastOdometer(vno); } catch (Exception ex) {}
                String driverName    = rs.getString("DRIVER_NAME")    != null ? rs.getString("DRIVER_NAME")    : "";
                String driverBadge   = rs.getString("DRIVER_BADGE")   != null ? rs.getString("DRIVER_BADGE")   : "";
                String driverContact = rs.getString("DRIVER_CONTACT") != null ? rs.getString("DRIVER_CONTACT") : "";
                sb.append("{");
                sb.append("\"vehicleNo\":\"").append(esc(vno)).append("\",");
                sb.append("\"vehicleType\":\"").append(esc(rs.getString("VEHICLE_TYPE"))).append("\",");
                sb.append("\"department\":\"").append(esc(rs.getString("DEPARTMENT"))).append("\",");
                sb.append("\"fuelType\":\"").append(esc(rs.getString("FUEL_TYPE"))).append("\",");
                sb.append("\"make\":\"").append(esc(rs.getString("MAKE"))).append("\",");
                sb.append("\"model\":\"").append(esc(rs.getString("MODEL"))).append("\",");
                sb.append("\"lastOdometer\":").append(lastOdo).append(",");
                sb.append("\"drivers\":[{");
                sb.append("\"driverId\":0,");
                sb.append("\"driverName\":\"").append(esc(driverName)).append("\",");
                sb.append("\"employeeNo\":\"").append(esc(driverBadge)).append("\",");
                sb.append("\"contactNo\":\"").append(esc(driverContact)).append("\",");
                sb.append("\"licenceNo\":\"").append(esc(driverBadge)).append("\"");
                sb.append("}]}");
            }
            sb.append("]");
            out.print(sb.toString());
        } catch (Exception e) {
            out.print("[]");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    /* ════════════════════════════════════════════════════════
       AJAX: Get drivers by unit ID
       ════════════════════════════════════════════════════════ */
    private void jsonDriversByUnit(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        PrintWriter out = res.getWriter();
        try {
            int unitId = Integer.parseInt(req.getParameter("unitId"));
            List list  = new DriverMasterDAO().getByUnitId(unitId);
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < list.size(); i++) {
                DriverMaster d = (DriverMaster) list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"driverId\":").append(d.getDriverId());
                sb.append(",\"driverName\":\"").append(esc(d.getDriverName())).append("\"");
                sb.append(",\"employeeNo\":\"").append(esc(d.getEmployeeNo())).append("\"");
                sb.append(",\"contactNo\":\"").append(esc(d.getContactNo())).append("\"");
                sb.append(",\"licenceNo\":\"").append(esc(d.getLicenceNo())).append("\"");
                sb.append("}");
            }
            sb.append("]");
            out.print(sb.toString());
        } catch (Exception e) { out.print("[]"); }
    }

    /* ════════════════════════════════════════════════════════
       AJAX: Get vehicles by unit ID
       ════════════════════════════════════════════════════════ */
    private void jsonVehiclesByUnit(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        PrintWriter out = res.getWriter();
        try {
            int unitId = Integer.parseInt(req.getParameter("unitId"));
            List list  = new VehicleMasterDAO().getByUnitId(unitId);
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < list.size(); i++) {
                VehicleMaster v = (VehicleMaster) list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"vehicleId\":").append(v.getVehicleId());
                sb.append(",\"vehicleNo\":\"").append(esc(v.getVehicleNo())).append("\"");
                sb.append(",\"fuelType\":\"").append(esc(v.getFuelType())).append("\"");
                sb.append(",\"vehicleType\":\"").append(esc(v.getVehicleType())).append("\"");
                sb.append("}");
            }
            sb.append("]");
            out.print(sb.toString());
        } catch (Exception e) { out.print("[]"); }
    }

    /* ════════════════════════════════════════════════════════
       AJAX: All units list
       ════════════════════════════════════════════════════════ */
    private void jsonAllUnits(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        PrintWriter out = res.getWriter();
        try {
            List list = new UnitMasterDAO().getAll();
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < list.size(); i++) {
                UnitMaster u = (UnitMaster) list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"unitId\":").append(u.getUnitId());
                sb.append(",\"orgName\":\"").append(esc(u.getOrgName())).append("\"");
                sb.append(",\"unitCode\":\"").append(esc(u.getUnitCode())).append("\"");
                sb.append("}");
            }
            sb.append("]");
            out.print(sb.toString());
        } catch (Exception e) { out.print("[]"); }
    }

    /* ════════════════════════════════════════════════════════
       AJAX: Generate next RCAV number
       Format: RCAV/YYYY/MM/NNN  (sequential within month)
       ════════════════════════════════════════════════════════ */
    private void jsonGenerateRCAV(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        PrintWriter out = res.getWriter();
        java.sql.Connection conn = null;
        java.sql.PreparedStatement ps = null;
        java.sql.ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT NVL(COUNT(*),0) + 1 AS NEXT_SEQ FROM FUEL_ENTRY " +
                "WHERE TRUNC(ENTRY_DATE,'MM') = TRUNC(SYSDATE,'MM')"
            );
            rs = ps.executeQuery();
            int seq = rs.next() ? rs.getInt("NEXT_SEQ") : 1;
            java.util.Calendar cal = java.util.Calendar.getInstance();
            String rcav = "RCAV/" +
                cal.get(java.util.Calendar.YEAR) + "/" +
                String.format("%02d", cal.get(java.util.Calendar.MONTH) + 1) + "/" +
                String.format("%03d", seq);
            out.print("{\"rcavNo\":\"" + rcav + "\"}");
        } catch (Exception e) {
            out.print("{\"rcavNo\":\"RCAV/" +
                new java.text.SimpleDateFormat("yyyyMM").format(new java.util.Date()) +
                "/" + System.currentTimeMillis() % 1000 + "\"}");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}
