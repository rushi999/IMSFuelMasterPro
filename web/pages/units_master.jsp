<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
  if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
  }
  com.barc.ims.dao.UnitMasterDAO dao = new com.barc.ims.dao.UnitMasterDAO();
  java.util.List units = new java.util.ArrayList();
  try { units = dao.getAll(); } catch (Exception ex) {}
  pageContext.setAttribute("units", units);
  pageContext.setAttribute("activePage",    "units_master");
  pageContext.setAttribute("masterSection", "unit");
  pageContext.setAttribute("pageTitle",     "Units Master");

  com.barc.ims.model.UnitMaster editUnit = null;
  String editIdStr = request.getParameter("editId");
  if (editIdStr != null && !editIdStr.isEmpty()) {
    try { editUnit = dao.getById(Integer.parseInt(editIdStr)); } catch (Exception ex) {}
  }
  pageContext.setAttribute("editUnit", editUnit);
  boolean showUnitForm = (editUnit != null) || "1".equals(request.getParameter("showForm"));
  pageContext.setAttribute("showUnitForm", showUnitForm);
%>
<%@ include file="header.jsp" %>

<div class="container-fluid ims-main-content">
  <div class="ims-page-header">
    <h2><i class="fa fa-database"></i> Masters Module</h2>
    <span class="ims-badge-tag">Master Data</span>
  </div>

  <!-- Master navigation sub-tabs -->
  <ul class="nav nav-tabs ims-form-tabs" style="margin-bottom:20px">
    <li class="active">
      <a href="<%=request.getContextPath()%>/pages/units_master.jsp">
        <i class="fa fa-building"></i> Unit Master
      </a>
    </li>
    <li>
      <a href="<%=request.getContextPath()%>/MasterServlet?section=vehicle">
        <i class="fa fa-car"></i> Vehicle Master
      </a>
    </li>
    <li>
      <a href="<%=request.getContextPath()%>/MasterServlet?section=driver">
        <i class="fa fa-id-card"></i> Driver Master
      </a>
    </li>
    <li>
      <a href="<%=request.getContextPath()%>/TankRefillServlet">
        <i class="fa fa-tint"></i> Tank Master
      </a>
    </li>
  </ul>

  <!-- ═══ FORM PANEL — shown ABOVE table, hidden by default ═══ -->
  <div id="unitFormPanel" style="display:${showUnitForm ? 'block' : 'none'}">
    <div class="panel panel-default ims-panel">
      <div class="panel-heading ims-panel-heading"
           style="display:flex;justify-content:space-between;align-items:center">
        <span>
          <i class="fa fa-${editUnit != null ? 'pencil':'plus-circle'}"></i>
          <c:choose>
            <c:when test="${editUnit != null}">
              Edit Unit &mdash; <strong>${editUnit.orgName}</strong>
            </c:when>
            <c:otherwise>Add New Unit</c:otherwise>
          </c:choose>
        </span>
        <button type="button" class="btn btn-default btn-sm" onclick="hideUnitForm()">
          <i class="fa fa-times"></i> Close
        </button>
      </div>
      <div class="panel-body">
        <form action="<%=request.getContextPath()%>/UnitMasterServlet"
              method="post" id="unitForm">
          <input type="hidden" name="action" value="save">
          <input type="hidden" name="unitId"
                 value="${editUnit != null ? editUnit.unitId : ''}">

          <div class="row">
            <div class="col-sm-6">
              <div class="form-group">
                <label>Organisation Name <span class="text-danger">*</span></label>
                <input type="text" name="orgName" class="form-control ims-input"
                       placeholder="Full organisation name" required
                       value="<c:out value='${editUnit.orgName}'/>">
              </div>
            </div>
            <div class="col-sm-3">
              <div class="form-group">
                <label>Unit Code</label>
                <input type="text" name="unitCode" class="form-control ims-input"
                       placeholder="e.g. IGCAR-01"
                       value="<c:out value='${editUnit.unitCode}'/>">
              </div>
            </div>
            <div class="col-sm-3">
              <div class="form-group">
                <label>Unit Type</label>
                <select name="unitType" class="form-control ims-select">
                  <option value="DAE Unit"
                    ${editUnit.unitType eq 'DAE Unit' ? 'selected':''}>DAE Unit</option>
                  <option value="BARC Department"
                    ${editUnit.unitType eq 'BARC Department' ? 'selected':''}>BARC Department</option>
                  <option value="External Agency"
                    ${editUnit.unitType eq 'External Agency' ? 'selected':''}>External Agency</option>
                  <option value="Other"
                    ${editUnit.unitType eq 'Other' ? 'selected':''}>Other</option>
                </select>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-sm-4">
              <div class="form-group">
                <label>Contact Person</label>
                <input type="text" name="contactPerson" class="form-control ims-input"
                       placeholder="Contact person name"
                       value="<c:out value='${editUnit.contactPerson}'/>">
              </div>
            </div>
            <div class="col-sm-4">
              <div class="form-group">
                <label>Designation</label>
                <input type="text" name="designation" class="form-control ims-input"
                       placeholder="Designation"
                       value="<c:out value='${editUnit.designation}'/>">
              </div>
            </div>
            <div class="col-sm-4">
              <div class="form-group">
                <label>Phone / Extension</label>
                <input type="text" name="phoneExt" class="form-control ims-input"
                       placeholder="Phone / ext"
                       value="<c:out value='${editUnit.phoneExt}'/>">
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-sm-3">
              <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control ims-select">
                  <option value="Active"
                    ${editUnit.status eq 'Active' ? 'selected':''}>Active</option>
                  <option value="Inactive"
                    ${editUnit.status eq 'Inactive' ? 'selected':''}>Inactive</option>
                  <option value="Suspended"
                    ${editUnit.status eq 'Suspended' ? 'selected':''}>Suspended</option>
                </select>
              </div>
            </div>
            <div class="col-sm-9">
              <div class="form-group">
                <label>Notes</label>
                <input type="text" name="notes" class="form-control ims-input"
                       placeholder="Additional notes"
                       value="<c:out value='${editUnit.notes}'/>">
              </div>
            </div>
          </div>

          <div class="ims-form-actions">
            <button type="submit" class="btn ims-btn-success">
              <i class="fa fa-save"></i> Save Unit
            </button>
            <button type="button" class="btn btn-default" onclick="hideUnitForm()">
              <i class="fa fa-times"></i> Cancel
            </button>
            <c:if test="${editUnit != null}">
              <button type="button" class="btn ims-btn-danger"
                      onclick="deleteUnit(${editUnit.unitId},'${editUnit.orgName}')">
                <i class="fa fa-trash"></i> Delete
              </button>
            </c:if>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- ═══ FULL-WIDTH UNIT LIST TABLE ═══ -->
  <div class="panel panel-default ims-panel">
    <div class="panel-heading ims-panel-heading"
         style="display:flex;justify-content:space-between;align-items:center">
      <span>
        <i class="fa fa-list"></i> DAE Units / Organisations
        <span class="badge" style="margin-left:6px">${units.size()}</span>
      </span>
      <button class="btn ims-btn-success btn-sm" onclick="showUnitForm()">
        <i class="fa fa-plus"></i> Add New Unit
      </button>
    </div>
    <div class="panel-body" style="padding:0">
      <div style="padding:10px 14px 8px">
        <div class="input-group input-group-sm" style="max-width:320px">
          <span class="input-group-addon"><i class="fa fa-search"></i></span>
          <input type="text" id="unitSearch" class="form-control"
                 placeholder="Search unit name, code..."
                 oninput="filterUnitList(this.value)">
        </div>
      </div>
      <div class="table-responsive">
        <table class="table table-hover ims-table" style="margin-bottom:0">
          <thead>
            <tr>
              <th>#</th>
              <th>Organisation</th>
              <th>Unit Code</th>
              <th>Type</th>
              <th>Contact Person</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody id="unitListContainer">
            <c:forEach var="u" items="${units}" varStatus="st">
            <tr class="ims-master-row
                ${editUnit != null && editUnit.unitId == u.unitId ? 'ims-master-item-active' : ''}"
                data-search="${u.orgName} ${u.unitCode} ${u.unitType}">
              <td class="ims-mono">${st.count}</td>
              <td>
                <strong>${u.orgName}</strong>
                <span class="ims-master-code" style="color:var(--txt3)">&nbsp;(${u.unitCode})</span>
              </td>
              <td class="ims-mono">${u.unitCode}</td>
              <td>
                <span class="label label-default" style="font-size:10px">${u.unitType}</span>
              </td>
              <td>${not empty u.contactPerson ? u.contactPerson : '&mdash;'}</td>
              <td>
                <span class="label ${u.status eq 'Active' ? 'label-success' : 'label-default'}">
                  ${u.status}
                </span>
              </td>
              <td>
                <button class="btn btn-default btn-xs"
                        onclick="showUnitFormEdit(${u.unitId})" title="Edit">
                  <i class="fa fa-pencil"></i>
                </button>
              </td>
            </tr>
            </c:forEach>
            <c:if test="${empty units}">
            <tr>
              <td colspan="7" class="text-center text-muted" style="padding:28px">
                <i class="fa fa-inbox fa-2x"></i><br>No units registered yet.
              </td>
            </tr>
            </c:if>
          </tbody>
        </table>
      </div>
      <!-- Pagination injected here by JS -->
    </div>
  </div>

  <!-- Delete confirmation modal -->
  <div class="modal fade" id="deleteUnitModal" tabindex="-1">
    <div class="modal-dialog modal-sm">
      <div class="modal-content ims-modal">
        <div class="modal-header">
          <h4 class="modal-title"><i class="fa fa-exclamation-triangle text-danger"></i> Confirm Delete</h4>
        </div>
        <div class="modal-body">
          Delete unit <strong id="delUnitName"></strong>? This cannot be undone.
        </div>
        <div class="modal-footer">
          <form action="<%=request.getContextPath()%>/UnitMasterServlet" method="post">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="unitId" id="delUnitId">
            <button type="button" class="btn btn-default btn-sm"
                    data-dismiss="modal">Cancel</button>
            <button type="submit" class="btn ims-btn-danger btn-sm">
              <i class="fa fa-trash"></i> Delete
            </button>
          </form>
        </div>
      </div>
    </div>
  </div>

</div><!-- /container -->

<%@ include file="footer.jsp" %>

<script>
/* ══════════════════════════════════════════
   UNIT FORM TOGGLE — no page reload for Add
   ══════════════════════════════════════════ */
function showUnitForm() {
  var panel = document.getElementById('unitFormPanel');
  // Clear form for new entry
  var form = document.getElementById('unitForm');
  form.reset();
  form.querySelector('[name="unitId"]').value = '';
  // Update heading
  panel.querySelector('.panel-heading span i').className = 'fa fa-plus-circle';
  panel.querySelector('.panel-heading span').childNodes[1].textContent = ' Add New Unit';
  panel.style.display = 'block';
  panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function showUnitFormEdit(unitId) {
  // Navigate to edit page (loads unit data server-side)
  window.location = '<%=request.getContextPath()%>/pages/units_master.jsp?editId=' + unitId;
}

function hideUnitForm() {
  document.getElementById('unitFormPanel').style.display = 'none';
  // Remove editId from URL without reload if possible
  if (window.history && window.history.replaceState) {
    var url = window.location.pathname;
    window.history.replaceState({}, '', url);
  }
}

function deleteUnit(id, name) {
  document.getElementById('delUnitId').value = id;
  document.getElementById('delUnitName').textContent = name;
  $('#deleteUnitModal').modal('show');
}

/* ══════════════════════════════════════════
   SEARCH
   ══════════════════════════════════════════ */
function filterUnitList(q) {
  q = (q||'').toLowerCase();
  var rows = document.querySelectorAll('#unitListContainer tr.ims-master-row');
  rows.forEach(function(r) {
    r.style.display =
      (r.getAttribute('data-search')||'').toLowerCase().indexOf(q) >= 0 ? '' : 'none';
  });
  // Re-paginate after filter
  initPagination('unitListContainer', 10);
}

/* ══════════════════════════════════════════
   PAGINATION
   ══════════════════════════════════════════ */
function initPagination(tableBodyId, pageSize) {
  pageSize = pageSize || 10;
  // Only count visible rows (respects search filter)
  var allRows = Array.prototype.slice.call(
    document.querySelectorAll('#' + tableBodyId + ' tr.ims-master-row')
  ).filter(function(r) { return r.style.display !== 'none'; });

  var total = allRows.length;
  var totalPages = Math.ceil(total / pageSize);

  // Remove old pagination
  var oldPgn = document.getElementById(tableBodyId + '_pgn');
  if (oldPgn) oldPgn.parentNode.removeChild(oldPgn);

  if (total === 0) return;

  // Show first page
  gotoPageRows(allRows, 1, pageSize);

  // Build pagination bar
  var pgn = document.createElement('div');
  pgn.id = tableBodyId + '_pgn';
  pgn.style.cssText = 'padding:6px 14px 8px;display:flex;align-items:center;gap:5px;flex-wrap:wrap';

  var info = document.createElement('small');
  info.id = tableBodyId + '_pgnInfo';
  info.style.cssText = 'color:var(--txt3,#4a6080);font-size:11px;margin-right:6px';
  info.textContent = 'Showing 1–' + Math.min(pageSize, total) + ' of ' + total;
  pgn.appendChild(info);

  for (var i = 1; i <= totalPages; i++) {
    (function(p) {
      var btn = document.createElement('button');
      btn.textContent = p;
      btn.className = 'btn btn-xs ' + (p === 1 ? 'ims-btn-primary' : 'btn-default');
      btn.setAttribute('data-page', p);
      btn.onclick = function() {
        gotoPageRows(allRows, p, pageSize);
        // Update active button
        pgn.querySelectorAll('button').forEach(function(b) {
          b.className = 'btn btn-xs ' + (parseInt(b.getAttribute('data-page'))===p ? 'ims-btn-primary' : 'btn-default');
        });
        // Update info text
        var infoEl = document.getElementById(tableBodyId + '_pgnInfo');
        if (infoEl) infoEl.textContent = 'Showing ' + ((p-1)*pageSize+1) + '\u2013' + Math.min(p*pageSize, total) + ' of ' + total;
      };
      pgn.appendChild(btn);
    })(i);
  }

  // Insert after table-responsive div
  var tbl = document.getElementById(tableBodyId);
  if (tbl) {
    var wrapper = tbl.closest('.table-responsive') || tbl.closest('.panel-body');
    if (wrapper) {
      wrapper.parentNode.insertBefore(pgn, wrapper.nextSibling);
    }
  }

  window['_pgnState_' + tableBodyId] = { rows: allRows, pageSize: pageSize, total: total };
}

function gotoPageRows(rows, p, pageSize) {
  rows.forEach(function(r, i) {
    r.style.display = (i >= (p-1)*pageSize && i < p*pageSize) ? '' : 'none';
  });
}

/* ── Auto-init on DOM ready ── */
document.addEventListener('DOMContentLoaded', function() {
  initPagination('unitListContainer', 10);
  <c:if test="${showUnitForm}">
  var fp = document.getElementById('unitFormPanel');
  if (fp) { fp.scrollIntoView({ behavior: 'smooth', block: 'start' }); }
  </c:if>
});
</script>
