# IMS Fuel Master Pro Deployment Checklist

This project is deployable as a standard Java EE 5 WAR for Tomcat 7 and Oracle 10g.

## 1. Prepare Oracle

Run the schema and seed scripts as the application schema owner:

```sh
sqlplus ims_fuel/ims_fuel123@ORCL @sql/01_schema.sql
sqlplus ims_fuel/ims_fuel123@ORCL @sql/02_seed_data.sql
sqlplus ims_fuel/ims_fuel123@ORCL @sql/03_v2_schema_changes.sql
sqlplus ims_fuel/ims_fuel123@ORCL @sql/04_fix8_schema.sql
sqlplus ims_fuel/ims_fuel123@ORCL @sql/05_fix_rcav_view.sql
sqlplus ims_fuel/ims_fuel123@ORCL @sql/06_tms_admin_role.sql
```

## 2. Configure Tomcat environment

Set these variables in the service account, `setenv.sh`, or the service manager:

```sh
export IMS_DB_URL=jdbc:oracle:thin:@YOUR_HOST:1521:YOUR_SID
export IMS_DB_USER=ims_fuel
export IMS_DB_PASS=change_me
```

Environment variables override JVM properties and `web.xml` defaults.

## 3. Build the WAR

```sh
ant clean dist
```

Expected output:

```text
dist/IMSFuelMasterPro.war
```

## 4. Deploy the WAR

```sh
export CATALINA_HOME=/opt/tomcat7
./scripts/deploy-war.sh
```

Optionally change the context path:

```sh
IMS_APP_NAME=fuel ./scripts/deploy-war.sh
```

## 5. Smoke test after startup

- Open `/IMSFuelMasterPro/login.jsp`.
- Sign in with a seeded user.
- Confirm the dashboard loads tank cards and KPI values.
- Create a test fuel entry in a staging database.
- Generate the daily report for the test date.

## 6. Rollback

Stop Tomcat, replace the WAR in `webapps/` with the previous artifact, remove the exploded application directory, and start Tomcat again.
