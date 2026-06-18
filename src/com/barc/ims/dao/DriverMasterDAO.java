package com.barc.ims.dao;

import com.barc.ims.model.DriverMaster;
import com.barc.ims.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DriverMasterDAO - CRUD for DRIVER_MASTER (Other DAE Units)
 */
public class DriverMasterDAO {

    public List<DriverMaster> getAll() throws SQLException {
        return getByUnitId(-1);
    }

    public List<DriverMaster> getByUnitId(int unitId) throws SQLException {
        List<DriverMaster> list = new ArrayList<DriverMaster>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT D.*, U.ORG_NAME, U.UNIT_CODE " +
                "FROM DRIVER_MASTER D JOIN UNIT_MASTER U ON D.UNIT_ID=U.UNIT_ID " +
                (unitId > 0 ? "WHERE D.UNIT_ID=? " : "") +
                "ORDER BY U.ORG_NAME, D.DRIVER_NAME";
            ps = conn.prepareStatement(sql);
            if (unitId > 0) ps.setInt(1, unitId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        } finally { close(rs,ps,conn); }
    }

    public DriverMaster getById(int id) throws SQLException {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "SELECT D.*, U.ORG_NAME, U.UNIT_CODE " +
                "FROM DRIVER_MASTER D JOIN UNIT_MASTER U ON D.UNIT_ID=U.UNIT_ID " +
                "WHERE D.DRIVER_ID=?"
            );
            ps.setInt(1, id);
            rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        } finally { close(rs,ps,conn); }
    }

    public boolean save(DriverMaster d) throws SQLException {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (d.getDriverId() > 0) {
                ps = conn.prepareStatement(
                    "UPDATE DRIVER_MASTER SET UNIT_ID=?,DRIVER_NAME=?,EMPLOYEE_NO=?," +
                    "LICENCE_NO=?,LICENCE_TYPE=?,LICENCE_EXPIRY=?,CONTACT_NO=?," +
                    "ADDRESS=?,STATUS=?,NOTES=? WHERE DRIVER_ID=?"
                );
                setParams(ps, d); ps.setInt(11, d.getDriverId());
            } else {
                ps = conn.prepareStatement(
                    "INSERT INTO DRIVER_MASTER (UNIT_ID,DRIVER_NAME,EMPLOYEE_NO," +
                    "LICENCE_NO,LICENCE_TYPE,LICENCE_EXPIRY,CONTACT_NO,ADDRESS,STATUS,NOTES) " +
                    "VALUES (?,?,?,?,?,?,?,?,?,?)"
                );
                setParams(ps, d);
            }
            return ps.executeUpdate() > 0;
        } finally { close(null,ps,conn); }
    }

    private void setParams(PreparedStatement ps, DriverMaster d) throws SQLException {
        ps.setInt(1, d.getUnitId());
        ps.setString(2, d.getDriverName());
        ps.setString(3, d.getEmployeeNo());
        ps.setString(4, d.getLicenceNo());
        ps.setString(5, d.getLicenceType());
        if (d.getLicenceExpiry() != null)
            ps.setDate(6, new java.sql.Date(d.getLicenceExpiry().getTime()));
        else ps.setNull(6, Types.DATE);
        ps.setString(7, d.getContactNo());
        ps.setString(8, d.getAddress());
        ps.setString(9, d.getStatus() != null ? d.getStatus() : "Active");
        ps.setString(10, d.getNotes());
    }

    public boolean delete(int id) throws SQLException {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "UPDATE DRIVER_MASTER SET STATUS='Inactive' WHERE DRIVER_ID=?"
            );
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } finally { close(null,ps,conn); }
    }

    private DriverMaster mapRow(ResultSet rs) throws SQLException {
        DriverMaster d = new DriverMaster();
        d.setDriverId(rs.getInt("DRIVER_ID"));
        d.setUnitId(rs.getInt("UNIT_ID"));
        d.setDriverName(rs.getString("DRIVER_NAME"));
        d.setEmployeeNo(rs.getString("EMPLOYEE_NO"));
        d.setLicenceNo(rs.getString("LICENCE_NO"));
        d.setLicenceType(rs.getString("LICENCE_TYPE"));
        d.setLicenceExpiry(rs.getDate("LICENCE_EXPIRY"));
        d.setContactNo(rs.getString("CONTACT_NO"));
        d.setAddress(rs.getString("ADDRESS"));
        d.setStatus(rs.getString("STATUS"));
        d.setNotes(rs.getString("NOTES"));
        try { d.setOrgName(rs.getString("ORG_NAME")); } catch (Exception e) {}
        try { d.setUnitCode(rs.getString("UNIT_CODE")); } catch (Exception e) {}
        return d;
    }

    private void close(ResultSet rs, PreparedStatement ps, Connection conn) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        DBConnection.close(conn);
    }
}
