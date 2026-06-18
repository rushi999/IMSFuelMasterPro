package com.barc.ims.dao;

import com.barc.ims.model.TankMaster;
import com.barc.ims.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * TankDAO - Tank status queries
 */
public class TankDAO {

    public List<TankMaster> getAllTanks() throws SQLException {
        List<TankMaster> list = new ArrayList<TankMaster>();
        Connection conn = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            st = conn.createStatement();
            rs = st.executeQuery("SELECT * FROM V_TANK_STATUS ORDER BY TANK_ID");
            while (rs.next()) {
                TankMaster t = new TankMaster();
                t.setTankId(rs.getInt("TANK_ID"));
                t.setTankCode(rs.getString("TANK_CODE"));
                t.setTankName(rs.getString("TANK_NAME"));
                t.setFuelType(rs.getString("FUEL_TYPE"));
                t.setCapacity(rs.getDouble("CAPACITY"));
                t.setCurrentLevel(rs.getDouble("CURRENT_LEVEL"));
                t.setPctFull(rs.getDouble("PCT_FULL"));
                t.setStatus(rs.getString("STATUS"));
                list.add(t);
            }
            return list;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (st != null) try { st.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }
}
