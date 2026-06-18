package com.barc.ims.model;

/**
 * VehicleMaster - Maps to VEHICLE_MASTER table (Other DAE Units)
 */
public class VehicleMaster {
    private int    vehicleId;
    private int    unitId;
    private String orgName;   // joined from UNIT_MASTER
    private String unitCode;
    private String vehicleNo;
    private String vehicleType;
    private String make;
    private String model;
    private int    yearMfg;
    private String fuelType;
    private int    engineCc;
    private String chassisNo;
    private String status;
    private String notes;

    public int    getVehicleId()        { return vehicleId; }
    public void   setVehicleId(int v)   { vehicleId = v; }
    public int    getUnitId()           { return unitId; }
    public void   setUnitId(int v)      { unitId = v; }
    public String getOrgName()          { return orgName; }
    public void   setOrgName(String v)  { orgName = v; }
    public String getUnitCode()         { return unitCode; }
    public void   setUnitCode(String v) { unitCode = v; }
    public String getVehicleNo()        { return vehicleNo; }
    public void   setVehicleNo(String v){ vehicleNo = v != null ? v.toUpperCase() : null; }
    public String getVehicleType()      { return vehicleType; }
    public void   setVehicleType(String v){ vehicleType = v; }
    public String getMake()             { return make; }
    public void   setMake(String v)     { make = v; }
    public String getModel()            { return model; }
    public void   setModel(String v)    { model = v; }
    public int    getYearMfg()          { return yearMfg; }
    public void   setYearMfg(int v)     { yearMfg = v; }
    public String getFuelType()         { return fuelType; }
    public void   setFuelType(String v) { fuelType = v; }
    public int    getEngineCc()         { return engineCc; }
    public void   setEngineCc(int v)    { engineCc = v; }
    public String getChassisNo()        { return chassisNo; }
    public void   setChassisNo(String v){ chassisNo = v; }
    public String getStatus()           { return status; }
    public void   setStatus(String v)   { status = v; }
    public String getNotes()            { return notes; }
    public void   setNotes(String v)    { notes = v; }
}
