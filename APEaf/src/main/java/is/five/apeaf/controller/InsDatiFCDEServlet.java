package is.five.apeaf.controller;

import java.io.IOException;
import java.util.StringJoiner;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import is.five.apeaf.dao.InsDatiFCDEDAO;
import is.five.apeaf.dao.InsResiduiAttiviDAO;
import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.utils.SessionVariables;

@WebServlet("/ins-dati-fcde")
public class InsDatiFCDEServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int NUMERO_CAMPI = 5;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        UserView user =
                (UserView) session.getAttribute("ubAP");
        String anno_selezionato = (String)request.getSession().getAttribute("anno_selezionato");

        if (session == null || user == null  || !user.getActive() || anno_selezionato==null || anno_selezionato.length()==0) {
            response.sendRedirect("index.jsp");
            return;
        }

        try {


            int anno;

            try {
                anno = Integer.parseInt(
                		anno_selezionato.trim()
                );

            } catch (NumberFormatException e) {
                throw new IllegalArgumentException(
                        "Anno finanziario non valido."
                );
            }

            StringJoiner values =
                    new StringJoiner(";");


            /*
             * 5 campi standard.
             */
            for (int i = 0; i < 5; i++) {

                String value =
                        request.getParameter(
                                "risc_" + i
                        );

                if (value == null ||
                    value.trim().isEmpty()) {

                    value = "0";
                }

                values.add(
                        value.trim()
                );
            }


            /*
             * Tipologie dinamiche.
             */
            String[] nuoveTipologie =
                    request.getParameterValues(
                            "nuova_tipologia[]"
                    );

            String[] nuoviValori =
                    request.getParameterValues(
                            "nuova_tipologia_valore[]"
                    );


            if (nuoveTipologie != null) {

                for (int i = 0;
                     i < nuoveTipologie.length;
                     i++) {

                    String tipologia =
                            nuoveTipologie[i];

                    if (tipologia == null ||
                        tipologia.trim().isEmpty()) {

                        continue;
                    }


                    /*
                     * ; e = sono riservati
                     * al nostro formato CSV.
                     */
                    tipologia =
                            tipologia
                                .trim()
                                .replace(";", " ")
                                .replace("=", " ");


                    String valore = "0";

                    if (nuoviValori != null &&
                        i < nuoviValori.length &&
                        nuoviValori[i] != null &&
                        !nuoviValori[i]
                            .trim()
                            .isEmpty()) {

                        valore =
                                nuoviValori[i]
                                    .trim();
                    }


                    values.add(
                            tipologia
                            + "="
                            + valore
                    );
                }
            }


            InsDatiFCDEDAO.saveOrUpdate(
                    user.getId(),
                    anno,
                    values.toString()
            );

            session.setAttribute(
                    InsDatiFCDEServlet.class.getName(),
                    "Dati FCDE salvati correttamente per l'anno "
                            + anno + "."
            );

        } catch (Exception e) {

            session.setAttribute(
                    InsDatiFCDEServlet.class.getName(),
                    "Errore durante il salvataggio: "
                            + e.getMessage()
            );
        }

		response.sendRedirect("home.jsp?" + request.getSession().getAttribute(SessionVariables.CALLER));

    }
}