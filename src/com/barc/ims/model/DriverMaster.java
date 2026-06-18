package com.barc.ims.model;

import java.util.Date;

/**
 * DriverMaster - Maps to DRIVER_MASTER table (Other DAE Units)
 */
public class DriverMaster {
    private int    driverId;
    private int    unitId;
    private String orgName;     // joined from UNIT_MASTER
    private String unitCode;
    private String driverName;
    private String employeeNo;
    private String licenceNo;
    private String licenceType;
    private Date   licenceExpiry;
    private String contactNo;
    private String address;
    private String status;
    private String notes;

    public int    getDriverId()          { return driverId; }
    public void   setDriverId(int v)     { driverId = v; }
    public int    getUnitId()            { return unitId; }
    public void   setUnitId(int v)       { unitId = v; }
    public String getOrgName()           { return orgName; }
    public void   setOrgName(String v)   { orgName = v; }
    public String getUnitCode()          { return unitCode; }
    public void   setUnitCode(String v)  { unitCode = v; }
    public String getDriverName()        { return driverName; }
    public void   setDriverName(String v){ driverName = v; }
    public String getEmployeeNo()        { return employeeNo; }
    public void   setEmployeeNo(String v){ employeeNo = v; }
    public String getLicenceNo()         { return licenceNo; }
    public void   setLicenceNo(String v) { licenceNo = v; }
    public String getLicenceType()       { return licenceType; }
    public void   setLicenceType(String v){ licenceType = v; }
    public Date   getLicenceExpiry()     { return licenceExpiry; }
    public void   setLicenceExpiry(Date v){ licenceExpiry = v; }
    public String getContactNo()         { return contactNo; }
    public void   setContactNo(String v) { contactNo = v; }
    public String getAddress()           { return address; }
    public void   setAddress(String v)   { address = v; }
    public String getStatus()            { return status; }
    public void   setStatus(String v)    { status = v; }
    public String getNotes()             { return notes; }
    public void   setNotes(String v)     { notes = v; }
}
