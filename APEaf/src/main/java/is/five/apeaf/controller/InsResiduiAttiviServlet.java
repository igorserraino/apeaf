package is.five.apeaf.controller;

import java.io.IOException;
import java.util.StringJoiner;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import is.five.apeaf.dao.InsResiduiAttiviDAO;
import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.utils.SessionVariables;

@WebServlet("/ins-residui-attivi")
public class InsResiduiAttiviServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /*
     * Le prime 5 voci sono quelle standard:
     *
     * 0 = Accertamenti ICI
     * 1 = Accertamenti TASI
     * 2 = Accertamenti IMU
     * 3 = Tassa Rifiuti
     * 4 = CDS
     */
    private static final int NUMERO_CAMPI_STANDARD = 5;

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

        String annoSelezionato =
                (String) session.getAttribute("anno_selezionato");

        if (user == null
                || !user.getActive()
                || annoSelezionato == null
                || annoSelezionato.trim().isEmpty()) {

            response.sendRedirect("index.jsp");
            return;
        }

        try {

            /*
             * ANNO
             */
            int anno;

            try {

                anno = Integer.parseInt(
                        annoSelezionato.trim()
                );

            } catch (NumberFormatException e) {

                throw new IllegalArgumentException(
                        "Anno finanziario non valido."
                );
            }


            /*
             * Costruzione CSV.
             */
            StringJoiner values =
                    new StringJoiner(";");


            /*
             * -------------------------------------------------
             * 1. VOCI STANDARD
             * -------------------------------------------------
             */
            for (
                    int i = 0;
                    i < NUMERO_CAMPI_STANDARD;
                    i++
            ) {

                String value =
                        request.getParameter(
                                "risc_" + i
                        );

                if (value == null
                        || value.trim().isEmpty()) {

                    value = "0";
                }

                values.add(
                        value.trim()
                );
            }


            /*
             * -------------------------------------------------
             * 2. VOCI AGGIUNTIVE
             * -------------------------------------------------
             *
             * Il JSP invierà:
             *
             * nuova_tipologia[]
             * nuova_tipologia_valore[]
             *
             * Esempio:
             *
             * Canone patrimoniale
             * 1500
             *
             * Verrà salvato:
             *
             * Canone patrimoniale=1500
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

                for (
                        int i = 0;
                        i < nuoveTipologie.length;
                        i++
                ) {

                    String tipologia =
                            nuoveTipologie[i];

                    if (tipologia == null
                            || tipologia.trim().isEmpty()) {

                        continue;
                    }

                    tipologia =
                            tipologia.trim();


                    /*
                     * Evitiamo caratteri che romperebbero
                     * il nostro CSV.
                     */
                    tipologia =
                            tipologia
                                .replace(";", " ")
                                .replace("=", " ");


                    String valore = "0";

                    if (nuoviValori != null
                            && i < nuoviValori.length
                            && nuoviValori[i] != null
                            && !nuoviValori[i]
                                    .trim()
                                    .isEmpty()) {

                        valore =
                                nuoviValori[i].trim();
                    }


                    /*
                     * Formato:
                     *
                     * Nome tipologia=valore
                     */
                    values.add(
                            tipologia
                            + "="
                            + valore
                    );
                }
            }


            /*
             * Inserisce oppure aggiorna il record
             * identificato da:
             *
             * idUser + anno
             */
            InsResiduiAttiviDAO.saveOrUpdate(
                    user.getId(),
                    anno,
                    values.toString()
            );


            session.setAttribute(
                    InsResiduiAttiviServlet.class.getName(),

                    "Residui attivi salvati correttamente "
                    + "per l'anno "
                    + anno
                    + "."
            );

        } catch (Exception e) {

            e.printStackTrace();

            session.setAttribute(
                    InsResiduiAttiviServlet.class.getName(),

                    "Errore durante il salvataggio: "
                    + e.getMessage()
            );
        }


        response.sendRedirect(
                "home.jsp?"
                + session.getAttribute(
                        SessionVariables.CALLER
                )
        );
    }
}