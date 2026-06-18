<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt"%>
<%
  if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
  }
  pageContext.setAttribute("activePage",    "units_master");
  pageContext.setAttribute("masterSection", "driver");
  pageContext.setAttribute("pageTitle",     "Driver Master");
%>
<%@ include file="header.jsp" %>

<div class="container-fluid ims-main-content">
  <div class="ims-page-header">
    <h2><i class="fa fa-id-card"></i> Driver Master</h2>
    <span class="ims-badge-tag">Other DAE Units</span>
  </div>

  <ul class="nav nav-tabs ims-form-tabs" style="margin-bottom:20px">
    <li><a href="<%=request.getContextPath()%>/pages/units_master.jsp"><i class="fa fa-building"></i> Unit Master</a></li>
    <li><a href="<%=request.getContextPath()%>/MasterServlet?section=vehicle"><i class="fa fa-car"></i> Vehicle Master</a></li>
    <li class="active"><a href="<%=request.getContextPath()%>/MasterServlet?section=driver"><i class="fa fa-id-card"></i> Driver Master</a></li>
    <li><a href="<%=request.getContextPath()%>/TankRefillServlet"><i class="fa fa-tint"></i> Tank Master</a></li>
  </ul>

  <div class="ims-filter-bar" style="margin-bottom:16px">
    <form method="get" action="<%=request.getContextPath()%>/MasterServlet" class="form-inline">
      <input type="hidden" name="section" value="driver">
      <div class="form-group">
        <label><i class="fa fa-filter"></i> Filter by Unit &nbsp;</label>
        <select name="filterUnit" class="form-control ims-select-sm" onchange="this.form.submit()">
          <option value="">All Units</option>
          <c:forEach var="u" items="${units}">
            <option value="${u.unitId}" ${filterUnit == u.unitId ? 'selected':''}>${u.orgName} (${u.unitCode})</option>
          </c:forEach>
        </select>
      </div>
      &nbsp;
      <a href="<%=request.getContextPath()%>/MasterServlet?section=driver" class="btn btn-default btn-sm">
        <i class="fa fa-times"></i> Clear
      </a>
    </form>
  </div>

  <!-- Driver Form Panel — shown above list on Add/Edit -->
  <div id="driverFormPanel" style="display:${editDriver != null ? 'block' : 'none'}">
    <div class="panel panel-default ims-panel">
      <div class="panel-heading ims-panel-heading" style="display:flex;justify-content:space-between;align-items:center">
        <span>
          <i class="fa fa-${editDriver != null ? 'pencil':'plus-circle'}"></i>
          <c:choose>
            <c:when test="${editDriver != null}">Edit Driver &mdash; <strong>${editDriver.driverName}</strong></c:when>
            <c:otherwise>Add New Driver</c:otherwise>
          </c:choose>
        </span>
        <button type="button" class="btn btn-default btn-sm" onclick="hideDriverForm()">
          <i class="fa fa-times"></i> Close
        </button>
      </div>
      <div class="panel-body">
        <form action="<%=request.getContextPath()%>/MasterServlet" method="post" id="driverForm">
          <input type="hidden" name="section"  value="driver">
          <input type="hidden" name="action"   value="save">
          <input type="hidden" name="driverId" value="${editDriver != null ? editDriver.driverId : ''}">
          <div class="row">
            <div class="col-sm-6">
              <div class="form-group">
                <label>Select Unit / Organisation <span class="text-danger">*</span></label>
                <select name="unitId" class="form-control ims-select" required>
                  <option value="">-- Select Unit --</option>
                  <c:forEach var="u" items="${units}">
                    <option value="${u.unitId}" ${editDriver != null && editDriver.unitId == u.unitId ? 'selected' : ''}>
                      ${u.orgName} (${u.unitCode})
                    </option>
                  </c:forEach>
                </select>
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>Driver Name <span class="text-danger">*</span></label>
                <input type="text" name="driverName" class="form-control ims-input"
                       placeholder="Full name" required
                       value="<c:out value='${editDriver.driverName}'/>">
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col-sm-4">
              <div class="form-group">
                <label>Emp No / CC No</label>
                <input type="text" name="employeeNo" class="form-control ims-input"
                       placeholder="Employee / CC number"
                       value="<c:out value='${editDriver.employeeNo}'/>">
              </div>
            </div>
            <div class="col-sm-4">
              <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control ims-select">
                  <option value="Active"    ${editDriver.status eq 'Active'    ? 'selected':''}>Active</option>
                  <option value="Inactive"  ${editDriver.status eq 'Inactive'  ? 'selected':''}>Inactive</option>
                  <option value="Suspended" ${editDriver.status eq 'Suspended' ? 'selected':''}>Suspended</option>
                </select>
              </div>
            </div>
            <div class="col-sm-4">
              <div class="form-group">
                <label>Notes</label>
                <input type="text" name="notes" class="form-control ims-input"
                       placeholder="Optional notes"
                       value="<c:out value='${editDriver.notes}'/>">
              </div>
            </div>
          </div>
          <div class="ims-form-actions">
            <button type="submit" class="btn ims-btn-success"><i class="fa fa-save"></i> Save Driver</button>
            <button type="button" class="btn btn-default" onclick="hideDriverForm()"><i class="fa fa-times"></i> Cancel</button>
            <c:if test="${editDriver != null}">
              <button type="button" class="btn ims-btn-danger"
                      onclick="deleteDriver(${editDriver.driverId},'${editDriver.driverName}')">
                <i class="fa fa-user-times"></i> Deactivate
              </button>
            </c:if>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Full-width list -->
  <div class="panel panel-default ims-panel">
    <div class="panel-heading ims-panel-heading" style="display:flex;justify-content:space-between;align-items:center">
      <span><i class="fa fa-list"></i> Registered Drivers <span class="badge" style="margin-left:6px">${drivers.size()}</span></span>
      <button class="btn ims-btn-success btn-sm" onclick="showDriverForm(null)">
        <i class="fa fa-plus"></i> Add New Driver
      </button>
    </div>
    <div class="panel-body" style="padding:0">
      <div class="ims-master-search" style="padding:10px 14px 0">
        <div class="input-group input-group-sm" style="max-width:320px">
          <span class="input-group-addon"><i class="fa fa-search"></i></span>
          <input type="text" class="form-control" placeholder="Search driver name or emp no..."
                 oninput="filterDriverList(this.value)">
        </div>
      </div>
      <div class="table-responsive">
        <table class="table table-hover ims-table" style="margin-bottom:0">
          <thead>
            <tr>
              <th>#</th><th>Driver Name</th><th>Organisation</th>
              <th>Emp No / CC No</th><th>Status</th><th>Action</th>
            </tr>
          </thead>
          <tbody id="driverListContainer">
            <c:forEach var="d" items="${drivers}" varStatus="st">
            <tr class="ims-master-row ${editDriver != null && editDriver.driverId == d.driverId ? 'ims-master-item-active' : ''}"
                data-search="${d.driverName} ${d.orgName} ${d.employeeNo}">
              <td class="ims-mono">${st.count}</td>
              <td><strong><i class="fa fa-user" style="color:#3b9eff;margin-right:5px"></i>${d.driverName}</strong></td>
              <td>${d.orgName}</td>
              <td class="ims-mono">${not empty d.employeeNo ? d.employeeNo : '&mdash;'}</td>
              <td><span class="label ${d.status eq 'Active' ? 'label-success' : 'label-default'}">${d.status}</span></td>
              <td>
                <button class="btn btn-default btn-xs" onclick="showDriverForm(${d.driverId})" title="Edit">
                  <i class="fa fa-pencil"></i>
                </button>
              </td>
            </tr>
            </c:forEach>
            <c:if test="${empty drivers}">
            <tr><td colspan="6" class="text-center text-muted" style="padding:24px">
              <i class="fa fa-id-card fa-2x"></i><br>No drivers registered yet.
            </td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>
  </div>


</div>

<div class="modal fade" id="deleteModal" tabindex="-1">
  <div class="modal-dialog modal-sm">
    <div class="modal-content ims-modal">
      <div class="modal-header ims-modal-header-danger">
        <h4 class="modal-title"><i class="fa fa-user-times"></i> Deactivate Driver</h4>
      </div>
      <div class="modal-body">
        <p>Deactivate driver <strong id="delName"></strong>?</p>
        <p class="text-muted"><small>Driver set to Inactive. Fuel history retained.</small></p>
      </div>
      <div class="modal-footer">
        <form action="<%=request.getContextPath()%>/MasterServlet" method="post">
          <input type="hidden" name="section"  value="driver">
          <input type="hidden" name="action"   value="delete">
          <input type="hidden" name="driverId" id="delId">
          <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
          <button type="submit" class="btn ims-btn-danger"><i class="fa fa-user-times"></i> Deactivate</button>
        </form>
      </div>
    </div>
  </div>
</div>

<script>
function filterDriverList(q) {
  q = q.toLowerCase();
  document.querySelectorAll('#driverListContainer tr.ims-master-row').forEach(function(el) {
    el.style.display = (el.getAttribute('data-search') || '').toLowerCase().indexOf(q) >= 0 ? '' : 'none';
  });
}
function showDriverForm(driverId) {
  if (driverId) {
    window.location = '<%=request.getContextPath()%>/MasterServlet?section=driver&editId=' + driverId;
  } else {
    // Show blank form
    document.getElementById('driverFormPanel').style.display = 'block';
    document.getElementById('driverFormPanel').scrollIntoView({behavior:'smooth',block:'start'});
    // Clear form fields for new entry
    document.getElementById('driverForm').reset();
    document.querySelector('[name="driverId"]').value = '';
  }
}
function hideDriverForm() {
  document.getElementById('driverFormPanel').style.display = 'none';
}
function deleteDriver(id, name) {
  document.getElementById('delId').value = id;
  document.getElementById('delName').textContent = name;
  $('#deleteModal').modal('show');
}

function initPagination(tableBodyId, pageSize) {
  pageSize = pageSize || 10;
  var rows = document.querySelectorAll('#' + tableBodyId + ' tr.ims-master-row');
  var total = rows.length;
  if (total === 0) return;
  var totalPages = Math.ceil(total / pageSize);
  var current = 1;
  var wrapperId = tableBodyId + '_pgn';

  function renderPage(p) {
    current = p;
    rows.forEach(function(r, i) {
      r.style.display = (i >= (p-1)*pageSize && i < p*pageSize) ? '' : 'none';
    });
    var ctrl = document.getElementById(wrapperId);
    if (!ctrl) return;
    var btns = '<nav style="margin:6px 12px 4px;display:flex;align-items:center;gap:6px;flex-wrap:wrap">' +
      '<small style="color:var(--txt3,#4a6080);font-size:11px;margin-right:4px">' +
      'Showing ' + Math.min((p-1)*pageSize+1, total) + '–' + Math.min(p*pageSize, total) + ' of ' + total +
      '</small>';
    for (var i = 1; i <= totalPages; i++) {
      var active = i===current ? 'ims-btn-primary' : 'btn-default';
      btns += '<button class="btn btn-xs ' + active + '" onclick="gotoPage(\''+tableBodyId+'\','+i+','+pageSize+')">' + i + '</button>';
    }
    btns += '</nav>';
    ctrl.innerHTML = btns;
  }

  // Insert pagination control after table wrapper
  var tbl = document.getElementById(tableBodyId);
  if (tbl) {
    var wrapper = tbl.closest('.table-responsive') || tbl.closest('.panel-body');
    if (wrapper) {
      var pgn = document.createElement('div');
      pgn.id = wrapperId;
      wrapper.parentNode.insertBefore(pgn, wrapper.nextSibling);
    }
  }
  renderPage(1);
  // store for gotoPage
  window['_pgn_' + tableBodyId] = { rows: rows, pageSize: pageSize, totalPages: totalPages };
}

function gotoPage(tableBodyId, p, pageSize) {
  var state = window['_pgn_' + tableBodyId];
  if (!state) return;
  var rows = state.rows;
  rows.forEach(function(r, i) {
    r.style.display = (i >= (p-1)*pageSize && i < p*pageSize) ? '' : 'none';
  });
  // update button states
  var ctrl = document.getElementById(tableBodyId + '_pgn');
  if (!ctrl) return;
  var btns = ctrl.querySelectorAll('button');
  btns.forEach(function(b, i) {
    var pageNum = i + 1;
    b.className = 'btn btn-xs ' + (pageNum===p ? 'ims-btn-primary' : 'btn-default');
  });
  // update showing text
  var total = rows.length;
  var small = ctrl.querySelector('small');
  if (small) small.textContent = 'Showing ' + Math.min((p-1)*pageSize+1,total) + '–' + Math.min(p*pageSize,total) + ' of ' + total;
}

document.addEventListener('DOMContentLoaded', function() {
  initPagination('driverListContainer', 10);
  <c:if test="${editDriver != null}">
  document.getElementById('driverFormPanel').scrollIntoView({behavior:'smooth',block:'start'});
  </c:if>
});
</script>
<%@ include file="footer.jsp" %>
