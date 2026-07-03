package is.five.apeaf.controller;

import java.io.IOException;
import java.net.InetAddress;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

import is.five.apeaf.dao.Update_apnetwork_advloggerDAO;
import is.five.apeaf.dao.model.UserView;



@WebFilter("/*") // Applies to all requests
public class UserFilter implements Filter {

	public void init(FilterConfig filterConfig) throws ServletException {
		// Initialization code (if needed)
	}

	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {

		HttpServletRequest req = (HttpServletRequest) request;
		HttpServletResponse res = (HttpServletResponse) response;
		HttpSession session = req.getSession(false);

		String path = req.getRequestURI();

		// Allow requests to /sso without filtering
		if (path.endsWith("/sso")) {
			chain.doFilter(request, response);
			return;
		}
		try {
			// Retrieve the user from session
			UserView ubAP = (UserView) session.getAttribute("ubAP");

			String[] appArray = ubAP.getApplicazioni().split(";");

			if (ubAP != null && (ubAP.getGroupId() == 1 || ubAP.getGroupId() == 2))
				chain.doFilter(request, response); // Continue to the requested resource
			else

			if (ubAP != null && appArray[1] != null && appArray[1].equals("on")) {
				chain.doFilter(request, response); // Continue to the requested resource
			} else {
				String ip = request.getRemoteAddr();
				if (ip.equalsIgnoreCase("0:0:0:0:0:0:0:1")) {
				    InetAddress inetAddress = InetAddress.getLocalHost();
				    String ipAddress = inetAddress.getHostAddress();
				    ip = ipAddress;
				}
				Update_apnetwork_advloggerDAO update_apnetwork_advloggerDAO = new Update_apnetwork_advloggerDAO();
				update_apnetwork_advloggerDAO.insert(ubAP, ip, "KO NOT LICENSED");

				res.sendRedirect("/apwarning/new-home.jsp"); // Redirect unauthorized users
			}

		} catch (Exception exc) {
			res.sendRedirect("/apnetwork"); // Redirect unauthorized users
		}
	}

	public void destroy() {
		// Cleanup code (if needed)
	}
}
