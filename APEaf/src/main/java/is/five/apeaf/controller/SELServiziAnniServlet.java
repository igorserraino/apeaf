package is.five.apeaf.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.utils.ErrorMessages;
import is.five.apeaf.utils.SessionVariables;




/**
 * Servlet implementation class SELServiziAnniServlet
 */
@WebServlet("/SELServiziAnniServlet")
public class SELServiziAnniServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public SELServiziAnniServlet() {
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
		
		request.getSession().setAttribute(ErrorMessages.class.getName(), null);
		request.getSession().setAttribute(AnnoFinanziarioServlet.class.getName(), null);
		request.getSession().removeAttribute("ERROR");
		request.getSession().removeAttribute("id-attivitagestori");
		//request.getSession().removeAttribute(SessionVariables.ANNO);
		request.getSession().removeAttribute(SessionVariables.SERVIZIO);

		UserView user = (UserView) request.getSession().getAttribute("ubAP");
		if (user==null)
			{ response.sendRedirect("index.jsp"); return; }
		String id_anno = request.getParameter("select_anno");
		String id_servizio = request.getParameter("select_servizio");
		request.getSession().setAttribute(SessionVariables.ANNO, id_anno);
		request.getSession().setAttribute(SessionVariables.SERVIZIO, id_servizio);
		
		
			
		
		
		
		response.sendRedirect("home.jsp?" + request.getSession().getAttribute(SessionVariables.CALLER));
	}

}
