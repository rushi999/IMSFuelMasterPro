package com.barc.ims.dao;

import com.barc.ims.model.FuelEntry;
import com.barc.ims.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * FuelEntryDAO v3 — All DB operations for FUEL_ENTRY table.
 * Matches updated SP_ISSUE_FUEL with 20 IN + 2 OUT parameters.
 * Oracle 10g / JDK 1.7 compatible.
 */
public class FuelEntryDAO {

    /**
     * Insert via stored procedure SP_ISSUE_FUEL (20 IN + 2 OUT params).
     * All fields now properly passed including RCAV_NO, REMARKS,
     * VEHICLE_TYPE, ENTRY_TIME, ORG_NAME, DRIVER_BADGE, DRIVER_CONTACT.
     */
    public String saveFuelEntry(FuelEntry e) throws SQLException {
        Connection conn = null;
        CallableStatement cs = null;
        try {
            conn = DBConnection.getConnection();
            cs = conn.prepareCall(
                "{ CALL SP_ISSUE_FUEL(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) }"
            );
            // IN params 1-20
            cs.setString(1,  nvl(e.getEntryCategory(), "BARC"));
            cs.setString(2,  nvl(e.getVehicleNo(), ""));
            cs.setString(3,  nvl(e.getFuelType(), "DIESEL"));
            cs.setDouble(4,  e.getQtyIssued());
            cs.setString(5,  e.getDriverName());
            cs.setString(6,  e.getDriverBadge());
            cs.setString(7,  e.getDriverContact());
            cs.setString(8,  e.getDepartment());
            cs.setString(9,  e.getOrgName());
            cs.setString(10, e.getVehicleType());

            // Odometer — null-safe
            if (e.getPrevOdometer() > 0)
                cs.setLong(11, e.getPrevOdometer());
            else
                cs.setNull(11, Types.NUMERIC);

            if (e.getCurrOdometer() > 0)
                cs.setLong(12, e.getCurrOdometer());
            else
                cs.setNull(12, Types.NUMERIC);

            // Tank ID
            if (e.getTankId() > 0)
                cs.setInt(13, e.getTankId());
            else
                cs.setNull(13, Types.NUMERIC);

            cs.setString(14, e.getRcavNo());
            cs.setString(15, e.getAuthOfficer());
            cs.setString(16, e.getIssuedBy());

            if (e.getEntryDate() != null)
                cs.setDate(17, new java.sql.Date(e.getEntryDate().getTime()));
            else
                cs.setNull(17, Types.DATE);

            cs.setString(18, e.getEntryTime());
            cs.setString(19, e.getRemarks());
            cs.setInt(20, e.getCreatedBy());

            // OUT params 21-22
            cs.registerOutParameter(21, Types.NUMERIC);
            cs.registerOutParameter(22, Types.VARCHAR);

            cs.execute();

            String status = cs.getString(22);
            if ("SUCCESS".equals(status)) {
                e.setEntryId(cs.getInt(21));
            }
            return status;

        } finally {
            if (cs != null) try { cs.close(); } catch (Exception ex) {}
            DBConnection.close(conn);
        }
    }

    /**
     * Daily report: entries between fromDate and toDate (inclusive).
     * category: null / "" / "ALL" = all categories, else filter by value.
     */
    public List<FuelEntry> getDailyEntries(
            java.util.Date fromDate,
            java.util.Date toDate,
            String category) throws SQLException {

        List<FuelEntry> list = new ArrayList<FuelEntry>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            StringBuilder sql = new StringBuilder(
                "SELECT * FROM V_DAILY_REPORT " +
                "WHERE TRUNC(ENTRY_DATE) >= TRUNC(?) " +
                "AND TRUNC(ENTRY_DATE) <= TRUNC(?) "
            );
            boolean filterCat = category != null &&
                                 !category.isEmpty() &&
                                 !"ALL".equalsIgnoreCase(category);
            if (filterCat)
                sql.append("AND ENTRY_CATEGORY = ? ");
            sql.append("ORDER BY ENTRY_DATE, ENTRY_ID");

            ps = conn.prepareStatement(sql.toString());
            ps.setDate(1, new java.sql.Date(fromDate.getTime()));
            ps.setDate(2, new java.sql.Date(toDate.getTime()));
            if (filterCat) ps.setString(3, category.toUpperCase());

            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
            return list;

        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ex) {}
            if (ps != null) try { ps.close(); } catch (Exception ex) {}
            DBConnection.close(conn);
        }
    }

    /**
     * Overload: single-date convenience (keeps backward compat).
     */
    public List<FuelEntry> getDailyEntries(
            java.util.Date date, String category) throws SQLException {
        return getDailyEntries(date, date, category);
    }

    /**
     * RCAV monthly report — now includes unit/org, diesel, petrol splits.
     */
    public List<FuelEntry> getMonthlyRCAV(int month, int year) throws SQLException {
        List<FuelEntry> list = new ArrayList<FuelEntry>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT VEHICLE_NO, DEPARTMENT, DRIVER_NAME, VEHICLE_TYPE, ORG_NAME, " +
                "  OPEN_KM, CLOSE_KM, TOTAL_KM, " +
                "  DIESEL_LITRES, PETROL_LITRES, TOTAL_FUEL, AVG_MILEAGE, ENTRY_CATEGORY " +
                "FROM V_RCAV_MONTHLY " +
                "WHERE EXTRACT(MONTH FROM REPORT_MONTH) = ? " +
                "AND EXTRACT(YEAR  FROM REPORT_MONTH) = ? " +
                "ORDER BY VEHICLE_NO";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, month);
            ps.setInt(2, year);
            rs = ps.executeQuery();
            while (rs.next()) {
                FuelEntry fe = new FuelEntry();
                fe.setVehicleNo(rs.getString("VEHICLE_NO"));
                fe.setDepartment(rs.getString("DEPARTMENT"));
                fe.setDriverName(rs.getString("DRIVER_NAME"));
                fe.setVehicleType(rs.getString("VEHICLE_TYPE"));
                fe.setOrgName(rs.getString("ORG_NAME"));
                fe.setPrevOdometer(rs.getLong("OPEN_KM"));
                fe.setCurrOdometer(rs.getLong("CLOSE_KM"));
                fe.setDistanceKm(rs.getDouble("TOTAL_KM"));
                fe.setQtyIssued(rs.getDouble("TOTAL_FUEL"));
                fe.setAvgMileage(rs.getDouble("AVG_MILEAGE"));
                fe.setEntryCategory(rs.getString("ENTRY_CATEGORY"));
                // Store diesel/petrol splits using purpose/supplyType temporarily
                fe.setPurpose(String.valueOf(rs.getDouble("DIESEL_LITRES")));
                fe.setSupplyType(String.valueOf(rs.getDouble("PETROL_LITRES")));
                list.add(fe);
            }
            return list;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ex) {}
            if (ps != null) try { ps.close(); } catch (Exception ex) {}
            DBConnection.close(conn);
        }
    }

    /** Returns the most recent CURR_ODOMETER for a given vehicle, or 0 if none. */
    public long getLastOdometer(String vehicleNo) throws SQLException {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT MAX(CURR_ODOMETER) AS LAST_ODO " +
                "FROM FUEL_ENTRY " +
                "WHERE UPPER(VEHICLE_NO)=UPPER(?) AND CURR_ODOMETER IS NOT NULL"
            );
            ps.setString(1, vehicleNo.trim());
            rs = ps.executeQuery();
            if (rs.next() && rs.getObject("LAST_ODO") != null)
                return rs.getLong("LAST_ODO");
            return 0;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ex) {}
            if (ps != null) try { ps.close(); } catch (Exception ex) {}
            DBConnection.close(conn);
        }
    }

    /** Dashboard KPIs */
    public double getTotalDisbursed(String period, String fuelType) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String dateFilter;
            if      ("DAILY".equals(period))  dateFilter = "TRUNC(ENTRY_DATE) = TRUNC(SYSDATE)";
            else if ("WEEKLY".equals(period)) dateFilter = "ENTRY_DATE >= TRUNC(SYSDATE,'IW')";
            else if ("MONTHLY".equals(period))dateFilter = "TRUNC(ENTRY_DATE,'MM') = TRUNC(SYSDATE,'MM')";
            else                              dateFilter = "1=1";
            String fuelFilter = (fuelType != null && !fuelType.isEmpty())
                ? " AND FUEL_TYPE = ?"
                : "";
            String sql = "SELECT NVL(SUM(QTY_ISSUED),0) FROM FUEL_ENTRY WHERE "
                       + dateFilter + fuelFilter;
            ps = conn.prepareStatement(sql);
            if (fuelType != null && !fuelType.isEmpty())
                ps.setString(1, fuelType.toUpperCase());
            rs = ps.executeQuery();
            return rs.next() ? rs.getDouble(1) : 0;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ex) {}
            if (ps != null) try { ps.close(); } catch (Exception ex) {}
            DBConnection.close(conn);
        }
    }

    private FuelEntry mapRow(ResultSet rs) throws SQLException {
        FuelEntry e = new FuelEntry();
        e.setEntryId(rs.getInt("ENTRY_ID"));
        try { e.setReqNo(rs.getString("REQ_NO")); } catch (Exception ex) {}
        e.setVehicleNo(rs.getString("VEHICLE_NO"));
        e.setVehicleType(rs.getString("VEHICLE_TYPE"));
        e.setEntryCategory(rs.getString("ENTRY_CATEGORY"));
        e.setFuelType(rs.getString("FUEL_TYPE"));
        e.setQtyIssued(rs.getDouble("QTY_ISSUED"));
        e.setPrevOdometer(rs.getLong("PREV_ODOMETER"));
        e.setCurrOdometer(rs.getLong("CURR_ODOMETER"));
        e.setDistanceKm(rs.getDouble("DISTANCE_KM"));
        e.setAvgMileage(rs.getDouble("AVG_MILEAGE"));
        e.setDriverName(rs.getString("DRIVER_NAME"));
        try { e.setDriverBadge(rs.getString("DRIVER_BADGE")); } catch (Exception ex) {}
        try { e.setDriverContact(rs.getString("DRIVER_CONTACT")); } catch (Exception ex) {}
        e.setDepartment(rs.getString("DEPARTMENT"));
        e.setOrgName(rs.getString("ORG_NAME"));
        try { e.setRcavNo(rs.getString("RCAV_NO")); } catch (Exception ex) {}
        e.setIssuedBy(rs.getString("ISSUED_BY"));
        try { e.setAuthOfficer(rs.getString("AUTH_OFFICER")); } catch (Exception ex) {}
        e.setEntryDate(rs.getDate("ENTRY_DATE"));
        try { e.setEntryTime(rs.getString("ENTRY_TIME")); } catch (Exception ex) {}
        try { e.setRemarks(rs.getString("REMARKS")); } catch (Exception ex) {}
        try { e.setPurpose(rs.getString("PURPOSE")); } catch (Exception ex) {}
        try { e.setSupplyType(rs.getString("SUPPLY_TYPE")); } catch (Exception ex) {}
        return e;
    }

    private String nvl(String val, String def) {
        return (val != null && !val.trim().isEmpty()) ? val.trim() : def;
    }
}
