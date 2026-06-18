<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt"%>
<%
  if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
  }
  pageContext.setAttribute("activePage", "tank_master");
  pageContext.setAttribute("pageTitle",  "Tank Master");
%>
<%@ include file="header.jsp" %>

<div class="container-fluid ims-main-content">
  <div class="ims-page-header">
    <h2><i class="fa fa-tint"></i> Tank Master</h2>
    <span class="ims-badge-tag">Refill Management</span>
    <span class="pull-right text-muted" style="font-size:12px;margin-top:8px">
      <i class="fa fa-info-circle"></i>
      Log tanker refills here — dashboard updates automatically
    </span>
  </div>

  <div class="row">

    <!-- LEFT: Current Tank Status -->
    <div class="col-md-5">
      <div class="ims-section-title">
        <i class="fa fa-bar-chart"></i> Current Tank Status
      </div>
      <c:forEach var="t" items="${tanks}">
      <div class="panel panel-default ims-panel ims-tank-status-card">
        <div class="panel-body">
          <div class="row" style="align-items:center">
            <!-- Tank visual bar -->
            <div class="col-xs-8">
              <div style="display:flex;justify-content:space-between;
                          align-items:center;margin-bottom:6px">
                <strong style="font-size:14px;letter-spacing:1px">
                  <i class="fa fa-tint"></i> ${t.tankName}
                </strong>
                <span class="ims-tank-status-badge
                  <c:choose>
                    <c:when test="${t.status eq 'Normal'}">ims-status-normal</c:when>
                    <c:when test="${t.status eq 'Low'}">ims-status-low</c:when>
                    <c:otherwise>ims-status-verlow</c:otherwise>
                  </c:choose>">
                  <span class="ims-dot"></span>${t.status}
                </span>
              </div>

              <!-- Progress bar -->
              <div class="progress ims-prog" style="height:18px;margin-bottom:6px">
                <div class="progress-bar
                  <c:choose>
                    <c:when test="${t.pctFull >= 50}">progress-bar-success</c:when>
                    <c:when test="${t.pctFull >= 25}">progress-bar-warning</c:when>
                    <c:otherwise>progress-bar-danger</c:otherwise>
                  </c:choose>"
                  style="width:<fmt:formatNumber value='${t.pctFull}' pattern='0'/>%;
                         font-size:11px;line-height:18px">
                  <fmt:formatNumber value="${t.pctFull}" pattern="0.#"/>%
                </div>
              </div>

              <div style="font-size:12px;color:#8ba4c8">
                <i class="fa fa-tint"></i>
                <strong><fmt:formatNumber value="${t.currentLevel}" pattern="#,##0"/> L</strong>
                available of
                <fmt:formatNumber value="${t.capacity}" pattern="#,##0"/> L capacity
                &nbsp;&middot;&nbsp;
                <span class="label ${t.fuelType eq 'DIESEL' ?
                  'label-primary' : 'label-danger'}">${t.fuelType}</span>
              </div>
            </div>

            <!-- Quick stats -->
            <div class="col-xs-4 text-right">
              <div style="font-size:24px;font-weight:700;
                color:<c:choose>
                  <c:when test='${t.pctFull >= 50}'>#00d68f</c:when>
                  <c:when test='${t.pctFull >= 25}'>#ffd700</c:when>
                  <c:otherwise>#ff4757</c:otherwise>
                </c:choose>">
                <fmt:formatNumber value="${t.pctFull}" pattern="0.#"/>%
              </div>
              <div style="font-size:10px;color:#4a6080;letter-spacing:1px">FULL</div>
            </div>
          </div>
        </div>
      </div>
      </c:forEach>
      <c:if test="${empty tanks}">
        <div class="alert alert-info">
          <i class="fa fa-info-circle"></i>
          No tanks configured. Run 02_seed_data.sql to initialise.
        </div>
      </c:if>
    </div>

    <!-- RIGHT: Refill Entry Form -->
    <div class="col-md-7">
      <div class="ims-section-title">
        <i class="fa fa-plus-circle"></i> Log New Tanker Refill
      </div>
      <div class="panel panel-default ims-panel">
        <div class="panel-heading ims-panel-heading">
          <i class="fa fa-truck"></i> Tanker Refill Entry
          <small class="pull-right text-muted">
            Tank level will update immediately on save
          </small>
        </div>
        <div class="panel-body">
          <form action="<%=request.getContextPath()%>/TankRefillServlet"
                method="post" id="refillForm">

            <div class="row">
              <!-- Tank selection -->
              <div class="col-sm-6">
                <div class="form-group">
                  <label>Select Tank <span class="text-danger">*</span></label>
                  <select name="tankId" class="form-control ims-select"
                          id="refillTankId" required
                          onchange="showTankSpace(this)">
                    <option value="">-- Select Tank to Refill --</option>
                    <c:forEach var="t" items="${tanks}">
                      <option value="${t.tankId}"
                              data-capacity="${t.capacity}"
                              data-level="${t.currentLevel}"
                              data-name="${t.tankName}"
                              data-fuel="${t.fuelType}">
                        ${t.tankName} — ${t.fuelType}
                        (${t.currentLevel}L / ${t.capacity}L)
                      </option>
                    </c:forEach>
                  </select>
                  <div id="tankSpaceInfo" class="ims-tank-inline-info"
                       style="display:none;margin-top:6px"></div>
                </div>
              </div>

              <!-- Quantity -->
              <div class="col-sm-6">
                <div class="form-group">
                  <label>Quantity Filled (Litres) <span class="text-danger">*</span></label>
                  <input type="number" name="refillQty" id="refillQty"
                         class="form-control ims-input"
                         placeholder="Enter litres filled"
                         min="1" step="0.5" required
                         oninput="validateRefillQty()">
                  <div id="qtyWarn" class="ims-warn-msg" style="display:none">
                    <i class="fa fa-exclamation-triangle"></i>
                    Quantity exceeds available tank space!
                  </div>
                </div>
              </div>
            </div>

            <div class="row">
              <!-- Refill Date -->
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Refill Date <span class="text-danger">*</span></label>
                  <input type="date" name="refillDate" id="refillDate"
                         class="form-control ims-input" required>
                </div>
              </div>

              <!-- Supplier -->
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Supplier Name</label>
                  <input type="text" name="supplier"
                         class="form-control ims-input"
                         placeholder="e.g. HPCL, BPCL, IOC">
                </div>
              </div>

              <!-- Challan No -->
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Challan / Invoice No.</label>
                  <input type="text" name="challanNo"
                         class="form-control ims-input"
                         placeholder="Delivery challan number">
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-sm-12">
                <div class="form-group">
                  <label>Remarks</label>
                  <input type="text" name="remarks"
                         class="form-control ims-input"
                         placeholder="Any remarks about this refill">
                </div>
              </div>
            </div>

            <div class="ims-form-actions">
              <button type="submit" class="btn ims-btn-success">
                <i class="fa fa-plus"></i> Log Refill &amp; Update Tank
              </button>
              <button type="reset" class="btn btn-default"
                      onclick="$('#tankSpaceInfo').hide()">
                <i class="fa fa-times"></i> Clear
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Recent Refill History -->
      <div class="ims-section-title" style="margin-top:20px">
        <i class="fa fa-history"></i> Recent Refill History
        <c:if test="${not empty refills}">
          <button type="button" class="btn btn-xs ims-btn-secondary pull-right" style="margin-top:-2px" onclick="downloadRefillPDF()">
            <i class="fa fa-file-pdf-o"></i> Download PDF
          </button>
        </c:if>
      </div>
      <div class="panel panel-default ims-panel">
        <div class="table-responsive" style="max-height:340px;overflow-y:auto;">
          <table class="table table-hover ims-table" id="refillHistoryTable">
            <thead style="position:sticky;top:0;z-index:2;background:var(--card);">
              <tr>
                <th>Date</th>
                <th>Tank</th>
                <th>Fuel</th>
                <th>Qty Filled (L)</th>
                <th>Before (L)</th>
                <th>After (L)</th>
                <th>Supplier</th>
                <th>Challan</th>
                <th>Entered By</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty refills}">
                  <c:forEach var="r" items="${refills}">
                  <tr>
                    <td class="ims-mono">
                      <fmt:formatDate value="${r.refillDate}" pattern="dd-MMM-yyyy"/>
                    </td>
                    <td><strong>${r.tankName}</strong></td>
                    <td>
                      <span class="label ${r.fuelType eq 'DIESEL' ?
                        'label-primary' : 'label-danger'}">${r.fuelType}</span>
                    </td>
                    <td class="ims-mono ims-green">
                      <strong>+<fmt:formatNumber value="${r.refillQty}" pattern="#,##0.#"/></strong>
                    </td>
                    <td class="ims-mono">
                      <fmt:formatNumber value="${r.levelBefore}" pattern="#,##0"/>
                    </td>
                    <td class="ims-mono">
                      <fmt:formatNumber value="${r.levelAfter}"  pattern="#,##0"/>
                    </td>
                    <td>${not empty r.supplier ? r.supplier : '&mdash;'}</td>
                    <td class="ims-mono">
                      ${not empty r.challanNo ? r.challanNo : '&mdash;'}
                    </td>
                    <td>${not empty r.enteredByName ? r.enteredByName : '&mdash;'}</td>
                  </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="9" class="text-center ims-no-data">
                      <i class="fa fa-history fa-2x"></i><br>
                      No refill records yet. Log your first refill above.
                    </td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div><!-- /row -->
</div>

<script>
var IMS_CTX = '<%=request.getContextPath()%>';
var _refillSpace = 0;

$(document).ready(function(){
  var now = new Date();
  $('#refillDate').val(now.toISOString().split('T')[0]);
});

function showTankSpace(sel) {
  var opt = sel.options[sel.selectedIndex];
  var capacity = parseFloat(opt.getAttribute('data-capacity')) || 0;
  var level    = parseFloat(opt.getAttribute('data-level'))    || 0;
  var name     = opt.getAttribute('data-name')  || '';
  var fuel     = opt.getAttribute('data-fuel')  || '';
  _refillSpace = capacity - level;

  if (sel.value) {
    $('#tankSpaceInfo').html(
      '<i class="fa fa-info-circle"></i> ' +
      '<strong>' + name + '</strong> &mdash; ' +
      '<span class="label ' + (fuel==='DIESEL'?'label-primary':'label-danger') +
      '">' + fuel + '</span> &mdash; ' +
      'Current: <strong>' + level.toLocaleString() + ' L</strong> &mdash; ' +
      'Available space: <strong style="color:#00d68f">' +
      _refillSpace.toLocaleString() + ' L</strong>'
    ).show();
  } else {
    $('#tankSpaceInfo').hide();
    _refillSpace = 0;
  }
  validateRefillQty();
}

function validateRefillQty() {
  var qty = parseFloat($('#refillQty').val()) || 0;
  if (_refillSpace > 0 && qty > _refillSpace) {
    $('#qtyWarn').show();
  } else {
    $('#qtyWarn').hide();
  }
}

function downloadRefillPDF() {
  var tbl = document.getElementById('refillHistoryTable');
  if (!tbl) return;
  var win = window.open('', '_blank');
  win.document.write('<!DOCTYPE html><html><head>');
  win.document.write('<title>Tank Refill History — IMS Fuel Master Pro</title>');
  win.document.write('<style>');
  win.document.write('body{font-family:Arial,sans-serif;font-size:12px;color:#111;margin:24px}');
  win.document.write('h2{font-size:16px;margin-bottom:4px;color:#003366}');
  win.document.write('.sub{font-size:11px;color:#666;margin-bottom:16px}');
  win.document.write('table{width:100%;border-collapse:collapse}');
  win.document.write('th{background:#003366;color:#fff;padding:7px 8px;text-align:left;font-size:11px}');
  win.document.write('td{padding:6px 8px;border-bottom:1px solid #ddd;font-size:11px}');
  win.document.write('tr:nth-child(even) td{background:#f5f8ff}');
  win.document.write('.badge-d{background:#337ab7;color:#fff;padding:2px 6px;border-radius:3px}');
  win.document.write('.badge-p{background:#d9534f;color:#fff;padding:2px 6px;border-radius:3px}');
  win.document.write('.green{color:#007700;font-weight:bold}');
  win.document.write('@media print{body{margin:0}}');
  win.document.write('</style></head><body>');
  win.document.write('<h2><img src="' + window.location.origin + '<%=request.getContextPath()%>/images/BARC-Logo.png" height="36" style="vertical-align:middle;margin-right:10px">IMS Fuel Master Pro — Tank Refill History</h2>');
  win.document.write('<div class="sub">Bhabha Atomic Research Centre, Trombay, Mumbai 400085 &nbsp;|&nbsp; Generated: ' + new Date().toLocaleString('en-IN') + '</div>');

  // Clone table into plain HTML
  var rows = tbl.querySelectorAll('tr');
  win.document.write('<table><thead>');
  // Header row
  var headers = tbl.querySelectorAll('thead th');
  win.document.write('<tr>');
  headers.forEach(function(th){ win.document.write('<th>' + th.innerText + '</th>'); });
  win.document.write('</tr></thead><tbody>');
  // Data rows
  var bodyRows = tbl.querySelectorAll('tbody tr');
  bodyRows.forEach(function(tr){
    win.document.write('<tr>');
    tr.querySelectorAll('td').forEach(function(td, idx){
      var txt = td.innerText.trim();
      if (idx === 2) { // fuel type column
        var cls = txt==='DIESEL'?'badge-d':'badge-p';
        win.document.write('<td><span class="' + cls + '">' + txt + '</span></td>');
      } else if (idx === 3) {
        win.document.write('<td class="green">' + txt + '</td>');
      } else {
        win.document.write('<td>' + txt + '</td>');
      }
    });
    win.document.write('</tr>');
  });
  win.document.write('</tbody></table>');
  win.document.write('<script>window.onload=function(){window.print();}<\/script>');
  win.document.write('</body></html>');
  win.document.close();
}
</script>
<%@ include file="footer.jsp" %>
