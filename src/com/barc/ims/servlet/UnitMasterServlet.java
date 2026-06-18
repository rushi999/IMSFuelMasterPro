package com.barc.ims.servlet;

import com.barc.ims.dao.UnitMasterDAO;
import com.barc.ims.dao.VehicleMasterDAO;
import com.barc.ims.dao.DriverMasterDAO;
import com.barc.ims.model.UnitMaster;
import com.barc.ims.model.VehicleMaster;
import com.barc.ims.model.DriverMaster;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.*;

/**
 * UnitMasterServlet - CRUD operations for Unit Master.
 * action=save|delete|list
 * GET action=vehicles|drivers returns JSON for associated records
 */
public class UnitMasterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            try {
                int unitId = Integer.parseInt(req.getParameter("unitId"));
                new UnitMasterDAO().delete(unitId);
                req.getSession().setAttribute("successMsg", "Unit deleted successfully.");
            } catch (Exception e) {
                req.getSession().setAttribute("errorMsg", "Delete failed: " + e.getMessage());
            }
            res.sendRedirect(req.getContextPath() + "/MasterServlet?section=unit");
            return;
        }

        // save (add or edit)
        UnitMaster u = new UnitMaster();
        String unitIdStr = req.getParameter("unitId");
        if (unitIdStr != null && !unitIdStr.isEmpty())
            u.setUnitId(Integer.parseInt(unitIdStr));

        u.setOrgName(req.getParameter("orgName"));
        u.setUnitCode(req.getParameter("unitCode"));
        u.setUnitType(req.getParameter("unitType"));
        u.setVehicleNo(req.getParameter("vehicleNo"));
        u.setVehicleMake(req.getParameter("vehicleMake"));
        u.setVehicleModel(req.getParameter("vehicleModel"));
        try { u.setYearMfg(Integer.parseInt(req.getParameter("yearMfg"))); } catch (Exception e) {}
        u.setFuelType(req.getParameter("fuelType"));
        try { u.setEngineCc(Integer.parseInt(req.getParameter("engineCc"))); } catch (Exception e) {}
        u.setDriverName(req.getParameter("driverName"));
        u.setDriverLicence(req.getParameter("driverLicence"));
        try {
            String exp = req.getParameter("licenceExpiry");
            if (exp != null && !exp.isEmpty())
                u.setLicenceExpiry(new SimpleDateFormat("yyyy-MM-dd").parse(exp));
        } catch (Exception e) {}
        u.setDriverContact(req.getParameter("driverContact"));
        u.setContactPerson(req.getParameter("contactPerson"));
        u.setDesignation(req.getParameter("designation"));
        u.setPhoneExt(req.getParameter("phoneExt"));
        u.setStatus(req.getParameter("status"));
        u.setNotes(req.getParameter("notes"));

        try {
            new UnitMasterDAO().save(u);
            req.getSession().setAttribute("successMsg", "Unit master saved successfully.");
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", "Save failed: " + e.getMessage());
        }
        res.sendRedirect(req.getContextPath() + "/MasterServlet?section=unit");
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("vehicles".equals(action)) {
            res.setContentType("application/json;charset=UTF-8");
            PrintWriter out = res.getWriter();
            try {
                int unitId = Integer.parseInt(req.getParameter("unitId"));
                List<VehicleMaster> vehicles = new VehicleMasterDAO().getByUnitId(unitId);
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < vehicles.size(); i++) {
                    VehicleMaster v = vehicles.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{");
                    sb.append("\"vehicleId\":").append(v.getVehicleId()).append(",");
                    sb.append("\"vehicleNo\":\"").append(esc(v.getVehicleNo())).append("\",");
                    sb.append("\"vehicleType\":\"").append(esc(v.getVehicleType())).append("\",");
                    sb.append("\"fuelType\":\"").append(esc(v.getFuelType())).append("\",");
                    sb.append("\"status\":\"").append(esc(v.getStatus())).append("\",");
                    sb.append("\"regDate\":\"\"");
                    sb.append("}");
                }
                sb.append("]");
                out.print(sb.toString());
            } catch (Exception e) {
                out.print("[]");
            }
            return;
        }

        if ("drivers".equals(action)) {
            res.setContentType("application/json;charset=UTF-8");
            PrintWriter out = res.getWriter();
            try {
                int unitId = Integer.parseInt(req.getParameter("unitId"));
                List<DriverMaster> drivers = new DriverMasterDAO().getByUnitId(unitId);
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < drivers.size(); i++) {
                    DriverMaster d = drivers.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{");
                    sb.append("\"driverId\":").append(d.getDriverId()).append(",");
                    sb.append("\"employeeNo\":\"").append(esc(d.getEmployeeNo())).append("\",");
                    sb.append("\"driverName\":\"").append(esc(d.getDriverName())).append("\",");
                    sb.append("\"licenceNo\":\"").append(esc(d.getLicenceNo())).append("\",");
                    sb.append("\"status\":\"").append(esc(d.getStatus())).append("\"");
                    sb.append("}");
                }
                sb.append("]");
                out.print(sb.toString());
            } catch (Exception e) {
                out.print("[]");
            }
            return;
        }

        res.sendRedirect(req.getContextPath() + "/MasterServlet?section=unit");
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
