<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt"%>
<%
  if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
  }
  pageContext.setAttribute("activePage",    "units_master");
  pageContext.setAttribute("masterSection", "vehicle");
  pageContext.setAttribute("pageTitle",     "Vehicle Master");
%>
<%@ include file="header.jsp" %>

<div class="container-fluid ims-main-content">
  <div class="ims-page-header">
    <h2><i class="fa fa-car"></i> Vehicle Master</h2>
    <span class="ims-badge-tag">Other DAE Units</span>
  </div>

  <ul class="nav nav-tabs ims-form-tabs" style="margin-bottom:20px">
    <li><a href="<%=request.getContextPath()%>/pages/units_master.jsp"><i class="fa fa-building"></i> Unit Master</a></li>
    <li class="active"><a href="<%=request.getContextPath()%>/MasterServlet?section=vehicle"><i class="fa fa-car"></i> Vehicle Master</a></li>
    <li><a href="<%=request.getContextPath()%>/MasterServlet?section=driver"><i class="fa fa-id-card"></i> Driver Master</a></li>
    <li><a href="<%=request.getContextPath()%>/TankRefillServlet"><i class="fa fa-tint"></i> Tank Master</a></li>
  </ul>

  <div class="ims-filter-bar" style="margin-bottom:16px">
    <form method="get" action="<%=request.getContextPath()%>/MasterServlet" class="form-inline">
      <input type="hidden" name="section" value="vehicle">
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
      <a href="<%=request.getContextPath()%>/MasterServlet?section=vehicle" class="btn btn-default btn-sm">
        <i class="fa fa-times"></i> Clear Filter
      </a>
    </form>
  </div>

  <!-- Vehicle Form Panel — above list -->
  <div id="vehicleFormPanel" style="display:${editVehicle != null ? 'block' : 'none'}">
    <div class="panel panel-default ims-panel">
      <div class="panel-heading ims-panel-heading" style="display:flex;justify-content:space-between;align-items:center">
        <span>
          <i class="fa fa-${editVehicle != null ? 'pencil':'plus-circle'}"></i>
          <c:choose>
            <c:when test="${editVehicle != null}">Edit Vehicle &mdash; <strong>${editVehicle.vehicleNo}</strong></c:when>
            <c:otherwise>Add New Vehicle</c:otherwise>
          </c:choose>
        </span>
        <button type="button" class="btn btn-default btn-sm" onclick="hideVehicleForm()">
          <i class="fa fa-times"></i> Close
        </button>
      </div>
      <div class="panel-body">
        <form action="<%=request.getContextPath()%>/MasterServlet" method="post" id="vehicleForm">
          <input type="hidden" name="section"   value="vehicle">
          <input type="hidden" name="action"    value="save">
          <input type="hidden" name="vehicleId" value="${editVehicle != null ? editVehicle.vehicleId : ''}">
          <div class="ims-form-section-title">Unit / Organisation</div>
          <div class="row">
            <div class="col-sm-8">
              <div class="form-group">
                <label>Select Unit / Organisation <span class="text-danger">*</span></label>
                <select name="unitId" class="form-control ims-select" required>
                  <option value="">-- Select Unit --</option>
                  <c:forEach var="u" items="${units}">
                    <option value="${u.unitId}" ${editVehicle != null && editVehicle.unitId == u.unitId ? 'selected' : ''}>
                      ${u.orgName} (${u.unitCode})
                    </option>
                  </c:forEach>
                </select>
              </div>
            </div>
            <div class="col-sm-4">
              <div class="form-group">
                <label>Fuel Type <span class="text-danger">*</span></label>
                <select name="fuelType" class="form-control ims-select" required>
                  <option value="">-- Type --</option>
                  <option value="DIESEL"  ${editVehicle.fuelType eq 'DIESEL'  ? 'selected':''}>DIESEL</option>
                  <option value="PETROL"  ${editVehicle.fuelType eq 'PETROL'  ? 'selected':''}>PETROL</option>
                </select>
              </div>
            </div>
          </div>
          <div class="ims-form-section-title">Vehicle Details</div>
          <div class="row">
            <div class="col-sm-3">
              <div class="form-group">
                <label>Vehicle No. <span class="text-danger">*</span></label>
                <input type="text" name="vehicleNo" class="form-control ims-input"
                       placeholder="e.g. MH04GA1234" required style="text-transform:uppercase"
                       value="<c:out value='${editVehicle.vehicleNo}'/>">
              </div>
            </div>
            <div class="col-sm-3">
              <div class="form-group">
                <label>Vehicle Type <span class="text-danger">*</span></label>
                <select name="vehicleType" class="form-control ims-select" required>
                  <option value="">-- Type --</option>
                  <option value="Car"       ${editVehicle.vehicleType eq 'Car'       ? 'selected':''}>Car</option>
                  <option value="SUV"       ${editVehicle.vehicleType eq 'SUV'       ? 'selected':''}>SUV</option>
                  <option value="Truck"     ${editVehicle.vehicleType eq 'Truck'     ? 'selected':''}>Truck</option>
                  <option value="Bus"       ${editVehicle.vehicleType eq 'Bus'       ? 'selected':''}>Bus</option>
                  <option value="Mini Bus"  ${editVehicle.vehicleType eq 'Mini Bus'  ? 'selected':''}>Mini Bus</option>
                  <option value="Pickup"    ${editVehicle.vehicleType eq 'Pickup'    ? 'selected':''}>Pickup</option>
                  <option value="Tractor"   ${editVehicle.vehicleType eq 'Tractor'   ? 'selected':''}>Tractor</option>
                  <option value="Generator" ${editVehicle.vehicleType eq 'Generator' ? 'selected':''}>Generator</option>
                  <option value="Other"     ${editVehicle.vehicleType eq 'Other'     ? 'selected':''}>Other</option>
                </select>
              </div>
            </div>
            <div class="col-sm-3">
              <div class="form-group">
                <label>Make</label>
                <input type="text" name="make" class="form-control ims-input"
                       placeholder="e.g. Tata" value="<c:out value='${editVehicle.make}'/>">
              </div>
            </div>
            <div class="col-sm-3">
              <div class="form-group">
                <label>Model</label>
                <input type="text" name="model" class="form-control ims-input"
                       placeholder="e.g. Innova" value="<c:out value='${editVehicle.model}'/>">
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col-sm-4">
              <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control ims-select">
                  <option value="Active"   ${editVehicle.status eq 'Active'   ? 'selected':''}>Active</option>
                  <option value="Inactive" ${editVehicle.status eq 'Inactive' ? 'selected':''}>Inactive</option>
                  <option value="Scrapped" ${editVehicle.status eq 'Scrapped' ? 'selected':''}>Scrapped</option>
                </select>
              </div>
            </div>
            <div class="col-sm-8">
              <div class="form-group">
                <label>Notes</label>
                <input type="text" name="notes" class="form-control ims-input"
                       placeholder="Optional notes" value="<c:out value='${editVehicle.notes}'/>">
              </div>
            </div>
          </div>
          <div class="ims-form-actions">
            <button type="submit" class="btn ims-btn-success"><i class="fa fa-save"></i> Save Vehicle</button>
            <button type="button" class="btn btn-default" onclick="hideVehicleForm()"><i class="fa fa-times"></i> Cancel</button>
            <c:if test="${editVehicle != null}">
              <button type="button" class="btn ims-btn-danger"
                      onclick="deleteRecord(${editVehicle.vehicleId},'${editVehicle.vehicleNo}')">
                <i class="fa fa-trash"></i> Delete
              </button>
            </c:if>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Full-width vehicle list -->
  <div class="panel panel-default ims-panel">
    <div class="panel-heading ims-panel-heading" style="display:flex;justify-content:space-between;align-items:center">
      <span><i class="fa fa-list"></i> Registered Vehicles <span class="badge" style="margin-left:6px">${vehicles.size()}</span></span>
      <button class="btn ims-btn-success btn-sm" onclick="showVehicleForm(null)">
        <i class="fa fa-plus"></i> Add New Vehicle
      </button>
    </div>
    <div class="panel-body" style="padding:0">
      <div style="padding:10px 14px 0">
        <div class="input-group input-group-sm" style="max-width:320px">
          <span class="input-group-addon"><i class="fa fa-search"></i></span>
          <input type="text" class="form-control" placeholder="Search vehicle no, unit, make..."
                 oninput="filterVehicleList(this.value)">
        </div>
      </div>
      <div class="table-responsive">
        <table class="table table-hover ims-table" style="margin-bottom:0">
          <thead>
            <tr>
              <th>#</th><th>Vehicle No.</th><th>Organisation</th>
              <th>Type</th><th>Make / Model</th><th>Fuel</th><th>Status</th><th>Action</th>
            </tr>
          </thead>
          <tbody id="vehicleListContainer">
            <c:forEach var="v" items="${vehicles}" varStatus="st">
            <tr class="ims-master-row ${editVehicle != null && editVehicle.vehicleId == v.vehicleId ? 'ims-master-item-active' : ''}"
                data-search="${v.vehicleNo} ${v.orgName} ${v.make} ${v.model}">
              <td class="ims-mono">${st.count}</td>
              <td><strong class="ims-mono" style="color:#3b9eff">${v.vehicleNo}</strong></td>
              <td>${v.orgName}</td>
              <td>${v.vehicleType}</td>
              <td>${v.make} ${v.model}</td>
              <td><span class="label ${v.fuelType eq 'DIESEL' ? 'label-primary':'label-danger'}">${v.fuelType}</span></td>
              <td><span class="label ${v.status eq 'Active' ? 'label-success':'label-default'}">${v.status}</span></td>
              <td>
                <button class="btn btn-default btn-xs" onclick="showVehicleForm(${v.vehicleId})" title="Edit">
                  <i class="fa fa-pencil"></i>
                </button>
              </td>
            </tr>
            </c:forEach>
            <c:if test="${empty vehicles}">
            <tr><td colspan="8" class="text-center text-muted" style="padding:24px">
              <i class="fa fa-car fa-2x"></i><br>No vehicles registered yet.
            </td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>
  </div>


      </div>
    </div>
  </div>

<div class="modal fade" id="deleteModal" tabindex="-1">
  <div class="modal-dialog modal-sm">
    <div class="modal-content ims-modal">
      <div class="modal-header ims-modal-header-danger">
        <h4 class="modal-title"><i class="fa fa-trash"></i> Confirm Scrap</h4>
      </div>
      <div class="modal-body">
        <p>Mark vehicle <strong id="delName"></strong> as Scrapped?</p>
        <p class="text-muted"><small>Fuel history will be retained.</small></p>
      </div>
      <div class="modal-footer">
        <form action="<%=request.getContextPath()%>/MasterServlet" method="post">
          <input type="hidden" name="section"   value="vehicle">
          <input type="hidden" name="action"    value="delete">
          <input type="hidden" name="vehicleId" id="delId">
          <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
          <button type="submit" class="btn ims-btn-danger"><i class="fa fa-trash"></i> Mark Scrapped</button>
        </form>
      </div>
    </div>
  </div>
</div>

<script>
function filterVehicleList(q) {
  q = q.toLowerCase();
  document.querySelectorAll('#vehicleListContainer tr.ims-master-row').forEach(function(el) {
    el.style.display = (el.getAttribute('data-search') || '').toLowerCase().indexOf(q) >= 0 ? '' : 'none';
  });
}
function showVehicleForm(vehicleId) {
  if (vehicleId) {
    window.location = '<%=request.getContextPath()%>/MasterServlet?section=vehicle&editId=' + vehicleId;
  } else {
    document.getElementById('vehicleFormPanel').style.display = 'block';
    document.getElementById('vehicleFormPanel').scrollIntoView({behavior:'smooth',block:'start'});
    document.getElementById('vehicleForm').reset();
    document.querySelector('[name="vehicleId"]').value = '';
  }
}
function hideVehicleForm() {
  document.getElementById('vehicleFormPanel').style.display = 'none';
}
function deleteRecord(id, name) {
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
  var wrapperId = tableBodyId + '_pgn';

  function renderPage(p) {
    rows.forEach(function(r, i) {
      r.style.display = (i >= (p-1)*pageSize && i < p*pageSize) ? '' : 'none';
    });
    var ctrl = document.getElementById(wrapperId);
    if (!ctrl) return;
    var total2 = rows.length;
    var btns = '<nav style="margin:6px 12px 4px;display:flex;align-items:center;gap:6px;flex-wrap:wrap">' +
      '<small style="color:var(--txt3,#4a6080);font-size:11px;margin-right:4px">' +
      'Showing ' + Math.min((p-1)*pageSize+1,total2) + '\u2013' + Math.min(p*pageSize,total2) + ' of ' + total2 + '</small>';
    for (var i = 1; i <= totalPages; i++) {
      var active = (i===p) ? 'ims-btn-primary' : 'btn-default';
      btns += '<button class="btn btn-xs ' + active + '" onclick="gotoPage(\''+tableBodyId+'\','+i+','+pageSize+')">' + i + '</button>';
    }
    btns += '</nav>';
    ctrl.innerHTML = btns;
  }

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
  window['_pgn_' + tableBodyId] = { rows: rows, pageSize: pageSize, totalPages: totalPages, current: 1 };
}

function gotoPage(tableBodyId, p, pageSize) {
  var state = window['_pgn_' + tableBodyId];
  if (!state) return;
  var rows = state.rows;
  rows.forEach(function(r, i) {
    r.style.display = (i >= (p-1)*pageSize && i < p*pageSize) ? '' : 'none';
  });
  var ctrl = document.getElementById(tableBodyId + '_pgn');
  if (!ctrl) return;
  ctrl.querySelectorAll('button').forEach(function(b, i) {
    b.className = 'btn btn-xs ' + ((i+1)===p ? 'ims-btn-primary' : 'btn-default');
  });
  var small = ctrl.querySelector('small');
  var total = rows.length;
  if (small) small.textContent = 'Showing ' + Math.min((p-1)*pageSize+1,total) + String.fromCharCode(8211) + Math.min(p*pageSize,total) + ' of ' + total;
}

document.addEventListener('DOMContentLoaded', function() {
  initPagination('vehicleListContainer', 10);
  <c:if test="${editVehicle != null}">
  document.getElementById('vehicleFormPanel').scrollIntoView({behavior:'smooth',block:'start'});
  </c:if>
});
</script>
<%@ include file="footer.jsp" %>
