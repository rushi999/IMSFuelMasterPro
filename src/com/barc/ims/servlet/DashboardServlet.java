package com.barc.ims.servlet;

import com.barc.ims.dao.FuelEntryDAO;
import com.barc.ims.dao.TankDAO;
import com.barc.ims.model.TankMaster;
import com.barc.ims.util.DBConnection;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;

/**
 * DashboardServlet v2
 * GET /DashboardServlet?type=kpi    → JSON KPIs
 * GET /DashboardServlet?type=tanks  → JSON tank levels
 * GET /DashboardServlet?type=unitwise → JSON unit-wise disbursement
 * GET /DashboardServlet?type=vehperf  → JSON vehicle performance
 * GET /DashboardServlet             → forward to dashboard.jsp with full data
 */
public class DashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String type = req.getParameter("type");

        /* ── AJAX JSON endpoints ── */
        if ("kpi".equals(type))      { jsonKPI(req, res);      return; }
        if ("tanks".equals(type))    { jsonTanks(req, res);    return; }
        if ("unitwise".equals(type)) { jsonUnitWise(req, res); return; }
        if ("vehperf".equals(type))  { jsonVehPerf(req, res);  return; }
        if ("weekly".equals(type))   { jsonWeekly(req, res);   return; }
        if ("recent".equals(type))   { jsonRecentEntries(req, res); return; }

        /* ── Full page load: forward to dashboard.jsp ── */
        try {
            TankDAO       tankDao  = new TankDAO();
            FuelEntryDAO  entryDao = new FuelEntryDAO();
            List tanks = tankDao.getAllTanks();

            double kpiDaily   = entryDao.getTotalDisbursed("DAILY",   null);
            double kpiWeekly  = entryDao.getTotalDisbursed("WEEKLY",  null);
            double kpiMonthly = entryDao.getTotalDisbursed("MONTHLY", null);
            double kpiDDiesel = entryDao.getTotalDisbursed("DAILY",   "DIESEL");
            double kpiDPetrol = entryDao.getTotalDisbursed("DAILY",   "PETROL");

            req.setAttribute("tanks",      tanks);
            req.setAttribute("kpiDaily",   kpiDaily);
            req.setAttribute("kpiWeekly",  kpiWeekly);
            req.setAttribute("kpiMonthly", kpiMonthly);
            req.setAttribute("kpiDDiesel", kpiDDiesel);
            req.setAttribute("kpiDPetrol", kpiDPetrol);

            /* Unit-wise monthly disbursement */
            req.setAttribute("unitWiseData", getUnitWiseData());
            /* Vehicle performance */
            req.setAttribute("vehPerfData",  getVehPerfData());
            /* Weekly data */
            req.setAttribute("weeklyData",   getWeeklyData());
            /* Fleet counts */
            req.setAttribute("activeVehicles", getActiveVehicleCount());
            req.setAttribute("lowPerformers",  getLowPerformerCount());

            req.setAttribute("activePage", "dashboard");
            req.setAttribute("pageTitle",  "Dashboard");
            req.getRequestDispatcher("/pages/dashboard.jsp").forward(req, res);

        } catch (Exception e) {
            req.setAttribute("errorMsg", "Dashboard error: " + e.getMessage());
            req.getRequestDispatcher("/pages/dashboard.jsp").forward(req, res);
        }
    }

    /* ════════════════════════════════════════════════════════
       JSON: KPI numbers
    ════════════════════════════════════════════════════════ */
    private void jsonKPI(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.setHeader("Cache-Control","no-cache");
        PrintWriter out = res.getWriter();
        try {
            FuelEntryDAO dao = new FuelEntryDAO();
            double daily   = dao.getTotalDisbursed("DAILY",   null);
            double weekly  = dao.getTotalDisbursed("WEEKLY",  null);
            double monthly = dao.getTotalDisbursed("MONTHLY", null);
            out.print("{\"daily\":"   + daily   +
                      ",\"weekly\":"  + weekly  +
                      ",\"monthly\":" + monthly + "}");
        } catch (Exception e) {
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    /* ════════════════════════════════════════════════════════
       JSON: Tank levels
    ════════════════════════════════════════════════════════ */
    private void jsonTanks(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.setHeader("Cache-Control","no-cache");
        PrintWriter out = res.getWriter();
        try {
            List tanks = new TankDAO().getAllTanks();
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < tanks.size(); i++) {
                TankMaster t = (TankMaster) tanks.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"tankId\":").append(t.getTankId())
                  .append(",\"tankName\":\"").append(esc(t.getTankName())).append("\"")
                  .append(",\"fuelType\":\"").append(esc(t.getFuelType())).append("\"")
                  .append(",\"capacity\":").append(t.getCapacity())
                  .append(",\"level\":").append(t.getCurrentLevel())
                  .append(",\"pct\":").append(t.getPctFull())
                  .append(",\"status\":\"").append(esc(t.getStatus())).append("\"")
                  .append("}");
            }
            sb.append("]");
            out.print(sb.toString());
        } catch (Exception e) {
            out.print("[]");
        }
    }

    /* ════════════════════════════════════════════════════════
       JSON: Unit-wise monthly disbursement
    ════════════════════════════════════════════════════════ */
    private void jsonUnitWise(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        PrintWriter out = res.getWriter();
        try {
            out.print(buildUnitWiseJson(getUnitWiseData()));
        } catch (Exception e) { out.print("[]"); }
    }

    /* ════════════════════════════════════════════════════════
       JSON: Vehicle performance
    ════════════════════════════════════════════════════════ */
    private void jsonVehPerf(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        PrintWriter out = res.getWriter();
        try {
            out.print(buildVehPerfJson(getVehPerfData()));
        } catch (Exception e) { out.print("[]"); }
    }

    /* ════════════════════════════════════════════════════════
       JSON: Weekly chart data
    ════════════════════════════════════════════════════════ */
    private void jsonWeekly(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        PrintWriter out = res.getWriter();
        try {
            out.print(buildWeeklyJson(getWeeklyData()));
        } catch (Exception e) { out.print("[]"); }
    }

    /* ════════════════════════════════════════════════════════
       DB: Unit-wise monthly disbursement
    ════════════════════════════════════════════════════════ */
    private List getUnitWiseData() throws SQLException {
        List rows = new ArrayList();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT " +
                "  CASE WHEN E.ENTRY_CATEGORY='UNIT' " +
                "    THEN NVL(NVL(E.ORG_NAME, UM.ORG_NAME),'DAE Unit') " +
                "    ELSE NVL(B.DEPARTMENT, NVL(E.DEPARTMENT,'BARC')) END AS UNIT_NAME, " +
                "  E.ENTRY_CATEGORY, " +
                "  SUM(CASE WHEN E.FUEL_TYPE='DIESEL' THEN E.QTY_ISSUED ELSE 0 END) AS DIESEL_QTY, " +
                "  SUM(CASE WHEN E.FUEL_TYPE='PETROL' THEN E.QTY_ISSUED ELSE 0 END) AS PETROL_QTY, " +
                "  SUM(E.QTY_ISSUED) AS TOTAL_QTY, " +
                "  COUNT(*) AS TXN_COUNT " +
                "FROM FUEL_ENTRY E " +
                "LEFT JOIN BARC_VEHICLE_MASTER B  ON UPPER(E.VEHICLE_NO)=UPPER(B.VEHICLE_NO) " +
                "LEFT JOIN VEHICLE_MASTER      VM ON UPPER(E.VEHICLE_NO)=UPPER(VM.VEHICLE_NO) AND VM.STATUS='Active' " +
                "LEFT JOIN UNIT_MASTER         UM ON VM.UNIT_ID=UM.UNIT_ID " +
                "WHERE TRUNC(E.ENTRY_DATE,'MM') = TRUNC(SYSDATE,'MM') " +
                "GROUP BY " +
                "  CASE WHEN E.ENTRY_CATEGORY='UNIT' " +
                "    THEN NVL(NVL(E.ORG_NAME, UM.ORG_NAME),'DAE Unit') " +
                "    ELSE NVL(B.DEPARTMENT, NVL(E.DEPARTMENT,'BARC')) END, " +
                "  E.ENTRY_CATEGORY " +
                "ORDER BY TOTAL_QTY DESC"
            );
            rs = ps.executeQuery();
            while (rs.next()) {
                Map row = new HashMap();
                row.put("unitName",   rs.getString("UNIT_NAME"));
                row.put("category",   rs.getString("ENTRY_CATEGORY"));
                row.put("dieselQty",  rs.getDouble("DIESEL_QTY"));
                row.put("petrolQty",  rs.getDouble("PETROL_QTY"));
                row.put("totalQty",   rs.getDouble("TOTAL_QTY"));
                row.put("txnCount",   rs.getInt("TXN_COUNT"));
                rows.add(row);
            }
            return rows;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    /* ════════════════════════════════════════════════════════
       DB: Vehicle performance (monthly avg mileage vs expected)
    ════════════════════════════════════════════════════════ */
    private List getVehPerfData() throws SQLException {
        List rows = new ArrayList();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT * FROM (" +
                "  SELECT " +
                "    E.VEHICLE_NO, " +
                "    NVL(B.VEHICLE_TYPE, NVL(VM.VEHICLE_TYPE,'Vehicle')) AS VEHICLE_TYPE, " +
                "    CASE WHEN MAX(E.ENTRY_CATEGORY)='UNIT' " +
                "      THEN NVL(MAX(UM.ORG_NAME), NVL(MAX(E.ORG_NAME),'DAE Unit')) " +
                "      ELSE NVL(MAX(B.DEPARTMENT), NVL(MAX(E.DEPARTMENT),'BARC')) END AS DEPARTMENT, " +
                "    MAX(E.DRIVER_NAME) AS DRIVER_NAME, " +
                "    NVL(B.FUEL_TYPE, MAX(E.FUEL_TYPE)) AS FUEL_TYPE, " +
                "    ROUND(AVG(NULLIF(E.AVG_MILEAGE,0)), 2) AS AVG_MILEAGE " +
                "  FROM FUEL_ENTRY E " +
                "  LEFT JOIN BARC_VEHICLE_MASTER B  ON UPPER(E.VEHICLE_NO)=UPPER(B.VEHICLE_NO) " +
                "  LEFT JOIN VEHICLE_MASTER      VM ON UPPER(E.VEHICLE_NO)=UPPER(VM.VEHICLE_NO) AND VM.STATUS='Active' " +
                "  LEFT JOIN UNIT_MASTER         UM ON VM.UNIT_ID=UM.UNIT_ID " +
                "  WHERE E.VEHICLE_NO IS NOT NULL " +
                "    AND E.AVG_MILEAGE > 0 " +
                "    AND TRUNC(E.ENTRY_DATE,'MM') = TRUNC(SYSDATE,'MM') " +
                "  GROUP BY E.VEHICLE_NO, B.VEHICLE_TYPE, VM.VEHICLE_TYPE, B.DEPARTMENT, B.FUEL_TYPE " +
                "  ORDER BY AVG_MILEAGE ASC" +
                ") WHERE ROWNUM <= 15"
            );
            rs = ps.executeQuery();
            while (rs.next()) {
                Map row = new HashMap();
                row.put("vehicleNo",   rs.getString("VEHICLE_NO"));
                row.put("vehicleType", rs.getString("VEHICLE_TYPE"));
                row.put("department",  rs.getString("DEPARTMENT"));
                row.put("driverName",  rs.getString("DRIVER_NAME"));
                row.put("fuelType",    rs.getString("FUEL_TYPE"));
                row.put("avgMileage",  rs.getDouble("AVG_MILEAGE"));
                rows.add(row);
            }
            return rows;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    /* ════════════════════════════════════════════════════════
       DB: Weekly disbursement (last 7 days diesel + petrol)
    ════════════════════════════════════════════════════════ */
    private List getWeeklyData() throws SQLException {
        List rows = new ArrayList();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT " +
                "  TRUNC(ENTRY_DATE) AS DAY_DATE, " +
                "  SUM(CASE WHEN FUEL_TYPE='DIESEL' THEN QTY_ISSUED ELSE 0 END) AS DIESEL_QTY, " +
                "  SUM(CASE WHEN FUEL_TYPE='PETROL' THEN QTY_ISSUED ELSE 0 END) AS PETROL_QTY " +
                "FROM FUEL_ENTRY " +
                "WHERE ENTRY_DATE >= TRUNC(SYSDATE) - 6 " +
                "GROUP BY TRUNC(ENTRY_DATE) " +
                "ORDER BY DAY_DATE"
            );
            rs = ps.executeQuery();
            while (rs.next()) {
                Map row = new HashMap();
                row.put("dayDate",   rs.getDate("DAY_DATE"));
                row.put("dieselQty", rs.getDouble("DIESEL_QTY"));
                row.put("petrolQty", rs.getDouble("PETROL_QTY"));
                rows.add(row);
            }
            return rows;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    private int getActiveVehicleCount() throws SQLException {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT COUNT(DISTINCT VEHICLE_NO) FROM FUEL_ENTRY " +
                "WHERE TRUNC(ENTRY_DATE,'MM')=TRUNC(SYSDATE,'MM')"
            );
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    private int getLowPerformerCount() throws SQLException {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM (" +
                "  SELECT VEHICLE_NO, AVG(AVG_MILEAGE) AS AM " +
                "  FROM FUEL_ENTRY WHERE AVG_MILEAGE > 0 " +
                "  AND TRUNC(ENTRY_DATE,'MM')=TRUNC(SYSDATE,'MM') " +
                "  GROUP BY VEHICLE_NO HAVING AVG(AVG_MILEAGE) < 8)"
            );
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    /* ── JSON builders ── */
    private String buildUnitWiseJson(List rows) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < rows.size(); i++) {
            Map r = (Map) rows.get(i);
            if (i > 0) sb.append(",");
            sb.append("{\"unitName\":\"").append(esc(str(r.get("unitName")))).append("\"")
              .append(",\"category\":\"").append(esc(str(r.get("category")))).append("\"")
              .append(",\"dieselQty\":").append(r.get("dieselQty"))
              .append(",\"petrolQty\":").append(r.get("petrolQty"))
              .append(",\"totalQty\":").append(r.get("totalQty"))
              .append(",\"txnCount\":").append(r.get("txnCount"))
              .append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String buildVehPerfJson(List rows) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < rows.size(); i++) {
            Map r = (Map) rows.get(i);
            if (i > 0) sb.append(",");
            sb.append("{\"vehicleNo\":\"").append(esc(str(r.get("vehicleNo")))).append("\"")
              .append(",\"vehicleType\":\"").append(esc(str(r.get("vehicleType")))).append("\"")
              .append(",\"department\":\"").append(esc(str(r.get("department")))).append("\"")
              .append(",\"driverName\":\"").append(esc(str(r.get("driverName")))).append("\"")
              .append(",\"fuelType\":\"").append(esc(str(r.get("fuelType")))).append("\"")
              .append(",\"avgMileage\":").append(r.get("avgMileage"))
              .append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String buildWeeklyJson(List rows) {
        StringBuilder sb = new StringBuilder("[");
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("EEE");
        for (int i = 0; i < rows.size(); i++) {
            Map r = (Map) rows.get(i);
            if (i > 0) sb.append(",");
            java.util.Date d = (java.util.Date) r.get("dayDate");
            String day = d != null ? sdf.format(d).toUpperCase() : "DAY";
            sb.append("{\"day\":\"").append(day).append("\"")
              .append(",\"diesel\":").append(r.get("dieselQty"))
              .append(",\"petrol\":").append(r.get("petrolQty"))
              .append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    /* ══ JSON: Recent 20 fuel entries (today) ══ */
    private void jsonRecentEntries(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.setHeader("Cache-Control","no-cache");
        PrintWriter out = res.getWriter();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT * FROM (" +
                "  SELECT E.ENTRY_ID, E.REQ_NO, E.ENTRY_CATEGORY, E.VEHICLE_NO, " +
                "    E.FUEL_TYPE, E.QTY_ISSUED, E.DRIVER_NAME, E.DRIVER_BADGE, " +
                "    E.DEPARTMENT, E.ORG_NAME, E.RCAV_NO, E.ENTRY_DATE, E.ENTRY_TIME, " +
                "    E.PREV_ODOMETER, E.CURR_ODOMETER, E.REMARKS, " +
                "    NVL(TM.TANK_NAME, 'Tank') AS TANK_NAME " +
                "  FROM FUEL_ENTRY E " +
                "  LEFT JOIN TANK_MASTER TM ON E.TANK_ID = TM.TANK_ID " +
                "  WHERE TRUNC(E.ENTRY_DATE) = TRUNC(SYSDATE) " +
                "  ORDER BY E.ENTRY_ID DESC" +
                ") WHERE ROWNUM <= 20"
            );
            rs = ps.executeQuery();
            StringBuilder sb = new StringBuilder("[");
            boolean first = true;
            java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("dd-MMM-yyyy");
            while (rs.next()) {
                if (!first) sb.append(",");
                first = false;
                java.util.Date ed = rs.getDate("ENTRY_DATE");
                sb.append("{")
                  .append("\"entryId\":").append(rs.getInt("ENTRY_ID"))
                  .append(",\"reqNo\":\"").append(esc(rs.getString("REQ_NO"))).append("\"")
                  .append(",\"category\":\"").append(esc(rs.getString("ENTRY_CATEGORY"))).append("\"")
                  .append(",\"vehicleNo\":\"").append(esc(rs.getString("VEHICLE_NO"))).append("\"")
                  .append(",\"fuelType\":\"").append(esc(rs.getString("FUEL_TYPE"))).append("\"")
                  .append(",\"qtyIssued\":").append(rs.getDouble("QTY_ISSUED"))
                  .append(",\"driverName\":\"").append(esc(rs.getString("DRIVER_NAME"))).append("\"")
                  .append(",\"driverBadge\":\"").append(esc(rs.getString("DRIVER_BADGE"))).append("\"")
                  .append(",\"department\":\"").append(esc(rs.getString("DEPARTMENT"))).append("\"")
                  .append(",\"orgName\":\"").append(esc(rs.getString("ORG_NAME"))).append("\"")
                  .append(",\"rcavNo\":\"").append(esc(rs.getString("RCAV_NO"))).append("\"")
                  .append(",\"entryDate\":\"").append(ed != null ? df.format(ed) : "").append("\"")
                  .append(",\"entryTime\":\"").append(esc(rs.getString("ENTRY_TIME"))).append("\"")
                  .append(",\"prevOdo\":").append(rs.getLong("PREV_ODOMETER"))
                  .append(",\"currOdo\":").append(rs.getLong("CURR_ODOMETER"))
                  .append(",\"tankName\":\"").append(esc(rs.getString("TANK_NAME"))).append("\"")
                  .append(",\"remarks\":\"").append(esc(rs.getString("REMARKS"))).append("\"")
                  .append("}");
            }
            sb.append("]");
            out.print(sb.toString());
        } catch (Exception e) {
            out.print("[]");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e2) {}
            if (ps != null) try { ps.close(); } catch (Exception e2) {}
            DBConnection.close(conn);
        }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"");
    }
    private String str(Object o) { return o != null ? o.toString() : ""; }
}
