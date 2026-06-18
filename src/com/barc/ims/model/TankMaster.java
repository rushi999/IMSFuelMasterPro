package com.barc.ims.model;

import java.util.Date;

/**
 * TankMaster - Maps to TANK_MASTER / V_TANK_STATUS view
 */
public class TankMaster {
    private int    tankId;
    private String tankCode;
    private String tankName;
    private String fuelType;
    private double capacity;
    private double currentLevel;
    private double pctFull;
    private String status;       // Normal | Low | Very Low
    private double lowThreshold;
    private double veryLowThreshold;
    private Date   lastRefillDt;
    private double lastRefillQty;

    public int    getTankId()          { return tankId; }
    public void   setTankId(int v)     { tankId = v; }
    public String getTankCode()        { return tankCode; }
    public void   setTankCode(String v){ tankCode = v; }
    public String getTankName()        { return tankName; }
    public void   setTankName(String v){ tankName = v; }
    public String getFuelType()        { return fuelType; }
    public void   setFuelType(String v){ fuelType = v; }
    public double getCapacity()        { return capacity; }
    public void   setCapacity(double v){ capacity = v; }
    public double getCurrentLevel()    { return currentLevel; }
    public void   setCurrentLevel(double v){ currentLevel = v; }
    public double getPctFull()         { return pctFull; }
    public void   setPctFull(double v) { pctFull = v; }
    public String getStatus()          { return status; }
    public void   setStatus(String v)  { status = v; }
    public double getLowThreshold()    { return lowThreshold; }
    public void   setLowThreshold(double v){ lowThreshold = v; }
    public double getVeryLowThreshold(){ return veryLowThreshold; }
    public void   setVeryLowThreshold(double v){ veryLowThreshold = v; }
    public Date   getLastRefillDt()    { return lastRefillDt; }
    public void   setLastRefillDt(Date v){ lastRefillDt = v; }
    public double getLastRefillQty()   { return lastRefillQty; }
    public void   setLastRefillQty(double v){ lastRefillQty = v; }
}
