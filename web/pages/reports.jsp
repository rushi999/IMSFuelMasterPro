<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt"%>
<%
  if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
  }
  pageContext.setAttribute("activePage","reports");
  pageContext.setAttribute("pageTitle", "Reports");
  String rType = (String) request.getAttribute("reportType");
  if (rType == null) rType = "DAILY";
  pageContext.setAttribute("rType", rType);

  /* Today's date for default from/to */
  java.util.Date today = new java.util.Date();
  java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
  String todayStr = sdf.format(today);

  java.util.Date fromDate = (java.util.Date) request.getAttribute("fromDate");
  java.util.Date toDate   = (java.util.Date) request.getAttribute("toDate");
  String fromStr = (fromDate != null) ? sdf.format(fromDate) : todayStr;
  String toStr   = (toDate   != null) ? sdf.format(toDate)   : todayStr;
  pageContext.setAttribute("fromStr", fromStr);
  pageContext.setAttribute("toStr",   toStr);
  pageContext.setAttribute("rMonth", request.getAttribute("reportMonth"));
  pageContext.setAttribute("rYear",  request.getAttribute("reportYear"));
%>
<%@ include file="header.jsp" %>

<div class="container-fluid ims-main-content">
  <div class="ims-page-header">
    <h2><i class="fa fa-file-text-o"></i> Reports Module</h2>
    <span class="ims-badge-tag">Analytics</span>
    <span class="pull-right text-muted" style="font-size:12px;margin-top:8px">
      <i class="fa fa-clock-o"></i> Auto-generate: 17:00 IST daily
    </span>
  </div>

  <ul class="nav nav-tabs ims-form-tabs">
    <li class="${rType ne 'MONTHLY' ? 'active':''}">
      <a href="#tabDaily" data-toggle="tab"><i class="fa fa-calendar-check-o"></i> Daily Sheet</a>
    </li>
    <li class="${rType eq 'MONTHLY' ? 'active':''}">
      <a href="#tabRCAV" data-toggle="tab"><i class="fa fa-bar-chart"></i> Monthly RCAV Report</a>
    </li>
  </ul>

  <div class="tab-content ims-tab-content">

    <!-- ═══════════════════════════════════════════
         DAILY SHEET — Fix #5: from/to date range
    ═══════════════════════════════════════════ -->
    <div class="tab-pane ${rType ne 'MONTHLY' ? 'active':''}" id="tabDaily">

      <form method="get" action="<%=request.getContextPath()%>/ReportServlet"
            class="ims-filter-bar" id="dailyForm">
        <input type="hidden" name="reportType" value="DAILY">
        <div class="form-inline" style="flex-wrap:wrap;gap:8px">

          <!-- Fix #5: FROM date -->
          <div class="form-group">
            <label><i class="fa fa-calendar"></i> From &nbsp;</label>
            <input type="date" name="fromDate" id="fromDatePick"
                   class="form-control ims-input-sm" value="${fromStr}">
          </div>

          <!-- Fix #5: TO date -->
          <div class="form-group">
            <label>To &nbsp;</label>
            <input type="date" name="toDate" id="toDatePick"
                   class="form-control ims-input-sm" value="${toStr}">
          </div>

          <div class="form-group">
            <label>Category &nbsp;</label>
            <select name="category" class="form-control ims-select-sm">
              <option value="">All</option>
              <option value="BARC"  ${category eq 'BARC'  ? 'selected':''}>BARC Vehicles</option>
              <option value="UNIT"  ${category eq 'UNIT'  ? 'selected':''}>Other Units</option>
              <option value="LOOSE" ${category eq 'LOOSE' ? 'selected':''}>Loose Supply</option>
            </select>
          </div>

          <button type="submit" class="btn ims-btn-primary btn-sm">
            <i class="fa fa-refresh"></i> Generate
          </button>
          <button type="button" class="btn ims-btn-secondary btn-sm" onclick="exportDailyExcel()">
            <i class="fa fa-file-excel-o"></i> Excel
          </button>
          <button type="button" class="btn btn-default btn-sm" onclick="window.print()">
            <i class="fa fa-print"></i> Print
          </button>

          <!-- Quick selectors -->
          <button type="button" class="btn btn-default btn-xs" onclick="setToday()">Today</button>
          <button type="button" class="btn btn-default btn-xs" onclick="setThisWeek()">This Week</button>
          <button type="button" class="btn btn-default btn-xs" onclick="setThisMonth()">This Month</button>
        </div>
      </form>

      <!-- Daily sheet table -->
      <div class="panel panel-default ims-panel ims-report-panel" id="dailyPrintArea">
        <div class="panel-heading ims-report-header">
          <div class="row">
            <div class="col-sm-8">
              <h4 class="ims-report-title">
                DAILY FUEL DISBURSEMENT REGISTER<br>
                <small>Bhabha Atomic Research Centre — Transport Section</small>
              </h4>
            </div>
            <div class="col-sm-4 text-right">
              <div class="ims-report-meta">
                <c:choose>
                  <c:when test="${fromStr eq toStr}">
                    <strong>Date:</strong>
                    <fmt:parseDate value="${fromStr}" pattern="yyyy-MM-dd" var="fd"/>
                    <fmt:formatDate value="${fd}" pattern="dd-MMM-yyyy"/>
                  </c:when>
                  <c:otherwise>
                    <strong>From:</strong>
                    <fmt:parseDate value="${fromStr}" pattern="yyyy-MM-dd" var="fd"/>
                    <fmt:formatDate value="${fd}" pattern="dd-MMM-yyyy"/>
                    <strong> To:</strong>
                    <fmt:parseDate value="${toStr}"  pattern="yyyy-MM-dd" var="td"/>
                    <fmt:formatDate value="${td}" pattern="dd-MMM-yyyy"/>
                  </c:otherwise>
                </c:choose>
                <br>
                <strong>Generated:</strong>
                <fmt:formatDate value="<%=new java.util.Date()%>" pattern="dd-MMM-yyyy HH:mm"/>
              </div>
            </div>
          </div>
        </div>

        <div class="table-responsive">
          <table class="table table-bordered table-hover ims-table ims-report-table" id="dailyTable">
            <thead>
              <tr class="ims-report-thead">
                <th>#</th>
                <th>Req. No.</th>
                <th>Date</th>
                <th>Time</th>
                <th>Vehicle No.</th>
                <th>Category</th>
                <th>Fuel</th>
                <th>RCAV No.</th>
                <th>Dept / Unit</th>
                <th>Driver</th>
                <th>Prev KM</th>
                <th>Curr KM</th>
                <th>Dist</th>
                <th>Issued (L)</th>
                <th>Avg km/L</th>
                <th>Issued By</th>
                <th>Remarks</th>
                <th>Driver Sign</th>
                <th>Officer Sign</th>
                <th>Receipt</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty dailyList}">
                  <c:forEach var="e" items="${dailyList}" varStatus="st">
                  <tr>
                    <td>${st.count}</td>
                    <td class="ims-mono">${e.reqNo}</td>
                    <td class="ims-mono" style="white-space:nowrap">
                      <c:if test="${not empty e.entryDate}">
                        <fmt:formatDate value="${e.entryDate}" pattern="dd-MMM-yyyy"/>
                      </c:if>
                    </td>
                    <td class="ims-mono">${not empty e.entryTime ? e.entryTime : '&mdash;'}</td>
                    <td class="ims-mono ims-accent"><strong>${e.vehicleNo}</strong></td>
                    <td>
                      <span class="label
                        <c:choose>
                          <c:when test="${e.entryCategory eq 'BARC'}">label-primary</c:when>
                          <c:when test="${e.entryCategory eq 'UNIT'}">label-info</c:when>
                          <c:otherwise>label-warning</c:otherwise>
                        </c:choose>">${e.entryCategory}</span>
                    </td>
                    <td>
                      <span class="label ${e.fuelType eq 'DIESEL' ? 'label-primary':'label-danger'}">
                        ${e.fuelType}
                      </span>
                    </td>
                    <td class="ims-mono">${not empty e.rcavNo ? e.rcavNo : '&mdash;'}</td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty e.department}">${e.department}</c:when>
                        <c:when test="${not empty e.orgName}">${e.orgName}</c:when>
                        <c:otherwise>&mdash;</c:otherwise>
                      </c:choose>
                    </td>
                    <td>${not empty e.driverName ? e.driverName : '&mdash;'}</td>
                    <td class="ims-mono">${e.prevOdometer > 0 ? e.prevOdometer : '&mdash;'}</td>
                    <td class="ims-mono">${e.currOdometer > 0 ? e.currOdometer : '&mdash;'}</td>
                    <td class="ims-mono">${e.distanceKm > 0 ? e.distanceKm : '&mdash;'}</td>
                    <td class="ims-mono ims-green">
                      <strong><fmt:formatNumber value="${e.qtyIssued}" pattern="0.##"/> L</strong>
                    </td>
                    <td class="ims-mono">${e.avgMileage > 0 ? e.avgMileage : '&mdash;'}</td>
                    <td>${not empty e.issuedBy ? e.issuedBy : '&mdash;'}</td>
                    <td style="max-width:120px;word-break:break-word">
                      ${not empty e.remarks ? e.remarks : '&mdash;'}
                    </td>
                    <td class="ims-sig-cell"></td>
                    <td class="ims-sig-cell"></td>
                    <td>
                      <button type="button" class="btn btn-default btn-xs"
                              title="View Receipt"
                              onclick='viewDailyReceipt(${st.index})'>
                        <i class="fa fa-file-text-o"></i>
                      </button>
                    </td>
                  </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="20" class="text-center ims-no-data">
                      <i class="fa fa-inbox fa-2x"></i><br>
                      No records found for selected date range.<br>
                      <small>Select date range and click Generate.</small>
                    </td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
            <tfoot>
              <tr class="ims-report-tfoot">
                <td colspan="13" class="text-right"><strong>TOTALS:</strong></td>
                <td class="ims-mono">
                  <strong><fmt:formatNumber value="${grandTotal}" pattern="0.##"/> L</strong>
                </td>
                <td colspan="6"></td>
              </tr>
              <tr class="ims-totals-row">
                <td colspan="20">
                  <strong>Diesel:</strong> <fmt:formatNumber value="${totalDiesel}" pattern="0.##"/> L
                  &nbsp;|&nbsp;
                  <strong>Petrol:</strong> <fmt:formatNumber value="${totalPetrol}" pattern="0.##"/> L
                  &nbsp;|&nbsp;
                  <strong>Records:</strong> ${not empty dailyList ? dailyList.size() : 0}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>

      <!-- Embed daily data for JS receipt preview -->
      <script>
      var _dailyData = [
        <c:forEach var="e" items="${dailyList}" varStatus="st">
          <c:if test="${st.index > 0}">,</c:if>
          {
            reqNo:      "<c:out value='${e.reqNo}'/>",
            entryDate:  "<c:if test='${not empty e.entryDate}'><fmt:formatDate value='${e.entryDate}' pattern='dd-MMM-yyyy'/></c:if>",
            entryTime:  "<c:out value='${e.entryTime}'/>",
            vehicleNo:  "<c:out value='${e.vehicleNo}'/>",
            vehicleType:"<c:out value='${e.vehicleType}'/>",
            category:   "<c:out value='${e.entryCategory}'/>",
            fuelType:   "<c:out value='${e.fuelType}'/>",
            qtyIssued:  "${e.qtyIssued}",
            rcavNo:     "<c:out value='${e.rcavNo}'/>",
            driverName: "<c:out value='${e.driverName}'/>",
            department: "<c:out value='${not empty e.department ? e.department : e.orgName}'/>",
            prevKm:     "${e.prevOdometer > 0 ? e.prevOdometer : ''}",
            currKm:     "${e.currOdometer > 0 ? e.currOdometer : ''}",
            avgMileage: "${e.avgMileage > 0 ? e.avgMileage : ''}",
            issuedBy:   "<c:out value='${e.issuedBy}'/>",
            tankName:   "<c:out value='${e.tankName}'/>",
            driverBadge:"<c:out value='${e.driverBadge}'/>",
            remarks:    "<c:out value='${e.remarks}'/>"
          }
        </c:forEach>
      ];
      </script>
    </div><!-- /tabDaily -->

    <!-- ═══════════════════════════════════════════
         RCAV MONTHLY — Fix #6: Unit column, full receipt
    ═══════════════════════════════════════════ -->
    <div class="tab-pane ${rType eq 'MONTHLY' ? 'active':''}" id="tabRCAV">

      <form method="get" action="<%=request.getContextPath()%>/ReportServlet"
            class="ims-filter-bar" id="rcavForm">
        <input type="hidden" name="reportType" value="MONTHLY">
        <div class="form-inline" style="gap:8px">
          <div class="form-group">
            <label><i class="fa fa-calendar"></i> Month &nbsp;</label>
            <select name="month" class="form-control ims-select-sm" id="rcavMonth">
              <c:forEach begin="1" end="12" var="m">
                <option value="${m}" ${rMonth == m ? 'selected':''}>
                  <c:choose>
                    <c:when test="${m==1}">January</c:when><c:when test="${m==2}">February</c:when>
                    <c:when test="${m==3}">March</c:when><c:when test="${m==4}">April</c:when>
                    <c:when test="${m==5}">May</c:when><c:when test="${m==6}">June</c:when>
                    <c:when test="${m==7}">July</c:when><c:when test="${m==8}">August</c:when>
                    <c:when test="${m==9}">September</c:when><c:when test="${m==10}">October</c:when>
                    <c:when test="${m==11}">November</c:when><c:otherwise>December</c:otherwise>
                  </c:choose>
                </option>
              </c:forEach>
            </select>
          </div>
          &nbsp;
          <div class="form-group">
            <label>Year &nbsp;</label>
            <select name="year" class="form-control ims-select-sm" id="rcavYear">
              <option value="2026" ${rYear==2026?'selected':''}>2026</option>
              <option value="2025" ${rYear==2025?'selected':''}>2025</option>
              <option value="2024" ${rYear==2024?'selected':''}>2024</option>
              <option value="2023" ${rYear==2023?'selected':''}>2023</option>
            </select>
          </div>
          &nbsp;
          <div class="form-group">
            <label>Category &nbsp;</label>
            <select name="rcavCategory" class="form-control ims-select-sm">
              <option value="">All Units</option>
              <option value="BARC"  ${param.rcavCategory eq 'BARC'  ? 'selected':''}>BARC Vehicles</option>
              <option value="UNIT"  ${param.rcavCategory eq 'UNIT'  ? 'selected':''}>Other DAE Units</option>
              <option value="LOOSE" ${param.rcavCategory eq 'LOOSE' ? 'selected':''}>Loose Supply</option>
            </select>
          </div>
          &nbsp;
          <button type="submit" class="btn ims-btn-primary btn-sm">
            <i class="fa fa-refresh"></i> Generate RCAV
          </button>
          <button type="button" class="btn ims-btn-secondary btn-sm" onclick="exportRCAVExcel()">
            <i class="fa fa-file-excel-o"></i> Excel
          </button>
          <button type="button" class="btn btn-default btn-sm" onclick="window.print()">
            <i class="fa fa-print"></i> Print
          </button>
        </div>
      </form>

      <div class="panel panel-default ims-panel ims-report-panel">
        <div class="panel-heading ims-report-header">
          <div class="row">
            <div class="col-sm-8">
              <h4 class="ims-report-title">
                RCAV &mdash; REGISTER OF CONSUMPTION AND AVERAGE VEHICLE<br>
                <small>Bhabha Atomic Research Centre — Transport Section</small>
              </h4>
            </div>
            <div class="col-sm-4 text-right">
              <div class="ims-report-meta">
                <c:if test="${not empty rMonth}">
                  <strong>Period:</strong> ${rMonth}/${rYear}<br>
                </c:if>
                <strong>Generated:</strong>
                <fmt:formatDate value="<%=new java.util.Date()%>" pattern="dd-MMM-yyyy HH:mm"/>
              </div>
            </div>
          </div>
        </div>

        <div class="table-responsive">
          <table class="table table-bordered table-hover ims-table ims-report-table">
            <thead>
              <tr class="ims-report-thead">
                <th>#</th>
                <th>Vehicle No.</th>
                <th>Category</th>
                <th>Unit / Organisation</th>  <!-- merged: was Unit/Dept + Org Name -->
                <th>Vehicle Type</th>
                <th>Driver</th>
                <th>Open KM</th>
                <th>Close KM</th>
                <th>Total KM</th>
                <th>Diesel (L)</th>
                <th>Petrol (L)</th>
                <th>Total Fuel</th>
                <th>Avg km/L</th>
                <th>Performance</th>
                <th>Receipt</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty rcavList}">
                  <c:forEach var="e" items="${rcavList}" varStatus="st">
                    <td>${st.count}</td>
                    <td class="ims-mono ims-accent"><strong>${e.vehicleNo}</strong></td>
                    <td>
                      <c:choose>
                        <c:when test="${e.entryCategory eq 'BARC'}"><span class="label label-primary">BARC</span></c:when>
                        <c:when test="${e.entryCategory eq 'UNIT'}"><span class="label label-info">Other Unit</span></c:when>
                        <c:when test="${e.entryCategory eq 'LOOSE'}"><span class="label label-warning">Loose</span></c:when>
                        <c:otherwise><span class="label label-default">${not empty e.entryCategory ? e.entryCategory : 'N/A'}</span></c:otherwise>
                      </c:choose>
                    </td>
                    <%-- Smart unit/org column: show the right name by category --%>
                    <td>
                      <c:choose>
                        <c:when test="${e.entryCategory eq 'UNIT'}">
                          <%-- For Other Units: prefer orgName (from UNIT_MASTER), fall back to department --%>
                          <c:choose>
                            <c:when test="${not empty e.orgName}">${e.orgName}</c:when>
                            <c:when test="${not empty e.department}">${e.department}</c:when>
                            <c:otherwise>&mdash;</c:otherwise>
                          </c:choose>
                        </c:when>
                        <c:otherwise>
                          <%-- For BARC/LOOSE: show department --%>
                          <c:choose>
                            <c:when test="${not empty e.department}">${e.department}</c:when>
                            <c:otherwise>BARC</c:otherwise>
                          </c:choose>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>${not empty e.vehicleType ? e.vehicleType : '&mdash;'}</td>
                    <td>${not empty e.driverName  ? e.driverName  : '&mdash;'}</td>
                    <td class="ims-mono">${e.prevOdometer > 0 ? e.prevOdometer : '&mdash;'}</td>
                    <td class="ims-mono">${e.currOdometer > 0 ? e.currOdometer : '&mdash;'}</td>
                    <td class="ims-mono"><strong>${e.distanceKm > 0 ? e.distanceKm : '&mdash;'}</strong></td>
                    <%-- purpose holds diesel, supplyType holds petrol from DAO --%>
                    <td class="ims-mono">
                      <c:choose>
                        <c:when test="${e.purpose ne '0.0' && e.purpose ne '0'}">${e.purpose} L</c:when>
                        <c:otherwise>&mdash;</c:otherwise>
                      </c:choose>
                    </td>
                    <td class="ims-mono">
                      <c:choose>
                        <c:when test="${e.supplyType ne '0.0' && e.supplyType ne '0'}">${e.supplyType} L</c:when>
                        <c:otherwise>&mdash;</c:otherwise>
                      </c:choose>
                    </td>
                    <td class="ims-mono ims-green">
                      <strong><fmt:formatNumber value="${e.qtyIssued}" pattern="0.##"/> L</strong>
                    </td>
                    <td class="ims-mono">
                      <c:choose>
                        <c:when test="${e.avgMileage >= 12}"><span class="text-success">${e.avgMileage}</span></c:when>
                        <c:when test="${e.avgMileage >= 8}"> <span class="text-warning">${e.avgMileage}</span></c:when>
                        <c:when test="${e.avgMileage > 0}">  <span class="text-danger">${e.avgMileage}</span></c:when>
                        <c:otherwise>&mdash;</c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${e.avgMileage >= 12}"><span class="label label-success">Good</span></c:when>
                        <c:when test="${e.avgMileage >= 8}"> <span class="label label-warning">Average</span></c:when>
                        <c:when test="${e.avgMileage > 0}">  <span class="label label-danger">Poor</span></c:when>
                        <c:otherwise><span class="label label-default">N/A</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <button type="button" class="btn btn-default btn-xs"
                              onclick='viewRcavReceipt(${st.index})'
                              title="View Receipt">
                        <i class="fa fa-file-text-o"></i>
                      </button>
                    </td>
                  </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="15" class="text-center ims-no-data">
                      <i class="fa fa-bar-chart fa-2x"></i><br>
                      No RCAV data for selected period.<br>
                      <small>Select month/year and click Generate RCAV.</small>
                    </td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
            <tfoot>
              <tr class="ims-report-tfoot">
                <td colspan="15" style="font-size:11px;color:#7090b0">
                  RCAV &mdash; Register of Consumption and Average Vehicle |
                  BARC Transport Section | ${rMonth}/${rYear}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>

      <!-- Embed RCAV data for JS receipt -->
      <script>
      var _rcavData = [
        <c:forEach var="e" items="${rcavList}" varStatus="st">
          <c:if test="${st.index > 0}">,</c:if>
          {
            vehicleNo:  "<c:out value='${e.vehicleNo}'/>",
            vehicleType:"<c:out value='${e.vehicleType}'/>",
            unitOrg:    "<c:out value='${e.entryCategory eq "UNIT" ? (not empty e.orgName ? e.orgName : e.department) : (not empty e.department ? e.department : "BARC")}'/>",
            driverName: "<c:out value='${e.driverName}'/>",
            openKm:     "${e.prevOdometer}",
            closeKm:    "${e.currOdometer}",
            totalKm:    "${e.distanceKm}",
            diesel:     "${e.purpose}",
            petrol:     "${e.supplyType}",
            totalFuel:  "${e.qtyIssued}",
            avgMileage: "${e.avgMileage}",
            period:     "${rMonth}/${rYear}"
          }
        </c:forEach>
      ];
      </script>
    </div><!-- /tabRCAV -->

  </div><!-- /tab-content -->
</div>

<!-- ROW RECEIPT MODAL -->
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
          <!-- No Print button (Fix #4) — Download PDF only -->
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



<style>
/* 2-col receipt grid */
.ims-rcpt-grid{display:grid;grid-template-columns:1fr 1fr;gap:0;margin-bottom:12px}
.ims-rcpt-cell{padding:7px 12px 6px;border-bottom:1px solid rgba(99,179,255,0.08);border-right:1px solid rgba(99,179,255,0.06)}
.ims-rcpt-cell:nth-child(even){border-right:none}
.ims-rcpt-full{grid-column:1/-1 !important;border-right:none !important}
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

<script>
var IMS_CTX = '<%=request.getContextPath()%>';
if(typeof _dailyData==='undefined') _dailyData=[];
if(typeof _rcavData==='undefined')  _rcavData=[];
var _currentReceiptRows = [];
var _currentReceiptTitle = '';

/* ── Default dates ── */
$(document).ready(function(){
  var now = new Date();
  var td  = now.toISOString().split('T')[0];
  if (!$('#fromDatePick').val()) $('#fromDatePick').val(td);
  if (!$('#toDatePick').val())   $('#toDatePick').val(td);
  /* Ensure toDate >= fromDate */
  $('#fromDatePick').on('change', function(){
    if ($('#toDatePick').val() < this.value) $('#toDatePick').val(this.value);
  });
});

/* ── Quick date helpers ── */
function setToday() {
  var td = new Date().toISOString().split('T')[0];
  $('#fromDatePick,#toDatePick').val(td);
}
function setThisWeek() {
  var now = new Date();
  var day = now.getDay(); /* 0=Sun */
  var mon = new Date(now); mon.setDate(now.getDate() - (day===0?6:day-1));
  $('#fromDatePick').val(mon.toISOString().split('T')[0]);
  $('#toDatePick').val(now.toISOString().split('T')[0]);
}
function setThisMonth() {
  var now = new Date();
  var first = new Date(now.getFullYear(), now.getMonth(), 1);
  $('#fromDatePick').val(first.toISOString().split('T')[0]);
  $('#toDatePick').val(now.toISOString().split('T')[0]);
}

/* ── Excel exports ── */
function exportDailyExcel() {
  var url = IMS_CTX+'/ReportServlet?reportType=DAILY&export=excel' +
    '&fromDate='+$('#fromDatePick').val() +
    '&toDate='  +$('#toDatePick').val() +
    '&category='+$('select[name=category]').val();
  window.location.href = url;
}
function exportRCAVExcel() {
  var url = IMS_CTX+'/ReportServlet?reportType=MONTHLY&export=excel' +
    '&month='+$('#rcavMonth').val()+'&year='+$('#rcavYear').val() +
    '&rcavCategory='+encodeURIComponent($('select[name="rcavCategory"]').val()||'');
  window.location.href = url;
}

/* ── Daily row receipt (Fix #6: full data) ── */

function buildReceiptRows(e) {
  var prevK = parseFloat(e.prevKm || e.prevOdo || 0);
  var currK = parseFloat(e.currKm || e.currOdo || 0);
  var odo   = (prevK > 0 || currK > 0)
    ? (prevK > 0 ? prevK.toLocaleString() : '--') + ' \u2192 ' +
      (currK > 0 ? currK.toLocaleString() : '--') + ' km'
    : '--';
  var dept  = (e.category === 'UNIT')
    ? (e.orgName || e.department || '--')
    : (e.department || e.orgName || '--');
  var badge = String(e.driverBadge || e.employeeNo || '--');
  var rows  = [
    ['Req / Receipt No.', e.reqNo || '--', 'full'],
    ['Date', e.entryDate || '--', 'Time', e.entryTime || '--'],
    ['Vehicle No.', e.vehicleNo || '--', 'Fuel Type', e.fuelType || '--'],
    ['Tank', e.tankName || '--', 'RCAV No.', e.rcavNo || '--'],
    ['Department / Unit', dept, 'full'],
    ['Driver Name', e.driverName || '--', 'Emp No / CC No', badge],
    ['Odometer (Prev \u2192 Curr)', odo, 'full']
  ];
  if (e.remarks) rows.push(['Remarks', e.remarks, 'full']);
  return rows;
}

function showRowReceiptModal(rows, qty) {
  var html = '<div class="ims-rcpt-grid">';
  rows.forEach(function(r) {
    if (r.length === 4) {
      html += '<div class="ims-rcpt-cell"><div class="ims-rcpt-key">' + r[0] +
              '</div><div class="ims-rcpt-val">' + r[1] + '</div></div>' +
              '<div class="ims-rcpt-cell"><div class="ims-rcpt-key">' + r[2] +
              '</div><div class="ims-rcpt-val">' + r[3] + '</div></div>';
    } else {
      html += '<div class="ims-rcpt-cell ims-rcpt-full"><div class="ims-rcpt-key">' +
              r[0] + '</div><div class="ims-rcpt-val">' + r[1] + '</div></div>';
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

function viewDailyReceipt(idx) {
  if (typeof _dailyData === 'undefined' || !_dailyData ||
      idx < 0 || idx >= _dailyData.length) {
    alert('No receipt data. Please generate the report first.');
    return;
  }
  var e    = _dailyData[idx];
  var rows = buildReceiptRows(e);
  var qty  = parseFloat(e.qtyIssued || 0).toFixed(1);
  window._receiptTitle = 'Fuel Receipt - ' + (e.vehicleNo || e.reqNo || '');
  showRowReceiptModal(rows, qty);
}

function viewRcavReceipt(idx) {
  if (typeof _rcavData === 'undefined' || !_rcavData ||
      idx < 0 || idx >= _rcavData.length) return;
  var e = _rcavData[idx];
  var rows = [
    ['Period',       e.period      || '--', 'full'],
    ['Vehicle No.',  e.vehicleNo   || '--', 'Fuel Type',    e.fuelType    || '--'],
    ['Vehicle Type', e.vehicleType || '--', 'Unit / Org',   e.unitOrg     || '--'],
    ['Driver',       e.driverName  || '--', 'Emp No / CC No', String(e.driverBadge || '--')],
    ['Open KM',      e.openKm  ? e.openKm+' km'  : '--',
     'Close KM',     e.closeKm ? e.closeKm+' km' : '--'],
    ['Total KM',     e.totalKm ? e.totalKm+' km' : '--',
     'Avg Mileage',  (e.avgMileage && e.avgMileage !== '0') ? e.avgMileage+' km/L' : '--'],
    ['Diesel Issued',(e.diesel && e.diesel !== '0') ? e.diesel+' L' : '--',
     'Petrol Issued',(e.petrol && e.petrol !== '0') ? e.petrol+' L' : '--']
  ];
  window._rowReceiptData = rows;
  window._rowReceiptQty  = e.totalFuel || '--';
  window._receiptTitle   = 'RCAV - ' + (e.vehicleNo || '');
  showRowReceiptModal(rows, e.totalFuel ? e.totalFuel+' L' : '--');
}

function downloadRowPDF() {
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
  var html =
    '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>' + title + '</title>' +
    '<style>*{margin:0;padding:0;box-sizing:border-box}' +
    'body{font-family:Arial,sans-serif;font-size:12px;padding:20px;color:#111;max-width:580px;margin:0 auto}' +
    'h2{text-align:center;font-size:17px;color:#1a4080;margin-bottom:3px;letter-spacing:2px}' +
    '.sub{text-align:center;font-size:11px;color:#555;margin-bottom:2px}' +
    'hr{border:none;border-top:2px solid #1a4080;margin:10px 0}' +
    'table{width:100%;border-collapse:collapse;margin-bottom:14px}' +
    'td{padding:6px 10px;border-bottom:1px solid #eee;vertical-align:top}' +
    'td.k{color:#555;font-size:10px;text-transform:uppercase;letter-spacing:.7px;width:22%}' +
    'td.v{font-family:Courier New,monospace;font-weight:600;font-size:12px;width:28%}' +
    '.qty{display:flex;justify-content:space-between;padding:10px 12px;' +
    'border:2px solid #1a6ecc;border-radius:6px;margin-bottom:14px}' +
    '.qty-l{font-size:11px;text-transform:uppercase;letter-spacing:1px;color:#555;margin-top:2px}' +
    '.qty-v{font-family:Courier New,monospace;font-size:22px;font-weight:800;color:#007a40}' +
    '.sigs{display:flex;gap:30px;margin-top:40px}' +
    '.sig{flex:1;border-top:1px solid #aaa;padding-top:6px;text-align:center;font-size:11px;color:#666}' +
    '.footer{text-align:center;margin-top:16px;font-size:10px;color:#aaa;' +
    'border-top:1px dashed #ccc;padding-top:6px}' +
    '@media print{body{padding:10px}@page{size:A5;margin:12mm}}' +
    '</style></head><body>' +
    '<h2>&#9670; FUEL DISPENSE RECEIPT</h2>' +
    '<div class="sub">Bhabha Atomic Research Centre, Trombay, Mumbai 400085</div>' +
    '<div class="sub">Transport Section &mdash; IMS Fuel Master Pro</div><hr>' +
    '<table>' + tRows + '</table>' +
    '<div class="qty"><span class="qty-l">Quantity Issued</span>' +
    '<span class="qty-v">' + qty + ' L</span></div>' +
    '<div class="sigs">' +
    '<div class="sig">Issued By (Officer)<br><br><br>(Signature &amp; Date)</div>' +
    '<div class="sig">Driver / Receiver<br><br><br>(Signature &amp; Date)</div>' +
    '</div>' +
    '<div class="footer">IMS Fuel Master Pro &mdash; BARC Transport Section</div>' +
    '</body></html>';
  var blob   = new Blob([html], {type: 'text/html;charset=utf-8'});
  var url    = URL.createObjectURL(blob);
  var iframe = document.createElement('iframe');
  iframe.style.cssText = 'position:fixed;right:0;bottom:0;width:0;height:0;border:0';
  iframe.src = url;
  document.body.appendChild(iframe);
  iframe.onload = function() {
    setTimeout(function() {
      iframe.contentWindow.focus();
      iframe.contentWindow.print();
      setTimeout(function() {
        document.body.removeChild(iframe);
        URL.revokeObjectURL(url);
      }, 2000);
    }, 300);
  };
}

</script>

<%@ include file="footer.jsp" %>
