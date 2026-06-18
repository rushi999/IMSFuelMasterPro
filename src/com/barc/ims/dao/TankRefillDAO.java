package com.barc.ims.dao;

import com.barc.ims.model.TankRefill;
import com.barc.ims.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * TankRefillDAO - Insert and fetch tank refill log entries
 */
public class TankRefillDAO {

    /** Log a new tank refill and update TANK_MASTER.CURRENT_LEVEL */
    public String saveRefill(TankRefill r) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Get current level
            ps = conn.prepareStatement(
                "SELECT CURRENT_LEVEL, CAPACITY FROM TANK_MASTER WHERE TANK_ID=? AND IS_ACTIVE='Y'"
            );
            ps.setInt(1, r.getTankId());
            rs = ps.executeQuery();
            if (!rs.next()) {
                conn.rollback();
                return "ERROR: Tank not found or inactive.";
            }
            double currentLevel = rs.getDouble("CURRENT_LEVEL");
            double capacity     = rs.getDouble("CAPACITY");
            rs.close(); ps.close();

            double newLevel = currentLevel + r.getRefillQty();
            if (newLevel > capacity) {
                conn.rollback();
                return "ERROR: Refill quantity exceeds tank capacity. Available space: "
                    + (capacity - currentLevel) + " L";
            }

            // 2. Insert refill log
            ps = conn.prepareStatement(
                "INSERT INTO TANK_REFILL_LOG " +
                "(REFILL_ID,TANK_ID,REFILL_QTY,LEVEL_BEFORE,LEVEL_AFTER," +
                "SUPPLIER,CHALLAN_NO,REFILL_DATE,ENTERED_BY,REMARKS) " +
                "VALUES (SEQ_REFILL_LOG.NEXTVAL,?,?,?,?,?,?,?,?,?)"
            );
            ps.setInt(1, r.getTankId());
            ps.setDouble(2, r.getRefillQty());
            ps.setDouble(3, currentLevel);
            ps.setDouble(4, newLevel);
            ps.setString(5, r.getSupplier());
            ps.setString(6, r.getChallanNo());
            if (r.getRefillDate() != null)
                ps.setDate(7, new java.sql.Date(r.getRefillDate().getTime()));
            else
                ps.setDate(7, new java.sql.Date(System.currentTimeMillis()));
            ps.setInt(8, r.getEnteredBy());
            ps.setString(9, r.getRemarks());
            ps.executeUpdate(); ps.close();

            // 3. Update tank level
            ps = conn.prepareStatement(
                "UPDATE TANK_MASTER SET CURRENT_LEVEL=?, LAST_REFILL_DT=SYSDATE, " +
                "LAST_REFILL_QTY=? WHERE TANK_ID=?"
            );
            ps.setDouble(1, newLevel);
            ps.setDouble(2, r.getRefillQty());
            ps.setInt(3, r.getTankId());
            ps.executeUpdate();

            conn.commit();
            return "SUCCESS";

        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception ex) {}
            return "ERROR: " + e.getMessage();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (conn != null) try { conn.setAutoCommit(true); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    /** Get last N refill entries for display in tank master page */
    public List<TankRefill> getRecentRefills(int tankId, int limit) throws SQLException {
        List<TankRefill> list = new ArrayList<TankRefill>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT R.*, T.TANK_NAME, T.FUEL_TYPE, U.FULL_NAME AS ENTERED_BY_NAME " +
                "FROM TANK_REFILL_LOG R " +
                "JOIN TANK_MASTER T ON R.TANK_ID=T.TANK_ID " +
                "LEFT JOIN USERS U ON R.ENTERED_BY=U.USER_ID " +
                (tankId > 0 ? "WHERE R.TANK_ID=? " : "") +
                "ORDER BY R.REFILL_DATE DESC";
            if (tankId > 0) {
                ps = conn.prepareStatement(sql);
                ps.setInt(1, tankId);
            } else {
                ps = conn.prepareStatement(sql);
            }
            rs = ps.executeQuery();
            int count = 0;
            while (rs.next() && (limit <= 0 || count < limit)) {
                TankRefill r = new TankRefill();
                r.setRefillId(rs.getInt("REFILL_ID"));
                r.setTankId(rs.getInt("TANK_ID"));
                r.setTankName(rs.getString("TANK_NAME"));
                r.setFuelType(rs.getString("FUEL_TYPE"));
                r.setRefillQty(rs.getDouble("REFILL_QTY"));
                r.setLevelBefore(rs.getDouble("LEVEL_BEFORE"));
                r.setLevelAfter(rs.getDouble("LEVEL_AFTER"));
                r.setSupplier(rs.getString("SUPPLIER"));
                r.setChallanNo(rs.getString("CHALLAN_NO"));
                r.setRefillDate(rs.getDate("REFILL_DATE"));
                r.setEnteredByName(rs.getString("ENTERED_BY_NAME"));
                r.setRemarks(rs.getString("REMARKS"));
                list.add(r); count++;
            }
            return list;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }
}
