# IMS FUEL MASTER PRO
## BARC Transport Section — Integrated Fuel Management System
### Setup & Deployment Guide

---

## PROJECT STRUCTURE

```
IMSFuelMasterPro/
├── src/
│   └── com/barc/ims/
│       ├── model/          # Java Beans (FuelEntry, BarcVehicle, UnitMaster, TankMaster)
│       ├── dao/            # Database Access Objects (JDBC / Oracle 10g)
│       ├── servlet/        # HttpServlets (Login, FuelEntry, VehicleFetch, UnitMaster, Report, Dashboard, Tank)
│       └── util/           # DBConnection, AuthFilter, PasswordUtil
├── web/
│   ├── login.jsp           # Login page with animated gauge loader
│   ├── pages/
│   │   ├── header.jsp      # Shared nav (include in all pages)
│   │   ├── footer.jsp      # Shared footer + JS includes
│   │   ├── dashboard.jsp   # Live KPIs, tank visuals, vehicle performance
│   │   ├── fuel_entry.jsp  # 3-tab fuel entry forms (BARC / Unit / Loose)
│   │   ├── reports.jsp     # Daily sheet + Monthly RCAV
│   │   ├── units_master.jsp# CRUD for unit master data
│   │   └── error.jsp       # Generic error page
│   ├── css/
│   │   ├── ims-main.css    # Custom application styles (dark theme)
│   │   ├── bootstrap.min.css      ← SIDE-LOAD (Bootstrap 3.3.7)
│   │   └── font-awesome.min.css   ← SIDE-LOAD (FontAwesome 4.7)
│   ├── js/
│   │   ├── ims-main.js     # Custom JS: auto-fetch, mileage, receipt, charts
│   │   ├── jquery.min.js          ← SIDE-LOAD (jQuery 1.12.4)
│   │   └── bootstrap.min.js       ← SIDE-LOAD (Bootstrap 3.3.7)
│   └── WEB-INF/
│       └── web.xml
├── sql/
│   ├── 01_schema.sql       # All tables, sequences, views, stored procedure
│   └── 02_seed_data.sql    # Initial data (tanks, BARC vehicles, unit master, users)
├── lib/                    # JAR files (place here before build)
│   ├── ojdbc14.jar         ← Oracle 10g JDBC driver
│   ├── jstl.jar            ← JSTL 1.2
│   └── standard.jar        ← JSTL Standard
├── build.xml               # Apache Ant build (NetBeans compatible)
└── nbproject/              # NetBeans project files
```

---

## PREREQUISITES

| Component    | Version         |
|--------------|-----------------|
| JDK          | 1.7             |
| NetBeans IDE | 7.x or 8.x      |
| Tomcat       | 7.x             |
| Oracle DB    | 10g (XE or EE)  |
| Bootstrap    | 3.3.7           |
| FontAwesome  | 4.7.0           |
| jQuery       | 1.12.4          |
| JSTL         | 1.2             |

---

## STEP 1 — ORACLE DATABASE SETUP

1. Create a database user:
```sql
CREATE USER ims_fuel IDENTIFIED BY ims_fuel123;
GRANT CONNECT, RESOURCE TO ims_fuel;
GRANT CREATE VIEW TO ims_fuel;
GRANT CREATE PROCEDURE TO ims_fuel;
GRANT EXECUTE ON DBMS_OUTPUT TO ims_fuel;
```

2. Connect as `ims_fuel` and run:
```
sqlplus ims_fuel/ims_fuel123@ORCL @sql/01_schema.sql
sqlplus ims_fuel/ims_fuel123@ORCL @sql/02_seed_data.sql
```

3. Configure database connectivity. The WAR reads values in this order: environment variables, JVM system properties, `web.xml` context params, then built-in defaults. For production, prefer environment variables so credentials are not baked into the WAR:
```sh
export IMS_DB_URL=jdbc:oracle:thin:@YOUR_HOST:1521:YOUR_SID
export IMS_DB_USER=ims_fuel
export IMS_DB_PASS=change_me
```
You can still edit `web/WEB-INF/web.xml` for development defaults if required.

---

## STEP 2 — SIDE-LOAD LIBRARIES

Place the following files (download once, keep offline):

**`web/css/`**
- `bootstrap.min.css`   → Bootstrap 3.3.7
- `font-awesome.min.css` → FontAwesome 4.7.0
- Also copy `fonts/` folder (FontAwesome webfonts) to `web/fonts/`

**`web/js/`**
- `jquery.min.js`       → jQuery 1.12.4
- `bootstrap.min.js`    → Bootstrap 3.3.7

**`lib/`**
- `ojdbc14.jar`         → Oracle 10g JDBC (from Oracle installation: `$ORACLE_HOME/jdbc/lib/`)
- `jstl.jar`            → JSTL 1.2
- `standard.jar`        → Apache Taglibs Standard 1.1.2

---

## STEP 3 — COMMAND-LINE BUILD

For a complete deployable WAR from a terminal:
```sh
ant clean dist
```
The generated artifact is:
```
dist/IMSFuelMasterPro.war
```

To deploy to an existing Tomcat installation after building:
```sh
export CATALINA_HOME=/path/to/tomcat
export IMS_DB_URL=jdbc:oracle:thin:@YOUR_HOST:1521:YOUR_SID
export IMS_DB_USER=ims_fuel
export IMS_DB_PASS=change_me
./scripts/deploy-war.sh
```

The app will be available at `http://<server>:<port>/IMSFuelMasterPro/` unless `IMS_APP_NAME` is set before running the deploy script.

---

## STEP 4 — NETBEANS SETUP

1. Open NetBeans → **File → Open Project** → select `IMSFuelMasterPro/`
2. Right-click project → **Properties** → **Libraries** → add Tomcat 7 server
3. Right-click project → **Properties** → **Run** → set Server = Tomcat 7
4. Right-click project → **Build** (Ant will compile and create WAR)
5. Right-click project → **Run** (deploys to Tomcat, opens browser)

---

## STEP 5 — DEFAULT LOGIN

| Username | Password   | Role     |
|----------|------------|----------|
| admin    | ******  | ADMIN    |
| operator1| ******  | OPERATOR |
| operator2| ******  | OPERATOR |

---

## FEATURES SUMMARY

### Dashboard
- Live KPI cards: total capacity, daily/weekly/monthly disbursed, active vehicles, low performers
- 3 animated SVG tank visuals (Diesel A, Diesel B, Petrol) with colour-coded status
- Unit-wise disbursement table
- Vehicle performance monitor with progress bars and scrap flagging
- AJAX auto-refresh every 30 seconds

### Fuel Entry Module (3 tabs)
- **BARC Vehicles**: Vehicle No. → auto-fetch dept/driver/badge/fuel type from `BARC_VEHICLE_MASTER`
- **Other DAE Units**: Vehicle No. → search `UNIT_MASTER`; if not found, prompts to register
- **Loose/Other Supply**: Can, Lawn, Drum, Generator, Pump Set, etc.
- All forms: auto-calculate distance, avg mileage, amount
- Receipt preview modal → browser print / PDF

### Reports
- **Daily Disbursement Sheet**: filter by date & category, totals row, print-ready
- **Monthly RCAV Report**: grouped by vehicle, km, fuel, avg mileage, performance label

### Units Master
- Add / Edit / Delete DAE unit records (vehicle + driver + org details)
- Inline search/filter
- Soft delete-safe (fuel entries are retained)

---

## ARCHITECTURE NOTES

- All pages check `session.getAttribute("userId")` and redirect to `login.jsp` if null
- `AuthFilter` protects `/pages/*` and servlets
- `AppContextListener` initialises database settings at startup
- `DBConnection` reads DB config from environment variables, JVM properties, or `web.xml` context-params
- `SP_ISSUE_FUEL` stored procedure handles atomic fuel issue + tank level update + transaction log
- `VehicleFetchServlet` is a JSON endpoint called by JS AJAX (no page reload)
- `DashboardServlet` exposes `/DashboardServlet?type=kpi` and `?type=tanks` for AJAX refresh

---

## TROUBLESHOOTING

| Problem                        | Fix                                                     |
|--------------------------------|---------------------------------------------------------|
| ORA-12541: no listener         | Start Oracle listener: `lsnrctl start`                  |
| ClassNotFoundException JDBC    | Ensure ojdbc14.jar is in `lib/` and in Tomcat classpath |
| JSTL 500 error                 | Add jstl.jar + standard.jar to `lib/`                   |
| Bootstrap not loading          | Check `web/css/bootstrap.min.css` path                  |
| Session expires quickly        | Adjust `<session-timeout>` in web.xml (default: 30 min) |
| Port conflict                  | Change Tomcat HTTP port in `conf/server.xml`            |

---

*IMS Fuel Master Pro v1.0 | BARC Transport Section | Intranet Use Only*
