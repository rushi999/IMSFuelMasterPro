package com.barc.ims.dao;

import com.barc.ims.model.VehicleMaster;
import com.barc.ims.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * VehicleMasterDAO - CRUD for VEHICLE_MASTER (Other DAE Units)
 */
public class VehicleMasterDAO {

    public List<VehicleMaster> getAll() throws SQLException {
        return getByUnitId(-1);
    }

    public List<VehicleMaster> getByUnitId(int unitId) throws SQLException {
        List<VehicleMaster> list = new ArrayList<VehicleMaster>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT V.*, U.ORG_NAME, U.UNIT_CODE " +
                "FROM VEHICLE_MASTER V JOIN UNIT_MASTER U ON V.UNIT_ID=U.UNIT_ID " +
                (unitId > 0 ? "WHERE V.UNIT_ID=? " : "") +
                "ORDER BY U.ORG_NAME, V.VEHICLE_NO";
            ps = conn.prepareStatement(sql);
            if (unitId > 0) ps.setInt(1, unitId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        } finally { close(rs,ps,conn); }
    }

    public VehicleMaster getByVehicleNo(String vehicleNo) throws SQLException {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT V.*, U.ORG_NAME, U.UNIT_CODE " +
                "FROM VEHICLE_MASTER V JOIN UNIT_MASTER U ON V.UNIT_ID=U.UNIT_ID " +
                "WHERE V.VEHICLE_NO=? AND V.STATUS='Active'"
            );
            ps.setString(1, vehicleNo.toUpperCase().trim());
            rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        } finally { close(rs,ps,conn); }
    }

    public VehicleMaster getById(int id) throws SQLException {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT V.*, U.ORG_NAME, U.UNIT_CODE " +
                "FROM VEHICLE_MASTER V JOIN UNIT_MASTER U ON V.UNIT_ID=U.UNIT_ID " +
                "WHERE V.VEHICLE_ID=?"
            );
            ps.setInt(1, id);
            rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        } finally { close(rs,ps,conn); }
    }

    /** Search by partial vehicle number — for searchable dropdown */
    public List<VehicleMaster> search(String query) throws SQLException {
        List<VehicleMaster> list = new ArrayList<VehicleMaster>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT V.*, U.ORG_NAME, U.UNIT_CODE " +
                "FROM VEHICLE_MASTER V JOIN UNIT_MASTER U ON V.UNIT_ID=U.UNIT_ID " +
                "WHERE (UPPER(V.VEHICLE_NO) LIKE ? OR UPPER(U.ORG_NAME) LIKE ?) " +
                "AND V.STATUS='Active' AND ROWNUM <= 20 ORDER BY V.VEHICLE_NO"
            );
            String q = "%" + query.toUpperCase().trim() + "%";
            ps.setString(1, q); ps.setString(2, q);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        } finally { close(rs,ps,conn); }
    }

    public boolean save(VehicleMaster v) throws SQLException {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (v.getVehicleId() > 0) {
                ps = conn.prepareStatement(
                    "UPDATE VEHICLE_MASTER SET UNIT_ID=?,VEHICLE_NO=?,VEHICLE_TYPE=?," +
                    "MAKE=?,MODEL=?,YEAR_MFG=?,FUEL_TYPE=?,ENGINE_CC=?," +
                    "CHASSIS_NO=?,STATUS=?,NOTES=? WHERE VEHICLE_ID=?"
                );
                setParams(ps, v); ps.setInt(12, v.getVehicleId());
            } else {
                ps = conn.prepareStatement(
                    "INSERT INTO VEHICLE_MASTER (UNIT_ID,VEHICLE_NO,VEHICLE_TYPE," +
                    "MAKE,MODEL,YEAR_MFG,FUEL_TYPE,ENGINE_CC,CHASSIS_NO,STATUS,NOTES) " +
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?)"
                );
                setParams(ps, v);
            }
            return ps.executeUpdate() > 0;
        } finally { close(null,ps,conn); }
    }

    private void setParams(PreparedStatement ps, VehicleMaster v) throws SQLException {
        ps.setInt(1, v.getUnitId());
        ps.setString(2, v.getVehicleNo() != null ? v.getVehicleNo().toUpperCase() : null);
        ps.setString(3, v.getVehicleType());
        ps.setString(4, v.getMake());
        ps.setString(5, v.getModel());
        ps.setInt(6, v.getYearMfg());
        ps.setString(7, v.getFuelType());
        ps.setInt(8, v.getEngineCc());
        ps.setString(9, v.getChassisNo());
        ps.setString(10, v.getStatus() != null ? v.getStatus() : "Active");
        ps.setString(11, v.getNotes());
    }

    public boolean delete(int id) throws SQLException {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement("UPDATE VEHICLE_MASTER SET STATUS='Scrapped' WHERE VEHICLE_ID=?");
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } finally { close(null,ps,conn); }
    }

    private VehicleMaster mapRow(ResultSet rs) throws SQLException {
        VehicleMaster v = new VehicleMaster();
        v.setVehicleId(rs.getInt("VEHICLE_ID"));
        v.setUnitId(rs.getInt("UNIT_ID"));
        v.setVehicleNo(rs.getString("VEHICLE_NO"));
        v.setVehicleType(rs.getString("VEHICLE_TYPE"));
        v.setMake(rs.getString("MAKE"));
        v.setModel(rs.getString("MODEL"));
        v.setYearMfg(rs.getInt("YEAR_MFG"));
        v.setFuelType(rs.getString("FUEL_TYPE"));
        v.setEngineCc(rs.getInt("ENGINE_CC"));
        v.setChassisNo(rs.getString("CHASSIS_NO"));
        v.setStatus(rs.getString("STATUS"));
        v.setNotes(rs.getString("NOTES"));
        try { v.setOrgName(rs.getString("ORG_NAME")); } catch (Exception e) {}
        try { v.setUnitCode(rs.getString("UNIT_CODE")); } catch (Exception e) {}
        return v;
    }

    private void close(ResultSet rs, PreparedStatement ps, Connection conn) {
        if (rs   != null) try { rs.close();   } catch (Exception e) {}
        if (ps   != null) try { ps.close();   } catch (Exception e) {}
        DBConnection.close(conn);
    }
}
