package com.barc.ims.model;

/**
 * BarcVehicle - Maps to BARC_VEHICLE_MASTER table
 */
public class BarcVehicle {
    private int    vehicleId;
    private String vehicleNo;
    private String vehicleType;
    private String make;
    private String model;
    private int    yearMfg;
    private String fuelType;
    private String department;
    private String driverName;
    private String driverBadge;
    private String driverContact;
    private String isActive;

    public int    getVehicleId()     { return vehicleId; }
    public void   setVehicleId(int v){ vehicleId = v; }
    public String getVehicleNo()     { return vehicleNo; }
    public void   setVehicleNo(String v){ vehicleNo = v; }
    public String getVehicleType()   { return vehicleType; }
    public void   setVehicleType(String v){ vehicleType = v; }
    public String getMake()          { return make; }
    public void   setMake(String v)  { make = v; }
    public String getModel()         { return model; }
    public void   setModel(String v) { model = v; }
    public int    getYearMfg()       { return yearMfg; }
    public void   setYearMfg(int v)  { yearMfg = v; }
    public String getFuelType()      { return fuelType; }
    public void   setFuelType(String v){ fuelType = v; }
    public String getDepartment()    { return department; }
    public void   setDepartment(String v){ department = v; }
    public String getDriverName()    { return driverName; }
    public void   setDriverName(String v){ driverName = v; }
    public String getDriverBadge()   { return driverBadge; }
    public void   setDriverBadge(String v){ driverBadge = v; }
    public String getDriverContact() { return driverContact; }
    public void   setDriverContact(String v){ driverContact = v; }
    public String getIsActive()      { return isActive; }
    public void   setIsActive(String v){ isActive = v; }
}
