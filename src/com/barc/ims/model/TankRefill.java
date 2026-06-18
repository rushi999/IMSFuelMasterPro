package com.barc.ims.model;

import java.util.Date;

/**
 * TankRefill - Maps to TANK_REFILL_LOG table
 */
public class TankRefill {
    private int    refillId;
    private int    tankId;
    private String tankName;   // joined
    private String fuelType;   // joined
    private double refillQty;
    private double levelBefore;
    private double levelAfter;
    private String supplier;
    private String challanNo;
    private Date   refillDate;
    private int    enteredBy;
    private String enteredByName; // joined
    private String remarks;

    public int    getRefillId()           { return refillId; }
    public void   setRefillId(int v)      { refillId = v; }
    public int    getTankId()             { return tankId; }
    public void   setTankId(int v)        { tankId = v; }
    public String getTankName()           { return tankName; }
    public void   setTankName(String v)   { tankName = v; }
    public String getFuelType()           { return fuelType; }
    public void   setFuelType(String v)   { fuelType = v; }
    public double getRefillQty()          { return refillQty; }
    public void   setRefillQty(double v)  { refillQty = v; }
    public double getLevelBefore()        { return levelBefore; }
    public void   setLevelBefore(double v){ levelBefore = v; }
    public double getLevelAfter()         { return levelAfter; }
    public void   setLevelAfter(double v) { levelAfter = v; }
    public String getSupplier()           { return supplier; }
    public void   setSupplier(String v)   { supplier = v; }
    public String getChallanNo()          { return challanNo; }
    public void   setChallanNo(String v)  { challanNo = v; }
    public Date   getRefillDate()         { return refillDate; }
    public void   setRefillDate(Date v)   { refillDate = v; }
    public int    getEnteredBy()          { return enteredBy; }
    public void   setEnteredBy(int v)     { enteredBy = v; }
    public String getEnteredByName()      { return enteredByName; }
    public void   setEnteredByName(String v){ enteredByName = v; }
    public String getRemarks()            { return remarks; }
    public void   setRemarks(String v)    { remarks = v; }
}
