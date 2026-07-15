package is.five.apeaf.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Arrays;
import java.util.stream.Collectors;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import is.five.apeaf.dao.InsTabRuoliDAO;
import is.five.apeaf.dao.model.InsTabRuoli;
import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.utils.SessionVariables;

@WebServlet("/ins-tab-ruoli")
public class InsTabRuoliServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final BigDecimal PERCENTUALE_SANZIONE =
        new BigDecimal("0.30");

    private static final BigDecimal CENTO =
        new BigDecimal("100");

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserView user = (UserView) request.getSession().getAttribute("ubAP");
        
        String anno_selezionato = (String)request.getSession().getAttribute("anno_selezionato");


        if (session == null || user == null  || !user.getActive() || anno_selezionato==null || anno_selezionato.length()==0) {
			response.sendRedirect("/apnetwork");
            return;
        }

        

        String op = request.getParameter("op");

        if ("DELETE".equals(op)) {

            int id = Integer.parseInt(request.getParameter("id"));

            InsTabRuoliDAO.delete(id, user.getId());
    		response.sendRedirect("home.jsp?" + request.getSession().getAttribute(SessionVariables.CALLER));

            return;

        }

        try {

            String entrata =
                requiredParameter(request, "entrata");

            String concessionario =
                requiredParameter(request, "concessionario");

            String dataConsegnaRuolo =
                optionalParameter(request, "dataConsegnaRuolo");

            String numeroRuolo =
                requiredParameter(request, "numeroRuolo");

            int annoRuoloCoattivo =
                parseInteger(
                    requiredParameter(
                        request,
                        "annoRuoloCoattivo"
                    ),
                    "Anno ruolo coattivo"
                );

            BigDecimal impostaRuolo =
                parseAmount(request, "impostaRuolo");

            BigDecimal interessiRuolo =
                parseAmount(request, "interessiRuolo");

            BigDecimal impostaRiscossa =
                parseAmount(request, "impostaRiscossa");

            BigDecimal interessiRiscossi =
                parseAmount(request, "interessiRiscossi");


            // Totali ruolo

            BigDecimal sanzioniRuolo =
                impostaRuolo
                    .multiply(PERCENTUALE_SANZIONE)
                    .setScale(2, RoundingMode.HALF_UP);

            BigDecimal importoRuolo =
                impostaRuolo
                    .add(sanzioniRuolo)
                    .add(interessiRuolo)
                    .setScale(2, RoundingMode.HALF_UP);


            // Totali riscossi

            BigDecimal sanzioniRiscosse =
                impostaRiscossa
                    .multiply(PERCENTUALE_SANZIONE)
                    .setScale(2, RoundingMode.HALF_UP);

            BigDecimal importoRiscosso =
                impostaRiscossa
                    .add(sanzioniRiscosse)
                    .add(interessiRiscossi)
                    .setScale(2, RoundingMode.HALF_UP);


            // Residuo

            BigDecimal residuoDaRiscuotere =
                importoRuolo
                    .subtract(importoRiscosso)
                    .setScale(2, RoundingMode.HALF_UP);


            // Percentuale riscossa

            BigDecimal percentualeRiscosso =
                BigDecimal.ZERO.setScale(2);

            if (importoRuolo.compareTo(BigDecimal.ZERO) > 0) {
                percentualeRiscosso =
                    importoRiscosso
                        .multiply(CENTO)
                        .divide(
                            importoRuolo,
                            2,
                            RoundingMode.HALF_UP
                        );
            }


            String csvValues = toCsvRow(
                entrata,
                concessionario,
                dataConsegnaRuolo,
                String.valueOf(annoRuoloCoattivo),
                numeroRuolo,

                decimal(impostaRuolo),
                decimal(sanzioniRuolo),
                decimal(interessiRuolo),
                decimal(importoRuolo),

                decimal(impostaRiscossa),
                decimal(sanzioniRiscosse),
                decimal(interessiRiscossi),
                decimal(importoRiscosso),

                decimal(residuoDaRiscuotere),
                decimal(percentualeRiscosso)
            );

            InsTabRuoli record = new InsTabRuoli();

            record.setAnno(Integer.parseInt(anno_selezionato));
            record.setValues(csvValues);
            record.setIdUser(user.getId());

            InsTabRuoliDAO.saveOrUpdate(record);

            session.setAttribute(
                InsTabRuoliServlet.class.getName(),
                "Ruolo coattivo salvato correttamente."
            );

        } catch (IllegalArgumentException e) {

            session.setAttribute(
                InsTabRuoliServlet.class.getName(),
                e.getMessage()
            );

        } catch (Exception e) {

            e.printStackTrace();

            session.setAttribute(
                InsTabRuoliServlet.class.getName(),
                "Errore durante il salvataggio del ruolo coattivo."
            );
        }

		response.sendRedirect("home.jsp?" + request.getSession().getAttribute(SessionVariables.CALLER));
    }

    private static String requiredParameter(
            HttpServletRequest request,
            String name) {

        String value = request.getParameter(name);

        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                "Il campo '" + name + "' è obbligatorio."
            );
        }

        return value.trim();
    }

    private static String optionalParameter(
            HttpServletRequest request,
            String name) {

        String value = request.getParameter(name);

        return value == null
            ? ""
            : value.trim();
    }

    private static int parseInteger(
            String value,
            String fieldName) {

        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                fieldName + " non valido."
            );
        }
    }

    private static BigDecimal parseAmount(
            HttpServletRequest request,
            String name) {

        String value = optionalParameter(request, name);

        if (value.isEmpty()) {
            return BigDecimal.ZERO.setScale(2);
        }

        /*
         * L'input type=number invia normalmente il punto
         * come separatore decimale.
         */
        value = value.replace(",", ".");

        try {
            BigDecimal amount = new BigDecimal(value)
                .setScale(2, RoundingMode.HALF_UP);

            if (amount.compareTo(BigDecimal.ZERO) < 0) {
                throw new IllegalArgumentException(
                    "Il campo '" + name +
                    "' non può essere negativo."
                );
            }

            return amount;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                "Il campo '" + name + "' non è valido."
            );
        }
    }

    private static String decimal(BigDecimal value) {
        return value
            .setScale(2, RoundingMode.HALF_UP)
            .toPlainString();
    }

    private static String toCsvRow(String... values) {

        return Arrays.stream(values)
            .map(InsTabRuoliServlet::escapeCsvValue)
            .collect(Collectors.joining(";"));
    }

    private static String escapeCsvValue(String value) {

        if (value == null) {
            return "";
        }

        String result = value.trim();

        /*
         * Protegge i valori che contengono:
         * punto e virgola, virgolette o ritorni a capo.
         */
        if (result.contains(";")
                || result.contains("\"")
                || result.contains("\n")
                || result.contains("\r")) {

            result = result.replace("\"", "\"\"");

            return "\"" + result + "\"";
        }

        return result;
    }
}