package com.barc.ims.model;

import java.util.Date;

/**
 * FuelEntry v3 — Maps to FUEL_ENTRY table.
 * Added: rcavNo, entryTime, vehicleType, driverBadge, driverContact getters/setters.
 */
public class FuelEntry {
    private int    entryId;
    private String reqNo;
    private String entryCategory;
    private String vehicleNo;
    private String vehicleType;
    private String fuelType;
    private int    tankId;
    private double qtyIssued;
    private double ratePerLitre;
    private double amount;
    private String driverName;
    private String driverBadge;
    private String driverContact;
    private String department;
    private String orgName;
    private int    unitId;
    private String purpose;
    private String supplyType;
    private long   prevOdometer;
    private long   currOdometer;
    private double distanceKm;
    private double avgMileage;
    private String rcavNo;
    private String authOfficer;
    private String issuedBy;
    private Date   entryDate;
    private String entryTime;
    private String remarks;
    private int    createdBy;

    public int    getEntryId()           { return entryId; }
    public void   setEntryId(int v)      { entryId = v; }
    public String getReqNo()             { return reqNo; }
    public void   setReqNo(String v)     { reqNo = v; }
    public String getEntryCategory()     { return entryCategory; }
    public void   setEntryCategory(String v) { entryCategory = v; }
    public String getVehicleNo()         { return vehicleNo; }
    public void   setVehicleNo(String v) { vehicleNo = v; }
    public String getVehicleType()       { return vehicleType; }
    public void   setVehicleType(String v){ vehicleType = v; }
    public String getFuelType()          { return fuelType; }
    public void   setFuelType(String v)  { fuelType = v; }
    public int    getTankId()            { return tankId; }
    public void   setTankId(int v)       { tankId = v; }
    public double getQtyIssued()         { return qtyIssued; }
    public void   setQtyIssued(double v) { qtyIssued = v; }
    public double getRatePerLitre()      { return ratePerLitre; }
    public void   setRatePerLitre(double v){ ratePerLitre = v; }
    public double getAmount()            { return amount; }
    public void   setAmount(double v)    { amount = v; }
    public String getDriverName()        { return driverName; }
    public void   setDriverName(String v){ driverName = v; }
    public String getDriverBadge()       { return driverBadge; }
    public void   setDriverBadge(String v){ driverBadge = v; }
    public String getDriverContact()     { return driverContact; }
    public void   setDriverContact(String v){ driverContact = v; }
    public String getDepartment()        { return department; }
    public void   setDepartment(String v){ department = v; }
    public String getOrgName()           { return orgName; }
    public void   setOrgName(String v)   { orgName = v; }
    public int    getUnitId()            { return unitId; }
    public void   setUnitId(int v)       { unitId = v; }
    public String getPurpose()           { return purpose; }
    public void   setPurpose(String v)   { purpose = v; }
    public String getSupplyType()        { return supplyType; }
    public void   setSupplyType(String v){ supplyType = v; }
    public long   getPrevOdometer()      { return prevOdometer; }
    public void   setPrevOdometer(long v){ prevOdometer = v; }
    public long   getCurrOdometer()      { return currOdometer; }
    public void   setCurrOdometer(long v){ currOdometer = v; }
    public double getDistanceKm()        { return distanceKm; }
    public void   setDistanceKm(double v){ distanceKm = v; }
    public double getAvgMileage()        { return avgMileage; }
    public void   setAvgMileage(double v){ avgMileage = v; }
    public String getRcavNo()            { return rcavNo; }
    public void   setRcavNo(String v)    { rcavNo = v; }
    public String getAuthOfficer()       { return authOfficer; }
    public void   setAuthOfficer(String v){ authOfficer = v; }
    public String getIssuedBy()          { return issuedBy; }
    public void   setIssuedBy(String v)  { issuedBy = v; }
    public Date   getEntryDate()         { return entryDate; }
    public void   setEntryDate(Date v)   { entryDate = v; }
    public String getEntryTime()         { return entryTime; }
    public void   setEntryTime(String v) { entryTime = v; }
    public String getRemarks()           { return remarks; }
    public void   setRemarks(String v)   { remarks = v; }
    public int    getCreatedBy()         { return createdBy; }
    public void   setCreatedBy(int v)    { createdBy = v; }
}
