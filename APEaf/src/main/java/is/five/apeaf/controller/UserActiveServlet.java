package is.five.apeaf.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.utils.SessionVariables;





/**
 * Servlet implementation class UserActiveServlet
 */
@WebServlet("/useractive")
public class UserActiveServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UserActiveServlet() {
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
		
		request.getSession().setAttribute(SessionVariables.USER_SEL, null);

		
		UserView user = (UserView) request.getSession().getAttribute("ubAP");
		if (user==null)
			{ response.sendRedirect("index.jsp"); return; }
		
		
		String select_user = request.getParameter("select_user");
		request.getSession().setAttribute(SessionVariables.USER_SEL, select_user);
		
		
		
		
		
		response.sendRedirect("home.jsp?" + request.getSession().getAttribute(SessionVariables.CALLER));


		
		
	}

}
