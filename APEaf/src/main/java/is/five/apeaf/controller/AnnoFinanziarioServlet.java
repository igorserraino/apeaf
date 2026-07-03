package is.five.apeaf.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import is.five.apeaf.dao.AnnoFinanziarioDAO;
import is.five.apeaf.dao.model.AnnoFinanziario;
import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.utils.SessionVariables;

/**
 * Servlet implementation class AnnoFinanziarioServlet
 */
@WebServlet("/annofinanziario")
public class AnnoFinanziarioServlet extends HttpServlet {
	private static final long serialVersionUID = 1L; 
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AnnoFinanziarioServlet() {
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
		request.getSession().setAttribute(AnnoFinanziarioServlet.class.getName(), null);
		request.getSession().removeAttribute("ERROR");
		request.getSession().removeAttribute("id-attivitagestori");
		request.getSession().removeAttribute(SessionVariables.ANNO);
		//request.getSession().removeAttribute(SessionVariables.SERVIZIO);
		
		UserView user = (UserView) request.getSession().getAttribute("ubAP");
		if (user==null)
			{ response.sendRedirect("index.jsp"); return; }
		
		
		String id_anno = request.getParameter("select_anno");
		try {
			request.getSession().setAttribute(SessionVariables.ANNO, id_anno);
		} catch (NumberFormatException e) {
			request.getSession().setAttribute(SessionVariables.ANNO, null);
			request.getSession().setAttribute(AnnoFinanziarioServlet.class.getName(), "Impossibile procedere: controllare il dato inserito. " + e.getMessage());

		} catch (Exception e) {
			request.getSession().setAttribute(SessionVariables.ANNO, null);
			request.getSession().setAttribute(AnnoFinanziarioServlet.class.getName(), "Impossibile procedere: controllare il dato inserito. " + e.getMessage());

		}
				
						
		AnnoFinanziarioDAO dao = new AnnoFinanziarioDAO();
		
		if (request.getParameter("insert_nuovo_anno")!=null) {
			try {
			String anno_new = request.getParameter("nuovo_anno");
			
			AnnoFinanziario dato = new AnnoFinanziario();
			dato.setIdUser(user.getId()); 
			dato.setAnno(Integer.parseInt(anno_new)); 
			dao.save(dato);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				request.getSession().setAttribute(AnnoFinanziarioServlet.class.getName(), "Impossibile procedere: controllare il dato inserito. " + e.getMessage());
			}
			
		}
		
			response.sendRedirect("home.jsp?" + request.getSession().getAttribute(SessionVariables.CALLER));
		
	}

}
