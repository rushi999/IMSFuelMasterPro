package com.barc.ims.util;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.*;

/**
 * AuthFilter - Guards all protected pages.
 * Redirects unauthenticated requests to login.jsp.
 */
public class AuthFilter implements Filter {

    public void init(FilterConfig fc) throws ServletException {}
    public void destroy() {}

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);

        boolean loggedIn = (session != null && session.getAttribute("userId") != null);
        if (loggedIn) {
            // Prevent browser caching of protected pages
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            chain.doFilter(req, res);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp?timeout=1");
        }
    }
}
