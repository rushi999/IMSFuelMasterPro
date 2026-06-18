/* ============================================================
   IMS FUEL MASTER PRO — ims-main.js  (v3 — cleaned)
   BARC Transport Section

   IMPORTANT: All fuel-entry-specific functions have been
   REMOVED from this file. They now live directly in
   fuel_entry.jsp to avoid conflicts.

   This file contains ONLY:
   1. Clock / date update
   2. Dashboard vehicle performance table (static fallback)
   3. Dashboard KPI auto-refresh (AJAX)
   4. Shared toast notification
   5. General UI helpers (input uppercase, form validation)
   ============================================================ */

/* ── Fuel rates (kept for reference, not used in forms) ── */
var IMS_RATES = { DIESEL: 93.80, PETROL: 105.40 };

/* ── Static vehicle perf data (dashboard fallback if DB empty) ── */
var vehiclePerf = [
  { vno:'MH04GA1234', type:'Car',       dept:'Reactor Physics',   driver:'R.K. Sharma', fuel:'DIESEL', avg:14.2, target:15 },
  { vno:'MH04GB5678', type:'Jeep',      dept:'Chemistry Div.',    driver:'S.M. Patil',  fuel:'DIESEL', avg:11.8, target:12 },
  { vno:'MH04GC9012', type:'Ambulance', dept:'BARC Hospital',     driver:'A.D. Nair',   fuel:'PETROL', avg:8.1,  target:10 },
  { vno:'MH04GD3456', type:'Van',       dept:'Security Section',  driver:'T.K. Mishra', fuel:'DIESEL', avg:9.4,  target:11 },
  { vno:'MH04GE7890', type:'Car',       dept:'Acc. & Pulse',      driver:'P.V. Desai',  fuel:'PETROL', avg:16.8, target:15 },
  { vno:'MH04GF2233', type:'Bus',       dept:'Admin Block',       driver:'C.L. Verma',  fuel:'DIESEL', avg:6.2,  target:8  },
  { vno:'MH04GG4455', type:'Truck',     dept:'Civil Engineering', driver:'M.N. Bhat',   fuel:'DIESEL', avg:5.8,  target:7  },
  { vno:'MH04GH6677', type:'Car',       dept:'Electronics Div.',  driver:'R.S. Iyer',   fuel:'PETROL', avg:18.1, target:15 }
];

/* ============================================================
   CLOCK — runs on every page
   ============================================================ */
function updateClock() {
  var now = new Date();
  var hh  = pad2(now.getHours());
  var mm  = pad2(now.getMinutes());
  var ss  = pad2(now.getSeconds());
  var el  = document.getElementById('navClock');
  if (el) el.innerHTML = '<i class="fa fa-clock-o"></i> ' + hh + ':' + mm + ':' + ss;

  var dd = document.getElementById('dashDate');
  if (dd) {
    dd.textContent = now.toLocaleDateString('en-IN', {
      weekday:'long', year:'numeric', month:'long', day:'numeric'
    });
  }
}
function pad2(n) {
  return (n < 10 ? '0' : '') + n;
}
setInterval(updateClock, 1000);
updateClock();

/* ============================================================
   DASHBOARD — Vehicle Performance Table (static fallback)
   Only renders if #vehiclePerfBody exists AND is empty
   (dashboard.jsp v3 uses live DB via AJAX instead)
   ============================================================ */
function renderVehiclePerf() {
  var tbody = document.getElementById('vehiclePerfBody');
  if (!tbody) return;
  /* If dashboard v3 is loaded, it populates via AJAX — don't overwrite */
  if (tbody.innerHTML.indexOf('fa-spinner') === -1 &&
      tbody.innerHTML.trim() !== '') return;

  var html = '';
  for (var i = 0; i < vehiclePerf.length; i++) {
    var v   = vehiclePerf[i];
    var pct = Math.round((v.avg / v.target) * 100);
    var col = pct >= 90 ? '#00d68f' : pct >= 70 ? '#ffd700' : '#ff4757';
    var cls = pct >= 90 ? 'success' : pct >= 70 ? 'warning' : 'danger';
    var lbl = pct >= 90 ? 'Good'    : pct >= 70 ? 'Average' : 'Poor';
    html += '<tr>' +
      '<td class="ims-mono" style="color:#3b9eff">' + v.vno + '</td>' +
      '<td>' + v.type + '</td>' +
      '<td>' + v.dept + '</td>' +
      '<td>' + v.driver + '</td>' +
      '<td><span class="label label-' + (v.fuel==='DIESEL'?'primary':'danger') + '">' + v.fuel + '</span></td>' +
      '<td class="ims-mono" style="color:' + col + '">' + v.avg + ' km/L</td>' +
      '<td>' + v.target + ' km/L</td>' +
      '<td>' +
        '<div style="font-size:10px;color:' + col + ';margin-bottom:3px">' + pct + '% of target</div>' +
        '<div class="progress ims-prog">' +
          '<div class="progress-bar progress-bar-' + cls + '" style="width:' + Math.min(pct,100) + '%"></div>' +
        '</div>' +
      '</td>' +
      '<td><span class="label label-' + cls + '">' + lbl + '</span></td>' +
    '</tr>';
  }
  tbody.innerHTML = html;
}

/* ============================================================
   DASHBOARD — KPI Auto-refresh (AJAX)
   ============================================================ */
function refreshKPIs() {
  if (typeof IMS_CTX === 'undefined') return;
  /* Only run on dashboard page */
  if (!document.getElementById('kpiDaily')) return;
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
    },
    error: function() { /* silent — intranet may be slow */ }
  });
}

function animCounter(id, target) {
  var el = document.getElementById(id);
  if (!el) return;
  var current = parseFloat((el.textContent || '0').replace(/[^0-9.]/g,'')) || 0;
  var step = (target - current) / 20;
  var i = 0;
  var timer = setInterval(function(){
    current += step;
    i++;
    el.textContent = Math.round(current).toLocaleString();
    if (i >= 20) {
      clearInterval(timer);
      el.textContent = Math.round(target).toLocaleString();
    }
  }, 40);
}

/* ============================================================
   TOAST NOTIFICATION — shared across all pages
   ============================================================ */
function showToast(msg, type) {
  /* type: 'success' | 'warning' | 'danger' | 'info' */
  var bg = type === 'success' ? '#00d68f'
         : type === 'warning' ? '#ffd700'
         : type === 'info'    ? '#3b9eff'
         : '#ff4757';
  var tc = (type === 'warning') ? '#1a1a00' : '#fff';

  /* Use jQuery if available, else plain JS */
  if (typeof $ !== 'undefined') {
    var toast = $('<div>').css({
      position:'fixed', bottom:'70px', right:'20px', zIndex:9999,
      background: bg, color: tc,
      padding:'10px 18px', borderRadius:'8px',
      fontSize:'13px', fontWeight:'600',
      boxShadow:'0 4px 20px rgba(0,0,0,0.4)',
      maxWidth:'360px'
    }).text(msg);
    $('body').append(toast);
    setTimeout(function(){ toast.fadeOut(300, function(){ $(this).remove(); }); }, 3000);
  } else {
    /* Fallback: native alert for critical errors only */
    if (type === 'danger') alert(msg);
  }
}

/* ============================================================
   DOM READY — runs once jQuery is available
   NOTE: All fuel-entry-specific init code is inside
   fuel_entry.jsp's own <script> block. Nothing here
   touches fuel entry form elements.
   ============================================================ */
function imsMainInit() {
  /* Dashboard init */
  if (document.getElementById('vehiclePerfBody')) {
    renderVehiclePerf();
  }
  if (document.getElementById('kpiDaily')) {
    refreshKPIs();
    setInterval(refreshKPIs, 30000);
  }

  /* Auto-dismiss flash alerts after 5 seconds */
  setTimeout(function() {
    if (typeof $ !== 'undefined') {
      $('.ims-alert').fadeOut(400);
    }
  }, 5000);

  /* Uppercase vehicle number inputs — general rule */
  if (typeof $ !== 'undefined') {
    $(document).on('input', 'input[name=vehicleNo]', function() {
      this.value = this.value.toUpperCase();
    });
    /* Prevent negative numbers */
    $(document).on('input', 'input[type=number]', function() {
      if (parseFloat(this.value) < 0) this.value = 0;
    });
  }
}

/* ── Safe DOM-ready: works whether jQuery is loaded or not ── */
if (typeof $ !== 'undefined') {
  $(document).ready(function(){ imsMainInit(); });
} else if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', function(){
    /* jQuery should be loaded by now (footer includes it first) */
    if (typeof $ !== 'undefined') {
      $(document).ready(function(){ imsMainInit(); });
    } else {
      imsMainInit();
    }
  });
} else {
  imsMainInit();
}
