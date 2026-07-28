<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="java.util.Locale" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>

<%@ page import="is.five.apeaf.dao.AnnoFinanziarioDAO" %>
<%@ page import="is.five.apeaf.dao.InsResiduiAttiviDAO" %>
<%@ page import="is.five.apeaf.dao.InsDatiFCDEDAO" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@ page import="is.five.apeaf.dao.model.InsResiduiAttivi" %>
<%@ page import="is.five.apeaf.dao.model.InsDatiFCDE" %>
<%@ page import="is.five.apeaf.utils.CSVUtils" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>

<%
    request.getSession().setAttribute(
            SessionVariables.CALLER,
            "calcolo-fcde.jsp"
    );

    UserView user = (UserView) request
            .getSession()
            .getAttribute("ubAP");

    if (user == null || !user.getActive()) {
        response.sendRedirect("index.jsp");
        return;
    }


    /*
     * Recupero dell'anno finanziario selezionato.
     */
    String idAnnoSelezionato = session.getAttribute(SessionVariables.ANNO) != null
            ? String.valueOf(session.getAttribute(SessionVariables.ANNO))
            : "";

    String annoSelezionato = "";

    try {

        if (!idAnnoSelezionato.trim().isEmpty()) {

            AnnoFinanziarioDAO anniDAO =
                    new AnnoFinanziarioDAO();

            annoSelezionato = String.valueOf(
                    anniDAO
                            .findByID(
                                    Integer.parseInt(
                                            idAnnoSelezionato.trim()
                                    )
                            )
                            .getAnno()
            );
        }

    } catch (Exception exc) {

        annoSelezionato = "";
    }


    if (annoSelezionato == null ||
            annoSelezionato.trim().isEmpty()) {
%>

<div class="alert alert-warning d-flex align-items-center shadow-sm mb-4"
     role="alert">

    <i class="bi bi-arrow-up-right-circle-fill fs-2 me-3"></i>

    <div>
        <strong>Anno finanziario non selezionato.</strong>
        <br />
        Seleziona l'anno finanziario dal menu in alto a destra.
    </div>

</div>

<%
        return;
    }


    int anno;

    try {

        anno = Integer.parseInt(
                annoSelezionato.trim()
        );

    } catch (NumberFormatException exc) {
%>

<div class="alert alert-danger" role="alert">

    <i class="bi bi-exclamation-triangle-fill me-2"></i>

    Anno finanziario non valido:

    <strong>
        <%= annoSelezionato %>
    </strong>

</div>

<%
        return;
    }


    /*
     * Formattazione italiana dei valori.
     */
    DecimalFormat formatoItaliano3Decimali =
            new DecimalFormat(
                    "#,##0.000",
                    DecimalFormatSymbols.getInstance(
                            Locale.ITALY
                    )
            );

    formatoItaliano3Decimali.setRoundingMode(
            RoundingMode.HALF_UP
    );


    /*
     * Recupero dei record.
     *
     * Entrambi possono essere null se l'utente non ha ancora
     * salvato dati per l'anno selezionato.
     */
    InsResiduiAttivi residuiAttivi = null;
    InsDatiFCDE datiFCDE = null;

    try {

        residuiAttivi =
                InsResiduiAttiviDAO.findByUserAndAnno(
                        user.getId(),
                        anno
                );

    } catch (Exception exc) {

        residuiAttivi = null;
    }

    try {

        datiFCDE =
                InsDatiFCDEDAO.findByUserAndAnno(
                        user.getId(),
                        anno
                );

    } catch (Exception exc) {

        datiFCDE = null;
    }


    /*
     * Se il record o il relativo valore sono null,
     * viene utilizzata una stringa CSV vuota.
     */
    String csvResiduiAttivi =
            residuiAttivi != null &&
            residuiAttivi.getValue() != null
                    ? residuiAttivi.getValue().trim()
                    : "";

    String csvDatiFCDE =
            datiFCDE != null &&
            datiFCDE.getValue() != null
                    ? datiFCDE.getValue().trim()
                    : "";


    /*
     * Descrizioni delle cinque tipologie di entrata.
     */
    String[] tipologieEntrata = {
            "Accertamenti ICI",
            "Accertamenti TASI",
            "Accertamenti IMU",
            "Tassa Rifiuti",
            "CDS"
    };


    /*
     * Array contenenti i valori da mostrare nella tabella.
     */
    BigDecimal[] importiResidui =
            new BigDecimal[tipologieEntrata.length];

    BigDecimal[] importiFCDE =
            new BigDecimal[tipologieEntrata.length];

    BigDecimal[] percentualiAccantonamento =
            new BigDecimal[tipologieEntrata.length];


    BigDecimal totaleResiduiAttivi =
            BigDecimal.ZERO;

    BigDecimal totaleFCDE =
            BigDecimal.ZERO;


    /*
     * Lettura sicura dei valori CSV.
     *
     * In caso di:
     *
     * - record null;
     * - CSV null o vuoto;
     * - campo mancante;
     * - campo non numerico;
     * - errore di conversione;
     *
     * il valore utilizzato è BigDecimal.ZERO.
     */
    for (int index = 0;
         index < tipologieEntrata.length;
         index++) {

        BigDecimal residuo =
                BigDecimal.ZERO;

        BigDecimal fcde =
                BigDecimal.ZERO;


        try {

            BigDecimal valoreResiduo =
                    CSVUtils.getDecimalValue(
                            csvResiduiAttivi,
                            index
                    );

            if (valoreResiduo != null) {
                residuo = valoreResiduo;
            }

        } catch (Exception exc) {

            residuo = BigDecimal.ZERO;
        }


        try {

            BigDecimal valoreFCDE =
                    CSVUtils.getDecimalValue(
                            csvDatiFCDE,
                            index
                    );

            if (valoreFCDE != null) {
                fcde = valoreFCDE;
            }

        } catch (Exception exc) {

            fcde = BigDecimal.ZERO;
        }


        importiResidui[index] =
                residuo;

        importiFCDE[index] =
                fcde;


        /*
         * La percentuale vale zero quando il residuo è zero,
         * evitando divisioni per zero.
         */
        if (residuo.compareTo(BigDecimal.ZERO) != 0) {

            percentualiAccantonamento[index] =
                    fcde
                            .multiply(
                                    BigDecimal.valueOf(100)
                            )
                            .divide(
                                    residuo,
                                    3,
                                    RoundingMode.HALF_UP
                            );

        } else {

            percentualiAccantonamento[index] =
                    BigDecimal.ZERO;
        }


        totaleResiduiAttivi =
                totaleResiduiAttivi.add(
                        residuo
                );

        totaleFCDE =
                totaleFCDE.add(
                        fcde
                );
    }


    /*
     * Percentuale complessiva.
     */
    BigDecimal percentualeTotaleAccantonamento;

    if (totaleResiduiAttivi.compareTo(BigDecimal.ZERO) != 0) {

        percentualeTotaleAccantonamento =
                totaleFCDE
                        .multiply(
                                BigDecimal.valueOf(100)
                        )
                        .divide(
                                totaleResiduiAttivi,
                                3,
                                RoundingMode.HALF_UP
                        );

    } else {

        percentualeTotaleAccantonamento =
                BigDecimal.ZERO;
    }
%>


<h3 class="mb-4">

    <i class="bi bi-calculator"></i>

    CALCOLO % ACCANTONAMENTO FCDE

    <span class="badge bg-primary ms-2">
        <%= annoSelezionato %>
    </span>

</h3>


<div class="rounded p-4 dati-card valutazione-ruoli-card mt-4">

    <div class="dati-header mb-3">

        <div class="dati-title dati-section-title">

            <i class="bi bi-table"></i>

            <span>
                DATI COMPUTATI DA INS. RESIDUI ATTIVI E INS. DATI FCDE
            </span>

        </div>

    </div>


    <div class="table-responsive">

        <table class="valutazione-ruoli-table"
               aria-label="Confronto tra residui attivi e FCDE"
               style="max-width: 1200px;">

            <colgroup>
                <col class="col-tipologia" />
                <col class="col-valore" />
                <col class="col-valore" />
                <col class="col-valore" />
            </colgroup>


            <thead>

                <tr>

                    <th scope="col">
                        TIPOLOGIA ENTRATA
                    </th>

                    <th scope="col">
                        RESIDUI ATTIVI
                    </th>

                    <th scope="col">
                        FCDE
                    </th>

                    <th scope="col">
                        % ACCANTONAMENTO
                    </th>

                </tr>

            </thead>


            <tbody>

                <%
                    for (int index = 0;
                         index < tipologieEntrata.length;
                         index++) {
                %>

                <tr>

                    <th class="description-cell"
                        scope="row">

                        <%= tipologieEntrata[index] %>

                    </th>


                    <td class="number-cell">

                        <%= formatoItaliano3Decimali.format(
                                importiResidui[index]
                        ) %>

                    </td>


                    <td class="number-cell">

                        <%= formatoItaliano3Decimali.format(
                                importiFCDE[index]
                        ) %>

                    </td>


                    <td class="percentage-cell">

                        <%= formatoItaliano3Decimali.format(
                                percentualiAccantonamento[index]
                        ) %>%

                    </td>

                </tr>

                <%
                    }
                %>


                <tr class="table-spacer-row">

                    <td colspan="4"
                        style="height: 18px;
                               padding: 0;
                               border: none;
                               background: transparent;">
                    </td>

                </tr>


                <tr class="totals-row">

                    <th class="total-label"
                        scope="row">

                        TOTALE

                    </th>


                    <td class="total-number">

                        <%= formatoItaliano3Decimali.format(
                                totaleResiduiAttivi
                        ) %>

                    </td>


                    <td class="total-number">

                        <%= formatoItaliano3Decimali.format(
                                totaleFCDE
                        ) %>

                    </td>


                    <td class="total-number percentage-cell">

                        <%= formatoItaliano3Decimali.format(
                                percentualeTotaleAccantonamento
                        ) %>%

                    </td>

                </tr>

            </tbody>

        </table>

    </div>

</div>