<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService" %>
<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService.ViewData" %>
<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService.RowData" %>
<%@ page import="is.five.apeaf.service.QuotaFcdeLiberataService.TotalsData" %>

<%
request.getSession().setAttribute(
        SessionVariables.CALLER,
        "quota-fcde-liberata.jsp");

UserView user = (UserView) request.getSession().getAttribute("ubAP");
if (user == null || !user.getActive()) {
    response.sendRedirect("index.jsp");
    return;
}

String selectedYearId = session.getAttribute(SessionVariables.ANNO) != null
        ? (String) session.getAttribute(SessionVariables.ANNO)
        : "";

QuotaFcdeLiberataService service = new QuotaFcdeLiberataService();
ViewData viewData = service.load(user, selectedYearId);

if (!viewData.hasSelectedYear()) {
%>

<div class="alert alert-warning d-flex align-items-center shadow-sm mb-4"
     role="alert">
    <i class="bi bi-arrow-up-right-circle-fill fs-2 me-3"></i>
    <div>
        <strong>Anno finanziario non selezionato.</strong><br />
        Seleziona l'anno finanziario dal menu in alto a destra.
    </div>
</div>

<%
    return;
}
%>

<h3 class="mb-4">
    <i class="bi bi-calculator"></i> QUOTA FCDE LIBERATA
    <span class="badge bg-primary ms-2"><%= viewData.getSelectedYear() %></span>
</h3>

<div class="rounded p-4 dati-card quota-fcde-card mt-4">
    <div class="dati-header mb-3">
        <div class="dati-title dati-section-title">
            <i class="bi bi-table"></i>
            <span>DATI COMPUTATI DA CALCOLO FCDE E IPOTESI TAGLI</span>
        </div>
    </div>

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

            <thead>
                <tr>
                    <th class="empty-header" colspan="4"></th>
                    <th class="section-header" colspan="3" scope="colgroup">
                        SANZIONI + INTERESSI
                    </th>
                    <th class="spacer-cell"></th>
                    <th class="section-header" colspan="3" scope="colgroup">
                        QUOTA FCDE LIBERATA
                    </th>
                </tr>

                <tr>
                    <th class="percentage-header" scope="col">ENTRATA</th>
                    <th class="percentage-header" scope="col">
                        Quota FCDE<br />accantonata<br />a consuntivo
                    </th>
                    <th class="percentage-header" scope="col">% FCDE</th>
                    <td class="spacer-cell"></td>

                    <% for (String percentage : viewData.getSanctionPercentages()) { %>
                        <th class="percentage-header" scope="col"><%= percentage %></th>
                    <% } %>

                    <th class="spacer-cell"></th>

                    <% for (String percentage : viewData.getInterestPercentages()) { %>
                        <th class="percentage-header" scope="col"><%= percentage %></th>
                    <% } %>
                </tr>
            </thead>

            <tbody>
                <tr class="separator-row" aria-hidden="true">
                    <td colspan="11"></td>
                </tr>

                <% for (RowData row : viewData.getRows()) { %>
                    <tr>
                        <td class="description-cell"><%= row.getEntry() %></td>
                        <td class="description-cell text-end"><%= row.getFcde() %></td>
                        <td class="description-cell text-end"><%= row.getFcdePercentage() %></td>
                        <td class="spacer-cell"></td>

                        <% for (String value : row.getSanctionAndInterestValues()) { %>
                            <td class="amount-cell"><%= value %></td>
                        <% } %>

                        <td class="spacer-cell"></td>

                        <% for (String value : row.getReleasedFcdeValues()) { %>
                            <td class="amount-cell"><%= value %></td>
                        <% } %>
                    </tr>
                <% } %>

                <% TotalsData totals = viewData.getTotals(); %>

                <tr class="totals-row">
                    <th class="total-label" scope="row">TOTALI</th>
                    <td class="total-number text-end"><%= totals.getFcde() %></td>
                    <td class="total-number"></td>
                    <td class="spacer-cell"></td>

                    <% for (String value : totals.getSanctionAndInterestValues()) { %>
                        <td class="total-number text-end"><%= value %></td>
                    <% } %>

                    <td class="spacer-cell"></td>

                    <% for (String value : totals.getReleasedFcdeValues()) { %>
                        <td class="total-number text-end"><%= value %></td>
                    <% } %>
                </tr>
            </tbody>
        </table>
    </div>
</div>
