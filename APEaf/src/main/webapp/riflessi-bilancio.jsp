<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>

<%@ page import="is.five.apeaf.dao.model.UserView" %>

<%@ page import="is.five.apeaf.service.RiflessiBilancioService" %>
<%@ page import="is.five.apeaf.service.RiflessiBilancioService.ViewData" %>
<%@ page import="is.five.apeaf.service.RiflessiBilancioService.RowData" %>
<%@ page import="is.five.apeaf.service.RiflessiBilancioService.TotalsData" %>


<%

request.getSession().setAttribute(
    SessionVariables.CALLER,
    "riflessi-bilancio.jsp"
);


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

RiflessiBilancioService service =
    new RiflessiBilancioService();


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

%>



<div class="page-container">


<!-- ============================================================
     TITOLO
     ============================================================ -->

<h3 class="mb-4">


    <i class="bi bi-calculator me-2"></i>


    RIFLESSI SUL BILANCIO


    <span class="badge bg-primary ms-2">

        <%= viewData.getSelectedYear() %>

    </span>


</h3>



<!-- ============================================================
     CARD
     ============================================================ -->

<div class="rounded
            p-4
            dati-card
            riflessi-bilancio-card
            mt-4">


    <div class="dati-header mb-3">


        <div class="dati-title
                    dati-section-title">


            <i class="bi bi-table"></i>


            <span>

                DATI COMPUTATI DA RESIDUI ATTIVI,
                IPOTESI TAGLI E QUOTA FCDE LIBERATA

            </span>


        </div>


    </div>



    <% if (viewData.getRows() == null ||
           viewData.getRows().isEmpty()) { %>


        <div class="alert alert-info mb-0">


            <i class="bi bi-info-circle-fill me-2"></i>


            Nessun dato disponibile per le tipologie
            definite nell'anno

            <strong>
                <%= viewData.getSelectedYear() %>
            </strong>.


        </div>


    <% } else { %>



    <div class="table-responsive">


        <table class="riflessi-bilancio-table"
               aria-label="Impatto delle ipotesi di taglio sul bilancio"
               style="max-width:1200px">


            <colgroup>


                <col class="col-descrizione" />


                <%

                for (int i = 0;
                     i < viewData
                            .getHypothesisLabels()
                            .size();
                     i++) {

                %>


                    <col class="col-importo" />


                <% } %>


            </colgroup>



            <!-- =================================================
                 HEADER
                 ================================================= -->

            <thead>


                <tr>


                    <th class="empty-header">
                    </th>


                    <th class="section-header"
                        colspan="<%= viewData.getHypothesisLabels().size() %>"
                        scope="colgroup">


                        IPOTESI TAGLIO SANZIONI + INTERESSI


                    </th>


                </tr>



                <tr>


                    <th class="empty-header">
                    </th>


                    <%

                    for (String percentage :
                            viewData.getHypothesisLabels()) {

                    %>


                        <th class="percentage-header"
                            scope="col">


                            <%= percentage %>


                        </th>


                    <% } %>


                </tr>


            </thead>



            <!-- =================================================
                 BODY
                 ================================================= -->

            <tbody>


                <%

                for (RowData row :
                        viewData.getRows()) {

                %>


                    <!-- =========================================
                         SEPARATORE
                         ========================================= -->

                    <tr class="separator-row"
                        aria-hidden="true">


                        <td colspan="<%= 1 + viewData.getHypothesisLabels().size() %>">
                        </td>


                    </tr>



                    <!-- =========================================
                         TIPOLOGIA
                         ========================================= -->

                    <tr>


                        <th class="group-title"
                            scope="rowgroup">


                            <%= row.getEntry() %>


                        </th>


                        <td class="empty-header"
                            colspan="<%= viewData.getHypothesisLabels().size() %>">
                        </td>


                    </tr>



                    <!-- =========================================
                         RESIDUI ATTIVI
                         ========================================= -->

                    <tr>


                        <td class="description-cell">


                            RESIDUI ATTIVI


                        </td>


                        <%

                        for (String value :
                                row.getResidualValues()) {

                        %>


                            <td class="amount-cell">

                                <%= value %>

                            </td>


                        <% } %>


                    </tr>



                    <!-- =========================================
                         TAGLIO
                         ========================================= -->

                    <tr>


                        <td class="description-cell">


                            TAGLIO


                        </td>


                        <%

                        for (String value :
                                row.getCutValues()) {

                        %>


                            <td class="amount-cell">

                                <%= value %>

                            </td>


                        <% } %>


                    </tr>



                    <!-- =========================================
                         NUOVI RESIDUI
                         ========================================= -->

                    <tr>


                        <td class="description-cell">


                            NUOVI RESIDUI


                        </td>


                        <%

                        for (String value :
                                row.getNewResidualValues()) {

                        %>


                            <td class="amount-cell">

                                <%= value %>

                            </td>


                        <% } %>


                    </tr>



                    <!-- =========================================
                         MINOR ACCANTONAMENTO
                         ========================================= -->

                    <tr>


                        <td class="description-cell">


                            MINOR ACCANTONAMENTO FCDE


                        </td>


                        <%

                        for (String value :
                                row.getMinorFcdeValues()) {

                        %>


                            <td class="amount-cell">

                                <%= value %>

                            </td>


                        <% } %>


                    </tr>



                    <!-- =========================================
                         IMPATTO
                         ========================================= -->

                    <tr>


                        <td class="impact-label">


                            IMPATTO SUL BILANCIO


                        </td>


                        <%

                        for (String value :
                                row.getBudgetImpactValues()) {

                        %>


                            <td class="impact-value">

                                <%= value %>

                            </td>


                        <% } %>


                    </tr>


                <% } %>



                <!-- =================================================
                     TOTALI
                     ================================================= -->

                <%

                TotalsData totals =
                    viewData.getTotals();

                %>


                <tr class="separator-row"
                    aria-hidden="true">


                    <td colspan="<%= 1 + viewData.getHypothesisLabels().size() %>">
                    </td>


                </tr>



                <tr>


                    <th class="totals-title"
                        scope="rowgroup">


                        TOTALI


                    </th>


                    <td class="empty-header"
                        colspan="<%= viewData.getHypothesisLabels().size() %>">
                    </td>


                </tr>



                <!-- TOTALI RESIDUI -->

                <tr class="total-row">


                    <td class="description-cell">

                        RESIDUI ATTIVI

                    </td>


                    <%

                    for (String value :
                            totals.getResidualValues()) {

                    %>


                        <td class="amount-cell">

                            <%= value %>

                        </td>


                    <% } %>


                </tr>



                <!-- TOTALI TAGLIO -->

                <tr class="total-row">


                    <td class="description-cell">

                        TAGLIO

                    </td>


                    <%

                    for (String value :
                            totals.getCutValues()) {

                    %>


                        <td class="amount-cell">

                            <%= value %>

                        </td>


                    <% } %>


                </tr>



                <!-- TOTALI NUOVI RESIDUI -->

                <tr class="total-row">


                    <td class="description-cell">

                        NUOVI RESIDUI

                    </td>


                    <%

                    for (String value :
                            totals.getNewResidualValues()) {

                    %>


                        <td class="amount-cell">

                            <%= value %>

                        </td>


                    <% } %>


                </tr>



                <!-- TOTALI MINOR FCDE -->

                <tr class="total-row">


                    <td class="description-cell">

                        MINOR ACCANTONAMENTO FCDE

                    </td>


                    <%

                    for (String value :
                            totals.getMinorFcdeValues()) {

                    %>


                        <td class="amount-cell">

                            <%= value %>

                        </td>


                    <% } %>


                </tr>



                <!-- TOTALI IMPATTO -->

                <tr>


                    <td class="impact-label">

                        IMPATTO SUL BILANCIO

                    </td>


                    <%

                    for (String value :
                            totals.getBudgetImpactValues()) {

                    %>


                        <td class="impact-value">

                            <%= value %>

                        </td>


                    <% } %>


                </tr>


            </tbody>


        </table>


    </div>


    <% } %>


</div>


</div>