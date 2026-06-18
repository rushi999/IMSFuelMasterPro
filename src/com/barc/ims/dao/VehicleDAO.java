package com.barc.ims.dao;

import com.barc.ims.model.BarcVehicle;
import com.barc.ims.model.UnitMaster;
import com.barc.ims.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * VehicleDAO - BARC vehicle master fetch operations
 */
public class VehicleDAO {

    public BarcVehicle getByVehicleNo(String vehicleNo) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT * FROM BARC_VEHICLE_MASTER WHERE VEHICLE_NO = ? AND IS_ACTIVE = 'Y'"
            );
            ps.setString(1, vehicleNo.toUpperCase().trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                BarcVehicle v = new BarcVehicle();
                v.setVehicleId(rs.getInt("VEHICLE_ID"));
                v.setVehicleNo(rs.getString("VEHICLE_NO"));
                v.setVehicleType(rs.getString("VEHICLE_TYPE"));
                v.setMake(rs.getString("MAKE"));
                v.setModel(rs.getString("MODEL"));
                v.setYearMfg(rs.getInt("YEAR_MFG"));
                v.setFuelType(rs.getString("FUEL_TYPE"));
                v.setDepartment(rs.getString("DEPARTMENT"));
                v.setDriverName(rs.getString("DRIVER_NAME"));
                v.setDriverBadge(rs.getString("DRIVER_BADGE"));
                v.setDriverContact(rs.getString("DRIVER_CONTACT"));
                return v;
            }
            return null;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }
}
