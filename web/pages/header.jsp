<%-- header.jsp v3 — includes nozzle CSS --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>IMS Fuel Master Pro — BARC | ${pageTitle}</title>
  <script src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-theme.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-nozzle.css">
  <script>
    (function(){
      try {
        if(localStorage.getItem('ims_theme')==='light'){
          document.documentElement.className += ' ims-light-html';
        }
      } catch(e){}
    }());
  </script>
  <style>html.ims-light-html body{background:#f0f4f8!important}</style>
</head>
<body>
<script src="${pageContext.request.contextPath}/js/ims-theme.js"></script>

<nav class="navbar navbar-fixed-top ims-topbar">
  <div class="container-fluid">
    <div class="navbar-header">
    <button type="button" class="navbar-toggle collapsed"
            data-toggle="collapse" data-target="#mainNav">
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
    </button>

    <a class="navbar-brand ims-brand"
       href="${pageContext.request.contextPath}/pages/dashboard.jsp">

        <img src="${pageContext.request.contextPath}/images/BARC-Logo.png"
             alt="BARC Logo" height="46" width="46"
             class="navbar-logo">

        <span>IMS FUEL  Master <span class="brand-green">PRO</span></span>
    </a>
</div>
    <div class="collapse navbar-collapse" id="mainNav">
      <ul class="nav navbar-nav">
        <li class="${activePage eq 'dashboard'   ? 'active':''}">
          <a href="${pageContext.request.contextPath}/pages/dashboard.jsp">
            <i class="fa fa-tachometer"></i> Dashboard
          </a>
        </li>
        <li class="${activePage eq 'fuel_entry'  ? 'active':''}">
          <a href="${pageContext.request.contextPath}/pages/fuel_entry.jsp">
            <i class="fa fa-plus-circle"></i> Dispense Fuel
          </a>
        </li>
        <li class="${activePage eq 'reports'     ? 'active':''}">
          <a href="${pageContext.request.contextPath}/pages/reports.jsp">
            <i class="fa fa-file-text-o"></i> Reports
          </a>
        </li>
        <li class="dropdown ${activePage eq 'units_master' || activePage eq 'tank_master' ? 'active':''}">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            <i class="fa fa-database"></i> Masters <span class="caret"></span>
          </a>
          <ul class="dropdown-menu ims-user-menu">
            <li class="dropdown-header">
              <i class="fa fa-globe"></i> OTHER DAE UNITS
            </li>
            <li>
              <a href="${pageContext.request.contextPath}/pages/units_master.jsp">
                <i class="fa fa-building"></i> Unit Master
              </a>
            </li>
            <li>
              <a href="${pageContext.request.contextPath}/MasterServlet?section=vehicle">
                <i class="fa fa-car"></i> Vehicle Master
              </a>
            </li>
            <li>
              <a href="${pageContext.request.contextPath}/MasterServlet?section=driver">
                <i class="fa fa-id-card"></i> Driver Master
              </a>
            </li>
            <li role="separator" class="divider"></li>
            <li class="dropdown-header">
              <i class="fa fa-tint"></i> FUEL INFRASTRUCTURE
            </li>
            <li class="${activePage eq 'tank_master' ? 'active':''}">
              <a href="${pageContext.request.contextPath}/TankRefillServlet">
                <i class="fa fa-tint"></i> Tank Master &amp; Refill
              </a>
            </li>
          </ul>
        </li>
      </ul>

      <ul class="nav navbar-nav navbar-right ims-nav-right">
        <li>
          <a href="#" id="navClock" style="cursor:default">
            <i class="fa fa-clock-o"></i> --:--:--
          </a>
        </li>
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            <i class="fa fa-user-circle"></i>
            <c:out value="${sessionScope.fullName}"/>
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu ims-user-menu">
            <li class="dropdown-header">
              <c:out value="${sessionScope.role}"/> &mdash;
              <c:out value="${sessionScope.designation}"/>
            </li>
            <li role="separator" class="divider"></li>
            <li>
              <a href="${pageContext.request.contextPath}/LoginServlet?action=logout">
                <i class="fa fa-sign-out"></i> Logout
              </a>
            </li>
          </ul>
        </li>
        <li>
          <a class="ims-live-badge" style="cursor:default">
            <span class="ims-live-dot"></span>LIVE
          </a>
        </li>
      </ul>
    </div>
  </div>
</nav>

<!-- Flash messages -->
<div class="container-fluid ims-flash-area" style="margin-top:60px">
  <c:if test="${not empty sessionScope.successMsg}">
    <div class="alert alert-success alert-dismissible ims-alert">
      <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
      <i class="fa fa-check-circle"></i> <c:out value="${sessionScope.successMsg}"/>
    </div>
    <c:remove var="successMsg" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.errorMsg}">
    <div class="alert alert-danger alert-dismissible ims-alert">
      <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
      <i class="fa fa-exclamation-triangle"></i> <c:out value="${sessionScope.errorMsg}"/>
    </div>
    <c:remove var="errorMsg" scope="session"/>
  </c:if>
</div>
