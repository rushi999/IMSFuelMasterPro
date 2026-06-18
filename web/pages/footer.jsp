<%-- footer.jsp v3 — includes nozzle animation JS --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<footer class="ims-footer">
  <div class="container-fluid">
    <div class="row">
      <div class="col-sm-6">
        <span>
          <i class="fa fa-tint text-info"></i>
          <strong>IMS Fuel Master Pro</strong> &mdash;
          Bhabha Atomic Research Centre, Trombay, Mumbai 400085
        </span>
      </div>
      <div class="col-sm-6 text-right">
        <span class="text-dark">
          Traffic Section &nbsp;|&nbsp;
          Personnel Division &nbsp;|&nbsp;
          v1.0 &nbsp;&copy; 2026
        </span>
      </div>
    </div>
  </div>
</footer>

<!-- JS load order is critical — do NOT change -->

<script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
<script src="${pageContext.request.contextPath}/js/ims-main.js"></script>
<!-- Nozzle animation — LAST so it can find all form elements -->
<script src="${pageContext.request.contextPath}/js/ims-nozzle.js"></script>
</body>
</html>
