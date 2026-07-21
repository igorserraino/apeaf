<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.PageData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.GroupData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.RowData" %>
<%
request.getSession().setAttribute(SessionVariables.CALLER, "importi-definibili.jsp");
UserView user = (UserView) request.getSession().getAttribute("ubAP");
if (user == null || !user.getActive()) {
    response.sendRedirect("index.jsp");
    return;
}
String selectedYearId = session.getAttribute(SessionVariables.ANNO) != null
        ? (String) session.getAttribute(SessionVariables.ANNO)
        : "";
ImportiDefinibiliService service = new ImportiDefinibiliService();
PageData pageData = service.load(user, selectedYearId);
if (!pageData.hasSelectedYear()) {
%>
<div class="alert alert-warning d-flex align-items-center shadow-sm mb-4" role="alert">
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
    <i class="bi bi-calculator"></i> IMPORTI DEFINIBILI
    <span class="badge bg-primary ms-2"><%= pageData.getSelectedYear() %></span>
</h3>
<!-- AREA VISUALIZZAZIONE -->
<div class="rounded p-4 dati-card mt-4">
    <div class="dati-header mb-3">
        <div class="dati-title dati-section-title">
            <i class="bi bi-table"></i>
            <span>DATI COMPUTATI DA TABELLA RUOLI</span>
        </div>
    </div>
    <% if (!pageData.hasGroups()) { %>
    <div class="alert alert-info mb-0">Nessun ruolo coattivo memorizzato.</div>
    <% } else { %>
        <% for (GroupData group : pageData.getGroups()) { %>
        <div class="tab-ruoli-group">
            <div class="tab-ruoli-title-light" style="max-width:800px">
                <i class="bi bi-cash-coin"></i>
                <span>Entrata: <%= group.getEntry() %></span>
            </div>
            <div class="tab-ruoli-container">
                <table class="table table-bordered table-hover table-sm table-ruoli"
                       style="max-width:800px">
                    <thead>
                        <tr>
                            <th>ENTRATA</th>
                            <th>Anno ruolo coattivo</th>
                            <th>num. ruolo</th>
                            <th>IMPOSTA RESIDUA</th>
                            <th>SANZIONI RESIDUE</th>
                            <th>INTERESSI RESIDUI</th>
                            <th>Totale</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (RowData row : group.getRows()) { %>
                        <tr>
                            <td><%= row.getEntry() %></td>
                            <td class="text-center"><%= row.getRoleYear() %></td>
                            <td class="text-center"><%= row.getRoleNumber() %></td>
                            <td class="text-number"><%= row.getResidualTax() %></td>
                            <td class="text-number"><%= row.getResidualSanctions() %></td>
                            <td class="text-number"><%= row.getResidualInterest() %></td>
                            <td class="text-number"><%= row.getTotal() %></td>
                        </tr>
                        <% } %>
                        <tr class="table-primary fw-bold">
                            <td colspan="3" class="text-end">TOTALE <%= group.getEntry() %></td>
                            <td class="text-number"><%= group.getTotalResidualTax() %></td>
                            <td class="text-number"><%= group.getTotalResidualSanctions() %></td>
                            <td class="text-number"><%= group.getTotalResidualInterest() %></td>
                            <td class="text-number"><%= group.getTotalRoleAmount() %></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <% } %>
        <div class="tab-ruoli-group mt-4">
            <div class="tab-ruoli-title">
                <i class="bi bi-calculator-fill"></i>
                <span>TOTALI RUOLI</span>
            </div>
            <div class="tab-ruoli-container">
                <table class="table table-bordered table-sm table-ruoli mb-0" style="width:800px">
                    <thead>
                        <tr>
                            <th>IMPOSTA RESIDUA</th>
                            <th>SANZIONI RESIDUE</th>
                            <th>INTERESSI RESIDUI</th>
                            <th>IMPORTO RUOLO</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="table-primary fw-bold">
                            <td class="text-number"><%= pageData.getTotalResidualTax() %></td>
                            <td class="text-number"><%= pageData.getTotalResidualSanctions() %></td>
                            <td class="text-number"><%= pageData.getTotalResidualInterest() %></td>
                            <td class="text-number"><%= pageData.getTotalRoleAmount() %></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    <% } %>
</div>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const calculatedFields = [
        "impostaRuolo",
        "interessiRuolo",
        "impostaRiscossa",
        "interessiRiscossi"
    ];
    calculatedFields.forEach(function (id) {
        const field = document.getElementById(id);
        if (field) {
            field.addEventListener("input", calculateRuolo);
        }
    });
    calculateRuolo();
});
function getNumber(id) {
    const element = document.getElementById(id);
    if (!element) {
        return 0;
    }
    const value = parseFloat(element.value);
    return Number.isFinite(value) ? value : 0;
}
function setNumber(id, value) {
    const element = document.getElementById(id);
    if (!element) {
        return;
    }
    const safeValue = Number.isFinite(value) ? value : 0;
    element.value = safeValue.toFixed(2);
}
function calculateRuolo() {
    const impostaRuolo = getNumber("impostaRuolo");
    const interessiRuolo = getNumber("interessiRuolo");
    const sanzioniRuolo = impostaRuolo * 0.30;
    const importoRuolo = impostaRuolo + sanzioniRuolo + interessiRuolo;
    const impostaRiscossa = getNumber("impostaRiscossa");
    const interessiRiscossi = getNumber("interessiRiscossi");
    const sanzioniRiscosse = impostaRiscossa * 0.30;
    const importoRiscosso = impostaRiscossa + sanzioniRiscosse + interessiRiscossi;
    const residuoDaRiscuotere = importoRuolo - importoRiscosso;
    const percentualeRiscosso = importoRuolo > 0
            ? (importoRiscosso / importoRuolo) * 100
            : 0;
    setNumber("sanzioniRuolo", sanzioniRuolo);
    setNumber("importoRuolo", importoRuolo);
    setNumber("sanzioniRiscosse", sanzioniRiscosse);
    setNumber("importoRiscosso", importoRiscosso);
    setNumber("residuoDaRiscuotere", residuoDaRiscuotere);
    setNumber("percentualeRiscosso", percentualeRiscosso);
}
</script>
