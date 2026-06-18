-- ============================================================
-- IMS Fuel Master Pro — v3 Schema: TMS Admin Role
-- Run this after 05_fix_rcav_view.sql
-- ============================================================

-- Add TMS_ADMIN user (password: barc@1234)
INSERT INTO USERS (USER_ID, USERNAME, PASSWORD_HASH, FULL_NAME, DESIGNATION, ROLE)
VALUES (SEQ_USER.NEXTVAL, 'tmsadmin', '482c811da5d5b4bc6d497ffa98491e38', 'TMS Administrator', 'Transport Management Admin', 'ADMIN');

COMMIT;

-- Note: Role 'ADMIN' maps to TMS Admin profile (full KPI access)
--       Role 'OPERATOR' maps to Transport Officer profile (limited KPIs)
-- The existing 'admin' user already has ROLE='ADMIN' and gets full access.
