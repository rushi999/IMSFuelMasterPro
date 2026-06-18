<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         isErrorPage="true"%>
<%
  pageContext.setAttribute("activePage", "");
  pageContext.setAttribute("pageTitle",  "Error");
%>
<%@ include file="header.jsp" %>
<div class="container ims-main-content text-center" style="padding-top:80px">
  <div class="ims-error-icon"><i class="fa fa-exclamation-circle text-danger" style="font-size:72px"></i></div>
  <h2 class="text-danger">Oops! Something went wrong.</h2>
  <p class="text-muted">
    <%
      Integer code = (Integer) request.getAttribute("javax.servlet.error.status_code");
      String  msg  = (String)  request.getAttribute("javax.servlet.error.message");
      if (code != null) out.print("Error " + code + ": ");
      if (msg  != null && !msg.isEmpty()) out.print(msg);
      else out.print("An unexpected error occurred.");
    %>
  </p>
  <a href="<%=request.getContextPath()%>/pages/dashboard.jsp" class="btn ims-btn-primary">
    <i class="fa fa-home"></i> Back to Dashboard
  </a>
</div>
<%@ include file="footer.jsp" %>
