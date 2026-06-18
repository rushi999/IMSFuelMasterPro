package com.barc.ims.dao;

import com.barc.ims.model.UnitMaster;
import com.barc.ims.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UnitMasterDAO - CRUD for UNIT_MASTER table
 */
public class UnitMasterDAO {

    public List<UnitMaster> getAll() throws SQLException {
        List<UnitMaster> list = new ArrayList<UnitMaster>();
        Connection conn = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            st = conn.createStatement();
            rs = st.executeQuery(
                "SELECT * FROM UNIT_MASTER ORDER BY ORG_NAME"
            );
            while (rs.next()) list.add(mapRow(rs));
            return list;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (st != null) try { st.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    public UnitMaster getByVehicleNo(String vehicleNo) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT * FROM UNIT_MASTER WHERE VEHICLE_NO = ?"
            );
            ps.setString(1, vehicleNo.toUpperCase().trim());
            rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    public UnitMaster getById(int unitId) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement("SELECT * FROM UNIT_MASTER WHERE UNIT_ID = ?");
            ps.setInt(1, unitId);
            rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    public boolean save(UnitMaster u) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            String sql = u.getUnitId() > 0
                ? "UPDATE UNIT_MASTER SET ORG_NAME=?,UNIT_CODE=?,UNIT_TYPE=?,VEHICLE_NO=?," +
                  "VEHICLE_MAKE=?,VEHICLE_MODEL=?,YEAR_MFG=?,FUEL_TYPE=?,ENGINE_CC=?," +
                  "DRIVER_NAME=?,DRIVER_LICENCE=?,LICENCE_EXPIRY=?,DRIVER_CONTACT=?," +
                  "CONTACT_PERSON=?,DESIGNATION=?,PHONE_EXT=?,STATUS=?,NOTES=?,UPDATED_DT=SYSDATE " +
                  "WHERE UNIT_ID=?"
                : "INSERT INTO UNIT_MASTER (ORG_NAME,UNIT_CODE,UNIT_TYPE,VEHICLE_NO," +
                  "VEHICLE_MAKE,VEHICLE_MODEL,YEAR_MFG,FUEL_TYPE,ENGINE_CC," +
                  "DRIVER_NAME,DRIVER_LICENCE,LICENCE_EXPIRY,DRIVER_CONTACT," +
                  "CONTACT_PERSON,DESIGNATION,PHONE_EXT,STATUS,NOTES) " +
                  "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, u.getOrgName());
            ps.setString(2, u.getUnitCode());
            ps.setString(3, u.getUnitType());
            ps.setString(4, u.getVehicleNo() != null ? u.getVehicleNo().toUpperCase() : null);
            ps.setString(5, u.getVehicleMake());
            ps.setString(6, u.getVehicleModel());
            ps.setInt(7, u.getYearMfg());
            ps.setString(8, u.getFuelType());
            ps.setInt(9, u.getEngineCc());
            ps.setString(10, u.getDriverName());
            ps.setString(11, u.getDriverLicence());
            if (u.getLicenceExpiry() != null)
                ps.setDate(12, new java.sql.Date(u.getLicenceExpiry().getTime()));
            else ps.setNull(12, Types.DATE);
            ps.setString(13, u.getDriverContact());
            ps.setString(14, u.getContactPerson());
            ps.setString(15, u.getDesignation());
            ps.setString(16, u.getPhoneExt());
            ps.setString(17, u.getStatus());
            ps.setString(18, u.getNotes());
            if (u.getUnitId() > 0) ps.setInt(19, u.getUnitId());
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    public boolean delete(int unitId) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement("DELETE FROM UNIT_MASTER WHERE UNIT_ID = ?");
            ps.setInt(1, unitId);
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            DBConnection.close(conn);
        }
    }

    private UnitMaster mapRow(ResultSet rs) throws SQLException {
        UnitMaster u = new UnitMaster();
        u.setUnitId(rs.getInt("UNIT_ID"));
        u.setOrgName(rs.getString("ORG_NAME"));
        u.setUnitCode(rs.getString("UNIT_CODE"));
        u.setUnitType(rs.getString("UNIT_TYPE"));
        u.setVehicleNo(rs.getString("VEHICLE_NO"));
        u.setVehicleMake(rs.getString("VEHICLE_MAKE"));
        u.setVehicleModel(rs.getString("VEHICLE_MODEL"));
        u.setYearMfg(rs.getInt("YEAR_MFG"));
        u.setFuelType(rs.getString("FUEL_TYPE"));
        u.setEngineCc(rs.getInt("ENGINE_CC"));
        u.setDriverName(rs.getString("DRIVER_NAME"));
        u.setDriverLicence(rs.getString("DRIVER_LICENCE"));
        u.setLicenceExpiry(rs.getDate("LICENCE_EXPIRY"));
        u.setDriverContact(rs.getString("DRIVER_CONTACT"));
        u.setContactPerson(rs.getString("CONTACT_PERSON"));
        u.setDesignation(rs.getString("DESIGNATION"));
        u.setPhoneExt(rs.getString("PHONE_EXT"));
        u.setStatus(rs.getString("STATUS"));
        u.setNotes(rs.getString("NOTES"));
        return u;
    }
}
