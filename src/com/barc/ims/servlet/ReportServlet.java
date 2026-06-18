package com.barc.ims.servlet;

import com.barc.ims.dao.FuelEntryDAO;
import com.barc.ims.model.FuelEntry;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;

/**
 * ReportServlet v3
 * - Daily: fromDate + toDate range filter
 * - RCAV: includes Unit/Org column, diesel+petrol splits
 * - Excel export for both types
 */
public class ReportServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String reportType = req.getParameter("reportType");
        String export     = req.getParameter("export");

        if ("excel".equals(export)) {
            if ("MONTHLY".equalsIgnoreCase(reportType)) exportMonthlyExcel(req, res);
            else                                        exportDailyExcel(req, res);
            return;
        }

        String category  = req.getParameter("category");
        try {
            FuelEntryDAO dao = new FuelEntryDAO();

            if ("MONTHLY".equalsIgnoreCase(reportType)) {
                int month = getInt(req,"month", Calendar.getInstance().get(Calendar.MONTH)+1);
                int year  = getInt(req,"year",  Calendar.getInstance().get(Calendar.YEAR));
                String rcavCat = req.getParameter("rcavCategory"); // null = all
                List rcavListAll = dao.getMonthlyRCAV(month, year);
                /* Filter by category if specified */
                List rcavList = new ArrayList();
                for (Object obj : rcavListAll) {
                    FuelEntry fe = (FuelEntry) obj;
                    if (rcavCat == null || rcavCat.isEmpty() ||
                        rcavCat.equalsIgnoreCase(fe.getEntryCategory())) {
                        rcavList.add(fe);
                    }
                }
                req.setAttribute("rcavList",    rcavList);
                req.setAttribute("reportMonth", month);
                req.setAttribute("reportYear",  year);
                req.setAttribute("rcavCatFilter", rcavCat);

            } else {
                /* Daily: parse fromDate & toDate */
                Date fromDate = parseDate(req.getParameter("fromDate"), new Date());
                Date toDate   = parseDate(req.getParameter("toDate"),   fromDate);
                // toDate must be >= fromDate
                if (toDate.before(fromDate)) toDate = fromDate;

                List dailyList = dao.getDailyEntries(fromDate, toDate, category);
                req.setAttribute("dailyList",  dailyList);
                req.setAttribute("fromDate",   fromDate);
                req.setAttribute("toDate",     toDate);
                req.setAttribute("category",   category);

                double diesel = 0, petrol = 0;
                for (Object o : dailyList) {
                    FuelEntry e = (FuelEntry) o;
                    if ("DIESEL".equals(e.getFuelType())) diesel += e.getQtyIssued();
                    else                                   petrol += e.getQtyIssued();
                }
                req.setAttribute("totalDiesel", diesel);
                req.setAttribute("totalPetrol", petrol);
                req.setAttribute("grandTotal",  diesel + petrol);
            }

            req.setAttribute("reportType", reportType);
            req.getRequestDispatcher("/pages/reports.jsp").forward(req, res);

        } catch (Exception e) {
            req.setAttribute("errorMsg", "Report error: " + e.getMessage());
            req.getRequestDispatcher("/pages/reports.jsp").forward(req, res);
        }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException { doGet(req, res); }

    /* ══ Excel: Daily ══ */
    private void exportDailyExcel(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        Date fromDate = parseDate(req.getParameter("fromDate"), new Date());
        Date toDate   = parseDate(req.getParameter("toDate"),   fromDate);
        if (toDate.before(fromDate)) toDate = fromDate;
        String category = req.getParameter("category");

        List list = new ArrayList();
        try { list = new FuelEntryDAO().getDailyEntries(fromDate, toDate, category); }
        catch (Exception e) {}

        SimpleDateFormat df = new SimpleDateFormat("ddMMMyyyy");
        String fname = "DailyFuel_" + df.format(fromDate) +
                       (toDate.equals(fromDate) ? "" : "_to_"+df.format(toDate)) + ".xls";
        res.setContentType("application/vnd.ms-excel");
        res.setHeader("Content-Disposition","attachment; filename=\""+fname+"\"");

        PrintWriter out = res.getWriter();
        out.println("<html><head><meta charset='UTF-8'></head><body>");
        out.println("<h2>DAILY FUEL DISBURSEMENT REGISTER — BARC</h2>");
        out.println("<p>From: " + new SimpleDateFormat("dd-MMM-yyyy").format(fromDate) +
                    " &nbsp; To: " + new SimpleDateFormat("dd-MMM-yyyy").format(toDate) + "</p>");
        out.println("<table border='1' cellpadding='4'>");
        out.println("<tr style='background:#1a4080;color:white;font-weight:bold'>" +
            "<th>#</th><th>Req.No</th><th>Date</th><th>Time</th>" +
            "<th>Vehicle No</th><th>Category</th><th>Fuel</th>" +
            "<th>Prev KM</th><th>Curr KM</th><th>Dist</th>" +
            "<th>Issued(L)</th><th>Avg km/L</th><th>RCAV No</th>" +
            "<th>Driver</th><th>Dept/Unit</th><th>Issued By</th><th>Remarks</th></tr>");
        double diesel=0, petrol=0;
        SimpleDateFormat dtf = new SimpleDateFormat("dd-MMM-yyyy");
        for (int i=0; i<list.size(); i++) {
            FuelEntry e = (FuelEntry)list.get(i);
            String bg = i%2==0?"#fff":"#f5f8fc";
            out.println("<tr style='background:"+bg+"'>" +
                "<td>"+(i+1)+"</td>" +
                "<td>"+nvl(e.getReqNo())+"</td>" +
                "<td>"+(e.getEntryDate()!=null?dtf.format(e.getEntryDate()):"")+"</td>" +
                "<td>"+nvl(e.getEntryTime())+"</td>" +
                "<td><b>"+nvl(e.getVehicleNo())+"</b></td>" +
                "<td>"+nvl(e.getEntryCategory())+"</td>" +
                "<td>"+nvl(e.getFuelType())+"</td>" +
                "<td>"+(e.getPrevOdometer()>0?e.getPrevOdometer():"")+"</td>" +
                "<td>"+(e.getCurrOdometer()>0?e.getCurrOdometer():"")+"</td>" +
                "<td>"+(e.getDistanceKm()>0?e.getDistanceKm():"")+"</td>" +
                "<td><b>"+e.getQtyIssued()+" L</b></td>" +
                "<td>"+(e.getAvgMileage()>0?e.getAvgMileage():"")+"</td>" +
                "<td>"+nvl(e.getRcavNo())+"</td>" +
                "<td>"+nvl(e.getDriverName())+"</td>" +
                "<td>"+nvl(e.getDepartment()!=null&&!e.getDepartment().isEmpty()?e.getDepartment():e.getOrgName())+"</td>" +
                "<td>"+nvl(e.getIssuedBy())+"</td>" +
                "<td>"+nvl(e.getRemarks())+"</td></tr>");
            if ("DIESEL".equals(e.getFuelType())) diesel+=e.getQtyIssued();
            else petrol+=e.getQtyIssued();
        }
        out.println("<tr style='background:#e8f0fe;font-weight:bold'>" +
            "<td colspan='10'>TOTALS ("+list.size()+" records)</td>" +
            "<td>"+(diesel+petrol)+" L</td>" +
            "<td colspan='6'>Diesel: "+diesel+" L | Petrol: "+petrol+" L</td></tr>");
        out.println("</table></body></html>");
    }

    /* ══ Excel: RCAV Monthly ══ */
    private void exportMonthlyExcel(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        int month = getInt(req,"month", Calendar.getInstance().get(Calendar.MONTH)+1);
        int year  = getInt(req,"year",  Calendar.getInstance().get(Calendar.YEAR));
        String rcavCat = req.getParameter("rcavCategory");
        List list = new ArrayList();
        try {
            List all = new FuelEntryDAO().getMonthlyRCAV(month, year);
            for (Object obj : all) {
                FuelEntry fe = (FuelEntry) obj;
                if (rcavCat == null || rcavCat.isEmpty() ||
                    rcavCat.equalsIgnoreCase(fe.getEntryCategory())) {
                    list.add(fe);
                }
            }
        } catch (Exception e) {}

        String[] mnames={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
        String mn = (month>=1&&month<=12)?mnames[month-1]:String.valueOf(month);
        String catLabel = (rcavCat!=null&&!rcavCat.isEmpty()) ? " ["+rcavCat+"]" : "";
        String fname = "RCAV_"+mn+"_"+year+catLabel.replace("[","").replace("]","")+".xls";
        res.setContentType("application/vnd.ms-excel");
        res.setHeader("Content-Disposition","attachment; filename=\""+fname+"\"");

        PrintWriter out = res.getWriter();
        out.println("<html><head><meta charset='UTF-8'></head><body>");
        out.println("<h2>RCAV REPORT &mdash; "+mn+" "+year+catLabel+"</h2>");
        out.println("<p style='color:#555;font-size:12px'>Bhabha Atomic Research Centre &mdash; Transport Section | IMS Fuel Master Pro</p>");
        out.println("<table border='1' cellpadding='4' style='border-collapse:collapse;font-size:12px'>");
        out.println("<tr style='background:#1a4080;color:white;font-weight:bold'>" +
            "<th>#</th><th>Vehicle No</th><th>Category</th><th>Unit / Organisation</th>" +
            "<th>Vehicle Type</th><th>Driver</th>" +
            "<th>Open KM</th><th>Close KM</th><th>Total KM</th>" +
            "<th>Diesel(L)</th><th>Petrol(L)</th><th>Total Fuel</th>" +
            "<th>Avg km/L</th><th>Performance</th></tr>");

        double grandDiesel=0, grandPetrol=0;
        for (int i=0; i<list.size(); i++) {
            FuelEntry e = (FuelEntry)list.get(i);
            String bg   = i%2==0?"#fff":"#f5f8fc";
            double diesel = safeDouble(e.getPurpose());
            double petrol = safeDouble(e.getSupplyType());
            grandDiesel += diesel; grandPetrol += petrol;
            long totalKm  = e.getCurrOdometer()-e.getPrevOdometer();
            String perf   = e.getAvgMileage()>=12?"Good":e.getAvgMileage()>=8?"Average":"Poor";
            String pc     = e.getAvgMileage()>=12?"#006600":e.getAvgMileage()>=8?"#cc6600":"#cc0000";
            String cat    = nvl(e.getEntryCategory());
            /* Resolve unit/org name based on category */
            String unitOrg;
            if ("BARC".equalsIgnoreCase(cat) || "LOOSE".equalsIgnoreCase(cat)) {
                unitOrg = nvl(e.getDepartment()).isEmpty() ? "BARC" : nvl(e.getDepartment());
            } else {
                /* UNIT: prefer orgName (from UNIT_MASTER via view join), fall back to department */
                unitOrg = nvl(e.getOrgName()).isEmpty() ? nvl(e.getDepartment()) : nvl(e.getOrgName());
            }
            String catColor = "BARC".equalsIgnoreCase(cat)?"#1a5276":"UNIT".equalsIgnoreCase(cat)?"#1a6b5e":"#7e5109";
            out.println("<tr style='background:"+bg+"'>" +
                "<td>"+(i+1)+"</td>" +
                "<td><b>"+nvl(e.getVehicleNo())+"</b></td>" +
                "<td style='color:"+catColor+";font-weight:bold'>"+cat+"</td>" +
                "<td>"+unitOrg+"</td>" +
                "<td>"+nvl(e.getVehicleType())+"</td>" +
                "<td>"+nvl(e.getDriverName())+"</td>" +
                "<td>"+(e.getPrevOdometer()>0?e.getPrevOdometer():"")+"</td>" +
                "<td>"+(e.getCurrOdometer()>0?e.getCurrOdometer():"")+"</td>" +
                "<td><b>"+(totalKm>0?totalKm:"")+"</b></td>" +
                "<td>"+(diesel>0?diesel:"&mdash;")+"</td>" +
                "<td>"+(petrol>0?petrol:"&mdash;")+"</td>" +
                "<td>"+(e.getQtyIssued()>0?e.getQtyIssued():"")+"</td>" +
                "<td style='color:"+pc+"'><b>"+(e.getAvgMileage()>0?e.getAvgMileage():"&mdash;")+"</b></td>" +
                "<td style='color:"+pc+"'>"+perf+"</td></tr>");
        }
        /* Totals row */
        out.println("<tr style='background:#1a4080;color:white;font-weight:bold'>" +
            "<td colspan='11'>TOTALS ("+list.size()+" records)</td>" +
            "<td colspan='4'>Diesel: "+grandDiesel+" L | Petrol: "+grandPetrol+" L | Total: "+(grandDiesel+grandPetrol)+" L</td></tr>");
        out.println("</table></body></html>");
    }

    private Date parseDate(String s, Date def) {
        if (s==null||s.isEmpty()) return def;
        try { return new SimpleDateFormat("yyyy-MM-dd").parse(s); }
        catch (Exception e) { return def; }
    }
    private int getInt(HttpServletRequest req, String name, int def) {
        try { return Integer.parseInt(req.getParameter(name)); }
        catch (Exception e) { return def; }
    }
    private String nvl(String s) { return s!=null?s:""; }
    private double safeDouble(String s) {
        try { return Double.parseDouble(s); } catch (Exception e) { return 0; }
    }
}
