package is.five.apeaf.controller;

import java.io.IOException;
import java.math.BigDecimal;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import is.five.apeaf.dao.TabParDAO;
import is.five.apeaf.dao.model.TabPar;
import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.utils.SessionVariables;



@WebServlet("/TabParServlet")
public class TabParServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            HttpSession session = request.getSession(false);
    		UserView user = (UserView) request.getSession().getAttribute("ubAP");


            if (session == null || user == null  || !user.getActive()) {
				response.sendRedirect("/apnetwork");
                return;
            }


            BigDecimal sanzione = getDecimal(request.getParameter("abbattimento_sanzione"));
            BigDecimal interessi = getDecimal(request.getParameter("abbattimento_interessi"));

            boolean newSanzione = TabParDAO.saveValue(

                    user.getId(),

                    TabPar.TYPE_SANZIONE,

                    sanzione);

            boolean newInteressi = TabParDAO.saveValue(

                    user.getId(),

                    TabPar.TYPE_INTERESSI,

                    interessi);

            if (!newSanzione || !newInteressi) {

                session.setAttribute(

                        TabParServlet.class.getName(),

                        "Uno o più valori erano già presenti e non sono stati inseriti.");

            } else {

                session.setAttribute(

                        TabParServlet.class.getName(),

                        "Parametri salvati correttamente.");

            }
            session.setAttribute(
                    TabParServlet.class.getName(),
                    "Parametri salvati correttamente"
            );

        } catch (Exception e) {

            request.getSession().setAttribute(
                    TabParServlet.class.getName(),
                    "Errore salvataggio parametri: " + e.getMessage()
            );
        }

		response.sendRedirect("home.jsp?" + request.getSession().getAttribute(SessionVariables.CALLER));
    }

    private BigDecimal getDecimal(String value) {

        if (value == null || value.trim().isEmpty()) {
            return BigDecimal.ZERO;
        }

        return new BigDecimal(value.trim().replace(",", "."));
    }
}