<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core"     prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"      prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%
  if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
  }
  /* Load fresh data if not already forwarded from DashboardServlet */
  if (request.getAttribute("tanks") == null) {
    try {
      com.barc.ims.dao.TankDAO tankDao = new com.barc.ims.dao.TankDAO();
      com.barc.ims.dao.FuelEntryDAO entryDao = new com.barc.ims.dao.FuelEntryDAO();
      pageContext.setAttribute("tanks",      tankDao.getAllTanks());
      pageContext.setAttribute("kpiDaily",   entryDao.getTotalDisbursed("DAILY",  null));
      pageContext.setAttribute("kpiWeekly",  entryDao.getTotalDisbursed("WEEKLY", null));
      pageContext.setAttribute("kpiMonthly", entryDao.getTotalDisbursed("MONTHLY",null));
    } catch (Exception ex) {
      pageContext.setAttribute("tanks", new java.util.ArrayList());
      pageContext.setAttribute("kpiDaily",   0.0);
      pageContext.setAttribute("kpiWeekly",  0.0);
      pageContext.setAttribute("kpiMonthly", 0.0);
    }
  }
  String userRole = (String) session.getAttribute("role");
  if (userRole == null) userRole = "OPERATOR";
  boolean isTmsAdmin = "ADMIN".equals(userRole) || "TMS_ADMIN".equals(userRole);
  pageContext.setAttribute("isTmsAdmin", isTmsAdmin);
  pageContext.setAttribute("activePage", "dashboard");
  pageContext.setAttribute("pageTitle",  "Dashboard");
%>
<%@ include file="header.jsp" %>

<!-- Dashboard-specific styles -->
<style>
/* ═══ HORIZONTAL CAPSULE TANK — Inspired by fuel station display ═══ */

/* Tank card wrapper */
/* ════════════════════════════════════════════════════════
   PROFESSIONAL FUEL STATION TANK — SVG, no div seams
   ════════════════════════════════════════════════════════ */

/* ── Keyframes ── */
@keyframes waveSlow {
  0%   { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}
@keyframes waveFast {
  0%   { transform: translateX(-50%); }
  100% { transform: translateX(0); }
}
@keyframes bubbleUp {
  0%   { transform: translateY(0) scale(1); opacity: 0.6; }
  80%  { opacity: 0.3; }
  100% { transform: translateY(-88px) scale(0.2); opacity: 0; }
}
@keyframes sheenMove {
  0%   { opacity: 0.0; }
  40%  { opacity: 0.07; }
  100% { opacity: 0.0; }
}
@keyframes hTankAlert {
  0%,100% { filter: drop-shadow(0 0 0px rgba(255,71,87,0)); }
  50%      { filter: drop-shadow(0 0 14px rgba(255,71,87,0.70)); }
}

/* ── Wave animation groups — GPU-accelerated, perfectly seamless ── */
.ims-wave-front {
  animation: waveSlow 6s linear infinite;
  will-change: transform;
  backface-visibility: hidden;
}
.ims-wave-back  {
  animation: waveFast 9s linear infinite;
  will-change: transform;
  backface-visibility: hidden;
}

/* ── Bubble elements ── */
.ims-tank-bubble { animation: bubbleUp ease-in infinite; }

/* ── Moving sheen ── */
.ims-tank-sheen { animation: sheenMove 4s ease-in-out infinite; }

/* ── Wrapper ── */
.ims-htank-wrap { padding: 8px 0 4px; }

/* ── SVG container ── */
.ims-tank-svg-container {
  width: 100%;
  max-width: 340px;
  margin: 0 auto;
  display: block;
  position: relative;
}
.ims-tank-svg {
  width: 100%;
  height: auto;
  display: block;
  overflow: visible;
  filter: drop-shadow(0 6px 18px rgba(0,0,0,0.45));
}
.tank-alert .ims-tank-svg { animation: hTankAlert 2s ease-in-out infinite; }

/* ── Info strip ── */
.ims-htank-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
  padding: 0 4px;
}
.ims-htank-label {
  font-size: 14px; letter-spacing: 2px; text-transform: uppercase;
  color: var(--txt3,#4a6080); font-family: monospace; font-weight: 700;
}
.ims-htank-pct-badge {
  font-family: monospace; font-size: 30px; font-weight: 900;
  text-align: center; line-height: 1;
  text-shadow: 0 0 18px currentColor;
}
.ims-htank-litres {
  font-family: monospace; font-size: 14px; font-weight: 700;
  color: var(--txt2,#8ba4c8); text-align: right; line-height: 1.5;
}
.ims-tank-3d-label { font-size: 15px !important; letter-spacing: 2px; font-weight: 700 !important; }

/* Nozzle filling animation overlay */
#nozzleOverlay {
  position:fixed; inset:0; z-index:9000;
  background:rgba(0,0,0,0.75);
  display:flex; flex-direction:column;
  align-items:center; justify-content:center;
  backdrop-filter:blur(4px);
}
#nozzleOverlay.hidden { display:none; }
.nozzle-container { text-align:center; }
.nozzle-title {
  font-family:monospace; font-size:20px; letter-spacing:3px;
  color:#3b9eff; margin-bottom:20px;
  text-shadow:0 0 20px rgba(59,158,255,0.5);
}
.nozzle-subtitle {
  font-size:13px; color:#8ba4c8; margin-top:16px;
  letter-spacing:1px;
}
/* Bar charts */
.dash-bar { cursor:default; transition:opacity 0.2s; }
.dash-bar:hover { opacity:0.85; }

/* KPI trend arrow */
.kpi-trend-up   { color:#00d68f; font-size:12px; }
.kpi-trend-down { color:#ff4757; font-size:12px; }

/* Table improvements */
.ims-dash-table th { font-size:12px; letter-spacing:1.5px; }
.ims-perf-bar-wrap { height:6px; background:rgba(255,255,255,0.08); border-radius:3px; margin-top:3px; }
body.ims-light .ims-perf-bar-wrap { background:rgba(0,0,0,0.08); }
.ims-perf-bar { height:100%; border-radius:3px; transition:width 1s ease; }

/* Sortable column headers */
.ims-dash-table thead th[onclick] { white-space:nowrap; user-select:none; }
.ims-dash-table thead th[onclick]:hover { color:var(--accent,#3b9eff) !important; }

/* Pagination buttons */
#uwPagination .btn, #vpPagination .btn {
  background: rgba(255,255,255,0.04);
  border-color: var(--border);
  color: var(--txt2);
  font-size: 12px;
  padding: 4px 9px;
}
body.ims-light #uwPagination .btn,
body.ims-light #vpPagination .btn { background: rgba(0,0,0,0.04); }
#uwPagination .btn-primary, #vpPagination .btn-primary {
  background: var(--accent,#3b9eff) !important;
  border-color: var(--accent,#3b9eff) !important;
  color: #fff !important;
}
#uwPagination .btn.disabled, #vpPagination .btn.disabled {
  opacity:0.35; cursor:default; pointer-events:none;
}

/* Alert pulse for very low tanks */
@keyframes tankAlert {
  0%,100% { box-shadow: 0 0 0 0 rgba(255,71,87,0); }
  50%      { box-shadow: 0 0 0 8px rgba(255,71,87,0.2); }
}
.tank-alert { animation: tankAlert 2s infinite; }

/* ── Recent Entries Table — sticky header ── */
.ims-dash-table thead th {
  position: sticky !important;
  top: 0 !important;
  z-index: 5 !important;
  background: var(--card, #161f2e) !important;
  white-space: nowrap;
  font-size: 11px;
  letter-spacing: 0.5px;
  padding: 8px 10px !important;
}
body.ims-light .ims-dash-table thead th {
  background: #f5f8fc !important;
}
.ims-dash-table td {
  padding: 7px 10px !important;
  vertical-align: middle !important;
  font-size: 12px;
}
.ims-dash-table tbody tr:hover td { cursor: default; }

/* ── Horizontal tank card — proper height ── */
.ims-htank-wrap { padding: 12px 4px 6px; }
.ims-htank { min-width: 240px; }

/* Tank status badge */
.ims-tank-status-badge {
  display: inline-flex; align-items: center; gap: 4px;
  font-size: 10px; padding: 1px 8px; border-radius: 10px;
  font-weight: 600; letter-spacing: 0.5px;
}
.ims-status-normal { background: rgba(0,214,143,0.12); color: #00d68f; border: 1px solid rgba(0,214,143,0.3); }
.ims-status-low    { background: rgba(255,215,0,0.12); color: #ffd700; border: 1px solid rgba(255,215,0,0.3); }
.ims-status-verlow { background: rgba(255,71,87,0.12);  color: #ff4757; border: 1px solid rgba(255,71,87,0.3); }
.ims-dot {
  width: 6px; height: 6px; border-radius: 50%;
  background: currentColor; display: inline-block;
}
body.ims-light .ims-status-normal { background: rgba(0,120,80,0.08) !important; color: #007a58 !important; }
body.ims-light .ims-status-low    { background: rgba(180,130,0,0.08) !important; color: #8a6000 !important; }
body.ims-light .ims-status-verlow { background: rgba(180,30,40,0.08) !important; color: #cc2233 !important; }

    
    
/* ════════════════════════ COMPACT 2-COL RECEIPT ═══════════════════════ */
.ims-rcpt-grid{display:grid;grid-template-columns:1fr 1fr;gap:0;margin-bottom:12px}
.ims-rcpt-cell{padding:7px 12px 6px;border-bottom:1px solid rgba(99,179,255,0.08);border-right:1px solid rgba(99,179,255,0.06)}
.ims-rcpt-cell:nth-child(even){border-right:none}
.ims-rcpt-full{grid-column:1/-1;border-right:none}
.ims-rcpt-key{font-size:10px;text-transform:uppercase;letter-spacing:.9px;color:var(--txt3,#4a6080);margin-bottom:2px}
.ims-rcpt-val{font-family:monospace;font-size:13px;font-weight:600;color:var(--txt1,#e2eaf8);word-break:break-word}
.ims-rcpt-qty{display:flex;justify-content:space-between;align-items:center;padding:10px 12px;margin-top:6px;border-radius:6px;background:rgba(59,158,255,0.08);border:1px solid rgba(59,158,255,0.20)}
.ims-rcpt-qty-lbl{font-size:12px;text-transform:uppercase;letter-spacing:1px;color:var(--txt2,#8ba4c8)}
.ims-rcpt-qty-val{font-family:monospace;font-size:20px;font-weight:800;color:#00d68f}
body.ims-light .ims-rcpt-cell{border-bottom-color:rgba(0,0,60,0.07);border-right-color:rgba(0,0,60,0.05)}
body.ims-light .ims-rcpt-key{color:#7090b0}
body.ims-light .ims-rcpt-val{color:#1a2340}
body.ims-light .ims-rcpt-qty{background:rgba(26,110,204,0.06);border-color:rgba(26,110,204,0.18)}
body.ims-light .ims-rcpt-qty-lbl{color:#5070a0}
body.ims-light .ims-rcpt-qty-val{color:#007a58}

</style>

<div class="container-fluid ims-main-content">

  <!-- Page header -->
  <div class="ims-page-header">
    <h2><i class="fa fa-tachometer"></i> Operations Dashboard</h2>
    <span class="ims-badge-live"><span class="ims-live-dot"></span>Real-Time</span>
    <div class="refresh-badge pull-right" style="margin-top:6px;cursor:pointer" onclick="refreshDashboard()" title="Refresh now">
      <i class="fa fa-refresh" id="refreshIcon"></i>
      <span id="lastRefresh" style="font-size:10px;color:#4a6080;margin-left:4px">Auto-refreshes every 30s</span>
    </div>
    <span class="pull-right text-muted ims-date-label" id="dashDate" style="margin-top:8px;margin-right:16px"></span>
  </div>

  <!-- ═══ KPI CARDS ═══ -->
  <div class="row ims-kpi-row">

    <!-- Avail Petrol / Total Petrol -->
    <div class="col-xs-6 col-sm-4 col-md-2">
      <div class="ims-kpi-card" style="--kpi:#ff6b35">
        <div class="ims-kpi-label"><i class="fa fa-tint" style="color:#ff6b35"></i> Petrol Available</div>
        <div class="ims-kpi-val" id="kpiPetrolAvail" style="font-size:19px">
          <c:set var="petrolAvail" value="0"/>
          <c:set var="petrolCap"   value="0"/>
          <c:forEach var="t" items="${tanks}">
            <c:if test="${t.fuelType eq 'PETROL'}">
              <c:set var="petrolAvail" value="${petrolAvail + t.currentLevel}"/>
              <c:set var="petrolCap"   value="${petrolCap   + t.capacity}"/>
            </c:if>
          </c:forEach>
          <fmt:formatNumber value="${petrolAvail}" pattern="#,##0"/>
          <span style="font-size:13px;color:var(--txt3)"> / <fmt:formatNumber value="${petrolCap}" pattern="#,##0"/></span>
        </div>
        <div class="ims-kpi-sub">Litres (Petrol)</div>
      </div>
    </div>

    <!-- Avail Diesel / Total Diesel -->
    <div class="col-xs-6 col-sm-4 col-md-2">
      <div class="ims-kpi-card" style="--kpi:#3b9eff">
        <div class="ims-kpi-label"><i class="fa fa-tint" style="color:#3b9eff"></i> Diesel Available</div>
        <div class="ims-kpi-val" id="kpiDieselAvail" style="font-size:19px">
          <c:set var="dieselAvail" value="0"/>
          <c:set var="dieselCap"   value="0"/>
          <c:forEach var="t" items="${tanks}">
            <c:if test="${t.fuelType eq 'DIESEL'}">
              <c:set var="dieselAvail" value="${dieselAvail + t.currentLevel}"/>
              <c:set var="dieselCap"   value="${dieselCap   + t.capacity}"/>
            </c:if>
          </c:forEach>
          <fmt:formatNumber value="${dieselAvail}" pattern="#,##0"/>
          <span style="font-size:13px;color:var(--txt3)"> / <fmt:formatNumber value="${dieselCap}" pattern="#,##0"/></span>
        </div>
        <div class="ims-kpi-sub">Litres (Diesel)</div>
      </div>
    </div>

    <div class="col-xs-6 col-sm-4 col-md-2">
      <div class="ims-kpi-card" style="--kpi:#00d68f">
        <div class="ims-kpi-label"><i class="fa fa-calendar-check-o"></i> Today Disbursed</div>
        <div class="ims-kpi-val" id="kpiDaily">
          <fmt:formatNumber value="${kpiDaily}" pattern="#,##0.#"/>
        </div>
        <div class="ims-kpi-sub">Litres</div>
        <div class="kpi-trend-up" id="kpiDailyTrend"></div>
      </div>
    </div>
    <div class="col-xs-6 col-sm-4 col-md-2">
      <div class="ims-kpi-card" style="--kpi:#ffd700">
        <div class="ims-kpi-label"><i class="fa fa-calendar-o"></i> Weekly Disbursed</div>
        <div class="ims-kpi-val" id="kpiWeekly">
          <fmt:formatNumber value="${kpiWeekly}" pattern="#,##0.#"/>
        </div>
        <div class="ims-kpi-sub">Litres</div>
      </div>
    </div>
    <div class="col-xs-6 col-sm-4 col-md-2">
      <div class="ims-kpi-card" style="--kpi:#00e5c3">
        <div class="ims-kpi-label"><i class="fa fa-line-chart"></i> Monthly Disbursed</div>
        <div class="ims-kpi-val" id="kpiMonthly">
          <fmt:formatNumber value="${kpiMonthly}" pattern="#,##0.#"/>
        </div>
        <div class="ims-kpi-sub">Litres</div>
      </div>
    </div>

    <!-- Active Vehicles + Low Performers — TMS Admin only -->
    <c:if test="${isTmsAdmin}">
    <div class="col-xs-6 col-sm-4 col-md-2">
      <div class="ims-kpi-card" style="--kpi:#ff6b35">
        <div class="ims-kpi-label"><i class="fa fa-truck"></i> Active Vehicles</div>
        <div class="ims-kpi-val" id="kpiVehicles">
          ${not empty activeVehicles ? activeVehicles : '--'}
        </div>
        <div class="ims-kpi-sub">This Month</div>
      </div>
    </div>
    <div class="col-xs-6 col-sm-4 col-md-2">
      <div class="ims-kpi-card" style="--kpi:#ff4757">
        <div class="ims-kpi-label"><i class="fa fa-exclamation-triangle"></i> Low Performers</div>
        <div class="ims-kpi-val" id="kpiLow">
          ${not empty lowPerformers ? lowPerformers : '--'}
        </div>
        <div class="ims-kpi-sub">Below 8 km/L</div>
      </div>
    </div>
    </c:if>

  </div>

  <!-- ═══ FUEL TANKS — REALISTIC 3D STYLE ═══ -->
  <div class="ims-section-title">
    <i class="fa fa-tint"></i> Fuel Tank Status — Live Monitoring
  </div>
  <div class="row" id="tanksRow">
    <c:forEach var="t" items="${tanks}" varStatus="st">
    <%-- Compute fill color based on pct --%>
    <%
      com.barc.ims.model.TankMaster t = (com.barc.ims.model.TankMaster)
        pageContext.getAttribute("t");
    %>
    <div class="col-sm-4">
      <div class="panel panel-default ims-panel ims-tank-panel
            ${t.pctFull < 12 ? 'tank-alert' : ''}"
           style="border-color:
             <c:choose>
               <c:when test="${t.status eq 'Normal'}">rgba(0,214,143,0.3)</c:when>
               <c:when test="${t.status eq 'Low'}">rgba(255,215,0,0.4)</c:when>
               <c:otherwise>rgba(255,71,87,0.5)</c:otherwise>
             </c:choose>">
        <div class="panel-body" style="padding:16px">

          <!-- Tank header -->
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px">
            <div>
              <div style="font-size:14px;font-weight:700;letter-spacing:1px;color:var(--txt1,#e8f0fe)">
                ${t.tankName}
              </div>
              <div style="font-size:11px;color:var(--txt3,#4a6080);margin-top:2px">
                Capacity: <fmt:formatNumber value="${t.capacity}" pattern="#,##0"/> L
              </div>
            </div>
            <span class="ims-tank-status-badge
              <c:choose>
                <c:when test="${t.status eq 'Normal'}">ims-status-normal</c:when>
                <c:when test="${t.status eq 'Low'}">ims-status-low</c:when>
                <c:otherwise>ims-status-verlow</c:otherwise>
              </c:choose>">
              <span class="ims-dot"></span>${t.status}
            </span>
          </div>

          <!-- ═══ PROFESSIONAL FUEL STATION TANK SVG ═══ -->
          <%
            // ── Colours per fuel/status ──
            String fluidC1,fluidC2,fluidC3,waveC1,waveC2,shellStroke,shellGlow,rimColor,pctColor;
            if ("PETROL".equals(t.getFuelType())) {
              fluidC1="#ff9520"; fluidC2="#d95e00"; fluidC3="#a33c00";
              waveC1="rgba(255,175,70,0.72)"; waveC2="rgba(220,110,20,0.50)";
              shellStroke="#c8681a"; shellGlow="rgba(255,140,40,0.30)"; rimColor="#e07820";
            } else if ("Low".equals(t.getStatus()) || "Very Low".equals(t.getStatus())) {
              fluidC1="#ffe44d"; fluidC2="#c8a000"; fluidC3="#8a6a00";
              waveC1="rgba(255,235,70,0.72)"; waveC2="rgba(210,175,15,0.50)";
              shellStroke="#b09010"; shellGlow="rgba(255,215,30,0.30)"; rimColor="#d4aa20";
            } else {
              fluidC1="#38b6ff"; fluidC2="#1565c0"; fluidC3="#0a3580";
              waveC1="rgba(90,195,255,0.72)"; waveC2="rgba(35,140,240,0.50)";
              shellStroke="#2a78c8"; shellGlow="rgba(59,158,255,0.30)"; rimColor="#3a90e0";
            }
            pctColor = "Normal".equals(t.getStatus()) ? "#00d68f"
                     : "Low".equals(t.getStatus())    ? "#ffd700" : "#ff4757";
            double fp     = t.getPctFull();
            double fluidH = 100.0 * fp / 100.0;        // out of 100px body
            double fluidY = 100.0 - fluidH;             // top of fluid in body
            double waveY  = fluidY - 7.0;               // wave path Y anchor
            // Gauge tick major positions (% values mapped to SVG Y in 100px height)
            // Scale bar on right: Y=5 is 100%, Y=95 is 0%
            String tid = "t" + t.getTankId();
          %>
          <div class="ims-htank-wrap">
            <div class="ims-tank-svg-container">
              <%-- viewBox: 380 wide × 148 tall
                   Layout:
                     x 0-379: full width
                     y 0-15:  top fittings zone
                     y 15-115: main tank body (100px tall capsule)
                     y 115-148: bottom fittings + leg supports
                   Left cap radius: 50px (half of 100px height)
                   Right cap: same
                   Scale bar inset from right
              --%>
              <svg class="ims-tank-svg" viewBox="0 0 380 148"
                   xmlns="http://www.w3.org/2000/svg">
                <defs>
                  <!-- ── Capsule clip (tank interior) ── -->
                  <clipPath id="cap_<%=tid%>">
                    <rect x="2" y="15" width="340" height="100" rx="50" ry="50"/>
                  </clipPath>
                  <!-- ── Fluid gradient ── -->
                  <linearGradient id="fg_<%=tid%>" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%"   stop-color="<%=fluidC1%>"/>
                    <stop offset="60%"  stop-color="<%=fluidC2%>"/>
                    <stop offset="100%" stop-color="<%=fluidC3%>"/>
                  </linearGradient>
                  <!-- ── Shell dark background gradient ── -->
                  <linearGradient id="sh_<%=tid%>" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%"   stop-color="rgba(22,36,68,0.97)"/>
                    <stop offset="100%" stop-color="rgba(8,14,32,0.99)"/>
                  </linearGradient>
                  <!-- ── Top highlight sheen ── -->
                  <linearGradient id="hl_<%=tid%>" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%"   stop-color="rgba(255,255,255,0.11)"/>
                    <stop offset="55%"  stop-color="rgba(255,255,255,0.02)"/>
                    <stop offset="100%" stop-color="rgba(0,0,0,0)"/>
                  </linearGradient>
                  <!-- ── Moving sheen (diagonal) ── -->
                  <linearGradient id="ms_<%=tid%>" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%"   stop-color="rgba(255,255,255,0)"/>
                    <stop offset="50%"  stop-color="rgba(255,255,255,0.07)"/>
                    <stop offset="100%" stop-color="rgba(255,255,255,0)"/>
                  </linearGradient>
                  <!-- ── Glow filter ── -->
                  <filter id="glow_<%=tid%>" x="-10%" y="-10%" width="120%" height="120%">
                    <feGaussianBlur stdDeviation="3" result="blur"/>
                    <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
                  </filter>
                  <!-- ── Outer shell glow ── -->
                  <filter id="shellglow_<%=tid%>">
                    <feGaussianBlur stdDeviation="4" result="blur"/>
                    <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
                  </filter>
                </defs>

                <!-- ════════════════════════════════
                     SUPPORT LEGS
                     ════════════════════════════════ -->
                <rect x="88"  y="113" width="14" height="28" rx="4"
                      fill="rgba(25,40,75,0.95)" stroke="<%=shellStroke%>" stroke-width="1.2"/>
                <rect x="242" y="113" width="14" height="28" rx="4"
                      fill="rgba(25,40,75,0.95)" stroke="<%=shellStroke%>" stroke-width="1.2"/>
                <!-- Leg base plates -->
                <rect x="80"  y="138" width="30" height="5" rx="2"
                      fill="rgba(40,65,110,0.9)" stroke="<%=shellStroke%>" stroke-width="1"/>
                <rect x="234" y="138" width="30" height="5" rx="2"
                      fill="rgba(40,65,110,0.9)" stroke="<%=shellStroke%>" stroke-width="1"/>

                <!-- ════════════════════════════════
                     TANK SHELL (background fill)
                     ════════════════════════════════ -->
                <rect x="2" y="15" width="340" height="100" rx="50" ry="50"
                      fill="url(#sh_<%=tid%>)"/>

                <!-- ════════════════════════════════
                     FLUID FILL (clipped inside capsule)
                     ════════════════════════════════ -->
                <g clip-path="url(#cap_<%=tid%>)">
                  <!-- Fluid body -->
                  <rect x="2" y="<%=15 + fluidY + 7%>" width="340" height="<%=fluidH + 5%>"
                        fill="url(#fg_<%=tid%>)"/>

                  <%-- Seamless wave paths: 680px wide = exactly 2 full cycles of 340px period
                       Start Y == End Y so translateX(-50%) loops invisibly --%>
                  <!-- Wave 1 — slow, 2 full cycles, perfect tileability -->
                  <g class="ims-wave-front">
                    <path d="M-340,<%=15 + waveY + 4%>
                             C-255,<%=15 + waveY - 10%> -170,<%=15 + waveY + 18%> -85,<%=15 + waveY + 4%>
                             C   0,<%=15 + waveY - 10%>  85,<%=15 + waveY + 18%>  170,<%=15 + waveY + 4%>
                             C 255,<%=15 + waveY - 10%> 340,<%=15 + waveY + 18%>  425,<%=15 + waveY + 4%>
                             C 510,<%=15 + waveY - 10%> 595,<%=15 + waveY + 18%>  680,<%=15 + waveY + 4%>
                             L680,120 L-340,120 Z"
                          fill="<%=waveC1%>"/>
                  </g>
                  <!-- Wave 2 — slower, offset phase, same period -->
                  <g class="ims-wave-back">
                    <path d="M-340,<%=15 + waveY + 8%>
                             C-255,<%=15 + waveY + 22%> -170,<%=15 + waveY - 6%>  -85,<%=15 + waveY + 8%>
                             C   0,<%=15 + waveY + 22%>  85,<%=15 + waveY - 6%>   170,<%=15 + waveY + 8%>
                             C 255,<%=15 + waveY + 22%> 340,<%=15 + waveY - 6%>   425,<%=15 + waveY + 8%>
                             C 510,<%=15 + waveY + 22%> 595,<%=15 + waveY - 6%>   680,<%=15 + waveY + 8%>
                             L680,120 L-340,120 Z"
                          fill="<%=waveC2%>"/>
                  </g>

                  <!-- Bubbles -->
                  <circle class="ims-tank-bubble" cx="75"  cy="<%=15 + fluidY + 22%>" r="3.2"
                          fill="rgba(255,255,255,0.24)" style="animation-duration:2.3s;animation-delay:0s"/>
                  <circle class="ims-tank-bubble" cx="165" cy="<%=15 + fluidY + 32%>" r="2.2"
                          fill="rgba(255,255,255,0.18)" style="animation-duration:1.8s;animation-delay:0.7s"/>
                  <circle class="ims-tank-bubble" cx="260" cy="<%=15 + fluidY + 19%>" r="2.8"
                          fill="rgba(255,255,255,0.21)" style="animation-duration:2.9s;animation-delay:1.4s"/>
                  <circle class="ims-tank-bubble" cx="210" cy="<%=15 + fluidY + 40%>" r="1.8"
                          fill="rgba(255,255,255,0.15)" style="animation-duration:2.0s;animation-delay:1.0s"/>
                  <circle class="ims-tank-bubble" cx="120" cy="<%=15 + fluidY + 50%>" r="2.0"
                          fill="rgba(255,255,255,0.16)" style="animation-duration:2.6s;animation-delay:0.4s"/>

                  <!-- Top sheen over entire interior -->
                  <rect x="2" y="15" width="340" height="100" fill="url(#hl_<%=tid%>)"/>

                  <!-- Moving sheen sweep -->
                  <rect x="2" y="15" width="340" height="100"
                        class="ims-tank-sheen" fill="url(#ms_<%=tid%>)"/>
                </g>

                <!-- ════════════════════════════════
                     SHELL BORDER + RIM RING
                     ════════════════════════════════ -->
                <!-- Outer glow ring -->
                <rect x="2" y="15" width="340" height="100" rx="50" ry="50"
                      fill="none" stroke="<%=shellGlow%>" stroke-width="7"
                      filter="url(#shellglow_<%=tid%>)"/>
                <!-- Crisp rim -->
                <rect x="2" y="15" width="340" height="100" rx="50" ry="50"
                      fill="none" stroke="<%=rimColor%>" stroke-width="2.5"/>
                <!-- Inner darker rim (depth) -->
                <rect x="5" y="18" width="334" height="94" rx="47" ry="47"
                      fill="none" stroke="rgba(0,0,0,0.25)" stroke-width="1.5"/>

                <!-- ════════════════════════════════
                     FUEL LEVEL GAUGE SCALE (right side)
                     Positioned at x=350–372, y=20–112
                     ════════════════════════════════ -->
                <!-- Scale background track -->
                <rect x="355" y="20" width="8" height="94" rx="4"
                      fill="rgba(15,25,50,0.7)" stroke="rgba(99,179,255,0.20)" stroke-width="1"/>
                <!-- Scale fill indicator -->
                <rect x="355" y="<%=20 + (94 * (100-fp)/100)%>" width="8"
                      height="<%=94 * fp / 100%>" rx="4"
                      fill="<%=pctColor%>" opacity="0.85"/>
                <!-- Scale tick marks -->
                <line x1="350" y1="20" x2="364" y2="20" stroke="<%=rimColor%>" stroke-width="1.5"/>
                <text x="367" y="24" font-size="7" fill="<%=rimColor%>" font-family="monospace">F</text>
                <line x1="352" y1="43.5" x2="362" y2="43.5" stroke="rgba(99,179,255,0.4)" stroke-width="1"/>
                <line x1="352" y1="67" x2="362" y2="67" stroke="rgba(99,179,255,0.4)" stroke-width="1"/>
                <text x="367" y="70" font-size="7" fill="rgba(99,179,255,0.5)" font-family="monospace">½</text>
                <line x1="352" y1="90.5" x2="362" y2="90.5" stroke="rgba(99,179,255,0.4)" stroke-width="1"/>
                <line x1="350" y1="114" x2="364" y2="114" stroke="rgba(255,71,87,0.7)" stroke-width="1.5"/>
                <text x="367" y="118" font-size="7" fill="rgba(255,71,87,0.7)" font-family="monospace">E</text>
                <!-- Needle pointer -->
                <polygon points="348,<%=20 + 94*(100-fp)/100%> 353,<%=20 + 94*(100-fp)/100 - 3%> 353,<%=20 + 94*(100-fp)/100 + 3%>"
                         fill="<%=pctColor%>" filter="url(#glow_<%=tid%>)"/>

                <!-- ════════════════════════════════
                     TOP FITTINGS
                     ════════════════════════════════ -->
                <!-- Main fill pipe (centre-top) -->
                <rect x="154" y="4" width="36" height="13" rx="4"
                      fill="rgba(28,46,88,0.96)" stroke="<%=rimColor%>" stroke-width="1.8"/>
                <rect x="162" y="7" width="20" height="7" rx="2"
                      fill="rgba(0,0,0,0.40)" stroke="rgba(99,179,255,0.55)" stroke-width="1"/>
                <!-- Pressure gauge nub (left of pipe) -->
                <circle cx="120" cy="12" r="7"
                        fill="rgba(28,46,88,0.95)" stroke="<%=rimColor%>" stroke-width="1.5"/>
                <circle cx="120" cy="12" r="3.5"
                        fill="rgba(0,0,0,0.35)" stroke="rgba(99,179,255,0.45)" stroke-width="0.8"/>
                <!-- Vent cap (right of pipe) -->
                <rect x="220" y="7" width="18" height="7" rx="3"
                      fill="rgba(28,46,88,0.95)" stroke="<%=rimColor%>" stroke-width="1.4"/>
                <!-- Rivet details — mid and bottom only (top removed) -->
                <circle cx="30"  cy="65" r="3"   fill="rgba(35,55,95,0.8)" stroke="<%=shellStroke%>" stroke-width="1"/>
                <circle cx="314" cy="65" r="3"   fill="rgba(35,55,95,0.8)" stroke="<%=shellStroke%>" stroke-width="1"/>
                <circle cx="30"  cy="90" r="2.2" fill="rgba(35,55,95,0.7)" stroke="<%=shellStroke%>" stroke-width="0.8"/>
                <circle cx="314" cy="90" r="2.2" fill="rgba(35,55,95,0.7)" stroke="<%=shellStroke%>" stroke-width="0.8"/>

                <!-- ════════════════════════════════
                     BOTTOM DRAIN + OUTLET PIPE
                     ════════════════════════════════ -->
                <rect x="162" y="115" width="20" height="18" rx="4"
                      fill="rgba(20,35,70,0.96)" stroke="<%=shellStroke%>" stroke-width="1.5"/>
                <rect x="166" y="120" width="12" height="8" rx="2"
                      fill="rgba(0,0,0,0.4)" stroke="rgba(99,179,255,0.30)" stroke-width="0.8"/>
              </svg>
            </div>

            <!-- ── Info strip below tank ── -->
            <div class="ims-htank-info">
              <div>
                <div class="ims-htank-label">${t.fuelType}</div>
                <div style="margin-top:5px">
                  <span class="ims-tank-status-badge
                    <c:choose>
                      <c:when test="${t.status eq 'Normal'}">ims-status-normal</c:when>
                      <c:when test="${t.status eq 'Low'}">ims-status-low</c:when>
                      <c:otherwise>ims-status-verlow</c:otherwise>
                    </c:choose>">
                    <span class="ims-dot"></span>${t.status}
                  </span>
                </div>
              </div>
              <div class="text-center">
                <div class="ims-htank-pct-badge" style="color:<%=pctColor%>">
                  <fmt:formatNumber value="${t.pctFull}" pattern="0.#"/>%
                </div>
                <div style="font-size:10px;color:var(--txt3);letter-spacing:2px;margin-top:3px;font-weight:600">FULL</div>
              </div>
              <div class="ims-htank-litres text-right">
                <fmt:formatNumber value="${t.currentLevel}" pattern="#,##0"/> L<br>
                <span style="font-size:12px;color:var(--txt3)">
                  / <fmt:formatNumber value="${t.capacity}" pattern="#,##0"/> L
                </span>
              </div>
            </div>
          </div>





          <c:if test="${t.status eq 'Very Low'}">
          <div class="alert alert-danger" style="margin-top:10px;padding:6px 10px;font-size:11px;border-radius:6px">
            <i class="fa fa-exclamation-triangle"></i>
            <strong>URGENT:</strong> Refill required immediately.
            <a href="<%=request.getContextPath()%>/TankRefillServlet" class="alert-link">Log Refill &rarr;</a>
          </div>
          </c:if>
          <c:if test="${t.status eq 'Low'}">
          <div class="alert alert-warning" style="margin-top:10px;padding:6px 10px;font-size:11px;border-radius:6px">
            <i class="fa fa-exclamation-triangle"></i>
            Tank level low. Schedule refill soon.
            <a href="<%=request.getContextPath()%>/TankRefillServlet" class="alert-link">Log Refill &rarr;</a>
          </div>
          </c:if>

        </div>
      </div>
    </div>
    </c:forEach>

    <c:if test="${empty tanks}">
    <div class="col-xs-12">
      <div class="alert alert-info">
        <i class="fa fa-info-circle"></i>
        No tank data. Run 01_schema.sql and 02_seed_data.sql first.
      </div>
    </div>
    </c:if>
  </div>


  <!-- ═══ TODAY'S RECENT FUEL DISPENSE ENTRIES ═══ -->
  <div class="ims-section-title" style="margin-top:10px">
    <i class="fa fa-clock-o"></i> Today's Fuel Dispense — Recent Entries
    <small style="font-size:11px;color:#4a6080;font-weight:400;margin-left:8px">
      <i class="fa fa-refresh" id="recentRefreshIcon" style="cursor:pointer" onclick="loadRecentEntries()" title="Refresh"></i>
      Live
    </small>
  </div>
  <div class="panel panel-default ims-panel" style="margin-bottom:20px">
    <div class="panel-body" style="padding:10px 14px 8px">
      <div class="table-responsive" style="max-height:280px;overflow-y:auto;">
        <table class="table table-hover ims-table ims-dash-table" id="recentEntriesTable" style="font-size:12px;margin-bottom:0">
          <thead style="position:sticky;top:0;z-index:2">
            <tr>
              <th>#</th>
              <th>Req No.</th>
              <th>Time</th>
              <th>Vehicle No.</th>
              <th>Category</th>
              <th>Fuel</th>
              <th>Tank</th>
              <th>RCAV No.</th>
              <th>Dept / Unit</th>
              <th>Driver</th>
              <th>Prev KM</th>
              <th>Curr KM</th>
              <th>Issued (L)</th>
              <th>Remarks</th>
              <th>Receipt</th>
            </tr>
          </thead>
          <tbody id="recentEntriesBody">
            <tr>
              <td colspan="15" class="text-center text-muted" style="padding:20px">
                <i class="fa fa-spinner fa-spin"></i> Loading...
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- ═══ CHARTS ROW ═══ -->
  <div class="row" style="margin-bottom:20px">
    <!-- Weekly bar chart -->
    <div class="col-md-8">
      <div class="panel panel-default ims-panel">
        <div class="panel-heading ims-panel-heading">
          <i class="fa fa-bar-chart"></i> Weekly Fuel Disbursement (Last 7 Days)
          <div class="chart-legend pull-right" style="font-size:11px;display:flex;gap:12px;align-items:center">
            <span><span style="display:inline-block;width:10px;height:10px;background:#3b9eff;border-radius:2px;margin-right:4px"></span>Diesel</span>
            <span><span style="display:inline-block;width:10px;height:10px;background:#ff6b35;border-radius:2px;margin-right:4px"></span>Petrol</span>
          </div>
        </div>
        <div class="panel-body">
          <div id="weeklyChart"
               style="display:flex;align-items:flex-end;gap:6px;height:160px;padding-top:16px">
            <div class="text-center text-muted" style="width:100%;line-height:160px;font-size:12px">
              <i class="fa fa-spinner fa-spin"></i> Loading chart data...
            </div>
          </div>
          <div id="weeklyLabels" style="display:flex;justify-content:space-between;margin-top:6px;padding:0 2px;font-size:10px;color:#4a6080"></div>
        </div>
      </div>
    </div>

    <!-- This Month KPIs — TMS Admin only -->
    <c:if test="${isTmsAdmin}">
    <div class="col-md-4">
      <div class="panel panel-default ims-panel" style="height:100%">
        <div class="panel-heading ims-panel-heading">
          <i class="fa fa-pie-chart"></i> This Month KPIs
          <span class="label label-warning pull-right" style="margin-top:2px;font-size:10px">TMS ADMIN</span>
        </div>
        <div class="panel-body" style="display:flex;flex-direction:column;gap:14px">
          <div>
            <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:5px">
              <span style="color:var(--txt2,#8ba4c8)">Diesel vs Petrol (today)</span>
            </div>
            <div style="display:flex;gap:6px;align-items:center;font-size:12px">
              <span style="color:#3b9eff;font-family:monospace" id="kpiDDiesel">--</span>
              <span style="color:#4a6080">D</span>
              <div style="flex:1;height:8px;background:rgba(255,255,255,0.07);border-radius:4px;overflow:hidden">
                <div id="dieselBar" style="height:100%;background:#3b9eff;border-radius:4px;width:0%;transition:width 1s ease"></div>
              </div>
              <span style="color:#ff6b35;font-family:monospace" id="kpiDPetrol">--</span>
              <span style="color:#4a6080">P</span>
            </div>
          </div>
          <c:set var="m" value="${kpiMonthly}"/>
          <c:set var="targets" value="${60000}"/>
          <div>
            <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:5px">
              <span style="color:var(--txt2,#8ba4c8)">Monthly vs Capacity</span>
              <span style="color:#00e5c3;font-family:monospace">
                <fmt:formatNumber value="${kpiMonthly > 0 ? (kpiMonthly/60000*100) : 0}" pattern="0.#"/>%
              </span>
            </div>
            <div style="height:8px;background:rgba(255,255,255,0.07);border-radius:4px;overflow:hidden">
              <div style="height:100%;background:#00e5c3;border-radius:4px;
                width:<fmt:formatNumber value='${kpiMonthly > 0 ? (kpiMonthly/60000*100) : 0}' pattern='0.#'/>%;
                transition:width 1.5s ease"></div>
            </div>
          </div>
          <div>
            <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:5px">
              <span style="color:var(--txt2,#8ba4c8)">Tank Utilisation</span>
              <span id="tankUtilPct" style="color:#ffd700;font-family:monospace">--</span>
            </div>
            <div style="height:8px;background:rgba(255,255,255,0.07);border-radius:4px;overflow:hidden">
              <div id="tankUtilBar" style="height:100%;background:#ffd700;border-radius:4px;width:0%;transition:width 1.5s ease"></div>
            </div>
          </div>
          <div>
            <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:5px">
              <span style="color:var(--txt2,#8ba4c8)">Reporting Compliance</span>
              <span style="color:#00d68f;font-family:monospace">100%</span>
            </div>
            <div style="height:8px;background:rgba(255,255,255,0.07);border-radius:4px;overflow:hidden">
              <div style="height:100%;background:#00d68f;border-radius:4px;width:100%"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    </c:if>
  </div>

  <!-- ═══ UNIT-WISE DISBURSEMENT (LIVE DB) ═══ -->
  <div class="ims-section-title">
    <i class="fa fa-table"></i> Unit-Wise Disbursement — This Month
    <small style="font-size:11px;color:#4a6080;font-weight:400;margin-left:8px">
      <i class="fa fa-database"></i> Live from DB
    </small>
  </div>
  <div class="panel panel-default ims-panel">
    <div class="panel-body" style="padding:12px 14px 8px">
      <!-- Toolbar -->
      <div class="row" style="margin-bottom:10px">
        <div class="col-sm-4 col-xs-12" style="margin-bottom:6px">
          <div class="input-group input-group-sm">
            <span class="input-group-addon"><i class="fa fa-search"></i></span>
            <input type="text" id="uwSearch" class="form-control ims-input"
              placeholder="Search unit / department..." oninput="uwFilter()">
          </div>
        </div>
        <div class="col-sm-3 col-xs-6" style="margin-bottom:6px">
          <select id="uwCatFilter" class="form-control input-group-sm ims-select" onchange="uwFilter()">
            <option value="">All Categories</option>
            <option value="BARC">BARC Vehicles</option>
            <option value="UNIT">Other DAE Units</option>
            <option value="LOOSE">Loose / Other</option>
          </select>
        </div>
        <div class="col-sm-3 col-xs-6" style="margin-bottom:6px">
          <select id="uwFuelFilter" class="form-control input-group-sm ims-select" onchange="uwFilter()">
            <option value="">All Fuel Types</option>
            <option value="diesel">Has Diesel</option>
            <option value="petrol">Has Petrol</option>
          </select>
        </div>
        <div class="col-sm-2 col-xs-12 text-right" style="margin-bottom:6px">
          <span id="uwCount" class="text-muted" style="font-size:12px;line-height:30px"></span>
        </div>
      </div>
      <!-- Table -->
      <div class="table-responsive">
        <table class="table table-hover ims-table ims-dash-table" id="unitWiseTable">
          <thead>
            <tr>
              <th style="cursor:pointer" onclick="uwSort('unit')">Unit / Department <i class="fa fa-sort" id="uwSort_unit"></i></th>
              <th style="cursor:pointer" onclick="uwSort('cat')">Category <i class="fa fa-sort" id="uwSort_cat"></i></th>
              <th style="cursor:pointer" onclick="uwSort('diesel')">Diesel (L) <i class="fa fa-sort" id="uwSort_diesel"></i></th>
              <th style="cursor:pointer" onclick="uwSort('petrol')">Petrol (L) <i class="fa fa-sort" id="uwSort_petrol"></i></th>
              <th style="cursor:pointer" onclick="uwSort('total')">Total (L) <i class="fa fa-sort" id="uwSort_total"></i></th>
              <th style="cursor:pointer" onclick="uwSort('txn')">Transactions <i class="fa fa-sort" id="uwSort_txn"></i></th>
              <th>Share</th>
            </tr>
          </thead>
          <tbody id="unitWiseBody">
            <tr>
              <td colspan="7" class="text-center text-muted" style="padding:20px">
                <i class="fa fa-spinner fa-spin"></i> Loading...
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <!-- Pagination -->
      <div class="row" style="margin-top:8px;align-items:center">
        <div class="col-sm-6 col-xs-12">
          <span id="uwPageInfo" class="text-muted" style="font-size:12px"></span>
        </div>
        <div class="col-sm-6 col-xs-12 text-right">
          <div class="btn-group btn-group-sm" id="uwPagination"></div>
        </div>
      </div>
    </div>
  </div>

  <!-- ═══ VEHICLE PERFORMANCE — TMS Admin only ═══ -->
  <c:if test="${isTmsAdmin}">
  <div class="ims-section-title">
    <i class="fa fa-car"></i> Vehicle Performance Monitor — This Month
    <span class="label label-warning" style="margin-left:8px;font-size:10px;vertical-align:middle">TMS ADMIN</span>
    <small style="font-size:11px;color:#4a6080;font-weight:400;margin-left:8px">
      <i class="fa fa-database"></i> Live from DB
    </small>
  </div>
  <div class="panel panel-default ims-panel" style="margin-bottom:40px">
    <div class="panel-body" style="padding:12px 14px 8px">
      <!-- Toolbar -->
      <div class="row" style="margin-bottom:10px">
        <div class="col-sm-3 col-xs-12" style="margin-bottom:6px">
          <div class="input-group input-group-sm">
            <span class="input-group-addon"><i class="fa fa-search"></i></span>
            <input type="text" id="vpSearch" class="form-control ims-input"
              placeholder="Vehicle no / driver..." oninput="vpFilter()">
          </div>
        </div>
        <div class="col-sm-2 col-xs-6" style="margin-bottom:6px">
          <select id="vpTypeFilter" class="form-control input-group-sm ims-select" onchange="vpFilter()">
            <option value="">All Types</option>
            <option value="Car">Car</option>
            <option value="Jeep">Jeep</option>
            <option value="SUV">SUV</option>
            <option value="Bus">Bus</option>
            <option value="Minibus">Minibus</option>
            <option value="Van">Van</option>
            <option value="Truck">Truck</option>
            <option value="Pickup">Pickup</option>
            <option value="Motorcycle">Motorcycle</option>
            <option value="Ambulance">Ambulance</option>
            <option value="Other">Other</option>
          </select>
        </div>
        <div class="col-sm-3 col-xs-6" style="margin-bottom:6px">
          <select id="vpDeptFilter" class="form-control input-group-sm ims-select" onchange="vpFilter()">
            <option value="">All Departments</option>
          </select>
        </div>
        <div class="col-sm-2 col-xs-6" style="margin-bottom:6px">
          <select id="vpFuelFilter" class="form-control input-group-sm ims-select" onchange="vpFilter()">
            <option value="">All Fuels</option>
            <option value="DIESEL">Diesel</option>
            <option value="PETROL">Petrol</option>
          </select>
        </div>
        <div class="col-sm-2 col-xs-6" style="margin-bottom:6px">
          <select id="vpFlagFilter" class="form-control input-group-sm ims-select" onchange="vpFilter()">
            <option value="">All Flags</option>
            <option value="ok">OK (≥10 km/L)</option>
            <option value="monitor">Monitor (8–10)</option>
            <option value="risk">High Risk (&lt;8)</option>
          </select>
        </div>
      </div>
      <!-- Table -->
      <div class="table-responsive">
        <table class="table table-hover ims-table ims-dash-table" id="vehPerfTable">
          <thead>
            <tr>
              <th style="cursor:pointer" onclick="vpSort('vno')">Vehicle No. <i class="fa fa-sort" id="vpSort_vno"></i></th>
              <th style="cursor:pointer" onclick="vpSort('type')">Type <i class="fa fa-sort" id="vpSort_type"></i></th>
              <th style="cursor:pointer" onclick="vpSort('dept')">Department <i class="fa fa-sort" id="vpSort_dept"></i></th>
              <th>Driver</th>
              <th>Fuel</th>
              <th style="cursor:pointer" onclick="vpSort('mileage')">Avg Mileage <i class="fa fa-sort" id="vpSort_mileage"></i></th>
              <th>Performance</th>
              <th style="cursor:pointer" onclick="vpSort('flag')">Flag <i class="fa fa-sort" id="vpSort_flag"></i></th>
            </tr>
          </thead>
          <tbody id="vehPerfBody">
            <tr>
              <td colspan="8" class="text-center text-muted" style="padding:20px">
                <i class="fa fa-spinner fa-spin"></i> Loading...
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <!-- Pagination -->
      <div class="row" style="margin-top:8px;align-items:center">
        <div class="col-sm-6 col-xs-12">
          <span id="vpPageInfo" class="text-muted" style="font-size:12px"></span>
        </div>
        <div class="col-sm-6 col-xs-12 text-right">
          <div class="btn-group btn-group-sm" id="vpPagination"></div>
        </div>
      </div>
    </div>
  </div>

  </c:if><%-- end isTmsAdmin veh perf --%>



<!-- ROW RECEIPT MODAL — exact copy from reports.jsp -->
<div class="modal fade" id="rowReceiptModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content ims-receipt-modal">
      <div class="modal-header ims-receipt-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title"><i class="fa fa-file-text"></i> FUEL ISSUE RECEIPT</h4>
        <p class="ims-receipt-sub">Bhabha Atomic Research Centre, Trombay, Mumbai 400085</p>
        <small>Transport Section &mdash; IMS Fuel Master Pro</small>
      </div>
      <div class="modal-body" id="rowReceiptBody"></div>
      <div class="modal-footer ims-receipt-footer">
        <div class="row ims-sig-row">
          <div class="col-xs-6 ims-sig-box">Issued By (Officer)<br><br><br>(Signature &amp; Date)</div>
          <div class="col-xs-6 ims-sig-box">Driver / Receiver<br><br><br>(Signature &amp; Date)</div>
        </div>
        <div style="margin-top:12px">
          <button class="btn ims-btn-primary btn-sm" onclick="downloadRowPDF()">
            <i class="fa fa-file-pdf-o"></i> Download PDF
          </button>
          <button class="btn btn-default btn-sm" data-dismiss="modal">
            <i class="fa fa-times"></i> Close
          </button>
        </div>
      </div>
    </div>
  </div>
</div>

</div><!-- /container -->

<!-- ═══ NOZZLE FILLING ANIMATION OVERLAY ═══ -->
<div id="nozzleOverlay" class="hidden">
  <div class="nozzle-container">
    <div class="nozzle-title" id="nozzleTitle">PROCESSING...</div>
    <svg width="180" height="260" viewBox="0 0 180 260" id="nozzleSvg">
      <defs>
        <linearGradient id="nozzleBodyGrad" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%"   stop-color="#2a3a5a"/>
          <stop offset="50%"  stop-color="#4a6080"/>
          <stop offset="100%" stop-color="#2a3a5a"/>
        </linearGradient>
        <linearGradient id="fuelFlowGrad" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%"   stop-color="#3b9eff" stop-opacity="0.9"/>
          <stop offset="100%" stop-color="#0d47a1" stop-opacity="0.7"/>
        </linearGradient>
        <clipPath id="tankBodyClip">
          <rect x="40" y="130" width="100" height="100" rx="8"/>
        </clipPath>
      </defs>

      <!-- Nozzle hose -->
      <path d="M 90 10 Q 20 10 20 60 Q 20 100 50 110 L 60 115"
        stroke="#4a6080" stroke-width="12" fill="none" stroke-linecap="round"/>
      <path d="M 90 10 Q 20 10 20 60 Q 20 100 50 110 L 60 115"
        stroke="#2a3a5a" stroke-width="8" fill="none" stroke-linecap="round"/>

      <!-- Nozzle body -->
      <rect x="50" y="106" width="36" height="54" rx="6"
        fill="url(#nozzleBodyGrad)" stroke="#6080a0" stroke-width="1.5"/>
      <!-- Nozzle grip -->
      <rect x="52" y="125" width="14" height="28" rx="4"
        fill="#1a2a3a" stroke="#3b9eff" stroke-width="1" opacity="0.8"/>
      <!-- Nozzle tip -->
      <rect x="76" y="118" width="22" height="10" rx="5"
        fill="#3a5070" stroke="#6080a0" stroke-width="1.5"/>
      <rect x="92" y="120" width="18" height="6" rx="3"
        fill="#2a4060"/>

      <!-- Fuel stream (animated) -->
      <g id="fuelStream">
        <rect x="98" y="126" width="8" height="12" rx="2"
          fill="url(#fuelFlowGrad)" opacity="0.9">
          <animate attributeName="height" values="0;12;0" dur="0.4s" repeatCount="indefinite"/>
          <animate attributeName="opacity" values="0.9;0.4;0.9" dur="0.4s" repeatCount="indefinite"/>
        </rect>
        <ellipse cx="102" cy="140" rx="5" ry="2" fill="#3b9eff" opacity="0.6">
          <animate attributeName="cy" values="138;142;138" dur="0.4s" repeatCount="indefinite"/>
          <animate attributeName="opacity" values="0.7;0.2;0.7" dur="0.4s" repeatCount="indefinite"/>
        </ellipse>
      </g>

      <!-- Tank body -->
      <rect x="40" y="140" width="100" height="100" rx="8"
        fill="rgba(20,30,50,0.9)" stroke="#4a6080" stroke-width="2"/>
      <!-- Tank liquid fill (animated) -->
      <g clip-path="url(#tankBodyClip)">
        <rect id="nozzleTankFill" x="40" y="240" width="100" height="0"
          fill="url(#fuelFlowGrad)" opacity="0.85">
          <animate attributeName="y"      values="240;140;240" dur="2.5s" repeatCount="indefinite"/>
          <animate attributeName="height" values="0;100;0"     dur="2.5s" repeatCount="indefinite"/>
        </rect>
        <!-- Wave on fill surface -->
        <path id="nozzleWave"
          d="M30,200 C50,194 70,206 90,200 C110,194 130,206 150,200 C170,194 190,206 210,200 V250 H30Z"
          fill="rgba(59,158,255,0.4)">
          <animateTransform attributeName="transform" type="translate"
            values="0,0;-60,0;0,0" dur="2.5s" repeatCount="indefinite"/>
          <animate attributeName="d"
            values="M30,200 C50,194 70,206 90,200 C110,194 130,206 150,200 C170,194 190,206 210,200 V250 H30Z;
                    M30,150 C50,144 70,156 90,150 C110,144 130,156 150,150 C170,144 190,156 210,150 V250 H30Z;
                    M30,200 C50,194 70,206 90,200 C110,194 130,206 150,200 C170,194 190,206 210,200 V250 H30Z"
            dur="2.5s" repeatCount="indefinite"/>
        </path>
      </g>
      <!-- Tank level lines -->
      <line x1="42" y1="173" x2="52" y2="173" stroke="rgba(255,255,255,0.2)" stroke-width="1"/>
      <line x1="42" y1="198" x2="52" y2="198" stroke="rgba(255,255,255,0.2)" stroke-width="1"/>
      <line x1="42" y1="223" x2="52" y2="223" stroke="rgba(255,255,255,0.2)" stroke-width="1"/>
      <!-- Tank outline front -->
      <rect x="40" y="140" width="100" height="100" rx="8"
        fill="none" stroke="#6080a0" stroke-width="1.5"/>
      <!-- Tap at bottom -->
      <rect x="80" y="238" width="20" height="10" rx="4"
        fill="#3a5070" stroke="#6080a0" stroke-width="1.5"/>
    </svg>

    <!-- Fill progress bar -->
    <div style="width:200px;height:6px;background:rgba(255,255,255,0.1);border-radius:3px;margin:0 auto">
      <div id="nozzleProgress" style="height:100%;background:linear-gradient(90deg,#3b9eff,#00e5c3);border-radius:3px;width:0%;transition:width 0.1s linear"></div>
    </div>
    <div class="nozzle-subtitle" id="nozzleSubtitle">Saving entry to database...</div>
  </div>
</div>

<script>
var IMS_CTX = '<%=request.getContextPath()%>';

/* ════════════════════════════════════════════════
   DASHBOARD INIT
   ════════════════════════════════════════════════ */
$(document).ready(function(){
  loadUnitWise();
  loadVehPerf();
  loadWeeklyChart();
  loadRecentEntries();
  loadKPIBars();
  loadTankUtil();

  /* Auto-refresh every 30 seconds */
  setInterval(refreshDashboard, 30000);
});

function refreshDashboard() {
  var icon = document.getElementById('refreshIcon');
  if (icon) { icon.className = 'fa fa-refresh fa-spin'; }
  /* Refresh KPIs */
  $.ajax({
    url: IMS_CTX + '/DashboardServlet',
    data: { type: 'kpi' },
    dataType: 'json',
    success: function(d) {
      if (d && !d.error) {
        animCounter('kpiDaily',   d.daily);
        animCounter('kpiWeekly',  d.weekly);
        animCounter('kpiMonthly', d.monthly);
      }
      if (icon) icon.className = 'fa fa-refresh';
      document.getElementById('lastRefresh').textContent =
        'Refreshed ' + new Date().toLocaleTimeString('en-IN',{hour12:false});
    },
    error: function(){ if (icon) icon.className = 'fa fa-refresh'; }
  });
  /* Refresh tanks */
  $.ajax({
    url: IMS_CTX + '/DashboardServlet',
    data: { type: 'tanks' },
    dataType: 'json',
    success: function(tanks) { updateTankBars(tanks); }
  });
  /* Refresh tables */
  loadRecentEntries();
  loadUnitWise();
  loadVehPerf();
}

function animCounter(id, target) {
  var el = document.getElementById(id);
  if (!el) return;
  var curr = parseFloat((el.textContent||'0').replace(/[^0-9.]/g,'')) || 0;
  var step = (target - curr) / 20;
  var i = 0;
  var t = setInterval(function(){
    curr += step; i++;
    el.textContent = Math.round(curr).toLocaleString();
    if (i >= 20) { clearInterval(t); el.textContent = Math.round(target).toLocaleString(); }
  }, 40);
}

/* ════════════════════════════════════════════════
   UNIT-WISE TABLE — live from DB
   ════════════════════════════════════════════════ */
/* ══════════════════════════════════════════════════════════════════
   UNIT-WISE DISBURSEMENT — search / filter / sort / paginate
   ══════════════════════════════════════════════════════════════════ */
var _uwAll = [], _uwFiltered = [], _uwPage = 1, _uwPerPage = 10;
var _uwSortCol = '', _uwSortDir = 1;

function loadUnitWise() {
  $.ajax({
    url: IMS_CTX + '/DashboardServlet',
    data: { type: 'unitwise' },
    dataType: 'json',
    success: function(data) {
      var tbody = document.getElementById('unitWiseBody');
      if (!tbody) return;
      if (!data || !data.length) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center ims-no-data">' +
          '<i class="fa fa-inbox fa-2x"></i><br>No disbursements recorded this month yet.</td></tr>';
        document.getElementById('uwCount').textContent = '';
        return;
      }
      /* attach grand total for share % */
      var grand = 0;
      data.forEach(function(r){ grand += parseFloat(r.totalQty)||0; });
      data.forEach(function(r){ r._grand = grand; });
      _uwAll = data;
      _uwPage = 1;
      uwFilter();
    },
    error: function() {
      document.getElementById('unitWiseBody').innerHTML =
        '<tr><td colspan="7" class="text-center text-muted">Error loading data.</td></tr>';
    }
  });
}

function uwFilter() {
  var q    = ($('#uwSearch').val()||'').toLowerCase().trim();
  var cat  = ($('#uwCatFilter').val()||'');   /* exact match — values are BARC/UNIT/LOOSE */
  var fuel = ($('#uwFuelFilter').val()||'').toLowerCase();
  _uwFiltered = _uwAll.filter(function(r){
    if (q && (r.unitName||'').toLowerCase().indexOf(q) < 0) return false;
    if (cat  && (r.category||'').toUpperCase() !== cat.toUpperCase()) return false;
    if (fuel === 'diesel' && !(parseFloat(r.dieselQty) > 0)) return false;
    if (fuel === 'petrol' && !(parseFloat(r.petrolQty) > 0)) return false;
    return true;
  });
  _uwPage = 1;
  uwRenderTable();
}

function uwSort(col) {
  if (_uwSortCol === col) _uwSortDir *= -1;
  else { _uwSortCol = col; _uwSortDir = 1; }
  /* reset icons */
  ['unit','cat','diesel','petrol','total','txn'].forEach(function(c){
    var el = document.getElementById('uwSort_'+c);
    if (el) el.className = 'fa fa-sort' + (c===col ? (_uwSortDir===1?' fa-sort-asc':' fa-sort-desc') : '');
  });
  _uwFiltered.sort(function(a,b){
    var va, vb;
    switch(col){
      case 'unit':   va=(a.unitName||'').toLowerCase();  vb=(b.unitName||'').toLowerCase(); break;
      case 'cat':    va=(a.category||'').toLowerCase();  vb=(b.category||'').toLowerCase(); break;
      case 'diesel': va=parseFloat(a.dieselQty)||0;      vb=parseFloat(b.dieselQty)||0; break;
      case 'petrol': va=parseFloat(a.petrolQty)||0;      vb=parseFloat(b.petrolQty)||0; break;
      case 'total':  va=parseFloat(a.totalQty)||0;       vb=parseFloat(b.totalQty)||0; break;
      case 'txn':    va=parseInt(a.txnCount)||0;         vb=parseInt(b.txnCount)||0; break;
      default: return 0;
    }
    return va < vb ? -_uwSortDir : va > vb ? _uwSortDir : 0;
  });
  uwRenderTable();
}

function uwRenderTable() {
  var tbody = document.getElementById('unitWiseBody');
  var total  = _uwFiltered.length;
  var pages  = Math.max(1, Math.ceil(total / _uwPerPage));
  _uwPage    = Math.min(_uwPage, pages);
  var start  = (_uwPage - 1) * _uwPerPage;
  var slice  = _uwFiltered.slice(start, start + _uwPerPage);
  var grand  = _uwAll.length ? (_uwAll[0]._grand||0) : 0;

  document.getElementById('uwCount').textContent =
    total + ' record' + (total!==1?'s':'') + ' found';

  if (!slice.length) {
    tbody.innerHTML = '<tr><td colspan="7" class="text-center ims-no-data" style="padding:24px">' +
      '<i class="fa fa-search fa-2x"></i><br>No matching records.</td></tr>';
    document.getElementById('uwPageInfo').textContent = '';
    document.getElementById('uwPagination').innerHTML = '';
    return;
  }

  var html = '';
  slice.forEach(function(r, i){
    var total_r = parseFloat(r.totalQty)  || 0;
    var diesel  = parseFloat(r.dieselQty) || 0;
    var petrol  = parseFloat(r.petrolQty) || 0;
    var share   = grand > 0 ? (total_r / grand * 100).toFixed(1) : 0;
    var catCls  = r.category === 'BARC' ? 'label-primary'
                : r.category === 'UNIT' ? 'label-info' : 'label-warning';
    var barColor = (start+i) < 3 ? '#3b9eff' : (start+i) < 6 ? '#00e5c3' : '#ff6b35';
    html += '<tr>' +
      '<td><strong>' + escH(r.unitName) + '</strong></td>' +
      '<td><span class="label ' + catCls + '">' + escH(r.category) + '</span></td>' +
      '<td class="ims-mono">' + (diesel > 0 ? diesel.toLocaleString() : '&mdash;') + '</td>' +
      '<td class="ims-mono">' + (petrol > 0 ? petrol.toLocaleString() : '&mdash;') + '</td>' +
      '<td class="ims-mono"><strong>' + total_r.toLocaleString() + ' L</strong></td>' +
      '<td class="ims-mono">' + r.txnCount + '</td>' +
      '<td style="min-width:110px">' +
        '<div style="font-size:11px;color:#8ba4c8;margin-bottom:3px">' + share + '%</div>' +
        '<div class="ims-perf-bar-wrap">' +
          '<div class="ims-perf-bar" style="width:' + share + '%;background:' + barColor + '"></div>' +
        '</div>' +
      '</td>' +
    '</tr>';
  });
  tbody.innerHTML = html;

  /* page info */
  document.getElementById('uwPageInfo').textContent =
    'Showing ' + (start+1) + '–' + Math.min(start+_uwPerPage, total) + ' of ' + total;

  /* pagination buttons */
  uwRenderPagination('uwPagination', pages, _uwPage, function(p){ _uwPage=p; uwRenderTable(); });
}

/* ══════════════════════════════════════════════════════════════════
   VEHICLE PERFORMANCE TABLE — search / filter / sort / paginate
   ══════════════════════════════════════════════════════════════════ */
var _vpAll = [], _vpFiltered = [], _vpPage = 1, _vpPerPage = 10;
var _vpSortCol = '', _vpSortDir = 1;

function loadVehPerf() {
  $.ajax({
    url: IMS_CTX + '/DashboardServlet',
    data: { type: 'vehperf' },
    dataType: 'json',
    success: function(data) {
      var tbody = document.getElementById('vehPerfBody');
      if (!tbody) return;
      if (!data || !data.length) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center ims-no-data">' +
          '<i class="fa fa-car fa-2x"></i><br>' +
          'No vehicle mileage data this month.</td></tr>';
        return;
      }
      _vpAll = data;
      /* Populate department filter dynamically from data — deduplicated */
      var depts = {};
      data.forEach(function(v){ if (v.department) depts[v.department] = 1; });
      var deptEl = document.getElementById('vpDeptFilter');
      /* Remove all existing options except the first "All Departments" */
      while (deptEl.options.length > 1) deptEl.remove(1);
      Object.keys(depts).sort().forEach(function(d){
        var o = document.createElement('option'); o.value = d; o.textContent = d;
        deptEl.appendChild(o);
      });
      _vpPage = 1;
      vpFilter();
    },
    error: function(){
      document.getElementById('vehPerfBody').innerHTML =
        '<tr><td colspan="8" class="text-center text-muted">Error loading performance data.</td></tr>';
    }
  });
}

function vpFilter() {
  var q    = ($('#vpSearch').val()||'').toLowerCase().trim();
  var type = ($('#vpTypeFilter').val()||'');
  var dept = ($('#vpDeptFilter').val()||'');
  var fuel = ($('#vpFuelFilter').val()||'');
  var flag = ($('#vpFlagFilter').val()||'');
  _vpFiltered = _vpAll.filter(function(v){
    if (q && (v.vehicleNo||'').toLowerCase().indexOf(q) < 0
          && (v.driverName||'').toLowerCase().indexOf(q) < 0) return false;
    if (type && v.vehicleType !== type) return false;
    if (dept && v.department  !== dept) return false;
    if (fuel && (v.fuelType||'').toUpperCase() !== fuel) return false;
    if (flag) {
      var avg = parseFloat(v.avgMileage)||0;
      if (flag === 'ok'      && !(avg >= 10)) return false;
      if (flag === 'monitor' && !(avg >= 8 && avg < 10)) return false;
      if (flag === 'risk'    && !(avg < 8))  return false;
    }
    return true;
  });
  _vpPage = 1;
  vpRenderTable();
}

function vpSort(col) {
  if (_vpSortCol === col) _vpSortDir *= -1;
  else { _vpSortCol = col; _vpSortDir = 1; }
  ['vno','type','dept','mileage','flag'].forEach(function(c){
    var el = document.getElementById('vpSort_'+c);
    if (el) el.className = 'fa fa-sort' + (c===col ? (_vpSortDir===1?' fa-sort-asc':' fa-sort-desc') : '');
  });
  _vpFiltered.sort(function(a,b){
    var va, vb;
    switch(col){
      case 'vno':     va=(a.vehicleNo||'').toLowerCase();  vb=(b.vehicleNo||'').toLowerCase(); break;
      case 'type':    va=(a.vehicleType||'').toLowerCase(); vb=(b.vehicleType||'').toLowerCase(); break;
      case 'dept':    va=(a.department||'').toLowerCase(); vb=(b.department||'').toLowerCase(); break;
      case 'mileage': va=parseFloat(a.avgMileage)||0;      vb=parseFloat(b.avgMileage)||0; break;
      case 'flag':    va=parseFloat(a.avgMileage)||0;      vb=parseFloat(b.avgMileage)||0; break;
      default: return 0;
    }
    return va < vb ? -_vpSortDir : va > vb ? _vpSortDir : 0;
  });
  vpRenderTable();
}

function vpRenderTable() {
  var TARGET = 10;
  var tbody  = document.getElementById('vehPerfBody');
  var total  = _vpFiltered.length;
  var pages  = Math.max(1, Math.ceil(total / _vpPerPage));
  _vpPage    = Math.min(_vpPage, pages);
  var start  = (_vpPage - 1) * _vpPerPage;
  var slice  = _vpFiltered.slice(start, start + _vpPerPage);

  if (!slice.length) {
    tbody.innerHTML = '<tr><td colspan="8" class="text-center ims-no-data" style="padding:24px">' +
      '<i class="fa fa-search fa-2x"></i><br>No matching records.</td></tr>';
    document.getElementById('vpPageInfo').textContent = '';
    document.getElementById('vpPagination').innerHTML = '';
    return;
  }

  var html = '';
  slice.forEach(function(v){
    var avg    = parseFloat(v.avgMileage) || 0;
    var pct    = Math.min((avg / TARGET) * 100, 100).toFixed(0);
    var col    = avg >= 12 ? '#00d68f' : avg >= 8 ? '#ffd700' : '#ff4757';
    var flag   = avg < 8
      ? '<span class="label label-danger"><i class="fa fa-flag"></i> High Risk</span>'
      : avg < 10
      ? '<span class="label label-warning"><i class="fa fa-exclamation"></i> Monitor</span>'
      : '<span class="label label-success"><i class="fa fa-check"></i> OK</span>';
    var fuelCls = (v.fuelType||'').toUpperCase() === 'PETROL' ? 'label-danger' : 'label-primary';
    html += '<tr>' +
      '<td class="ims-mono" style="color:#3b9eff"><strong>' + escH(v.vehicleNo) + '</strong></td>' +
      '<td>' + escH(v.vehicleType) + '</td>' +
      '<td>' + escH(v.department)  + '</td>' +
      '<td>' + escH(v.driverName)  + '</td>' +
      '<td><span class="label ' + fuelCls + '">' + escH(v.fuelType) + '</span></td>' +
      '<td class="ims-mono" style="color:' + col + '">' + avg + ' km/L</td>' +
      '<td style="min-width:120px">' +
        '<div style="font-size:11px;color:' + col + ';margin-bottom:3px">' +
          pct + '% of target (' + TARGET + ' km/L)' +
        '</div>' +
        '<div class="ims-perf-bar-wrap">' +
          '<div class="ims-perf-bar" style="width:' + pct + '%;background:' + col + '"></div>' +
        '</div>' +
      '</td>' +
      '<td>' + flag + '</td>' +
    '</tr>';
  });
  tbody.innerHTML = html;

  document.getElementById('vpPageInfo').textContent =
    'Showing ' + (start+1) + '–' + Math.min(start+_vpPerPage, total) + ' of ' + total;

  uwRenderPagination('vpPagination', pages, _vpPage, function(p){ _vpPage=p; vpRenderTable(); });
}

/* ═══ Shared pagination renderer ═══ */
function uwRenderPagination(containerId, pages, current, onPage) {
  var el = document.getElementById(containerId);
  if (!el) return;
  if (pages <= 1) { el.innerHTML = ''; return; }
  var html = '';
  /* Prev */
  html += '<button class="btn btn-default' + (current===1?' disabled':'') + '" ' +
    (current>1 ? 'onclick="('+onPage.toString()+')('+( current-1)+')"' : '') +
    '><i class="fa fa-chevron-left"></i></button>';
  /* Page buttons — show max 7 around current */
  var start = Math.max(1, current - 3);
  var end   = Math.min(pages, start + 6);
  start = Math.max(1, end - 6);
  if (start > 1) html += '<button class="btn btn-default" onclick="('+onPage.toString()+')(1)">1</button>';
  if (start > 2) html += '<button class="btn btn-default disabled">…</button>';
  for (var p = start; p <= end; p++) {
    html += '<button class="btn ' + (p===current?'btn-primary':'btn-default') + '" ' +
      'onclick="('+onPage.toString()+')('+p+')">' + p + '</button>';
  }
  if (end < pages - 1) html += '<button class="btn btn-default disabled">…</button>';
  if (end < pages)    html += '<button class="btn btn-default" onclick="('+onPage.toString()+')('+pages+')">'+pages+'</button>';
  /* Next */
  html += '<button class="btn btn-default' + (current===pages?' disabled':'') + '" ' +
    (current<pages ? 'onclick="('+onPage.toString()+')('+(current+1)+')"' : '') +
    '><i class="fa fa-chevron-right"></i></button>';
  el.innerHTML = html;
}

/* ════════════════════════════════════════════════
   WEEKLY BAR CHART — live from DB
   ════════════════════════════════════════════════ */
function loadWeeklyChart() {
  $.ajax({
    url: IMS_CTX + '/DashboardServlet',
    data: { type: 'weekly' },
    dataType: 'json',
    success: function(data) {
      var chart  = document.getElementById('weeklyChart');
      var labels = document.getElementById('weeklyLabels');
      if (!chart) return;

      if (!data || !data.length) {
        chart.innerHTML = '<div class="text-center text-muted" style="width:100%;line-height:160px;font-size:12px">' +
          '<i class="fa fa-bar-chart"></i> No data for last 7 days.</div>';
        return;
      }

      var max = 0;
      data.forEach(function(d){ max = Math.max(max, d.diesel + d.petrol); });
      if (max === 0) max = 1;

      var html = '', labelHtml = '';
      data.forEach(function(d){
        var dh = Math.round((d.diesel / max) * 145);
        var ph = Math.round((d.petrol / max) * 145);
        html += '<div style="flex:1;display:flex;flex-direction:column;align-items:center;' +
          'justify-content:flex-end;height:100%;gap:2px">' +
          (ph > 0 ? '<div class="dash-bar" style="width:100%;height:' + ph +
            'px;background:#ff6b35;border-radius:3px 3px 0 0;opacity:0.85" ' +
            'title="Petrol: ' + d.petrol + 'L"></div>' : '') +
          (dh > 0 ? '<div class="dash-bar" style="width:100%;height:' + dh +
            'px;background:#3b9eff;border-radius:' + (ph > 0 ? '0' : '3px 3px') + ' 0 0;opacity:0.85" ' +
            'title="Diesel: ' + d.diesel + 'L"></div>' : '') +
          (dh === 0 && ph === 0 ? '<div style="width:100%;height:4px;background:rgba(255,255,255,0.1);border-radius:2px"></div>' : '') +
          '</div>';
        labelHtml += '<span style="font-size:10px;color:#4a6080">' + (d.day||'') + '</span>';
      });
      chart.innerHTML = html;
      if (labels) labels.innerHTML = labelHtml;
    }
  });
}

/* ════════════════════════════════════════════════
   KPI BARS (Diesel/Petrol split today)
   ════════════════════════════════════════════════ */
function loadKPIBars() {
  $.ajax({
    url: IMS_CTX + '/DashboardServlet',
    data: { type: 'kpi' },
    dataType: 'json',
    success: function(d) {
      if (!d) return;
      var dd = parseFloat(d.dailyDiesel||0);
      var dp = parseFloat(d.dailyPetrol||0);
      var tot = dd + dp || 1;
      $('#kpiDDiesel').text(dd.toLocaleString() + ' L');
      $('#kpiDPetrol').text(dp.toLocaleString() + ' L');
      setTimeout(function(){
        $('#dieselBar').css('width', (dd/tot*100).toFixed(0)+'%');
      }, 400);
    }
  });
}

/* ════════════════════════════════════════════════
   TANK UTILISATION BAR
   ════════════════════════════════════════════════ */
function loadTankUtil() {
  $.ajax({
    url: IMS_CTX + '/DashboardServlet',
    data: { type: 'tanks' },
    dataType: 'json',
    success: function(tanks) {
      if (!tanks || !tanks.length) return;
      var totalLevel = 0, totalCap = 0;
      tanks.forEach(function(t){
        totalLevel += parseFloat(t.level)||0;
        totalCap   += parseFloat(t.capacity)||0;
      });
      var utilPct = totalCap > 0 ? (totalLevel / totalCap * 100).toFixed(1) : 0;
      $('#tankUtilPct').text(utilPct + '%');
      setTimeout(function(){
        $('#tankUtilBar').css('width', utilPct + '%');
      }, 600);
      updateTankBars(tanks);
    }
  });
}

function updateTankBars(tanks) {
  if (!tanks) return;
  /* Update progress bars inside tank cards without full page reload */
  tanks.forEach(function(t){
    /* We can't easily re-render SVG here, but we can update the progress bar below each tank */
  });
}

/* ════════════════════════════════════════════════
   NOZZLE ANIMATION — called from fuel_entry.jsp
   and master save actions via postMessage or direct call
   ════════════════════════════════════════════════ */
function showNozzleAnimation(title, subtitle, onComplete) {
  var overlay = document.getElementById('nozzleOverlay');
  if (!overlay) return;
  document.getElementById('nozzleTitle').textContent    = title    || 'PROCESSING...';
  document.getElementById('nozzleSubtitle').textContent = subtitle || 'Please wait...';
  document.getElementById('nozzleProgress').style.width = '0%';
  overlay.classList.remove('hidden');

  var pct = 0;
  var timer = setInterval(function(){
    pct += 2;
    document.getElementById('nozzleProgress').style.width = pct + '%';
    if (pct >= 100) {
      clearInterval(timer);
      setTimeout(function(){
        overlay.classList.add('hidden');
        if (typeof onComplete === 'function') onComplete();
      }, 400);
    }
  }, 30);
}

/* Expose globally so fuel_entry.jsp can call it */
window.showNozzleAnimation = showNozzleAnimation;


/* ════════════════════════════════════════════════
   RECENT ENTRIES TABLE — Today's dispenses
   ════════════════════════════════════════════════ */
function loadRecentEntries() {
  var icon = document.getElementById('recentRefreshIcon');
  if (icon) icon.className = 'fa fa-refresh fa-spin';
  $.ajax({
    url: IMS_CTX + '/DashboardServlet',
    data: { type: 'recent' },
    dataType: 'json',
    success: function(data) {
      var tbody = document.getElementById('recentEntriesBody');
      if (!tbody) return;
      window._lastRecentData = data;
      if (!data || !data.length) {
        tbody.innerHTML = '<tr><td colspan="15" class="text-center ims-no-data" style="padding:20px"><i class="fa fa-inbox fa-2x"></i><br>No entries recorded today yet.</td></tr>';
        if (icon) icon.className = 'fa fa-refresh';
        return;
      }
      var html = '';
      data.forEach(function(e, i) {
        var catCls = e.category==='BARC' ? 'label-primary' : e.category==='UNIT' ? 'label-info' : 'label-warning';
        var fuelCls = (e.fuelType||'')=='PETROL' ? 'label-danger' : 'label-primary';
        var deptUnit = e.category==='UNIT' ? (e.orgName||e.department||'--') : (e.department||'--');
        var prevKm = e.prevOdo > 0 ? e.prevOdo.toLocaleString() : '&mdash;';
        var currKm = e.currOdo > 0 ? e.currOdo.toLocaleString() : '&mdash;';
        html += '<tr>' +
          '<td class="ims-mono">' + (i+1) + '</td>' +
          '<td class="ims-mono" style="color:#3b9eff;white-space:nowrap">' + escH(e.reqNo||'--') + '</td>' +
          '<td class="ims-mono" style="white-space:nowrap">' + escH(e.entryTime||e.entryDate||'--') + '</td>' +
          '<td class="ims-mono"><strong style="color:#3b9eff">' + escH(e.vehicleNo||'&mdash;') + '</strong></td>' +
          '<td><span class="label ' + catCls + '">' + escH(e.category) + '</span></td>' +
          '<td><span class="label ' + fuelCls + '">' + escH(e.fuelType||'--') + '</span></td>' +
          '<td class="ims-mono">' + escH(e.tankName||'--') + '</td>' +
          '<td class="ims-mono">' + escH(e.rcavNo||'--') + '</td>' +
          '<td>' + escH(deptUnit) + '</td>' +
          '<td>' + escH(e.driverName||'--') + '</td>' +
          '<td class="ims-mono">' + prevKm + '</td>' +
          '<td class="ims-mono">' + currKm + '</td>' +
          '<td class="ims-mono"><strong style="color:#00d68f">' + (parseFloat(e.qtyIssued)||0).toFixed(1) + ' L</strong></td>' +
          '<td style="max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="' + escH(e.remarks||'')+'">' + escH(e.remarks||'&mdash;') + '</td>' +
          '<td style="white-space:nowrap">' +
          '<button class="btn btn-default btn-xs" title="View Receipt" ' +
          'onclick="showDashboardReceipt(_lastRecentData['+ i +'])"><i class="fa fa-file-text-o"></i></button></td>' +
          '</tr>';
      });
      tbody.innerHTML = html;
      if (icon) icon.className = 'fa fa-refresh';
    },
    error: function() {
      document.getElementById('recentEntriesBody').innerHTML =
        '<tr><td colspan="15" class="text-center text-muted">Error loading data.</td></tr>';
      if (icon) icon.className = 'fa fa-refresh';
    }
  });
}


/* ═══════════════════════════════════════════════════════════
   DASHBOARD RECEIPT — compact 2-col, merged fields
   ═══════════════════════════════════════════════════════════ */
function buildReceiptRows(e) {
  var odo = (e.prevOdo > 0 || e.currOdo > 0)
    ? (e.prevOdo > 0 ? Number(e.prevOdo).toLocaleString() : '--') +
      ' \u2192 ' +
      (e.currOdo  > 0 ? Number(e.currOdo).toLocaleString()  : '--') + ' km'
    : '--';
  var dept = e.category === 'UNIT'
    ? (e.orgName || e.department || '--')
    : (e.department || '--');
  var rows = [
    ['Req / Receipt No.', e.reqNo || '--', 'full'],
    ['Date', e.entryDate || '--', 'Time', e.entryTime || '--'],
    ['Vehicle No.', e.vehicleNo || '--', 'Fuel Type', e.fuelType || '--'],
    ['Tank', e.tankName || '--', 'RCAV No.', e.rcavNo || '--'],
    ['Department / Unit', dept, 'full'],
    ['Driver Name', e.driverName || '--', 'Emp No / CC No', String(e.driverBadge || '--')],
    ['Odometer (Prev \u2192 Curr)', odo, 'full']
  ];
  if (e.remarks) rows.push(['Remarks', e.remarks, 'full']);
  return rows;
}

function showRowReceiptModal(rows, qty) {
  var html = '<div class="ims-rcpt-grid">';
  rows.forEach(function(r) {
    if (r.length === 4) {
      html += '<div class="ims-rcpt-cell"><div class="ims-rcpt-key">' + r[0] + '</div>' +
              '<div class="ims-rcpt-val">' + r[1] + '</div></div>' +
              '<div class="ims-rcpt-cell"><div class="ims-rcpt-key">' + r[2] + '</div>' +
              '<div class="ims-rcpt-val">' + r[3] + '</div></div>';
    } else {
      html += '<div class="ims-rcpt-cell ims-rcpt-full"><div class="ims-rcpt-key">' + r[0] + '</div>' +
              '<div class="ims-rcpt-val">' + r[1] + '</div></div>';
    }
  });
  html += '</div><div class="ims-rcpt-qty">' +
          '<span class="ims-rcpt-qty-lbl">Qty Issued</span>' +
          '<span class="ims-rcpt-qty-val">' + qty + ' L</span></div>';
  document.getElementById('rowReceiptBody').innerHTML = html;
  window._rowReceiptData = rows;
  window._rowReceiptQty  = qty;
  $('#rowReceiptModal').modal('show');
}

function showDashboardReceipt(e) {
  if (!e) return;
  var rows = buildReceiptRows(e);
  var qty  = parseFloat(e.qtyIssued || 0).toFixed(1);
  window._receiptTitle = 'Fuel Receipt - ' + (e.vehicleNo || e.reqNo || '');
  showRowReceiptModal(rows, qty);
}

function downloadRowPDF() {
  var rows = window._rowReceiptData || [];
  var qty  = window._rowReceiptQty  || '--';
  var title = window._receiptTitle  || 'Fuel Dispense Receipt';
  var tRows = '';
  rows.forEach(function(r) {
    if (r.length === 4) {
      tRows += '<tr><td class="k">' + r[0] + '</td><td class="v">' + r[1] + '</td>' +
               '<td class="k">' + r[2] + '</td><td class="v">' + r[3] + '</td></tr>';
    } else {
      tRows += '<tr><td class="k">' + r[0] + '</td><td class="v" colspan="3">' + r[1] + '</td></tr>';
    }
  });
  var html = '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>' + title + '</title>' +
    '<style>*{margin:0;padding:0;box-sizing:border-box}body{font-family:Arial,sans-serif;font-size:12px;padding:20px;color:#111;max-width:580px;margin:0 auto}' +
    'h2{text-align:center;font-size:17px;color:#1a4080;margin-bottom:3px;letter-spacing:2px}.sub{text-align:center;font-size:11px;color:#555;margin-bottom:2px}' +
    'hr{border:none;border-top:2px solid #1a4080;margin:10px 0}table{width:100%;border-collapse:collapse;margin-bottom:14px}' +
    'td{padding:6px 10px;border-bottom:1px solid #eee;vertical-align:top}td.k{color:#555;font-size:10px;text-transform:uppercase;letter-spacing:.7px;width:22%}' +
    'td.v{font-family:Courier New,monospace;font-weight:600;font-size:12px;width:28%}' +
    '.qty{display:flex;justify-content:space-between;padding:10px 12px;border:2px solid #1a6ecc;border-radius:6px;margin-bottom:14px}' +
    '.qty-l{font-size:11px;text-transform:uppercase;letter-spacing:1px;color:#555;margin-top:2px}.qty-v{font-family:Courier New,monospace;font-size:22px;font-weight:800;color:#007a40}' +
    '.sigs{display:flex;gap:30px;margin-top:40px}.sig{flex:1;border-top:1px solid #aaa;padding-top:6px;text-align:center;font-size:11px;color:#666}' +
    '.footer{text-align:center;margin-top:16px;font-size:10px;color:#aaa;border-top:1px dashed #ccc;padding-top:6px}' +
    '@media print{body{padding:10px}@page{size:A5;margin:12mm}}</style></head><body>' +
    '<h2>&#9670; FUEL DISPENSE RECEIPT</h2>' +
    '<div class="sub">Bhabha Atomic Research Centre, Trombay, Mumbai 400085</div>' +
    '<div class="sub">Transport Section &mdash; IMS Fuel Master Pro</div><hr>' +
    '<table>' + tRows + '</table>' +
    '<div class="qty"><span class="qty-l">Quantity Issued</span><span class="qty-v">' + qty + ' L</span></div>' +
    '<div class="sigs"><div class="sig">Issued By (Officer)<br><br><br>(Signature &amp; Date)</div>' +
    '<div class="sig">Driver / Receiver<br><br><br>(Signature &amp; Date)</div></div>' +
    '<div class="footer">IMS Fuel Master Pro &mdash; BARC Transport Section</div></body></html>';
  var blob=new Blob([html],{type:'text/html;charset=utf-8'});
  var url=URL.createObjectURL(blob);
  var iframe=document.createElement('iframe');
  iframe.style.cssText='position:fixed;right:0;bottom:0;width:0;height:0;border:0';
  iframe.src=url;
  document.body.appendChild(iframe);
  iframe.onload=function(){setTimeout(function(){iframe.contentWindow.focus();iframe.contentWindow.print();setTimeout(function(){document.body.removeChild(iframe);URL.revokeObjectURL(url);},2000);},300);};
}


function escH(s) {
  if (!s) return '';
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
</script>

<%@ include file="footer.jsp" %>
