package is.five.apeaf.controller;


import java.io.IOException;
import java.util.StringJoiner;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import is.five.apeaf.dao.TabRiscDAO;
import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.utils.SessionVariables;

@WebServlet("/TabRiscServlet")
public class TabRiscServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {

        	 HttpSession session = request.getSession(false);
     		UserView user = (UserView) request.getSession().getAttribute("ubAP");


             if (session == null || user == null) {
 				response.sendRedirect("/apnetwork");
                 return;
             }

 
            StringJoiner sj = new StringJoiner(";");

            for (int i = 0; i < 5; i++) {
                String v = request.getParameter("risc_" + i);

                if (v == null || v.trim().isEmpty()) {
                    v = "0";
                }

                sj.add(v.trim());
            }

            TabRiscDAO.saveOrUpdate(user.getId(), sj.toString());

            session.setAttribute(TabRiscServlet.class.getName(),
                    "Parametri riscossione salvati correttamente.");

        } catch (Exception e) {

            request.getSession().setAttribute(TabRiscServlet.class.getName(),
                    "Errore durante il salvataggio: " + e.getMessage());
        }

		response.sendRedirect("home.jsp?" + request.getSession().getAttribute(SessionVariables.CALLER));
    }
}