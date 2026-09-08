<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.utils.Utils" %>

<%@ page import="is.five.apeaf.dao.TipologieDAO" %>

<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@ page import="is.five.apeaf.dao.model.Tipologia" %>

<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService" %>
<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService.ViewData" %>
<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService.RowData" %>
<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService.TotalsData" %>


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


if (user == null ||
    !user.getActive()) {


    response.sendRedirect(
        "index.jsp"
    );

    return;
}


/* ============================================================
   ANNO
   ============================================================ */

String selectedYearId =
    session.getAttribute(
        SessionVariables.ANNO
    ) != null

        ? String.valueOf(
            session.getAttribute(
                SessionVariables.ANNO
            )
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


    <i class="bi bi-exclamation-triangle-fill me-2">
    </i>


    Anno finanziario non valido:


    <strong>

        <%= viewData.getSelectedYear() %>

    </strong>


</div>


<%

    return;
}


/* ============================================================
   TIPOLOGIE DEFINITE
   ============================================================ */

List<Tipologia> tipologie =
    TipologieDAO.findByUserAndAnno(
        user.getId(),
        selectedYear
    );


Set<String> tipologieValide =
    new TreeSet<String>(
        String.CASE_INSENSITIVE_ORDER
    );


if (tipologie != null) {


    for (Tipologia tipologia :
            tipologie) {


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
   COERENTI / NON COERENTI

   Normalmente il nuovo service restituisce già solo coerenti.

   Manteniamo comunque il controllo per sicurezza.
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


        String nome =
            row.getEntry() != null

                ? row
                    .getEntry()
                    .trim()

                : "";


        if (!nome.isEmpty() &&
            tipologieValide.contains(nome)) {


            righeCoerenti.add(
                row
            );


            continue;
        }


        /* ----------------------------------------------------
           Non segnaliamo righe obsolete completamente a zero.
           ---------------------------------------------------- */

        boolean significativo =
            false;


        try {


            BigDecimal value =
                Utils.parseItalianNumber(
                    row.getFcde()
                );


            significativo =
                value != null &&
                value.compareTo(
                    BigDecimal.ZERO
                ) != 0;


        } catch (Exception exc) {

            significativo =
                false;
        }


        if (!significativo &&
            row.getSanctionAndInterestValues() != null) {


            for (String value :
                    row.getSanctionAndInterestValues()) {


                try {


                    BigDecimal parsed =
                        Utils.parseItalianNumber(
                            value
                        );


                    if (parsed != null &&
                        parsed.compareTo(
                            BigDecimal.ZERO
                        ) != 0) {


                        significativo =
                            true;

                        break;
                    }


                } catch (Exception exc) {

                    // ignora
                }
            }
        }


        if (!significativo &&
            row.getReleasedFcdeValues() != null) {


            for (String value :
                    row.getReleasedFcdeValues()) {


                try {


                    BigDecimal parsed =
                        Utils.parseItalianNumber(
                            value
                        );


                    if (parsed != null &&
                        parsed.compareTo(
                            BigDecimal.ZERO
                        ) != 0) {


                        significativo =
                            true;

                        break;
                    }


                } catch (Exception exc) {

                    // ignora
                }
            }
        }


        if (significativo) {

            righeNonCoerenti.add(
                row
            );
        }
    }
}


boolean hasRows =
    !righeCoerenti.isEmpty();


boolean hasIncoherentRows =
    !righeNonCoerenti.isEmpty();


TotalsData totals =
    viewData.getTotals();

%>



<!-- ============================================================
     TITOLO
     ============================================================ -->

<h3 class="mb-4">


    <i class="bi bi-calculator me-2">
    </i>


    QUOTA FCDE LIBERATA


    <span class="badge bg-primary ms-2">

        <%= viewData.getSelectedYear() %>

    </span>


</h3>



<!-- ============================================================
     WARNING
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


        <strong>

            Sono presenti dati relativi
            a tipologie non più definite.

        </strong>


        <div class="mt-2">


            Questi valori non partecipano
            al calcolo corrente.


        </div>


        <button type="button"
                class="btn
                       btn-sm
                       btn-outline-danger
                       mt-3"
                data-bs-toggle="collapse"
                data-bs-target="#nonCoherentValuesFcde">


            <i class="bi bi-eye-fill me-1">
            </i>


            Mostra valori non coerenti


            <span class="badge bg-danger ms-1">

                <%= righeNonCoerenti.size() %>

            </span>


        </button>


    </div>


</div>


<% } %>



<!-- ============================================================
     CARD
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

                DATI COMPUTATI DA CALCOLO FCDE
                E IPOTESI TAGLI

            </span>


        </div>


    </div>



    <% if (tipologieValide.isEmpty()) { %>


        <div class="alert alert-warning mb-0">


            Nessuna tipologia definita
            per l'anno

            <strong>
                <%= selectedYear %>
            </strong>.


        </div>


    <% } else if (!hasRows) { %>


        <div class="alert alert-info mb-0">


            Nessun dato disponibile.


        </div>


    <% } else { %>



    <div class="table-responsive">


        <table class="quota-fcde-table"
               aria-label="Calcolo quota FCDE liberata"
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



            <thead>


                <tr>


                    <th class="empty-header"
                        colspan="4">
                    </th>


                    <th class="section-header"
                        colspan="3">

                        SANZIONI + INTERESSI

                    </th>


                    <th class="spacer-cell">
                    </th>


                    <th class="section-header"
                        colspan="3">

                        QUOTA FCDE LIBERATA

                    </th>


                </tr>



                <tr>


                    <th class="percentage-header">

                        TIPOLOGIA

                    </th>


                    <th class="percentage-header">

                        Quota FCDE

                        <br />

                        accantonata

                        <br />

                        a consuntivo

                    </th>


                    <th class="percentage-header">

                        % FCDE

                    </th>


                    <td class="spacer-cell">
                    </td>



                    <!-- =================================================
                         Le ipotesi sono identificate dal parametro
                         SANZIONE.

                         Il parametro INTERESSI corrispondente viene
                         applicato internamente allo stesso indice.
                         ================================================= -->

                    <%

                    for (String percentage :
                            viewData.getSanctionPercentages()) {

                    %>


                        <th class="percentage-header">

                            <%= percentage %>

                        </th>


                    <% } %>



                    <th class="spacer-cell">
                    </th>



                    <%

                    for (String percentage :
                            viewData.getSanctionPercentages()) {

                    %>


                        <th class="percentage-header">

                            <%= percentage %>

                        </th>


                    <% } %>


                </tr>


            </thead>



            <tbody>


                <tr class="separator-row"
                    aria-hidden="true">


                    <td colspan="11">
                    </td>


                </tr>



                <%

                for (RowData row :
                        righeCoerenti) {

                %>


                <tr>


                    <td class="description-cell">

                        <%= row.getEntry() %>

                    </td>


                    <td class="description-cell text-end">

                        <%= row.getFcde() %>

                    </td>


                    <td class="description-cell text-end">

                        <%= row.getFcdePercentage() %>

                    </td>


                    <td class="spacer-cell">
                    </td>



                    <%

                    for (String value :
                            row.getSanctionAndInterestValues()) {

                    %>


                        <td class="amount-cell">

                            <%= value %>

                        </td>


                    <% } %>



                    <td class="spacer-cell">
                    </td>



                    <%

                    for (String value :
                            row.getReleasedFcdeValues()) {

                    %>


                        <td class="amount-cell">

                            <%= value %>

                        </td>


                    <% } %>


                </tr>


                <% } %>



                <!-- =================================================
                     TOTALI DIRETTAMENTE DAL SERVICE

                     Nessun ricalcolo nel JSP.
                     ================================================= -->

                <tr class="totals-row">


                    <th class="total-label">

                        TOTALI

                    </th>


                    <td class="total-number text-end">

                        <%= totals.getFcde() %>

                    </td>


                    <td class="total-number">
                    </td>


                    <td class="spacer-cell">
                    </td>



                    <%

                    for (String value :
                            totals.getSanctionAndInterestValues()) {

                    %>


                        <td class="total-number text-end">

                            <%= value %>

                        </td>


                    <% } %>



                    <td class="spacer-cell">
                    </td>



                    <%

                    for (String value :
                            totals.getReleasedFcdeValues()) {

                    %>


                        <td class="total-number text-end">

                            <%= value %>

                        </td>


                    <% } %>


                </tr>


            </tbody>


        </table>


    </div>


    <% } %>


</div>



<!-- ============================================================
     NON COERENTI
     ============================================================ -->

<% if (hasIncoherentRows) { %>


<div class="collapse mt-4"
     id="nonCoherentValuesFcde">


    <div class="card border-danger">


        <div class="card-header
                    border-danger
                    fw-bold
                    text-danger">


            <i class="bi bi-exclamation-octagon-fill me-2">
            </i>


            VALORI NON COERENTI


        </div>


        <div class="card-body">


            <div class="table-responsive">


                <table class="table
                              table-bordered
                              table-sm
                              table-hover">


                    <thead class="table-danger">


                        <tr>


                            <th>

                                TIPOLOGIA

                            </th>


                            <th>

                                FCDE

                            </th>


                            <th>

                                % FCDE

                            </th>


                        </tr>


                    </thead>


                    <tbody>


                        <%

                        for (RowData row :
                                righeNonCoerenti) {

                        %>


                        <tr>


                            <td class="text-danger fw-bold">

                                <%= row.getEntry() %>

                            </td>


                            <td>

                                <%= row.getFcde() %>

                            </td>


                            <td>

                                <%= row.getFcdePercentage() %>

                            </td>


                        </tr>


                        <% } %>


                    </tbody>


                </table>


            </div>


            <div class="alert alert-danger mb-0">


                <strong>

                    Chiedere a un amministratore
                    di verificare ed eventualmente
                    rimuovere i vecchi dati.

                </strong>


            </div>


        </div>


    </div>


</div>


<% } %>



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