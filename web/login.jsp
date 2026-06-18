<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  if (session.getAttribute("userId") != null) {
    response.sendRedirect(request.getContextPath() + "/pages/dashboard.jsp");
    return;
  }
  String err     = request.getParameter("error");
  String logout  = request.getParameter("logout");
  String timeout = request.getParameter("timeout");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>IMS Fuel Master Pro — Login</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap.min.css">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/font-awesome.min.css">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/ims-main.css">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/ims-theme.css">

  <script>
    (function(){
      try{
        if(localStorage.getItem('ims_theme')==='light'){
          document.documentElement.classList.add('ims-light-html');
          document.addEventListener('DOMContentLoaded',function(){
            document.body.classList.add('ims-light');
          });
        }
      }catch(e){}
    }());
  </script>
  <style>
    html.ims-light-html body { background: #eef3fb !important; }

    /* ── Login logo row — fuel icon only ── */
    .ims-login-logos {
      display: flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 14px;
    }
    .ims-fuel-logo-wrap {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 6px;
    }
    .ims-fuel-icon {
      height: 80px;
      width: 80px;
      object-fit: contain;
      filter: drop-shadow(0 0 12px rgba(59,158,255,0.45));
    }
    .ims-login-title-wrap {
      text-align: center;
      margin-bottom: 6px;
    }
    .ims-login-logo {
      display: block !important;
      font-size: 26px;
      letter-spacing: 3px;
      font-weight: 800;
      color: var(--txt1, #e2eaf8);
      margin-bottom: 4px;
    }
    body.ims-light .ims-login-logo { color: #1a3a6e; }

    /* Theme toggle in login footer — icon + text */
    .ims-login-theme-row {
      display: flex;
      align-items: center;
      justify-content: center;
      margin-top: 14px;
      gap: 0;
    }
    .ims-login-theme-btn {
      display: inline-flex !important;
      align-items: center !important;
      gap: 8px !important;
      padding: 7px 16px !important;
      border-radius: 20px !important;
      border: 1.5px solid rgba(99,179,255,0.40) !important;
      background: rgba(59,158,255,0.10) !important;
      color: #7ac4ff !important;
      font-size: 13px !important;
      font-weight: 500 !important;
      cursor: pointer !important;
      text-decoration: none !important;
      transition: background 0.2s, border-color 0.2s, color 0.2s !important;
      letter-spacing: 0.3px;
    }
    .ims-login-theme-btn:hover {
      background: rgba(59,158,255,0.22) !important;
      border-color: rgba(99,179,255,0.75) !important;
      color: #fff !important;
      text-decoration: none !important;
    }
    .ims-login-theme-btn .fa { font-size: 14px; }
    body.ims-light .ims-login-theme-btn {
      border-color: rgba(26,110,204,0.40) !important;
      background: rgba(26,110,204,0.09) !important;
      color: #1a6ecc !important;
    }
    body.ims-light .ims-login-theme-btn:hover {
      background: rgba(26,110,204,0.18) !important;
      color: #0a3a8a !important;
    }
  </style>
</head>
<body class="ims-login-body">

  <!-- Loader overlay -->
  <div id="ims-loader">
    <div class="ims-loader-content">
      <div class="ims-loader-logo">IMS FUEL MASTER <span>PRO</span></div>
      <div class="ims-loader-sub">
        BHABHA ATOMIC RESEARCH CENTRE &mdash; TROMBAY, MUMBAI
      </div>
      <div class="ims-gauge-wrap">
        <svg class="ims-gauge-svg" viewBox="0 0 200 110">
          <defs>
            <linearGradient id="gGrad" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%"   stop-color="#ff4757"/>
              <stop offset="50%"  stop-color="#ffd700"/>
              <stop offset="100%" stop-color="#00d68f"/>
            </linearGradient>
          </defs>
          <path d="M 20 100 A 80 80 0 0 1 180 100"
                stroke="#1a2a3a" stroke-width="18" fill="none"/>
          <path id="gaugeFill" d="M 20 100 A 80 80 0 0 1 180 100"
                stroke="url(#gGrad)" stroke-width="18" fill="none"
                stroke-linecap="round"
                stroke-dasharray="282" stroke-dashoffset="282"/>
          <text id="gaugePct" x="100" y="88" text-anchor="middle"
                font-family="monospace" font-size="26" fill="#3b9eff">0%</text>
          <text x="100" y="104" text-anchor="middle"
                font-family="sans-serif" font-size="10" fill="#4a6080">
            SYSTEM LOADING
          </text>
        </svg>
      </div>
      <div class="ims-loader-bar">
        <div id="loaderBar" class="ims-loader-bar-fill"></div>
      </div>
      <div id="loaderStatus" class="ims-loader-status">
        Initializing core systems...
      </div>
    </div>
  </div>

  <!-- Login Card -->
  <div id="ims-login-wrap" style="display:none">
    <div class="ims-login-card">

      <div class="ims-login-header">
        <!-- Fuel icon only — no BARC logo -->
        <div class="ims-login-logos">
          <div class="ims-fuel-logo-wrap">
            <img src="<%=request.getContextPath()%>/images/gas-pump.png"
                 alt="IMS Fuel" class="ims-fuel-icon">
          </div>
        </div>
        <!-- Title -->
        <div class="ims-login-title-wrap">
          <div class="ims-login-logo">IMS FUEL <span>PRO</span></div>
          <p class="ims-login-subtitle">
            Bhabha Atomic Research Centre<br>
            <small>Transport Section &mdash; Integrated Fuel Management</small>
          </p>
        </div>
        <div class="ims-login-badge">
          <i class="fa fa-lock"></i> BARC INTRANET ONLY
        </div>
      </div>

      <%-- Alert messages --%>
      <% if ("1".equals(err)) { %>
        <div class="alert alert-warning">
          <i class="fa fa-exclamation-triangle"></i>
          Please enter username and password.
        </div>
      <% } else if ("2".equals(err)) { %>
        <div class="alert alert-danger">
          <i class="fa fa-times-circle"></i>
          Invalid credentials. Please try again.
        </div>
      <% } else if ("3".equals(err)) { %>
        <div class="alert alert-danger">
          <i class="fa fa-database"></i>
          Database connection error. Contact system admin.
        </div>
      <% } else if ("1".equals(logout)) { %>
        <div class="alert alert-info">
          <i class="fa fa-sign-out"></i>
          You have been logged out successfully.
        </div>
      <% } else if ("1".equals(timeout)) { %>
        <div class="alert alert-warning">
          <i class="fa fa-clock-o"></i>
          Session expired. Please login again.
        </div>
      <% } %>

      <form action="<%=request.getContextPath()%>/LoginServlet"
            method="post" id="loginForm">
        <div class="form-group ims-form-group">
          <label><i class="fa fa-user"></i> Username</label>
          <input type="text" name="username"
                 class="form-control ims-input"
                 placeholder="Enter your username"
                 required autofocus autocomplete="off">
        </div>
        <div class="form-group ims-form-group">
          <label><i class="fa fa-key"></i> Password</label>
          <div class="input-group">
            <input type="password" name="password" id="loginPass"
                   class="form-control ims-input"
                   placeholder="Enter your password" required>
            <span class="input-group-addon ims-pass-toggle"
                  onclick="togglePass()" title="Show/hide password">
              <i class="fa fa-eye" id="passEye"></i>
            </span>
          </div>
        </div>
        <button type="submit" class="btn btn-block ims-btn-login">
          <i class="fa fa-sign-in"></i> &nbsp; SIGN IN
        </button>
      </form>

      <!-- Footer: hint + theme toggle -->
      <div class="ims-login-footer" style="text-align:center;margin-top:16px">
        <small class="text-muted">Default: admin / barc@1234</small>
        <div class="ims-login-theme-row">
          <a href="#" id="loginThemeBtn" class="ims-login-theme-btn" onclick="imsToggleTheme();updateLoginThemeBtn();return false;">
            <i class="fa fa-sun-o" id="loginThemeIcon"></i>
            <span id="loginThemeText">Switch to Light Mode</span>
          </a>
        </div>
      </div>
    </div>
  </div>

  <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
  <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
  <script src="<%=request.getContextPath()%>/js/ims-theme.js"></script>

  <script>
    /* ── Update login theme button text/icon ── */
    function updateLoginThemeBtn() {
      var isLight = document.body.classList.contains('ims-light');
      var icon = document.getElementById('loginThemeIcon');
      var text = document.getElementById('loginThemeText');
      if (icon) icon.className = isLight ? 'fa fa-moon-o' : 'fa fa-sun-o';
      if (text) text.textContent = isLight ? 'Switch to Dark Mode' : 'Switch to Light Mode';
    }
    document.addEventListener('DOMContentLoaded', function(){ updateLoginThemeBtn(); });

    /* ── Gauge loader animation ── */
    var pct = 0;
    var steps = [
      'Initializing core systems...',
      'Loading vehicle master database...',
      'Connecting to Oracle 10g...',
      'Loading tank sensor data...',
      'Calibrating fuel meters...',
      'Applying security protocols...',
      'System ready.'
    ];
    var timer = setInterval(function () {
      pct += 2;
      if (pct > 100) pct = 100;
      document.getElementById('loaderBar').style.width = pct + '%';
      var fill = document.getElementById('gaugeFill');
      fill.style.strokeDashoffset = 282 - (282 * pct / 100);
      document.getElementById('gaugePct').textContent = pct + '%';
      var si = Math.min(
        Math.floor(pct / (100 / steps.length)),
        steps.length - 1
      );
      document.getElementById('loaderStatus').textContent = steps[si];
      if (pct >= 100) {
        clearInterval(timer);
        setTimeout(function () {
          var loader = document.getElementById('ims-loader');
          loader.style.transition = 'opacity 0.45s ease';
          loader.style.opacity = '0';
          setTimeout(function () {
            loader.style.display = 'none';
            var wrap = document.getElementById('ims-login-wrap');
            wrap.style.display = 'flex';
            wrap.style.animation = 'fadeIn 0.4s ease';
            updateLoginThemeBtn();
          }, 450);
        }, 350);
      }
    }, 25);

    /* ── Password show/hide ── */
    function togglePass() {
      var p = document.getElementById('loginPass');
      var e = document.getElementById('passEye');
      if (p.type === 'password') {
        p.type = 'text';
        e.className = 'fa fa-eye-slash';
      } else {
        p.type = 'password';
        e.className = 'fa fa-eye';
      }
    }
  </script>
</body>
</html>
