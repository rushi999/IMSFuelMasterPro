-- ============================================================
-- IMS FUEL MASTER PRO — Fix 8: DB Schema & Stored Procedure
-- Run this script to fix missing fields in FUEL_ENTRY inserts
-- Oracle 10g | BARC Transport Section
-- ============================================================

-- Step 1: Add missing columns (safe — won't fail if already exist)
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FUEL_ENTRY ADD ENTRY_TIME VARCHAR2(10)';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FUEL_ENTRY ADD VEHICLE_TYPE VARCHAR2(30)';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FUEL_ENTRY ADD DRIVER_CONTACT VARCHAR2(15)';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FUEL_ENTRY ADD DRIVER_BADGE VARCHAR2(30)';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FUEL_ENTRY ADD RCAV_NO VARCHAR2(50)';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FUEL_ENTRY ADD REMARKS VARCHAR2(500)';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
END;
/

-- Step 2: Drop and recreate SP_ISSUE_FUEL with ALL fields
-- Now accepts 20 IN params + 2 OUT params
CREATE OR REPLACE PROCEDURE SP_ISSUE_FUEL(
  p_entry_category  IN VARCHAR2,
  p_vehicle_no      IN VARCHAR2,
  p_fuel_type       IN VARCHAR2,
  p_qty_issued      IN NUMBER,
  p_driver_name     IN VARCHAR2,
  p_driver_badge    IN VARCHAR2,
  p_driver_contact  IN VARCHAR2,
  p_department      IN VARCHAR2,
  p_org_name        IN VARCHAR2,
  p_vehicle_type    IN VARCHAR2,
  p_prev_odometer   IN NUMBER,
  p_curr_odometer   IN NUMBER,
  p_tank_id         IN NUMBER,
  p_rcav_no         IN VARCHAR2,
  p_auth_officer    IN VARCHAR2,
  p_issued_by       IN VARCHAR2,
  p_entry_date      IN DATE,
  p_entry_time      IN VARCHAR2,
  p_remarks         IN VARCHAR2,
  p_created_by      IN NUMBER,
  p_entry_id       OUT NUMBER,
  p_status         OUT VARCHAR2
) AS
  v_tank_id      NUMBER;
  v_level_before NUMBER;
  v_level_after  NUMBER;
  v_distance     NUMBER;
  v_mileage      NUMBER;
BEGIN
  /* ── Resolve tank: use provided tank_id if valid, else auto-pick ── */
  BEGIN
    SELECT TANK_ID, CURRENT_LEVEL INTO v_tank_id, v_level_before
    FROM TANK_MASTER
    WHERE TANK_ID = NVL(p_tank_id, -1) AND IS_ACTIVE = 'Y';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    /* Auto-pick tank by fuel type */
    BEGIN
      SELECT TANK_ID, CURRENT_LEVEL INTO v_tank_id, v_level_before
      FROM TANK_MASTER
      WHERE FUEL_TYPE = UPPER(p_fuel_type)
        AND IS_ACTIVE = 'Y'
        AND CURRENT_LEVEL >= p_qty_issued
        AND ROWNUM = 1
      ORDER BY CURRENT_LEVEL DESC;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      p_status := 'ERROR: No active ' || p_fuel_type || ' tank with sufficient fuel found.';
      RETURN;
    END;
  END;

  /* ── Check sufficient stock ── */
  IF v_level_before < p_qty_issued THEN
    p_status := 'ERROR: Insufficient fuel. Tank has ' ||
                v_level_before || ' L, requested ' || p_qty_issued || ' L.';
    RETURN;
  END IF;

  /* ── Calculate mileage ── */
  v_distance := NVL(p_curr_odometer, 0) - NVL(p_prev_odometer, 0);
  IF v_distance > 0 AND p_qty_issued > 0 THEN
    v_mileage := ROUND(v_distance / p_qty_issued, 2);
  END IF;

  /* ── Get next entry ID ── */
  SELECT SEQ_FUEL_ENTRY.NEXTVAL INTO p_entry_id FROM DUAL;

  /* ── Insert full record ── */
  INSERT INTO FUEL_ENTRY (
    ENTRY_ID, ENTRY_CATEGORY, VEHICLE_NO, VEHICLE_TYPE, FUEL_TYPE, TANK_ID,
    QTY_ISSUED, RATE_PER_LITRE, AMOUNT,
    DRIVER_NAME, DRIVER_BADGE, DRIVER_CONTACT,
    DEPARTMENT, ORG_NAME,
    PREV_ODOMETER, CURR_ODOMETER, DISTANCE_KM, AVG_MILEAGE,
    RCAV_NO, AUTH_OFFICER, ISSUED_BY,
    ENTRY_DATE, ENTRY_TIME, REMARKS, CREATED_BY
  ) VALUES (
    p_entry_id,
    NVL(p_entry_category, 'BARC'),
    UPPER(p_vehicle_no),
    p_vehicle_type,
    UPPER(p_fuel_type),
    v_tank_id,
    p_qty_issued,
    CASE UPPER(p_fuel_type) WHEN 'PETROL' THEN 105.40 ELSE 93.80 END,
    ROUND(p_qty_issued * CASE UPPER(p_fuel_type) WHEN 'PETROL' THEN 105.40 ELSE 93.80 END, 2),
    p_driver_name,
    p_driver_badge,
    p_driver_contact,
    p_department,
    p_org_name,
    NULLIF(p_prev_odometer, 0),
    NULLIF(p_curr_odometer, 0),
    NULLIF(v_distance, 0),
    v_mileage,
    p_rcav_no,
    p_auth_officer,
    p_issued_by,
    NVL(p_entry_date, SYSDATE),
    p_entry_time,
    p_remarks,
    p_created_by
  );

  /* ── Deduct from tank ── */
  v_level_after := v_level_before - p_qty_issued;
  UPDATE TANK_MASTER
  SET CURRENT_LEVEL    = v_level_after,
      LAST_REFILL_DT   = LAST_REFILL_DT  /* unchanged */
  WHERE TANK_ID = v_tank_id;

  /* ── Log transaction ── */
  INSERT INTO TANK_TRANSACTION (
    TXN_ID, TANK_ID, TXN_TYPE, QUANTITY, LEVEL_BEFORE, LEVEL_AFTER, ENTRY_ID
  ) VALUES (
    SEQ_TANK_TXN.NEXTVAL, v_tank_id, 'ISSUE', p_qty_issued,
    v_level_before, v_level_after, p_entry_id
  );

  COMMIT;
  p_status := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_status := 'ERROR: ' || SQLERRM;
END SP_ISSUE_FUEL;
/

-- Step 3: Update V_DAILY_REPORT view to include all new columns + date range support
CREATE OR REPLACE VIEW V_DAILY_REPORT AS
SELECT
  E.ENTRY_ID,
  E.VEHICLE_NO,
  NVL(E.ENTRY_CATEGORY, 'BARC')  AS ENTRY_CATEGORY,
  E.FUEL_TYPE,
  E.TANK_ID,
  E.QTY_ISSUED,
  E.PREV_ODOMETER,
  E.CURR_ODOMETER,
  E.DISTANCE_KM,
  E.AVG_MILEAGE,
  E.DRIVER_NAME,
  E.DRIVER_BADGE,
  E.DRIVER_CONTACT,
  E.DEPARTMENT,
  E.ORG_NAME,
  E.VEHICLE_TYPE,
  E.RCAV_NO,
  E.AUTH_OFFICER,
  E.ISSUED_BY,
  E.ENTRY_DATE,
  E.ENTRY_TIME,
  E.REMARKS,
  E.CREATED_BY,
  -- Computed REQ_NO
  'REQ-' || TO_CHAR(E.ENTRY_DATE,'YYYY') || '-' || LPAD(E.ENTRY_ID,4,'0') AS REQ_NO,
  -- Unit name (prefer ORG_NAME for non-BARC, dept for BARC)
  NVL(NVL(E.ORG_NAME, E.DEPARTMENT), 'BARC') AS UNIT_NAME
FROM FUEL_ENTRY E
ORDER BY E.ENTRY_DATE DESC, E.ENTRY_ID DESC;

-- Step 4: Update RCAV view to include unit/org name + fuel split
CREATE OR REPLACE VIEW V_RCAV_MONTHLY AS
SELECT
  E.VEHICLE_NO,
  NVL(NVL(E.DEPARTMENT, E.ORG_NAME), 'BARC')  AS DEPARTMENT,
  MAX(E.DRIVER_NAME)          AS DRIVER_NAME,
  MAX(E.VEHICLE_TYPE)         AS VEHICLE_TYPE,
  MAX(E.ORG_NAME)             AS ORG_NAME,
  MIN(E.PREV_ODOMETER)        AS OPEN_KM,
  MAX(E.CURR_ODOMETER)        AS CLOSE_KM,
  MAX(E.CURR_ODOMETER) - MIN(E.PREV_ODOMETER) AS TOTAL_KM,
  SUM(CASE WHEN E.FUEL_TYPE='DIESEL' THEN E.QTY_ISSUED ELSE 0 END) AS DIESEL_LITRES,
  SUM(CASE WHEN E.FUEL_TYPE='PETROL' THEN E.QTY_ISSUED ELSE 0 END) AS PETROL_LITRES,
  SUM(E.QTY_ISSUED)           AS TOTAL_FUEL,
  ROUND(
    (MAX(E.CURR_ODOMETER) - MIN(E.PREV_ODOMETER)) /
    NULLIF(SUM(E.QTY_ISSUED), 0),
  2)                          AS AVG_MILEAGE,
  TRUNC(E.ENTRY_DATE, 'MM')   AS REPORT_MONTH,
  MAX(E.ENTRY_CATEGORY)       AS ENTRY_CATEGORY
FROM FUEL_ENTRY E
WHERE E.VEHICLE_NO IS NOT NULL
  AND E.PREV_ODOMETER IS NOT NULL
GROUP BY
  E.VEHICLE_NO,
  NVL(NVL(E.DEPARTMENT, E.ORG_NAME), 'BARC'),
  TRUNC(E.ENTRY_DATE, 'MM');

COMMIT;
