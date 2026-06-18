package com.barc.ims.model;

import java.util.Date;

/**
 * UnitMaster - Maps to UNIT_MASTER table
 */
public class UnitMaster {
    private int    unitId;
    private String orgName;
    private String unitCode;
    private String unitType;
    private String vehicleNo;
    private String vehicleMake;
    private String vehicleModel;
    private int    yearMfg;
    private String fuelType;
    private int    engineCc;
    private String driverName;
    private String driverLicence;
    private Date   licenceExpiry;
    private String driverContact;
    private String contactPerson;
    private String designation;
    private String phoneExt;
    private String status;
    private String notes;

    public int    getUnitId()        { return unitId; }
    public void   setUnitId(int v)   { unitId = v; }
    public String getOrgName()       { return orgName; }
    public void   setOrgName(String v){ orgName = v; }
    public String getUnitCode()      { return unitCode; }
    public void   setUnitCode(String v){ unitCode = v; }
    public String getUnitType()      { return unitType; }
    public void   setUnitType(String v){ unitType = v; }
    public String getVehicleNo()     { return vehicleNo; }
    public void   setVehicleNo(String v){ vehicleNo = v; }
    public String getVehicleMake()   { return vehicleMake; }
    public void   setVehicleMake(String v){ vehicleMake = v; }
    public String getVehicleModel()  { return vehicleModel; }
    public void   setVehicleModel(String v){ vehicleModel = v; }
    public int    getYearMfg()       { return yearMfg; }
    public void   setYearMfg(int v)  { yearMfg = v; }
    public String getFuelType()      { return fuelType; }
    public void   setFuelType(String v){ fuelType = v; }
    public int    getEngineCc()      { return engineCc; }
    public void   setEngineCc(int v) { engineCc = v; }
    public String getDriverName()    { return driverName; }
    public void   setDriverName(String v){ driverName = v; }
    public String getDriverLicence() { return driverLicence; }
    public void   setDriverLicence(String v){ driverLicence = v; }
    public Date   getLicenceExpiry() { return licenceExpiry; }
    public void   setLicenceExpiry(Date v){ licenceExpiry = v; }
    public String getDriverContact() { return driverContact; }
    public void   setDriverContact(String v){ driverContact = v; }
    public String getContactPerson() { return contactPerson; }
    public void   setContactPerson(String v){ contactPerson = v; }
    public String getDesignation()   { return designation; }
    public void   setDesignation(String v){ designation = v; }
    public String getPhoneExt()      { return phoneExt; }
    public void   setPhoneExt(String v){ phoneExt = v; }
    public String getStatus()        { return status; }
    public void   setStatus(String v){ status = v; }
    public String getNotes()         { return notes; }
    public void   setNotes(String v) { notes = v; }
}
