<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
  if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
  }
  com.barc.ims.dao.TankDAO tankDao = new com.barc.ims.dao.TankDAO();
  java.util.List tanks = new java.util.ArrayList();
  try { tanks = tankDao.getAllTanks(); } catch (Exception ex) {}
  pageContext.setAttribute("tanks", tanks);
  String activeTab = request.getParameter("tab");
  if (activeTab == null || activeTab.isEmpty()) activeTab = "BARC";
  pageContext.setAttribute("activeTab", activeTab);
  pageContext.setAttribute("activePage", "fuel_entry");
  pageContext.setAttribute("pageTitle",  "Fuel Dispense");
%>
<%@ include file="header.jsp" %>

<div class="container-fluid ims-main-content">
  <div class="ims-page-header">
    <h2><i class="fa fa-tint"></i> Fuel Dispense Module</h2>
    <span class="ims-badge-tag">Transaction</span>
  </div>

  <ul class="nav nav-tabs ims-form-tabs" id="entryTabs">
    <li class="${activeTab eq 'BARC'  ? 'active':''}">
      <a href="#tabBARC"  data-toggle="tab"><i class="fa fa-building"></i> A &mdash; BARC Vehicles</a>
    </li>
    <li class="${activeTab eq 'UNIT'  ? 'active':''}">
      <a href="#tabUNIT"  data-toggle="tab"><i class="fa fa-globe"></i> B &mdash; Other DAE Units</a>
    </li>
    <li class="${activeTab eq 'LOOSE' ? 'active':''}">
      <a href="#tabLOOSE" data-toggle="tab"><i class="fa fa-flask"></i> C &mdash; Loose / Other Supply</a>
    </li>
  </ul>

  <div class="tab-content ims-tab-content">

    <!-- ═══ TAB A: BARC VEHICLES ═══ -->
    <div class="tab-pane ${activeTab eq 'BARC' ? 'active':''}" id="tabBARC">
      <div class="panel panel-default ims-panel">
        <div class="panel-heading ims-panel-heading">
          <i class="fa fa-car"></i> BARC Vehicle Fuel Issue
          <small class="pull-right text-muted"><i class="fa fa-bolt"></i> Type vehicle no. &amp; click Fetch</small>
        </div>
        <div class="panel-body">
          <form action="<%=request.getContextPath()%>/FuelEntryServlet" method="post" id="formBARC">
            <input type="hidden" name="entryCategory" value="BARC">

            <div class="ims-form-section-title">Vehicle Details</div>
            <div class="row">
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Vehicle Number <span class="ims-auto-tag"><i class="fa fa-search"></i> Searchable</span></label>
                  <div class="ims-search-wrap">
                    <div class="input-group">
                      <input type="text" id="barcVnoInput" name="vehicleNo"
                             class="form-control ims-input" placeholder="Type to search..."
                             autocomplete="off" oninput="barcVnoSearch(this.value)"
                             style="text-transform:uppercase" required>
                      <span class="input-group-btn">
                        <button type="button" class="btn ims-btn-secondary" onclick="fetchBarcVehicle()">
                          <i class="fa fa-download"></i> Fetch
                        </button>
                      </span>
                    </div>
                    <div id="barcVnoDropdown" class="ims-dropdown-list" style="display:none"></div>
                  </div>
                  <div id="barcScanMsg" class="ims-fetch-msg" style="display:none"><i class="fa fa-spinner fa-spin"></i> Fetching...</div>
                  <div id="barcFetchOk"  class="ims-ok-msg"   style="display:none"><i class="fa fa-check-circle"></i> Fetched</div>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Vehicle Type <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="vehicleType" id="barcVtype"
                         class="form-control ims-input ims-auto-field" placeholder="Auto-fetched" readonly>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Department <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="department" id="barcDept"
                         class="form-control ims-input ims-auto-field" placeholder="Auto-fetched" readonly>
                </div>
              </div>
            </div>

            <!-- SEARCHABLE DRIVER DROPDOWN - BARC -->
            <div class="row">
              <div class="col-sm-5">
                <div class="form-group">
                  <label>Select Driver <span class="ims-auto-tag"><i class="fa fa-search"></i> Searchable</span></label>
                  <div class="ims-search-wrap">
                    <input type="text" id="barcDriverSearch"
                           class="form-control ims-input"
                           placeholder="Search by name or badge..."
                           autocomplete="off"
                           oninput="filterDriverDropdown('barc', this.value)">
                    <div id="barcDriverDropdown" class="ims-dropdown-list" style="display:none"></div>
                  </div>
                  <!-- Add driver link removed — BARC section does not show this -->
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Driver Name <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="driverName" id="barcDriver"
                         class="form-control ims-input ims-auto-field" placeholder="Auto-filled" readonly>
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Employee Number <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="driverBadge" id="barcBadge"
                         class="form-control ims-input ims-auto-field" placeholder="Auto-filled" readonly>
                </div>
              </div>
            </div>

            <div class="ims-form-section-title">Fuel Details</div>
            <div class="row">
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Fuel Tank <span class="text-danger">*</span></label>
                  <select name="tankId" id="barcTankId" class="form-control ims-select" required
                          onchange="tankChanged(this,'#barcFuelType','#barcTankInfo')">
                    <option value="">-- Select Tank --</option>
                    <c:forEach var="t" items="${tanks}">
                      <option value="${t.tankId}" data-fuel="${t.fuelType}"
                              data-level="${t.currentLevel}" data-status="${t.status}">
                        ${t.tankName} (${t.fuelType}) &mdash; ${t.currentLevel}L [${t.status}]
                      </option>
                    </c:forEach>
                  </select>
                  <div id="barcTankInfo" class="ims-tank-inline-info" style="display:none"></div>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Fuel Type <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="fuelType" id="barcFuelType"
                         class="form-control ims-input ims-auto-field" placeholder="Auto from tank" readonly required>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Quantity Issued (Litres) <span class="text-danger">*</span></label>
                  <input type="number" name="qtyIssued" id="barcQty"
                         class="form-control ims-input" placeholder="0.00" min="0.5" step="0.5" required
                         oninput="validateQty('barc',this.value)">
                  <div id="barcQtyMsg" class="ims-qty-feedback" style="display:none;margin-top:4px;font-size:11px"></div>
                </div>
              </div>
            </div>

            <div class="ims-form-section-title">Mileage Details</div>
            <div class="row">
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Previous Odometer (km) <span class="ims-auto-tag"><i class="fa fa-history"></i> AUTO</span></label>
                  <input type="number" name="prevOdometer" id="barcPrevKm"
                         class="form-control ims-input" placeholder="Auto-filled on fetch" step="0.1" oninput="validateOdometer('barc')" type="number">
                  <small id="barcPrevKmHint" class="ims-odo-hint" style="display:none"></small>
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Current Odometer (km)</label>
                  <input type="number" name="currOdometer" id="barcCurKm"
                         class="form-control ims-input" placeholder="Current reading" step="0.1" oninput="validateOdometer('barc')" type="number">
                  <small id="barcCurKmHint" style="display:none;font-size:11px;margin-top:3px"></small>
                </div>
              </div>

            </div>

            <div class="ims-form-section-title">Entry Details</div>
            <div class="row">
              <div class="col-sm-3">
                <div class="form-group">
                  <label>RCAV No. <small class="text-muted">(Manual)</small></label>
                  <input type="text" name="rcavNo" id="barcRcav"
                         class="form-control ims-input" placeholder="Enter RCAV number">
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Date <span class="text-danger">*</span></label>
                  <input type="date" name="entryDate" id="barcDate" class="form-control ims-input" required>
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Time <span class="ims-auto-tag"><i class="fa fa-clock-o"></i> Live</span></label>
                  <input type="text" name="entryTime" id="barcTime" class="form-control ims-input ims-auto-field" readonly placeholder="HH:MM:SS">
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Remarks</label>
                  <input type="text" name="remarks" class="form-control ims-input" placeholder="Optional">
                </div>
              </div>
            </div>

            <div class="ims-form-actions">
              <button type="submit" class="btn ims-btn-primary"><i class="fa fa-save"></i> Save Entry</button>
              <button type="button" class="btn ims-btn-secondary" onclick="previewReceipt('BARC')">
                <i class="fa fa-file-text-o"></i> Receipt Preview
              </button>
              <button type="reset" class="btn btn-default" onclick="clearBarcForm()">
                <i class="fa fa-times"></i> Clear
              </button>
            </div>
          </form>
        </div>
      </div>
    </div><!-- /tabBARC -->

    <!-- ═══ TAB B: OTHER DAE UNITS ═══ -->
    <div class="tab-pane ${activeTab eq 'UNIT' ? 'active':''}" id="tabUNIT">
      <div class="panel panel-default ims-panel">
        <div class="panel-heading ims-panel-heading">
          <i class="fa fa-globe"></i> Other DAE Unit Fuel Issue
        </div>
        <div class="panel-body">
          <form action="<%=request.getContextPath()%>/FuelEntryServlet" method="post" id="formUNIT">
            <input type="hidden" name="entryCategory" value="UNIT">

            <div class="ims-form-section-title">Vehicle &amp; Unit Details</div>
            <div class="row">
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Vehicle Number <span class="ims-auto-tag"><i class="fa fa-search"></i> Searchable</span></label>
                  <div class="ims-search-wrap">
                    <div class="input-group">
                      <input type="text" id="unitVnoInput" name="vehicleNo"
                             class="form-control ims-input" placeholder="Type to search..."
                             autocomplete="off" oninput="unitVnoSearch(this.value)"
                             style="text-transform:uppercase" required>
                      <span class="input-group-btn">
                        <button type="button" class="btn ims-btn-secondary" onclick="fetchUnitVehicle()">
                          <i class="fa fa-download"></i> Fetch
                        </button>
                      </span>
                    </div>
                    <div id="unitVnoDropdown" class="ims-dropdown-list" style="display:none"></div>
                  </div>
                  <div id="unitScanMsg"  class="ims-fetch-msg" style="display:none"><i class="fa fa-spinner fa-spin"></i> Searching...</div>
                  <div id="unitNotFound" class="ims-warn-msg"  style="display:none">
                    <i class="fa fa-exclamation-triangle"></i> Not found.
                    <a href="<%=request.getContextPath()%>/MasterServlet?section=vehicle" target="_blank">
                      <strong>Register vehicle</strong>
                    </a>
                  </div>
                  <div id="unitFetchOk" class="ims-ok-msg" style="display:none"><i class="fa fa-check-circle"></i> Fetched</div>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Organisation <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="orgName" id="unitOrg"
                         class="form-control ims-input ims-auto-field" placeholder="Auto-fetched" readonly>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Vehicle Type <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="vehicleType" id="unitVtype"
                         class="form-control ims-input ims-auto-field" placeholder="Auto-fetched" readonly>
                </div>
              </div>
            </div>

            <!-- SEARCHABLE DRIVER DROPDOWN - OTHER UNITS -->
            <!-- Shows EmpNo — Name in dropdown (Fix #8) -->
            <div class="row">
              <div class="col-sm-5">
                <div class="form-group">
                  <label>Select Driver <span class="ims-auto-tag"><i class="fa fa-search"></i> EmpNo — Name</span></label>
                  <div class="ims-search-wrap">
                    <input type="text" id="unitDriverSearch"
                           class="form-control ims-input"
                           placeholder="Search by emp no. or name..."
                           autocomplete="off"
                           oninput="filterDriverDropdown('unit', this.value)">
                    <div id="unitDriverDropdown" class="ims-dropdown-list" style="display:none"></div>
                  </div>
                  <div style="margin-top:4px">
                    <a href="<%=request.getContextPath()%>/MasterServlet?section=driver"
                       target="_blank" id="unitAddDriverLink"
                       class="ims-auto-tag" style="display:none;color:#ff6b35">
                      <i class="fa fa-plus-circle"></i> Not in list? Add new driver
                    </a>
                  </div>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Driver Name <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="driverName" id="unitDriver"
                         class="form-control ims-input ims-auto-field" placeholder="Auto-filled" readonly>
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Employee Number <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="driverContact" id="unitContact"
                         class="form-control ims-input ims-auto-field" placeholder="Auto-filled" readonly>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-sm-4">
                <div class="form-group">
                  <label>RCAV No. <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO-GEN</span></label>
                  <div class="input-group">
                    <input type="text" name="rcavNo" id="unitRcav"
                           class="form-control ims-input ims-auto-field"
                           placeholder="Auto-generating..." readonly>
                    <span class="input-group-btn">
                      <button type="button" class="btn ims-btn-secondary btn-sm"
                              onclick="generateRCAV('unitRcav')" title="Regenerate">
                        <i class="fa fa-refresh"></i>
                      </button>
                    </span>
                  </div>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Date <span class="text-danger">*</span></label>
                  <input type="date" name="entryDate" id="unitDate" class="form-control ims-input" required>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Time <span class="ims-auto-tag"><i class="fa fa-clock-o"></i> Live</span></label>
                  <input type="text" name="entryTime" id="unitTime" class="form-control ims-input ims-auto-field" readonly placeholder="HH:MM:SS">
                </div>
              </div>
            </div>

            <div class="ims-form-section-title">Fuel Details</div>
            <div class="row">
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Fuel Tank <span class="text-danger">*</span></label>
                  <select name="tankId" id="unitTankId" class="form-control ims-select" required
                          onchange="tankChanged(this,'#unitFuelType','#unitTankInfo')">
                    <option value="">-- Select Tank --</option>
                    <c:forEach var="t" items="${tanks}">
                      <option value="${t.tankId}" data-fuel="${t.fuelType}"
                              data-level="${t.currentLevel}" data-status="${t.status}">
                        ${t.tankName} (${t.fuelType}) &mdash; ${t.currentLevel}L [${t.status}]
                      </option>
                    </c:forEach>
                  </select>
                  <div id="unitTankInfo" class="ims-tank-inline-info" style="display:none"></div>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Fuel Type <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="fuelType" id="unitFuelType"
                         class="form-control ims-input ims-auto-field" placeholder="Auto from tank" readonly required>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Quantity Issued (Litres) <span class="text-danger">*</span></label>
                  <input type="number" name="qtyIssued" id="unitQty"
                         class="form-control ims-input" placeholder="0.00" min="0.5" step="0.5" required
                         oninput="validateQty('unit',this.value)">
                  <div id="unitQtyMsg" class="ims-qty-feedback" style="display:none;margin-top:4px;font-size:11px"></div>
                </div>
              </div>
            </div>

            <div class="ims-form-section-title">Mileage Details</div>
            <div class="row">
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Previous Odometer (km) <span class="ims-auto-tag"><i class="fa fa-history"></i> AUTO</span></label>
                  <input type="number" name="prevOdometer" id="unitPrevKm"
                         class="form-control ims-input" placeholder="Auto-filled on fetch" step="0.1" oninput="validateOdometer('unit')" type="number">
                  <small id="unitPrevKmHint" class="ims-odo-hint" style="display:none"></small>
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Current Odometer (km)</label>
                  <input type="number" name="currOdometer" id="unitCurKm"
                         class="form-control ims-input" placeholder="Current reading" step="0.1" oninput="validateOdometer('unit')" type="number">
                  <small id="unitCurKmHint" style="display:none;font-size:11px;margin-top:3px"></small>
                </div>
              </div>

            </div>
            <div class="row">
              <div class="col-sm-12">
                <div class="form-group">
                  <label>Remarks</label>
                  <input type="text" name="remarks" class="form-control ims-input" placeholder="Optional">
                </div>
              </div>
            </div>

            <div class="ims-form-actions">
              <button type="submit" class="btn ims-btn-primary"><i class="fa fa-save"></i> Save Entry</button>
              <button type="button" class="btn ims-btn-secondary" onclick="previewReceipt('UNIT')">
                <i class="fa fa-file-text-o"></i> Receipt Preview
              </button>
              <button type="reset" class="btn btn-default" onclick="clearUnitForm()"><i class="fa fa-times"></i> Clear</button>
            </div>
          </form>
        </div>
      </div>
    </div><!-- /tabUNIT -->

    <!-- ═══ TAB C: LOOSE / OTHER SUPPLY ═══ -->
    <div class="tab-pane ${activeTab eq 'LOOSE' ? 'active':''}" id="tabLOOSE">
      <div class="panel panel-default ims-panel">
        <div class="panel-heading ims-panel-heading">
          <i class="fa fa-flask"></i> Loose / Other Supply
        </div>
        <div class="panel-body">
          <form action="<%=request.getContextPath()%>/FuelEntryServlet" method="post" id="formLOOSE">
            <input type="hidden" name="entryCategory" value="LOOSE">

            <div class="row">
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Fuel Tank <span class="text-danger">*</span></label>
                  <select name="tankId" id="looseTankId" class="form-control ims-select" required
                          onchange="tankChanged(this,'#looseFuelType','#looseTankInfo')">
                    <option value="">-- Select Tank --</option>
                    <c:forEach var="t" items="${tanks}">
                      <option value="${t.tankId}" data-fuel="${t.fuelType}"
                              data-level="${t.currentLevel}" data-status="${t.status}">
                        ${t.tankName} (${t.fuelType}) &mdash; ${t.currentLevel}L [${t.status}]
                      </option>
                    </c:forEach>
                  </select>
                  <div id="looseTankInfo" class="ims-tank-inline-info" style="display:none"></div>
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Fuel Type <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO</span></label>
                  <input type="text" name="fuelType" id="looseFuelType"
                         class="form-control ims-input ims-auto-field" placeholder="Auto from tank" readonly required>
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group">
                  <label>Quantity Issued (Litres) <span class="text-danger">*</span></label>
                  <input type="number" name="qtyIssued" id="looseQty"
                         class="form-control ims-input" placeholder="0.00" min="0.5" step="0.5" required
                         oninput="validateQty('loose',this.value)">
                  <div id="looseQtyMsg" class="ims-qty-feedback" style="display:none;margin-top:4px;font-size:11px"></div>
                </div>
              </div>
              <div class="col-sm-3">
                <!-- Fix #3: RCAV auto-gen for Loose section -->
                <div class="form-group">
                  <label>RCAV No. <span class="ims-auto-tag"><i class="fa fa-bolt"></i> AUTO-GEN</span></label>
                  <div class="input-group">
                    <input type="text" name="rcavNo" id="looseRcav"
                           class="form-control ims-input ims-auto-field"
                           placeholder="Auto-generating..." readonly>
                    <span class="input-group-btn">
                      <button type="button" class="btn ims-btn-secondary btn-sm"
                              onclick="generateRCAV('looseRcav')" title="Regenerate">
                        <i class="fa fa-refresh"></i>
                      </button>
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Requested By (Name) <span class="text-danger">*</span></label>
                  <input type="text" name="driverName" class="form-control ims-input"
                         placeholder="Full name of requester" required>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Emp No / PRNS ID</label>
                  <input type="text" name="driverBadge" class="form-control ims-input"
                         placeholder="Employee no. or PRNS ID">
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Designation</label>
                  <input type="text" name="designation" class="form-control ims-input"
                         placeholder="Designation / post">
                </div>
              </div>
            </div>
            <div class="row">
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Division / Section</label>
                  <input type="text" name="department" class="form-control ims-input"
                         placeholder="Division name">
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Date <span class="text-danger">*</span></label>
                  <input type="date" name="entryDate" id="looseDate" class="form-control ims-input" required>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group">
                  <label>Time <span class="ims-auto-tag"><i class="fa fa-clock-o"></i> Live</span></label>
                  <input type="text" name="entryTime" id="looseTime" class="form-control ims-input ims-auto-field" readonly placeholder="HH:MM:SS">
                </div>
              </div>
            </div>
            <div class="row">
              <div class="col-sm-12">
                <div class="form-group">
                  <label>Remarks</label>
                  <input type="text" name="remarks" class="form-control ims-input" placeholder="Optional">
                </div>
              </div>
            </div>

            <div class="ims-form-actions">
              <button type="submit" class="btn ims-btn-primary"><i class="fa fa-save"></i> Save Entry</button>
              <button type="button" class="btn ims-btn-secondary" onclick="previewReceipt('LOOSE')">
                <i class="fa fa-file-text-o"></i> Receipt Preview
              </button>
              <button type="reset" class="btn btn-default"><i class="fa fa-times"></i> Clear</button>
            </div>
          </form>
        </div>
      </div>
    </div><!-- /tabLOOSE -->

  </div><!-- /tab-content -->
</div>

<!-- RECEIPT MODAL — no Print button (Fix #4) -->
<div class="modal fade" id="receiptModal" tabindex="-1">
  <div class="modal-dialog" style="width:640px;max-width:96vw">
    <div class="modal-content ims-receipt-modal">
      <div class="modal-header ims-receipt-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title"><i class="fa fa-file-text"></i> FUEL ISSUE RECEIPT</h4>
        <p class="ims-receipt-sub">Bhabha Atomic Research Centre, Trombay, Mumbai 400085</p>
        <small>Transport Section &mdash; IMS Fuel Master Pro</small>
      </div>
      <div class="modal-body" id="receiptBody"></div>
      <div class="modal-footer ims-receipt-footer">
        <!-- Signature Pads -->
        <div class="row ims-sig-row" style="margin-bottom:10px">
          <div class="col-xs-6">
            <div style="font-size:11px;color:var(--txt3);margin-bottom:4px;font-weight:600">
              <i class="fa fa-pencil"></i> Issued By (Officer)
            </div>
            <canvas id="sigOfficer" width="260" height="80"
              style="border:1px solid var(--border);border-radius:6px;background:rgba(255,255,255,0.04);cursor:crosshair;width:100%"></canvas>
            <div style="margin-top:4px;text-align:right">
              <button class="btn btn-default btn-xs" onclick="clearSig('sigOfficer')">
                <i class="fa fa-times"></i> Clear
              </button>
            </div>
          </div>
          <div class="col-xs-6">
            <div style="font-size:11px;color:var(--txt3);margin-bottom:4px;font-weight:600">
              <i class="fa fa-pencil"></i> Driver / Receiver
            </div>
            <canvas id="sigDriver" width="260" height="80"
              style="border:1px solid var(--border);border-radius:6px;background:rgba(255,255,255,0.04);cursor:crosshair;width:100%"></canvas>
            <div style="margin-top:4px;text-align:right">
              <button class="btn btn-default btn-xs" onclick="clearSig('sigDriver')">
                <i class="fa fa-times"></i> Clear
              </button>
            </div>
          </div>
        </div>
        <div style="margin-top:8px">
          <button class="btn ims-btn-primary btn-sm" onclick="printReceiptPDF()">
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

<!-- NOT FOUND POPUP -->
<div class="modal fade" id="notFoundModal" tabindex="-1">
  <div class="modal-dialog modal-sm">
    <div class="modal-content ims-modal">
      <div class="modal-header" style="background:rgba(255,107,53,0.1);border-bottom:1px solid rgba(255,107,53,0.2)">
        <h4 class="modal-title" style="color:#ff6b35"><i class="fa fa-exclamation-triangle"></i> Vehicle Not Found</h4>
      </div>
      <div class="modal-body" style="text-align:center;padding:24px">
        <p>Vehicle <strong id="notFoundVno" style="color:#3b9eff"></strong> is not registered.</p>
        <a href="<%=request.getContextPath()%>/MasterServlet?section=vehicle"
           class="btn ims-btn-success btn-sm" target="_blank"
           onclick="$('#notFoundModal').modal('hide')">
          <i class="fa fa-plus"></i> Register in Vehicle Master
        </a>
      </div>
      <div class="modal-footer"><button class="btn btn-default btn-sm" data-dismiss="modal">Cancel</button></div>
    </div>
  </div>
</div>

<style>
.ims-search-wrap{position:relative}
.ims-dropdown-list{position:absolute;top:100%;left:0;right:0;z-index:1050;
  background:var(--card,#111827);border:1px solid rgba(99,179,255,0.3);
  border-radius:0 0 8px 8px;max-height:220px;overflow-y:auto;
  box-shadow:0 8px 24px rgba(0,0,0,0.4)}
.ims-dropdown-item{padding:9px 14px;cursor:pointer;font-size:13px;
  border-bottom:1px solid rgba(99,179,255,0.07);transition:background 0.15s}
.ims-dropdown-item:hover{background:rgba(59,158,255,0.12)}
.ims-dropdown-item .dd-main{font-family:monospace;color:#3b9eff;font-weight:600}
.ims-dropdown-item .dd-sub{font-size:11px;color:#8ba4c8;margin-top:2px}
.ims-ok-msg{font-size:11px;color:#00d68f;margin-top:4px}
.ims-tank-inline-info{margin-top:6px;padding:6px 10px;border-radius:6px;
  font-size:12px;background:rgba(59,158,255,0.07);border:1px solid rgba(59,158,255,0.2)}
body.ims-light .ims-dropdown-list{background:#fff;border-color:#d0dae8}
body.ims-light .ims-dropdown-item:hover{background:rgba(26,110,204,0.06)}
body.ims-light .ims-dropdown-item .dd-main{color:#1a6ecc}
body.ims-light .ims-dropdown-item .dd-sub{color:#7090b0}

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

<%@ include file="footer.jsp" %>

<script>
var IMS_CTX = '<%=request.getContextPath()%>';
var _barcDrivers = [];
var _unitDrivers = [];

/* ── Init ── */
$(document).ready(function(){
  setDates();
  startLiveClock();
  generateRCAV('unitRcav');
  generateRCAV('looseRcav');
});

function setDates() {
  // Fetch server time for date
  $.ajax({
    url: IMS_CTX + '/FuelEntryServlet',
    data: { action: 'servertime' },
    dataType: 'json',
    success: function(d) {
      if (d && d.date) {
        $('#barcDate,#unitDate,#looseDate').val(d.date);
      }
    },
    error: function() {
      // fallback to client date
      var dd = new Date().toISOString().split('T')[0];
      $('#barcDate,#unitDate,#looseDate').val(dd);
    }
  });
}

// Live clock — updates every second, reads from server offset
var _serverTimeOffset = 0; // ms offset between server and client
(function fetchServerOffset() {
  var t0 = Date.now();
  $.ajax({
    url: IMS_CTX + '/FuelEntryServlet',
    data: { action: 'servertime' },
    dataType: 'json',
    success: function(d) {
      if (d && d.timestamp) {
        var t1 = Date.now();
        var serverMs = parseInt(d.timestamp);
        _serverTimeOffset = serverMs - ((t0 + t1) / 2);
      }
    }
  });
})();

function getServerTime() {
  return new Date(Date.now() + _serverTimeOffset);
}

function startLiveClock() {
  function tick() {
    var now = getServerTime();
    var hh = String(now.getHours()).padStart(2,'0');
    var mm = String(now.getMinutes()).padStart(2,'0');
    var ss = String(now.getSeconds()).padStart(2,'0');
    var timeStr = hh + ':' + mm + ':' + ss;
    $('#barcTime').val(timeStr);
    $('#unitTime').val(timeStr);
    $('#looseTime').val(timeStr);
  }
  tick();
  setInterval(tick, 1000);
}

/* tankChanged is defined above with qty validation */

/* ════ BARC VEHICLE SEARCH ════ */
var barcVTimer;
function barcVnoSearch(val) {
  clearTimeout(barcVTimer);
  if (val.length < 2) { $('#barcVnoDropdown').hide(); return; }
  barcVTimer = setTimeout(function(){
    $.getJSON(IMS_CTX+'/MasterServlet?action=searchBarcVehicle&q='+encodeURIComponent(val), function(data){
      if (!data||!data.length){ $('#barcVnoDropdown').hide(); return; }
      var h='';
      data.forEach(function(v){
        h+='<div class="ims-dropdown-item" onclick=\'selectBarcVehicle('+JSON.stringify(v).replace(/'/g,"\\'")+')\'>' +
           '<div class="dd-main">'+v.vehicleNo+'</div>' +
           '<div class="dd-sub">'+v.department+' &middot; '+v.fuelType+'</div></div>';
      });
      $('#barcVnoDropdown').html(h).show();
    });
  }, 350);
}
function selectBarcVehicle(v) {
  $('#barcVnoInput').val(v.vehicleNo);
  $('#barcVtype').val(v.vehicleType||'');
  $('#barcDept').val(v.department||'');
  $('#barcVnoDropdown').hide();
  _barcDrivers = v.drivers||[];
  populateDriverSearch('barc', _barcDrivers);
  /* Auto-fill previous odometer from last recorded reading */
  if (v.lastOdometer && v.lastOdometer > 0) {
    $('#barcPrevKm').val(v.lastOdometer);
    $('#barcPrevKmHint').text('Last recorded: ' + parseInt(v.lastOdometer).toLocaleString() + ' km').show();
  } else {
    $('#barcPrevKm').val('');
    $('#barcPrevKmHint').text('No previous reading found').show();
  }
  calcMileage('barc');
  $('#barcFetchOk').show(); setTimeout(function(){$('#barcFetchOk').fadeOut();},3000);
}
function fetchBarcVehicle() {
  var val = $('#barcVnoInput').val().trim();
  if (!val){showToast('Enter vehicle number first','danger');return;}
  $('#barcScanMsg').show();
  $.getJSON(IMS_CTX+'/MasterServlet?action=searchBarcVehicle&q='+encodeURIComponent(val), function(data){
    $('#barcScanMsg').hide();
    if (data&&data.length) selectBarcVehicle(data[0]);
    else showToast('Vehicle not found in BARC master','warning');
  }).fail(function(){$('#barcScanMsg').hide();showToast('Server error','danger');});
}

/* ════ UNIT VEHICLE SEARCH ════ */
var unitVTimer;
function unitVnoSearch(val) {
  clearTimeout(unitVTimer);
  if (val.length < 2){ $('#unitVnoDropdown').hide(); return; }
  unitVTimer = setTimeout(function(){
    $.getJSON(IMS_CTX+'/MasterServlet?action=searchVehicle&q='+encodeURIComponent(val), function(data){
      if (!data||!data.length){ $('#unitVnoDropdown').hide(); return; }
      var h='';
      data.forEach(function(v){
        h+='<div class="ims-dropdown-item" onclick=\'selectUnitVehicle('+JSON.stringify(v).replace(/'/g,"\\'")+')\'>' +
           '<div class="dd-main">'+v.vehicleNo+'</div>' +
           '<div class="dd-sub">'+v.orgName+' &middot; '+v.vehicleType+' &middot; '+v.fuelType+'</div></div>';
      });
      $('#unitVnoDropdown').html(h).show();
    });
  }, 350);
}
function selectUnitVehicle(v) {
  $('#unitVnoInput').val(v.vehicleNo);
  $('#unitOrg').val(v.orgName||'');
  $('#unitVtype').val(v.vehicleType||'');
  $('#unitVnoDropdown').hide();
  $('#unitNotFound').hide();
  _unitDrivers = v.drivers||[];
  populateDriverSearch('unit', _unitDrivers);
  /* Fix #7: always sync the add-link visibility after populate */
  if (_unitDrivers.length===0) $('#unitAddDriverLink').show();
  /* Auto-fill previous odometer from last recorded reading */
  if (v.lastOdometer && v.lastOdometer > 0) {
    $('#unitPrevKm').val(v.lastOdometer);
    $('#unitPrevKmHint').text('Last recorded: ' + parseInt(v.lastOdometer).toLocaleString() + ' km').show();
  } else {
    $('#unitPrevKm').val('');
    $('#unitPrevKmHint').text('No previous reading found').show();
  }
  calcMileage('unit');
  $('#unitFetchOk').show(); setTimeout(function(){$('#unitFetchOk').fadeOut();},3000);
}
function fetchUnitVehicle() {
  var val = $('#unitVnoInput').val().trim();
  if (!val){showToast('Enter vehicle number first','danger');return;}
  $('#unitScanMsg').show(); $('#unitNotFound').hide();
  $.getJSON(IMS_CTX+'/MasterServlet?action=searchVehicle&q='+encodeURIComponent(val), function(data){
    $('#unitScanMsg').hide();
    if (data&&data.length) selectUnitVehicle(data[0]);
    else {
      $('#unitNotFound').show();
      document.getElementById('notFoundVno').textContent = val;
      $('#notFoundModal').modal('show');
    }
  }).fail(function(){$('#unitScanMsg').hide();showToast('Server error','danger');});
}

/* ════ SEARCHABLE DRIVER DROPDOWN (Fix #1) ════ */
/* prefix: 'barc' or 'unit'
   For BARC: shows "Badge — Name"
   For Unit: shows "EmpNo — Name" (Fix #8) */
function populateDriverSearch(prefix, drivers) {
  var searchId  = '#'+prefix+'DriverSearch';
  var dropId    = '#'+prefix+'DriverDropdown';
  var addLinkId = '#'+prefix+'AddDriverLink';
  $(searchId).val('').attr('placeholder',
    drivers.length===0 ? 'No drivers registered for this unit'
    : (prefix==='unit' ? 'Search by emp no. or name...' : 'Search by name or badge...')
  );
  $(dropId).hide();
  if (drivers.length===0) { $(addLinkId).show(); return; }
  /* Render all drivers on focus */
  $(searchId).off('focus').on('focus', function(){
    renderDriverDropdown(prefix, drivers, '');
  });
  /* Show "add" link below search */
  $(addLinkId).show();
}

function filterDriverDropdown(prefix, query) {
  var drivers = prefix==='barc' ? _barcDrivers : _unitDrivers;
  renderDriverDropdown(prefix, drivers, query);
}

function renderDriverDropdown(prefix, drivers, query) {
  var dropId    = '#'+prefix+'DriverDropdown';
  var addLinkId = '#'+prefix+'AddDriverLink';
  if (!drivers||!drivers.length){
    $(dropId).hide();
    if (prefix==='unit') $(addLinkId).show();
    return;
  }
  var q = (query||'').toLowerCase();
  var filtered = drivers.filter(function(d){
    var searchStr = (d.driverName+' '+(d.employeeNo||d.licenceNo||'')).toLowerCase();
    return !q || searchStr.indexOf(q)>=0;
  });
  if (!filtered.length){ $(dropId).hide(); return; }
  var h = '';
  filtered.forEach(function(d){
    var mainLabel = d.driverName + (d.employeeNo ? ' [' + d.employeeNo + ']' : '');
    var subLabel  = d.employeeNo ? 'Emp No: ' + d.employeeNo
                  : (d.contactNo ? 'Contact: ' + d.contactNo : '&nbsp;');
    /* Embed full driver object as data attribute to avoid index mismatch on filtered list */
    var safeJson  = JSON.stringify(d).replace(/'/g, "&#39;").replace(/"/g, "&quot;");
    h += '<div class="ims-dropdown-item" onclick="selectDriverObj(\''+prefix+'\', this)" data-driver="'+safeJson+'">' +
         '<div class="dd-main">'+mainLabel+'</div>' +
         '<div class="dd-sub">'+subLabel+'</div>' +
         '</div>';
  });
  $(dropId).html(h).show();
}

function selectDriverObj(prefix, el) {
  var raw = el.getAttribute('data-driver');
  var d;
  try { d = JSON.parse(raw.replace(/&quot;/g, '"').replace(/&#39;/g, "'")); }
  catch(e) { return; }
  var dropId   = '#'+prefix+'DriverDropdown';
  var searchId = '#'+prefix+'DriverSearch';
  var nameId   = '#'+prefix+'Driver';
  var badgeId  = (prefix==='barc') ? '#barcBadge' : null;
  var empNoId  = (prefix==='unit') ? '#unitContact' : null;

  var displayText = d.driverName + (d.employeeNo ? ' ['+d.employeeNo+']' : '');
  $(searchId).val(displayText);
  $(nameId).val(d.driverName||'');
  if (badgeId)  $(badgeId).val(d.employeeNo||'');
  if (empNoId)  $(empNoId).val(d.employeeNo||'');
  $(dropId).hide();
}

/* Legacy shim — not used but keep to avoid any residual references */
function selectDriver(prefix, idx) {
  var drivers = prefix==='barc' ? _barcDrivers : _unitDrivers;
  if (!drivers||idx<0||idx>=drivers.length) return;
  var d = drivers[idx];
  var displayText = d.driverName + (d.employeeNo ? ' ['+d.employeeNo+']' : '');
  $('#'+prefix+'DriverSearch').val(displayText);
  $('#'+prefix+'Driver').val(d.driverName||'');
  if (prefix==='barc') $('#barcBadge').val(d.employeeNo||'');
  if (prefix==='unit') $('#unitContact').val(d.employeeNo||'');
  $('#'+prefix+'DriverDropdown').hide();
}

/* Close dropdowns on outside click */
$(document).on('click', function(e){
  if (!$(e.target).closest('.ims-search-wrap').length)
    $('.ims-dropdown-list').hide();
});

/* ════ MILEAGE ════ */
/* ── Odometer validation — blocks submit if invalid ── */
var _odoError = { barc: false, unit: false };
function validateOdometer(p) {
  var prev  = parseFloat($('#'+p+'PrevKm').val())||0;
  var cur   = parseFloat($('#'+p+'CurKm').val())||0;
  var curEl = document.getElementById(p+'CurKm');
  var hintId = '#'+p+'CurKmHint';
  if (!curEl) return;
  if (cur > 0 && prev > 0 && cur <= prev) {
    curEl.style.borderColor  = '#ff4757';
    curEl.style.boxShadow    = '0 0 0 2px rgba(255,71,87,0.2)';
    _odoError[p] = true;
    $(hintId).text('⚠ Must be greater than previous (' + prev.toLocaleString() + ' km)').show().css('color','#ff4757');
  } else if (cur > 0 && prev > 0) {
    curEl.style.borderColor  = '#00d68f';
    curEl.style.boxShadow    = '0 0 0 2px rgba(0,214,143,0.15)';
    _odoError[p] = false;
    var dist = (cur - prev).toFixed(1);
    $(hintId).text('✓ Distance: ' + dist + ' km').show().css('color','#00d68f');
  } else {
    curEl.style.borderColor  = '';
    curEl.style.boxShadow    = '';
    _odoError[p] = false;
    $(hintId).hide();
  }
}

/* ── Qty live validation vs tank stock ── */
var _tankLevels = {};
// Populate tank levels from select options when tank changes
function tankChanged(sel, fuelId, infoId) {
  var opt    = sel.options[sel.selectedIndex];
  var fuel   = opt.getAttribute('data-fuel')   || '';
  var level  = opt.getAttribute('data-level')  || '0';
  var status = opt.getAttribute('data-status') || '';
  $(fuelId).val(fuel);
  // Store level for qty validation
  var prefix = sel.id.replace('TankId','');
  _tankLevels[prefix] = parseFloat(level)||0;
  if (sel.value) {
    var c = status==='Normal'?'#00d68f':status==='Low'?'#ffd700':'#ff4757';
    $(infoId).html('<i class="fa fa-tint"></i> <b>'+fuel+'</b> &mdash; <span style="color:'+c+'">'+status+'</span> &mdash; <b>'+parseFloat(level).toLocaleString()+' L</b>').show();
    // Revalidate qty if already entered
    var qtyVal = $('#'+prefix+'Qty').val();
    if (qtyVal) validateQty(prefix, qtyVal);
  } else { $(infoId).hide(); }
}

function validateQty(prefix, val) {
  var qty = parseFloat(val)||0;
  var avail = _tankLevels[prefix]||0;
  var msgEl = document.getElementById(prefix+'QtyMsg');
  var qtyEl = document.getElementById(prefix+'Qty');
  if (!msgEl || !qtyEl) return;
  if (qty <= 0) { msgEl.style.display='none'; qtyEl.style.borderColor=''; return; }
  if (avail === 0) { msgEl.style.display='none'; return; } // tank not selected yet
  if (qty > avail) {
    msgEl.innerHTML = '<i class="fa fa-exclamation-triangle"></i> Exceeds available stock ('+avail.toLocaleString()+' L)';
    msgEl.style.cssText = 'display:block;color:#ff4757;margin-top:4px;font-size:11px';
    qtyEl.style.borderColor = '#ff4757';
    qtyEl.style.boxShadow = '0 0 0 2px rgba(255,71,87,0.2)';
  } else if (qty > avail * 0.9) {
    msgEl.innerHTML = '<i class="fa fa-exclamation-circle"></i> High usage — '+( avail - qty ).toFixed(1)+' L will remain';
    msgEl.style.cssText = 'display:block;color:#ffd700;margin-top:4px;font-size:11px';
    qtyEl.style.borderColor = '#ffd700';
    qtyEl.style.boxShadow = '0 0 0 2px rgba(255,215,0,0.2)';
  } else {
    msgEl.innerHTML = '<i class="fa fa-check-circle"></i> OK &mdash; '+( avail - qty ).toFixed(1)+' L remaining after issue';
    msgEl.style.cssText = 'display:block;color:#00d68f;margin-top:4px;font-size:11px';
    qtyEl.style.borderColor = '#00d68f';
    qtyEl.style.boxShadow = '0 0 0 2px rgba(0,214,143,0.15)';
  }
}


function clearBarcForm(){
  $('#formBARC')[0].reset();
  _odoError['barc']=false;
  $('#barcCurKmHint').hide();
  document.getElementById('barcCurKm').style.borderColor='';
  document.getElementById('barcCurKm').style.boxShadow='';
  $('#barcVtype,#barcDept,#barcDriver,#barcBadge,#barcFuelType').val('');
  $('#barcQtyMsg').hide(); $('#barcQty').css({'borderColor':'','boxShadow':''});
  _tankLevels['barc']=0;
  $('#barcPrevKm,#barcCurKm').val('');
  $('#barcPrevKmHint').hide();
  $('#barcTankInfo,#barcFetchOk,#barcScanMsg').hide();
  $('#barcDriverSearch').val('').attr('placeholder','Search by name or badge...');
  $('#barcDriverDropdown').hide(); _barcDrivers=[];
}

function clearUnitForm(){
  $('#formUNIT')[0].reset();
  _odoError['unit']=false;
  $('#unitCurKmHint').hide();
  document.getElementById('unitCurKm').style.borderColor='';
  document.getElementById('unitCurKm').style.boxShadow='';
  $('#unitVtype,#unitOrg,#unitDriver,#unitContact,#unitFuelType').val('');
  $('#unitQtyMsg').hide(); $('#unitQty').css({'borderColor':'','boxShadow':''});
  _tankLevels['unit']=0;
  $('#unitPrevKm,#unitCurKm').val('');
  $('#unitPrevKmHint').hide();
  $('#unitTankInfo,#unitFetchOk,#unitScanMsg,#unitNotFound').hide();
  $('#unitAddDriverLink').hide();
  $('#unitDriverSearch').val('').attr('placeholder','Search by emp no. or name...');
  $('#unitDriverDropdown').hide(); _unitDrivers=[];
}

/* ════ RCAV AUTO-GEN (Fix #3) ════ */
function generateRCAV(targetId) {
  $.getJSON(IMS_CTX+'/MasterServlet?action=generateRCAV', function(d){
    if (d&&d.rcavNo) $('#'+targetId).val(d.rcavNo);
  }).fail(function(){
    var now=new Date();
    $('#'+targetId).val('RCAV/'+now.getFullYear()+'/'+
      String(now.getMonth()+1).padStart(2,'0')+'/'+
      String(Math.floor(Math.random()*900+100)));
  });
}

/* ════ SIGNATURE PAD ════ */
var _sigPads = {};

function initSigPad(canvasId) {
  var canvas = document.getElementById(canvasId);
  if (!canvas || _sigPads[canvasId]) return;
  var ctx    = canvas.getContext('2d');
  var drawing = false;
  var lastX = 0, lastY = 0;

  function getPos(e) {
    var rect = canvas.getBoundingClientRect();
    var scaleX = canvas.width  / rect.width;
    var scaleY = canvas.height / rect.height;
    var clientX = e.touches ? e.touches[0].clientX : e.clientX;
    var clientY = e.touches ? e.touches[0].clientY : e.clientY;
    return { x: (clientX - rect.left) * scaleX, y: (clientY - rect.top) * scaleY };
  }

  function startDraw(e) {
    e.preventDefault();
    drawing = true;
    var p = getPos(e);
    lastX = p.x; lastY = p.y;
    ctx.beginPath();
    ctx.arc(lastX, lastY, 0.8, 0, Math.PI*2);
    ctx.fillStyle = '#1a3a6e';
    ctx.fill();
  }
  function draw(e) {
    if (!drawing) return;
    e.preventDefault();
    var p = getPos(e);
    ctx.beginPath();
    ctx.moveTo(lastX, lastY);
    ctx.lineTo(p.x, p.y);
    ctx.strokeStyle = '#1a3a6e';
    ctx.lineWidth = 1.8;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.stroke();
    lastX = p.x; lastY = p.y;
  }
  function stopDraw() { drawing = false; }

  canvas.addEventListener('mousedown',  startDraw);
  canvas.addEventListener('mousemove',  draw);
  canvas.addEventListener('mouseup',    stopDraw);
  canvas.addEventListener('mouseleave', stopDraw);
  canvas.addEventListener('touchstart', startDraw, {passive:false});
  canvas.addEventListener('touchmove',  draw,      {passive:false});
  canvas.addEventListener('touchend',   stopDraw);
  _sigPads[canvasId] = true;
}

function clearSig(canvasId) {
  var canvas = document.getElementById(canvasId);
  if (canvas) canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);
}

function isSigEmpty(canvasId) {
  var canvas = document.getElementById(canvasId);
  if (!canvas) return true;
  var data = canvas.getContext('2d').getImageData(0, 0, canvas.width, canvas.height).data;
  for (var i = 3; i < data.length; i += 4) { if (data[i] > 0) return false; }
  return true;
}

/* Init pads when modal opens */
$('#receiptModal').on('shown.bs.modal', function(){
  initSigPad('sigOfficer');
  initSigPad('sigDriver');
});


/* ═══════════════════════════════════════════════════════════
   FUEL ENTRY RECEIPT PREVIEW — compact 2-col, merged fields
   ═══════════════════════════════════════════════════════════ */
function buildReceiptRows(e) {
  var odo = (e.prevOdo > 0 || e.currOdo > 0)
    ? (e.prevOdo > 0 ? Number(e.prevOdo).toLocaleString() : '--') +
      ' \u2192 ' +
      (e.currOdo  > 0 ? Number(e.currOdo).toLocaleString() : '--') + ' km'
    : '--';
  var dept = e.category === 'UNIT'
    ? (e.orgName || e.dept || '--')
    : (e.dept || '--');
  var rows = [
    ['Req / Receipt No.', e.rcavNo || 'Draft', 'full'],
    ['Date', e.date || '--', 'Time', e.time || '--'],
    ['Vehicle No.', e.vehicleNo || '--', 'Fuel Type', e.fuelType || '--'],
    ['Tank', e.tankName || '--', 'RCAV No.', e.rcavNo || '--'],
    ['Department / Unit', dept, 'full'],
    ['Driver Name', e.driver || '--', 'Emp No / CC No', e.badge || '--'],
    ['Odometer (Prev \u2192 Curr)', odo, 'full']
  ];
  if (e.remarks) rows.push(['Remarks', e.remarks, 'full']);
  return rows;
}

function showReceiptModal(rows, qty) {
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
  document.getElementById('receiptBody').innerHTML = html;
  window._rowReceiptData = rows;
  window._rowReceiptQty  = qty;
  $('#receiptModal').modal('show');
}

function previewReceipt(tab) {
  var e = {};
  if (tab === 'BARC') {
    var tankSel = document.getElementById('barcTankId');
    var tankOpt = tankSel ? tankSel.options[tankSel.selectedIndex] : null;
    e = {
      category  : 'BARC',
      rcavNo    : ($('#barcRcav').val()||'').trim() || 'Draft',
      date      : $('#barcDate').val() || '--',
      time      : $('#barcTime').val() || '--',
      vehicleNo : $('#barcVnoInput').val() || '--',
      fuelType  : $('#barcFuelType').val() || '--',
      tankName  : tankOpt ? tankOpt.text : '--',
      driver    : $('#barcDriver').val() || '--',
      badge     : $('#barcBadge').val() || '--',
      dept      : $('#barcDept').val() || '--',
      prevOdo   : parseFloat($('#barcPrevKm').val()) || 0,
      currOdo   : parseFloat($('#barcCurKm').val())  || 0,
      remarks   : ($('#formBARC textarea[name=remarks]').val() || $('input[name=remarks]').first().val() || '').trim()
    };
  } else if (tab === 'UNIT') {
    var tankSelU = document.getElementById('unitTankId');
    var tankOptU = tankSelU ? tankSelU.options[tankSelU.selectedIndex] : null;
    e = {
      category  : 'UNIT',
      rcavNo    : ($('#unitRcav').val()||'').trim() || 'Draft',
      date      : $('#unitDate').val() || '--',
      time      : $('#unitTime').val() || '--',
      vehicleNo : $('#unitVnoInput').val() || '--',
      fuelType  : $('#unitFuelType').val() || '--',
      tankName  : tankOptU ? tankOptU.text : '--',
      driver    : $('#unitDriver').val() || '--',
      badge     : $('#unitContact').val() || '--',
      orgName   : $('#unitOrg').val() || '--',
      dept      : '',
      prevOdo   : parseFloat($('#unitPrevKm').val()) || 0,
      currOdo   : parseFloat($('#unitCurKm').val())  || 0,
      remarks   : ($('#formUNIT textarea[name=remarks]').val() || '').trim()
    };
  } else {
    var tankSelL = document.getElementById('looseTankId');
    var tankOptL = tankSelL ? tankSelL.options[tankSelL.selectedIndex] : null;
    e = {
      category  : 'LOOSE',
      rcavNo    : ($('#looseRcav').val()||'').trim() || 'Draft',
      date      : $('#looseDate').val() || '--',
      time      : $('#looseTime').val() || '--',
      vehicleNo : $('input[name=vehicleNo]').val() || '--',
      fuelType  : $('#looseFuelType').val() || '--',
      tankName  : tankOptL ? tankOptL.text : '--',
      driver    : $('input[name=driverName]').val() || '--',
      badge     : $('input[name=driverBadge]').val() || '--',
      dept      : ($('input[name=department]').val() || '--'),
      prevOdo   : 0,
      currOdo   : 0,
      remarks   : ($('input[name=remarks]').last().val() || '').trim()
    };
  }
  var qty = parseFloat(
    $('#' + tab.toLowerCase() + 'Qty').val() ||
    $('input[name=qtyIssued]').last().val() || '0'
  ).toFixed(1);
  window._receiptTitle = 'Fuel Receipt - ' + (e.vehicleNo || e.rcavNo || '');
  var rows = buildReceiptRows(e);
  showReceiptModal(rows, qty);
}

function printReceiptPDF() {
  var rows  = window._rowReceiptData || [];
  var qty   = window._rowReceiptQty  || '--';
  var title = window._receiptTitle   || 'Fuel Dispense Receipt';
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


</script>
