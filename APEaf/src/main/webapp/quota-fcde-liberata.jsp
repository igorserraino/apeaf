<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.utils.Utils" %>

<%@ page import="is.five.apeaf.dao.TipologieDAO" %>

<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@ page import="is.five.apeaf.dao.model.Tipologia" %>

<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService" %>
<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService.ViewData" %>
<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService.RowData" %>


<%

/* ============================================================
   CALLER
   ============================================================ */

request.getSession().setAttribute(
    SessionVariables.CALLER,
    "quota-fcde-liberata.jsp"
);


/* ============================================================
   USER
   ============================================================ */

UserView user =
    (UserView) request
        .getSession()
        .getAttribute("ubAP");


if (user == null || !user.getActive()) {

    response.sendRedirect("index.jsp");
    return;
}


/* ============================================================
   ANNO SELEZIONATO
   ============================================================ */

String selectedYearId =
    session.getAttribute(SessionVariables.ANNO) != null
        ? String.valueOf(
            session.getAttribute(SessionVariables.ANNO)
          )
        : "";


/* ============================================================
   SERVICE
   ============================================================ */

QuotaFcdeLiberataService service =
    new QuotaFcdeLiberataService();


ViewData viewData =
    service.load(
        user,
        selectedYearId
    );


if (!viewData.hasSelectedYear()) {

%>


<div class="alert alert-warning
            d-flex
            align-items-center
            shadow-sm
            mb-4"
     role="alert">

    <i class="bi bi-arrow-up-right-circle-fill
              fs-2
              me-3">
    </i>


    <div>

        <strong>
            Anno finanziario non selezionato.
        </strong>

        <br />

        Seleziona l'anno finanziario
        dal menu in alto a destra.

    </div>

</div>


<%

    return;
}


/* ============================================================
   ANNO NUMERICO
   ============================================================ */

Integer selectedYear;


try {

    selectedYear =
        Integer.valueOf(
            viewData
                .getSelectedYear()
                .trim()
        );

} catch (Exception exc) {

%>


<div class="alert alert-danger">

    <i class="bi bi-exclamation-triangle-fill me-2"></i>

    Anno finanziario non valido:

    <strong>
        <%= viewData.getSelectedYear() %>
    </strong>

</div>


<%

    return;
}


/* ============================================================
   FORMATTAZIONE
   ============================================================ */

DecimalFormat formatoItaliano3Decimali =
    new DecimalFormat(
        "#,##0.000",
        DecimalFormatSymbols.getInstance(
            Locale.ITALY
        )
    );


/* ============================================================
   TIPOLOGIE ATTUALMENTE DEFINITE
   ============================================================ */

List<Tipologia> tipologieDefinite =
    TipologieDAO.findByUserAndAnno(
        user.getId(),
        selectedYear
    );


Set<String> tipologieValide =
    new TreeSet<String>(
        String.CASE_INSENSITIVE_ORDER
    );


if (tipologieDefinite != null) {

    for (Tipologia tipologia :
            tipologieDefinite) {


        if (tipologia == null ||
            tipologia.getValue() == null) {

            continue;
        }


        String nome =
            tipologia
                .getValue()
                .trim();


        if (!nome.isEmpty()) {

            tipologieValide.add(
                nome
            );
        }
    }
}


/* ============================================================
   RIGHE COERENTI / NON COERENTI

   IMPORTANTE:
   una riga non configurata viene considerata "non coerente"
   solo se contiene almeno un valore numerico diverso da zero.

   Le righe legacy completamente a zero vengono ignorate.
   ============================================================ */

List<RowData> righeCoerenti =
    new ArrayList<RowData>();


List<RowData> righeNonCoerenti =
    new ArrayList<RowData>();


if (viewData.getRows() != null) {

    for (RowData row :
            viewData.getRows()) {


        if (row == null) {
            continue;
        }


        String entry =
            row.getEntry() != null
                ? row.getEntry().trim()
                : "";


        /* ----------------------------------------------------
           TIPOLOGIA VALIDA
           ---------------------------------------------------- */

        if (!entry.isEmpty() &&
            tipologieValide.contains(entry)) {


            righeCoerenti.add(
                row
            );

            continue;
        }


        /* ----------------------------------------------------
           TIPOLOGIA NON VALIDA

           Verifichiamo se la riga contiene dati reali.
           ---------------------------------------------------- */

        boolean contieneValoriSignificativi =
            false;


        /* FCDE */

        try {

            BigDecimal valore =
                Utils.parseItalianNumber(
                    row.getFcde()
                );


            if (valore != null &&
                valore.compareTo(
                    BigDecimal.ZERO
                ) != 0) {


                contieneValoriSignificativi =
                    true;
            }

        } catch (Exception exc) {

            // ignora
        }


        /* SANZIONI + INTERESSI */

        if (!contieneValoriSignificativi &&
            row.getSanctionAndInterestValues() != null) {


            for (String value :
                    row.getSanctionAndInterestValues()) {


                try {

                    BigDecimal valore =
                        Utils.parseItalianNumber(
                            value
                        );


                    if (valore != null &&
                        valore.compareTo(
                            BigDecimal.ZERO
                        ) != 0) {


                        contieneValoriSignificativi =
                            true;

                        break;
                    }

                } catch (Exception exc) {

                    // ignora
                }
            }
        }


        /* QUOTA FCDE LIBERATA */

        if (!contieneValoriSignificativi &&
            row.getReleasedFcdeValues() != null) {


            for (String value :
                    row.getReleasedFcdeValues()) {


                try {

                    BigDecimal valore =
                        Utils.parseItalianNumber(
                            value
                        );


                    if (valore != null &&
                        valore.compareTo(
                            BigDecimal.ZERO
                        ) != 0) {


                        contieneValoriSignificativi =
                            true;

                        break;
                    }

                } catch (Exception exc) {

                    // ignora
                }
            }
        }


        /*
         * Aggiungiamo la riga tra i non coerenti
         * solo se contiene almeno un valore significativo.
         */
        if (contieneValoriSignificativi) {

            righeNonCoerenti.add(
                row
            );
        }
    }
}


/* ============================================================
   STATO PAGINA
   ============================================================ */

boolean hasCoherentRows =
    !righeCoerenti.isEmpty();


boolean hasIncoherentRows =
    !righeNonCoerenti.isEmpty();


/* ============================================================
   DIMENSIONI ARRAY TOTALI
   ============================================================ */

int numeroValoriTaglio =
    0;


int numeroValoriLiberati =
    0;


if (hasCoherentRows) {


    RowData firstRow =
        righeCoerenti.get(0);


    if (firstRow.getSanctionAndInterestValues() != null) {

        numeroValoriTaglio =
            firstRow
                .getSanctionAndInterestValues()
                .size();
    }


    if (firstRow.getReleasedFcdeValues() != null) {

        numeroValoriLiberati =
            firstRow
                .getReleasedFcdeValues()
                .size();
    }
}


/* ============================================================
   TOTALI
   ============================================================ */

BigDecimal totaleFcde =
    BigDecimal.ZERO;


BigDecimal[] totaliTaglio =
    new BigDecimal[numeroValoriTaglio];


BigDecimal[] totaliLiberati =
    new BigDecimal[numeroValoriLiberati];


for (int i = 0;
     i < totaliTaglio.length;
     i++) {


    totaliTaglio[i] =
        BigDecimal.ZERO;
}


for (int i = 0;
     i < totaliLiberati.length;
     i++) {


    totaliLiberati[i] =
        BigDecimal.ZERO;
}


/* ============================================================
   CALCOLO TOTALI SOLO SULLE RIGHE COERENTI
   ============================================================ */

for (RowData row :
        righeCoerenti) {


    /* --------------------------------------------------------
       FCDE
       -------------------------------------------------------- */

    try {

        BigDecimal valoreFcde =
            Utils.parseItalianNumber(
                row.getFcde()
            );


        if (valoreFcde != null) {

            totaleFcde =
                totaleFcde.add(
                    valoreFcde
                );
        }

    } catch (Exception exc) {

        // ignora
    }


    /* --------------------------------------------------------
       SANZIONI + INTERESSI
       -------------------------------------------------------- */

    if (row.getSanctionAndInterestValues() != null) {


        List<String> valori =
            row.getSanctionAndInterestValues();


        for (int i = 0;
             i < valori.size() &&
             i < totaliTaglio.length;
             i++) {


            try {

                BigDecimal valore =
                    Utils.parseItalianNumber(
                        valori.get(i)
                    );


                if (valore != null) {

                    totaliTaglio[i] =
                        totaliTaglio[i].add(
                            valore
                        );
                }

            } catch (Exception exc) {

                // ignora
            }
        }
    }


    /* --------------------------------------------------------
       QUOTA FCDE LIBERATA
       -------------------------------------------------------- */

    if (row.getReleasedFcdeValues() != null) {


        List<String> valori =
            row.getReleasedFcdeValues();


        for (int i = 0;
             i < valori.size() &&
             i < totaliLiberati.length;
             i++) {


            try {

                BigDecimal valore =
                    Utils.parseItalianNumber(
                        valori.get(i)
                    );


                if (valore != null) {

                    totaliLiberati[i] =
                        totaliLiberati[i].add(
                            valore
                        );
                }

            } catch (Exception exc) {

                // ignora
            }
        }
    }
}

%>



<!-- ============================================================
     TITOLO
     ============================================================ -->

<h3 class="mb-4">

    <i class="bi bi-calculator me-2"></i>

    QUOTA FCDE LIBERATA


    <span class="badge bg-primary ms-2">

        <%= viewData.getSelectedYear() %>

    </span>

</h3>



<!-- ============================================================
     WARNING VALORI NON COERENTI
     ============================================================ -->

<% if (hasIncoherentRows) { %>


<div class="alert alert-danger
            d-flex
            align-items-start
            shadow-sm
            mb-4"
     role="alert">


    <i class="bi bi-database-exclamation
              fs-2
              me-3">
    </i>


    <div class="flex-grow-1">


        <div class="fw-bold mb-1">

            Sono presenti dati associati
            a tipologie non più definite.

        </div>


        <div>

            Sono state individuate

            <strong>
                <%= righeNonCoerenti.size() %>
            </strong>

            tipologie storiche con valori effettivi
            che non corrispondono alle tipologie
            configurate per l'anno

            <strong>
                <%= selectedYear %>
            </strong>.

        </div>


        <div class="mt-2">

            Le righe legacy completamente a zero
            vengono ignorate.

            I valori indicati sotto invece

            <strong>
                non vengono utilizzati nel calcolo
                della quota FCDE liberata.
            </strong>

        </div>


        <button class="btn
                       btn-outline-danger
                       btn-sm
                       mt-3"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#nonCoherentValuesFcde"
                aria-expanded="false"
                aria-controls="nonCoherentValuesFcde">


            <i class="bi bi-eye-fill me-1"></i>

            Mostra valori non coerenti


            <span class="badge bg-danger ms-1">

                <%= righeNonCoerenti.size() %>

            </span>


        </button>


    </div>

</div>


<% } %>



<!-- ============================================================
     CARD PRINCIPALE
     ============================================================ -->

<div class="rounded
            p-4
            dati-card
            quota-fcde-card
            mt-4">


    <div class="dati-header mb-3">


        <div class="dati-title
                    dati-section-title">


            <i class="bi bi-table"></i>


            <span>

                DATI COMPUTATI DA CALCOLO FCDE E IPOTESI TAGLI

            </span>


        </div>


    </div>



    <% if (tipologieValide.isEmpty()) { %>


        <div class="alert alert-warning mb-0">


            <i class="bi bi-exclamation-triangle-fill me-2"></i>


            Nessuna tipologia definita per l'anno

            <strong>
                <%= selectedYear %>
            </strong>.


        </div>


    <% } else if (!hasCoherentRows) { %>


        <div class="alert alert-info mb-0">


            <i class="bi bi-info-circle-fill me-2"></i>


            Nessun dato disponibile per le tipologie
            attualmente definite.


        </div>


    <% } else { %>



    <!-- ========================================================
         TABELLA PRINCIPALE
         ======================================================== -->

    <div class="table-responsive">


        <table class="quota-fcde-table"
               aria-label="Calcolo della quota FCDE liberata"
               style="max-width:1500px">


            <colgroup>


                <col class="col-tipologia" />

                <col class="col-quota-fcde" />

                <col class="col-percentuale-fcde" />

                <col class="col-spacer" />


                <col class="col-importo" />

                <col class="col-importo" />

                <col class="col-importo" />


                <col class="col-spacer" />


                <col class="col-importo" />

                <col class="col-importo" />

                <col class="col-importo" />


            </colgroup>



            <!-- =================================================
                 HEADER SEZIONI
                 ================================================= -->

            <thead>


                <tr>


                    <th class="empty-header"
                        colspan="4">
                    </th>


                    <th class="section-header"
                        colspan="3"
                        scope="colgroup">

                        SANZIONI + INTERESSI

                    </th>


                    <th class="spacer-cell">
                    </th>


                    <th class="section-header"
                        colspan="3"
                        scope="colgroup">

                        QUOTA FCDE LIBERATA

                    </th>


                </tr>



                <!-- =============================================
                     HEADER COLONNE
                     ============================================= -->

                <tr>


                    <th class="percentage-header"
                        scope="col">

                        TIPOLOGIA

                    </th>


                    <th class="percentage-header"
                        scope="col">

                        Quota FCDE

                        <br />

                        accantonata

                        <br />

                        a consuntivo

                    </th>


                    <th class="percentage-header"
                        scope="col">

                        % FCDE

                    </th>


                    <td class="spacer-cell">
                    </td>



                    <!-- =========================================
                         PERCENTUALI SANZIONI
                         ========================================= -->

                    <%

                    if (viewData.getSanctionPercentages() != null) {

                        for (String percentage :
                                viewData.getSanctionPercentages()) {

                    %>


                        <th class="percentage-header"
                            scope="col">

                            <%= percentage %>

                        </th>


                    <%

                        }

                    }

                    %>



                    <th class="spacer-cell">
                    </th>



                    <!-- =========================================
                         PERCENTUALI INTERESSI
                         ========================================= -->

                    <%

                    if (viewData.getInterestPercentages() != null) {

                        for (String percentage :
                                viewData.getInterestPercentages()) {

                    %>


                        <th class="percentage-header"
                            scope="col">

                            <%= percentage %>

                        </th>


                    <%

                        }

                    }

                    %>


                </tr>


            </thead>



            <!-- =================================================
                 BODY
                 ================================================= -->

            <tbody>


                <tr class="separator-row"
                    aria-hidden="true">

                    <td colspan="11">
                    </td>

                </tr>



                <!-- =============================================
                     RIGHE COERENTI
                     ============================================= -->

                <%

                for (RowData row :
                        righeCoerenti) {

                %>


                <tr>


                    <!-- TIPOLOGIA -->

                    <td class="description-cell">

                        <%= row.getEntry() %>

                    </td>



                    <!-- FCDE -->

                    <td class="description-cell text-end">

                        <%= row.getFcde() %>

                    </td>



                    <!-- PERCENTUALE FCDE -->

                    <td class="description-cell text-end">

                        <%= row.getFcdePercentage() %>

                    </td>



                    <td class="spacer-cell">
                    </td>



                    <!-- =========================================
                         SANZIONI + INTERESSI
                         ========================================= -->

                    <%

                    if (row.getSanctionAndInterestValues() != null) {

                        for (String value :
                                row.getSanctionAndInterestValues()) {

                    %>


                        <td class="amount-cell">

                            <%= value %>

                        </td>


                    <%

                        }

                    }

                    %>



                    <td class="spacer-cell">
                    </td>



                    <!-- =========================================
                         QUOTA FCDE LIBERATA
                         ========================================= -->

                    <%

                    if (row.getReleasedFcdeValues() != null) {

                        for (String value :
                                row.getReleasedFcdeValues()) {

                    %>


                        <td class="amount-cell">

                            <%= value %>

                        </td>


                    <%

                        }

                    }

                    %>


                </tr>


                <% } %>



                <!-- =================================================
                     TOTALI

                     Sono calcolati SOLO dalle righe coerenti.
                     ================================================= -->

                <tr class="totals-row">


                    <th class="total-label"
                        scope="row">

                        TOTALI

                    </th>



                    <td class="total-number text-end">

                        <%= formatoItaliano3Decimali.format(
                                totaleFcde
                            ) %>

                    </td>



                    <td class="total-number">
                    </td>



                    <td class="spacer-cell">
                    </td>



                    <!-- =========================================
                         TOTALI SANZIONI + INTERESSI
                         ========================================= -->

                    <%

                    for (BigDecimal totale :
                            totaliTaglio) {

                    %>


                        <td class="total-number text-end">

                            <%= formatoItaliano3Decimali.format(
                                    totale
                                ) %>

                        </td>


                    <% } %>



                    <td class="spacer-cell">
                    </td>



                    <!-- =========================================
                         TOTALI QUOTA LIBERATA
                         ========================================= -->

                    <%

                    for (BigDecimal totale :
                            totaliLiberati) {

                    %>


                        <td class="total-number text-end">

                            <%= formatoItaliano3Decimali.format(
                                    totale
                                ) %>

                        </td>


                    <% } %>


                </tr>


            </tbody>


        </table>


    </div>


    <% } %>


</div>



<!-- ============================================================
     VALORI NON COERENTI
     ============================================================ -->

<% if (hasIncoherentRows) { %>


<div class="collapse mt-4"
     id="nonCoherentValuesFcde">


    <div class="card border-danger">


        <!-- ====================================================
             HEADER
             ==================================================== -->

        <div class="card-header border-danger">


            <div class="d-flex
                        align-items-center
                        justify-content-between">


                <div class="fw-bold text-danger">


                    <i class="bi bi-exclamation-octagon-fill me-2">
                    </i>


                    VALORI NON COERENTI


                </div>


                <span class="badge bg-danger">

                    <%= righeNonCoerenti.size() %>

                </span>


            </div>


        </div>



        <!-- ====================================================
             BODY
             ==================================================== -->

        <div class="card-body">


            <div class="alert alert-warning">


                <div class="d-flex align-items-start">


                    <i class="bi bi-info-circle-fill
                              fs-4
                              me-3">
                    </i>


                    <div>


                        <strong>

                            Sono presenti valori relativi
                            a vecchie tipologie.

                        </strong>


                        <br />


                        Le righe seguenti fanno riferimento
                        a tipologie non più presenti nella
                        configurazione

                        <strong>
                            Def. tipologie
                        </strong>

                        per l'anno

                        <strong>
                            <%= selectedYear %>
                        </strong>.


                        <br /><br />


                        Le righe legacy completamente a zero
                        vengono ignorate automaticamente.


                        <br />


                        I valori sotto riportati invece

                        <strong>
                            contengono dati effettivi
                        </strong>

                        e non vengono utilizzati
                        nei calcoli correnti.


                        <br /><br />


                        <strong>

                            Chiedere a un amministratore
                            di verificare ed eventualmente
                            rimuovere i vecchi dati.

                        </strong>


                    </div>


                </div>


            </div>



            <!-- =================================================
                 TABELLA DATI NON COERENTI
                 ================================================= -->

            <div class="table-responsive">


                <table class="table
                              table-bordered
                              table-hover
                              table-sm"
                       style="max-width:1300px">


                    <thead class="table-danger">


                        <tr>


                            <th>
                                TIPOLOGIA OBSOLETA
                            </th>


                            <th>
                                QUOTA FCDE
                            </th>


                            <th>
                                % FCDE
                            </th>


                            <th colspan="3">

                                SANZIONI + INTERESSI

                            </th>


                            <th colspan="3">

                                QUOTA FCDE LIBERATA

                            </th>


                        </tr>


                    </thead>



                    <tbody>


                        <%

                        for (RowData row :
                                righeNonCoerenti) {

                        %>


                        <tr>


                            <!-- =====================================
                                 TIPOLOGIA
                                 ===================================== -->

                            <td class="text-danger fw-bold">


                                <i class="bi bi-x-circle-fill me-1">
                                </i>


                                <%= row.getEntry() != null &&
                                    !row.getEntry().trim().isEmpty()
                                        ? row.getEntry()
                                        : "(tipologia vuota)" %>


                            </td>



                            <!-- =====================================
                                 FCDE
                                 ===================================== -->

                            <td class="text-number">

                                <%= row.getFcde() %>

                            </td>



                            <!-- =====================================
                                 % FCDE
                                 ===================================== -->

                            <td class="text-number">

                                <%= row.getFcdePercentage() %>

                            </td>



                            <!-- =====================================
                                 SANZIONI + INTERESSI
                                 ===================================== -->

                            <%

                            if (row.getSanctionAndInterestValues() != null) {

                                for (String value :
                                        row.getSanctionAndInterestValues()) {

                            %>


                                <td class="text-number">

                                    <%= value %>

                                </td>


                            <%

                                }

                            }

                            %>



                            <!-- =====================================
                                 QUOTA FCDE LIBERATA
                                 ===================================== -->

                            <%

                            if (row.getReleasedFcdeValues() != null) {

                                for (String value :
                                        row.getReleasedFcdeValues()) {

                            %>


                                <td class="text-number">

                                    <%= value %>

                                </td>


                            <%

                                }

                            }

                            %>


                        </tr>


                        <% } %>


                    </tbody>


                </table>


            </div>



            <!-- =================================================
                 WARNING ADMIN
                 ================================================= -->

            <div class="alert alert-danger mb-0">


                <i class="bi bi-shield-exclamation me-2"></i>


                <strong>

                    Intervento amministrativo richiesto:

                </strong>


                i valori sopra elencati appartengono
                a tipologie non più definite e contengono
                valori effettivi.

                Chiedere a un amministratore
                di verificarli ed eventualmente
                rimuoverli.


            </div>


        </div>


    </div>


</div>


<% } %>



<!-- ============================================================
     SCROLL AUTOMATICO
     ============================================================ -->

<style>

#nonCoherentValuesFcde {

    scroll-margin-top: 100px;

}

</style>


<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {


        const section =
            document.getElementById(
                "nonCoherentValuesFcde"
            );


        if (!section) {
            return;
        }


        section.addEventListener(
            "shown.bs.collapse",
            function () {


                section.scrollIntoView({
                    behavior: "smooth",
                    block: "start"
                });


            }
        );

    }
);

</script>