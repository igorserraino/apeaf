package is.five.apeaf.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import is.five.apeaf.dao.TipologieDAO;
import is.five.apeaf.dao.model.UserView;

 

@WebServlet("/TipologieServlet")
public class TipologieServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        UserView user = (UserView)
                request.getSession().getAttribute("ubAP");

        if (user == null || !user.getActive()) {

            response.sendRedirect("index.jsp");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "save";
        }

        try {

            if ("save".equalsIgnoreCase(action)) {

                save(request, user);

            } else if ("delete".equalsIgnoreCase(action)) {

                delete(request, user);
            }

        } catch (Exception e) {

            e.printStackTrace();

            request.getSession().setAttribute(
                TipologieServlet.class.getName(),
                "Errore: " + e.getMessage()
            );
        }

        response.sendRedirect(
            "home.jsp?def-tipologie.jsp"
        );
    }


    private void save(
            HttpServletRequest request,
            UserView user) {

        String value =
                request.getParameter("value");

        String annoParam =
                request.getParameter("anno");

        if (value == null || value.trim().isEmpty()) {

            request.getSession().setAttribute(
                TipologieServlet.class.getName(),
                "Specificare una tipologia."
            );

            return;
        }

        Integer anno;

        if (annoParam != null
                && !annoParam.trim().isEmpty()) {

            anno = Integer.parseInt(annoParam);

        } else {

            Object annoSession =
                    request.getSession()
                           .getAttribute("anno_selezionato");

            if (annoSession == null) {

                request.getSession().setAttribute(
                    TipologieServlet.class.getName(),
                    "Anno non selezionato."
                );

                return;
            }

            anno = Integer.valueOf(
                    annoSession.toString());
        }

        boolean saved = TipologieDAO.save(
                user.getId(),
                anno,
                value
        );

        if (saved) {

            request.getSession().setAttribute(
                TipologieServlet.class.getName(),
                "Tipologia memorizzata correttamente."
            );

        } else {

            request.getSession().setAttribute(
                TipologieServlet.class.getName(),
                "La tipologia è già presente."
            );
        }
    }


    private void delete(
            HttpServletRequest request,
            UserView user) {

        String idParam =
                request.getParameter("id");

        if (idParam == null) {
            return;
        }

        Integer id =
                Integer.valueOf(idParam);

        boolean deleted =
                TipologieDAO.delete(
                    id,
                    user.getId()
                );

        if (deleted) {

            request.getSession().setAttribute(
                TipologieServlet.class.getName(),
                "Tipologia eliminata."
            );

        } else {

            request.getSession().setAttribute(
                TipologieServlet.class.getName(),
                "Tipologia non trovata."
            );
        }
    }
}