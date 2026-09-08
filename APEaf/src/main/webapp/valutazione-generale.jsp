<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>

<%@ page import="is.five.apeaf.dao.model.UserView" %>

<%@ page import="is.five.apeaf.service.ValutazioneGeneraleService" %>
<%@ page import="is.five.apeaf.service.ValutazioneGeneraleService.ViewData" %>


<%

/* ============================================================
   CALLER
   ============================================================ */

request.getSession().setAttribute(
    SessionVariables.CALLER,
    "valutazione-generale.jsp"
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

ValutazioneGeneraleService service =
    new ValutazioneGeneraleService();


ViewData viewData =
    service.load(
        user,
        selectedYearId
    );


/* ============================================================
   ANNO NON SELEZIONATO
   ============================================================ */

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


    VALUTAZIONE GENERALE


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
            valutazione-generale-card">


    <!-- ========================================================
         HEADER
         ======================================================== -->

    <div class="dati-header mb-3">


        <div class="dati-title
                    dati-section-title">


            <i class="bi bi-calculator-fill"></i>


            <span>

                DATI COMPUTATI DA RESIDUI ATTIVI,
                RIFLESSI SUL BILANCIO
                E QUOTA FCDE LIBERATA

            </span>


        </div>


    </div>



    <% if (!viewData.hasData()) { %>


        <!-- ====================================================
             NESSUN DATO
             ==================================================== -->

        <div class="alert alert-info mb-0">


            <i class="bi bi-info-circle-fill me-2"></i>


            Nessun dato disponibile
            per l'anno

            <strong>
                <%= viewData.getSelectedYear() %>
            </strong>.


        </div>


    <% } else { %>



    <!-- ========================================================
         TABELLA
         ======================================================== -->

    <div class="valutazione-generale-table-wrapper">


        <table class="valutazione-generale-table"
               aria-label="Valutazione generale degli effetti sul bilancio"
               style="max-width:1200px">


            <!-- =================================================
                 HEADER
                 ================================================= -->

            <thead>


                <tr>


                    <th class="valutazione-generale-empty-header">
                    </th>


                    <th colspan="<%= viewData.getHypothesisLabels().size() %>"
                        class="valutazione-generale-main-header">


                        <i class="bi bi-percent me-2"></i>


                        TAGLIO SANZIONI + INTERESSI


                    </th>


                </tr>



                <tr>


                    <th class="valutazione-generale-row-header">
                    </th>


                    <%

                    for (String percentage :
                            viewData.getHypothesisLabels()) {

                    %>


                        <th class="valutazione-generale-percentuale">


                            <%= percentage %>


                        </th>


                    <% } %>


                </tr>


            </thead>



            <!-- =================================================
                 BODY
                 ================================================= -->

            <tbody>


                <!-- =============================================
                     TOTALE RESIDUI
                     ============================================= -->

                <tr>


                    <th scope="row">


                        TOTALE RESIDUI


                    </th>


                    <%

                    for (String value :
                            viewData.getTotalResidualValues()) {

                    %>


                        <td>

                            <%= value %>

                        </td>


                    <% } %>


                </tr>



                <!-- =============================================
                     TOTALE TAGLI
                     ============================================= -->

                <tr>


                    <th scope="row">


                        TOTALE TAGLI


                    </th>


                    <%

                    for (String value :
                            viewData.getTotalCutValues()) {

                    %>


                        <td>

                            <%= value %>

                        </td>


                    <% } %>


                </tr>



                <!-- =============================================
                     RESIDUI AL NETTO
                     ============================================= -->

                <tr>


                    <th scope="row">


                        RESIDUI AL NETTO


                    </th>


                    <%

                    for (String value :
                            viewData.getNetResidualValues()) {

                    %>


                        <td>

                            <%= value %>

                        </td>


                    <% } %>


                </tr>



                <!-- =============================================
                     MINOR ACCANTONAMENTO FCDE
                     ============================================= -->

                <tr>


                    <th scope="row">


                        MINOR ACCANTONAMENTO FCDE


                    </th>


                    <%

                    for (String value :
                            viewData.getMinorFcdeValues()) {

                    %>


                        <td>

                            <%= value %>

                        </td>


                    <% } %>


                </tr>



                <!-- =============================================
                     RISULTATO FINALE
                     ============================================= -->

                <tr class="valutazione-generale-result-row">


                    <th scope="row">


                        TOTALE


                    </th>


                    <%

                    for (String value :
                            viewData.getTotalValues()) {

                    %>


						<%
						String sign = "+";
						String absoluteValue = value != null ? value.trim() : "0";
						
						if (absoluteValue.startsWith("-")) {
						    sign = "-";
						    absoluteValue = absoluteValue.substring(1).trim();
						} else if (absoluteValue.startsWith("+")) {
						    sign = "+";
						    absoluteValue = absoluteValue.substring(1).trim();
						}
						%>
						
						<% if ("+".equals(sign)) { %>
						
						    <td class="valutazione-generale-positive">
						
						<% } else { %>
						
						    <td class="valutazione-generale-negative">
						
						<% } %>
						
						        <span class="valutazione-generale-sign">
						            <%= sign %>
						        </span>
						
						        <span>
						            <%= absoluteValue %>
						        </span>
						
						    </td>


                    <% } %>


                </tr>


            </tbody>


        </table>


    </div>


    <% } %>


</div>


</div>