package is.five.apeaf.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.URI;
import java.net.URL;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import is.five.apeaf.dao.SSOViewDAO;
import is.five.apeaf.dao.Update_apnetwork_advloggerDAO;
import is.five.apeaf.dao.UserViewDAO;
import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.utils.SessionVariables;

/**
 * Servlet implementation class LoginServlet
 */
@WebServlet("/sso")
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);

	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		request.getSession().removeAttribute("ubAP");
		request.getSession().removeAttribute("loginerror");
		request.getSession().removeAttribute("userBeanLinked");
		request.getSession().removeAttribute("pathAmmortizzabili");
		request.getSession().removeAttribute(SessionVariables.ANNO);
		request.getSession().setAttribute(SessionVariables.CALLER, "");
		request.getSession().setAttribute(SessionVariables.USER_SEL, null);
		request.getSession().setAttribute(SessionVariables.PAGE, null);
		request.getSession().setAttribute(SessionVariables.SERVIZIO, null);
		request.getSession().setAttribute(SessionVariables.ID_ESISTENTE, null);
		
		String ip = request.getRemoteAddr();
		if (ip.equalsIgnoreCase("0:0:0:0:0:0:0:1")) {
		    InetAddress inetAddress = InetAddress.getLocalHost();
		    String ipAddress = inetAddress.getHostAddress();
		    ip = ipAddress;
		}

		String username = null;
		UserView ubAP = null;
		Update_apnetwork_advloggerDAO update_apnetwork_advloggerDAO = new Update_apnetwork_advloggerDAO();


		try {
					
		HttpURLConnection conn = null;
		String temp_token = System.getenv("SSO_TOKEN");;
		
		if (ip.startsWith("192.168.1") || ip.equals("127.0.0.1") || ip.startsWith("169.254")) {
			 URI uri = URI.create("http://localhost:8080/apnetwork/check-session");
			URL url = uri.toURL();
			conn = (HttpURLConnection) url.openConnection();
		}
		else {
		 URI uri = URI.create("https://www.ambientepuntuale.it/apnetwork/check-session");
			URL url = uri.toURL();
			conn = (HttpURLConnection) url.openConnection();
		}
				
		
		conn.setRequestMethod("GET");
		conn.setRequestProperty("Cookie", "JSESSIONID="+request.getParameter("id"));
		conn.setRequestProperty("X-Internal-Token", temp_token);
		conn.setRequestProperty("X-Caller-App", "APEAF");
		conn.setRequestProperty("X-Caller-URL",request.getRequestURL().toString());
		conn.setRequestProperty("X-Caller-IP",ip);

				if (conn.getResponseCode() == 200) {
					BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream())); 
				
				    String json = reader.readLine();
				    username = json.replaceAll(".*\"username\"\\s*:\\s*\"([^\"]+)\".*", "$1");
				}
				

			if (username!=null) {
				
				/**
				 * token, ip SSO defence in depth
				 * 
				 */
				SSOViewDAO ssoViewDAO = new SSOViewDAO();
				if (!checkTime(ssoViewDAO.selectByUsername(username).getTimestamp(), Timestamp.from(Instant.now()))) 
					throw new Exception("TOKEN EXPIRED " + username);
				
				if (!checkIP(ssoViewDAO.selectByUsername(username).getIP(), ip)) 
					throw new Exception("IP MISMATCHING " + username);
				
				UserViewDAO userViewDAO = new UserViewDAO();
				
				ubAP = userViewDAO.selectByUsername(username);
        		if (ubAP==null) throw new Exception("USER " + username + " NULL ");
        				
        		request.getSession().setAttribute("ubAP", ubAP);
        		
        		update_apnetwork_advloggerDAO.insert(ubAP, ip, "OK");
        		System.out.println("APEAF " + ubAP.getUsername() + " LOGGED ON " + Instant.now());

        		request.getSession().setAttribute(SessionVariables.CALLER, request.getParameter("page"));
        		response.sendRedirect("home.jsp?"+request.getSession().getAttribute(SessionVariables.CALLER));
        		return;
			} else {
				update_apnetwork_advloggerDAO.insert(ubAP, ip, "KO APEAF username null");
				

				
				response.sendRedirect("/apnetwork");
			}

			
		} catch (Exception exc) {

			if (ubAP==null) 
					update_apnetwork_advloggerDAO.insert(new UserView(), ip, "KO APEAF " + exc.getMessage());
				else
					update_apnetwork_advloggerDAO.insert(ubAP, ip, "KO APEAF " + exc.getMessage());
    		response.sendRedirect("/apnetwork");

		}

	}

	private boolean checkTime(Timestamp timestamp1, Timestamp timestamp2) {
	    if (timestamp1 == null || timestamp2 == null) {
	        return false;
	    }

	    long diffInSeconds = Duration.between(timestamp2.toInstant(), timestamp2.toInstant()).getSeconds();
	    return diffInSeconds >= 0 && diffInSeconds < 5;
	}
	
	private boolean checkIP(String ip1, String ip2) {
	    return (ip1.equals(ip2));
	}

}