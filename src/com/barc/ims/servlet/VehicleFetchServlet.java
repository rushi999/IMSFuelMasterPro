package com.barc.ims.servlet;

import com.barc.ims.dao.UnitMasterDAO;
import com.barc.ims.dao.VehicleDAO;
import com.barc.ims.model.BarcVehicle;
import com.barc.ims.model.UnitMaster;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.*;

/**
 * VehicleFetchServlet - AJAX JSON endpoint for vehicle auto-fetch.
 * Called by frontend JS on vehicle number input.
 *
 * URL: /VehicleFetchServlet?type=BARC&vno=MH04GA1234
 *      /VehicleFetchServlet?type=UNIT&vno=TN22AB1234
 */
public class VehicleFetchServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.setHeader("Cache-Control", "no-cache");
        PrintWriter out = res.getWriter();

        String type = req.getParameter("type");
        String vno  = req.getParameter("vno");

        if (vno == null || vno.trim().isEmpty()) {
            out.print("{\"found\":false,\"error\":\"Vehicle number required\"}");
            return;
        }
        vno = vno.trim().toUpperCase();

        try {
            if ("BARC".equalsIgnoreCase(type)) {
                VehicleDAO dao = new VehicleDAO();
                BarcVehicle v = dao.getByVehicleNo(vno);
                if (v != null) {
                    out.print("{\"found\":true," +
                        "\"vehicleType\":" + jsonStr(v.getVehicleType()) + "," +
                        "\"department\":"  + jsonStr(v.getDepartment())  + "," +
                        "\"driverName\":"  + jsonStr(v.getDriverName())  + "," +
                        "\"driverBadge\":" + jsonStr(v.getDriverBadge()) + "," +
                        "\"driverContact\":" + jsonStr(v.getDriverContact()) + "," +
                        "\"fuelType\":"    + jsonStr(v.getFuelType())    + "," +
                        "\"make\":"        + jsonStr(v.getMake())        + "," +
                        "\"model\":"       + jsonStr(v.getModel())       + "}");
                } else {
                    out.print("{\"found\":false}");
                }
            } else if ("UNIT".equalsIgnoreCase(type)) {
                UnitMasterDAO dao = new UnitMasterDAO();
                UnitMaster u = dao.getByVehicleNo(vno);
                if (u != null) {
                    out.print("{\"found\":true," +
                        "\"orgName\":"      + jsonStr(u.getOrgName())      + "," +
                        "\"unitCode\":"     + jsonStr(u.getUnitCode())     + "," +
                        "\"driverName\":"   + jsonStr(u.getDriverName())   + "," +
                        "\"driverLicence\":" + jsonStr(u.getDriverLicence()) + "," +
                        "\"driverContact\":" + jsonStr(u.getDriverContact()) + "," +
                        "\"fuelType\":"     + jsonStr(u.getFuelType())     + "}");
                } else {
                    out.print("{\"found\":false,\"newEntry\":true}");
                }
            } else {
                out.print("{\"found\":false,\"error\":\"Unknown type\"}");
            }
        } catch (Exception e) {
            getServletContext().log("[IMS] VehicleFetch error", e);
            out.print("{\"found\":false,\"error\":\"DB error\"}");
        }
    }

    private String jsonStr(String val) {
        if (val == null) return "null";
        return "\"" + val.replace("\"", "\\\"") + "\"";
    }
}
