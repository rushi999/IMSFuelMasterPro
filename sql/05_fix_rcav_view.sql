-- ══════════════════════════════════════════════════════════════════
-- Patch: 05_fix_rcav_view.sql
-- Fixes V_RCAV_MONTHLY view so that:
--   1. UNIT entries show correct ORG_NAME / DEPARTMENT from UNIT_MASTER
--   2. VEHICLE_TYPE is fetched from VEHICLE_MASTER / BARC_VEHICLE_MASTER
--      not just from FUEL_ENTRY (which may be blank for old records)
--   3. GROUP BY no longer includes DEPARTMENT expression — avoids the
--      "category=UNIT but department=BARC" split-row bug
-- Run once on the DB: sqlplus user/pass@sid @05_fix_rcav_view.sql
-- ══════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW V_RCAV_MONTHLY AS
SELECT
  E.VEHICLE_NO,

  /* DEPARTMENT: BARC→use BARC_VEHICLE_MASTER.DEPARTMENT, UNIT→use UNIT_MASTER.ORG_NAME */
  CASE
    WHEN MAX(E.ENTRY_CATEGORY) IN ('BARC', 'LOOSE')
    THEN NVL(MAX(B.DEPARTMENT), NVL(MAX(E.DEPARTMENT), 'BARC'))
    ELSE NVL(MAX(UM.ORG_NAME),  NVL(MAX(E.ORG_NAME), MAX(E.DEPARTMENT)))
  END                           AS DEPARTMENT,

  MAX(E.DRIVER_NAME)            AS DRIVER_NAME,

  /* VEHICLE_TYPE: prefer master table → entry field */
  NVL(MAX(VM.VEHICLE_TYPE), NVL(MAX(B.VEHICLE_TYPE), MAX(E.VEHICLE_TYPE)))
                                AS VEHICLE_TYPE,

  /* ORG_NAME: for display — UNIT→UNIT_MASTER.ORG_NAME, BARC→dept */
  CASE
    WHEN MAX(E.ENTRY_CATEGORY) IN ('BARC', 'LOOSE')
    THEN NVL(MAX(B.DEPARTMENT), NVL(MAX(E.DEPARTMENT), 'BARC Transport'))
    ELSE NVL(MAX(UM.ORG_NAME),  NVL(MAX(E.ORG_NAME), 'DAE Unit'))
  END                           AS ORG_NAME,

  MIN(E.PREV_ODOMETER)          AS OPEN_KM,
  MAX(E.CURR_ODOMETER)          AS CLOSE_KM,
  MAX(E.CURR_ODOMETER) - MIN(E.PREV_ODOMETER) AS TOTAL_KM,

  SUM(CASE WHEN E.FUEL_TYPE='DIESEL' THEN E.QTY_ISSUED ELSE 0 END) AS DIESEL_LITRES,
  SUM(CASE WHEN E.FUEL_TYPE='PETROL' THEN E.QTY_ISSUED ELSE 0 END) AS PETROL_LITRES,
  SUM(E.QTY_ISSUED)             AS TOTAL_FUEL,

  ROUND(
    (MAX(E.CURR_ODOMETER) - MIN(E.PREV_ODOMETER)) /
    NULLIF(SUM(E.QTY_ISSUED), 0),
  2)                            AS AVG_MILEAGE,

  TRUNC(E.ENTRY_DATE, 'MM')     AS REPORT_MONTH,
  MAX(E.ENTRY_CATEGORY)         AS ENTRY_CATEGORY

FROM FUEL_ENTRY E
  /* BARC master for dept + vehicle type */
  LEFT JOIN BARC_VEHICLE_MASTER  B  ON UPPER(E.VEHICLE_NO) = UPPER(B.VEHICLE_NO)
  /* Other unit vehicle master for vehicle type */
  LEFT JOIN VEHICLE_MASTER       VM ON UPPER(E.VEHICLE_NO) = UPPER(VM.VEHICLE_NO)
                                    AND VM.STATUS = 'Active'
  /* Unit master for org name */
  LEFT JOIN UNIT_MASTER          UM ON VM.UNIT_ID = UM.UNIT_ID

WHERE E.VEHICLE_NO    IS NOT NULL
  AND E.PREV_ODOMETER IS NOT NULL

/* Group ONLY by vehicle + month — category resolved via MAX() above */
GROUP BY
  E.VEHICLE_NO,
  TRUNC(E.ENTRY_DATE, 'MM');

COMMIT;

PROMPT V_RCAV_MONTHLY recreated successfully.
