<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@ page import="is.five.apeaf.controller.InsTabRuoliServlet" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.PageData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.GroupData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.RowData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.TotalsData" %>

<%
request.getSession().setAttribute(SessionVariables.CALLER, "ins-tab-ruoli.jsp");

UserView user = (UserView) request.getSession().getAttribute("ubAP");
if (user == null || !user.getActive()) {
    response.sendRedirect("index.jsp");
    return;
}

String selectedYearId = session.getAttribute(SessionVariables.ANNO) != null
        ? (String) session.getAttribute(SessionVariables.ANNO)
        : "";

TabRuoliPageService service = new TabRuoliPageService();
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
    <i class="bi bi-sliders"></i> INSERIMENTO TABELLA RUOLI
    <span class="badge bg-primary ms-2"><%= pageData.getSelectedYear() %></span>
</h3>

<div class="bg-secondary rounded p-4">
    <div class="d-flex align-items-center justify-content-between mb-3">
        <h5 class="mb-0">
            <i class="bi bi-cash-coin me-2"></i> Nuovo ruolo coattivo
        </h5>

        <button type="submit" form="ruoloForm" class="btn btn-success btn-sm">
            <i class="bi bi-floppy-fill me-1"></i> Salva
        </button>
    </div>

    <%
    String message = (String) session.getAttribute(InsTabRuoliServlet.class.getName());
    if (message != null) {
    %>

    <div class="alert alert-info alert-dismissible fade show" role="alert">
        <%= message %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Chiudi"></button>
    </div>

    <%
        session.removeAttribute(InsTabRuoliServlet.class.getName());
    }
    %>

    <form id="ruoloForm" action="ins-tab-ruoli" method="post">
        <input type="hidden" name="op" value="save" />

        <div class="table-responsive">
            <table class="table table-bordered table-hover table-sm table-ruoli">
                <thead class="text-center">
                    <tr>
                        <th rowspan="2" style="width:100px">Entrata</th>
                        <th rowspan="2">Concessionario</th>
                        <th rowspan="2">Data consegna ruolo</th>
                        <th rowspan="2">Anno ruolo coattivo</th>
                        <th rowspan="2">N. ruolo</th>
                        <th colspan="4" class="table-warning">TOTALI RUOLI COATTIVI</th>
                        <th colspan="4" class="table-secondary">IMPORTI RISCOSSI</th>
                        <th rowspan="2">
                            Residui da riscuotere<br />al 31/12/<%= pageData.getSelectedYear() %>
                        </th>
                        <th rowspan="2">% riscosso</th>
                    </tr>
                    <tr>
                        <th>Imposta</th>
                        <th>Sanzioni</th>
                        <th>Interessi</th>
                        <th>Importo ruolo</th>
                        <th>Imposta</th>
                        <th>Sanzioni</th>
                        <th>Interessi</th>
                        <th>Importo riscosso</th>
                    </tr>
                </thead>

                <tbody>
                    <tr>
                        <td>
                            <select name="entrata"
                                    class="form-select form-select-sm select-entrata"
                                    required>
                                <option value="" selected disabled>Seleziona...</option>
                                <% for (String entryOption : pageData.getEntryOptions()) { %>
                                    <option value="<%= entryOption %>"><%= entryOption %></option>
                                <% } %>
                            </select>
                        </td>

                        <td>
                            <input type="text" name="concessionario"
                                   class="form-control form-control-sm"
                                   placeholder="Concessionario" required />
                        </td>

                        <td>
                            <input type="date" name="dataConsegnaRuolo"
                                   class="form-control form-control-sm"
                                   style="width:145px" />
                        </td>

                        <td>
                            <input type="number" name="annoRuoloCoattivo"
                                   class="form-control form-control-sm text-center"
                                   min="1900" max="2100" step="1" required />
                        </td>

                        <td>
                            <input type="text" name="numeroRuolo"
                                   class="form-control form-control-sm text-center" required />
                        </td>

                        <td>
                            <input type="number" name="impostaRuolo" id="impostaRuolo"
                                   class="form-control form-control-sm text-end"
                                   min="0" step="0.01" value="0.00" />
                        </td>

                        <td>
                            <input type="number" name="sanzioniRuolo" id="sanzioniRuolo"
                                   class="form-control form-control-sm text-end"
                                   step="0.01" value="0.00" readonly />
                        </td>

                        <td>
                            <input type="number" name="interessiRuolo" id="interessiRuolo"
                                   class="form-control form-control-sm text-end"
                                   min="0" step="0.01" value="0.00" />
                        </td>

                        <td>
                            <input type="number" name="importoRuolo" id="importoRuolo"
                                   class="form-control form-control-sm text-end fw-bold"
                                   step="0.01" value="0.00" readonly />
                        </td>

                        <td>
                            <input type="number" name="impostaRiscossa" id="impostaRiscossa"
                                   class="form-control form-control-sm text-end"
                                   min="0" step="0.01" value="0.00" />
                        </td>

                        <td>
                            <input type="number" name="sanzioniRiscosse" id="sanzioniRiscosse"
                                   class="form-control form-control-sm text-end"
                                   step="0.01" value="0.00" readonly />
                        </td>

                        <td>
                            <input type="number" name="interessiRiscossi" id="interessiRiscossi"
                                   class="form-control form-control-sm text-end"
                                   min="0" step="0.01" value="0.00" />
                        </td>

                        <td>
                            <input type="number" name="importoRiscosso" id="importoRiscosso"
                                   class="form-control form-control-sm text-end fw-bold"
                                   step="0.01" value="0.00" readonly />
                        </td>

                        <td>
                            <input type="number" name="residuoDaRiscuotere" id="residuoDaRiscuotere"
                                   class="form-control form-control-sm text-end fw-bold"
                                   step="0.01" value="0.00" readonly />
                        </td>

                        <td>
                            <div class="input-group input-group-sm">
                                <input type="number" name="percentualeRiscosso" id="percentualeRiscosso"
                                       class="form-control text-end fw-bold"
                                       step="0.01" value="0.00" readonly />
                                <span class="input-group-text">%</span>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </form>
</div>

<!-- AREA VISUALIZZAZIONE -->
<div class="rounded p-4 dati-card mt-4">
    <div class="dati-header mb-3">
        <div class="dati-title dati-section-title">
            <i class="bi bi-table"></i>
            <span>RUOLI COATTIVI MEMORIZZATI</span>
        </div>
    </div>

    <% if (!pageData.hasGroups()) { %>

    <div class="alert alert-info mb-0">Nessun ruolo coattivo memorizzato.</div>

    <% } else { %>

        <% for (GroupData group : pageData.getGroups()) {
            TotalsData totals = group.getTotals();
        %>

        <div class="tab-ruoli-group">
            <div class="tab-ruoli-title">
                <i class="bi bi-cash-coin"></i>
                <span>Entrata: <%= group.getEntry() %></span>
            </div>

            <div class="tab-ruoli-container">
                <table class="table table-bordered table-hover table-sm table-ruoli">
                    <thead>
                        <tr>
                            <th rowspan="2" style="width:100px">Entrata</th>
                            <th rowspan="2">Concessionario</th>
                            <th rowspan="2">Data consegna ruolo</th>
                            <th rowspan="2">Anno ruolo coattivo</th>
                            <th rowspan="2">N. ruolo</th>
                            <th colspan="4" class="table-warning">TOTALI RUOLI COATTIVI</th>
                            <th colspan="4" class="table-secondary">RISCOSSO</th>
                            <th rowspan="2">
                                RESIDUI RUOLI DA RISCUOTERE<br />
                                al 31/12/<%= pageData.getSelectedYear() %>
                            </th>
                            <th rowspan="2">% riscosso</th>
                            <th rowspan="2" style="width:70px">AZIONI</th>
                        </tr>
                        <tr>
                            <th>IMPOSTA</th>
                            <th>SANZIONI</th>
                            <th>INTERESSI</th>
                            <th>Importo ruolo</th>
                            <th>IMPOSTA</th>
                            <th>SANZIONI</th>
                            <th>INTERESSI</th>
                            <th>Importo riscosso</th>
                        </tr>
                    </thead>

                    <tbody>
                        <% for (RowData row : group.getRows()) { %>
                        <tr>
                            <td><%= row.getEntry() %></td>
                            <td><%= row.getConcessionaire() %></td>
                            <td class="text-center"><%= row.getDeliveryDate() %></td>
                            <td class="text-center"><%= row.getRoleYear() %></td>
                            <td class="text-center"><%= row.getRoleNumber() %></td>
                            <td class="text-number"><%= row.getRoleTax() %></td>
                            <td class="text-number"><%= row.getRoleSanctions() %></td>
                            <td class="text-number"><%= row.getRoleInterest() %></td>
                            <td class="text-number"><%= row.getRoleAmount() %></td>
                            <td class="text-number"><%= row.getCollectedTax() %></td>
                            <td class="text-number"><%= row.getCollectedSanctions() %></td>
                            <td class="text-number"><%= row.getCollectedInterest() %></td>
                            <td class="text-number"><%= row.getCollectedAmount() %></td>
                            <td class="text-number"><%= row.getResidual() %></td>
                            <td class="text-number">
                                <% if (row.hasPercentage()) { %>
                                    <%= row.getPercentage() %>%
                                <% } else { %>
                                    -
                                <% } %>
                            </td>
                            <td class="text-center">
                                <form action="ins-tab-ruoli" method="post" class="d-inline"
                                      onsubmit="return confirm('Eliminare questo ruolo?\nSarà possibile reinserirlo successivamente.');">
                                    <input type="hidden" name="op" value="DELETE" />
                                    <input type="hidden" name="id" value="<%= row.getId() %>" />
                                    <button type="submit" class="btn btn-sm btn-danger" title="Elimina">
                                        <i class="bi bi-trash-fill"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <% } %>

                        <tr class="totals-row">
                            <td colspan="4"></td>
                            <td>TOTALI RUOLI</td>
                            <td class="text-number"><%= totals.getRoleTax() %></td>
                            <td class="text-number"><%= totals.getRoleSanctions() %></td>
                            <td class="text-number"><%= totals.getRoleInterest() %></td>
                            <td class="text-number"><%= totals.getRoleAmount() %></td>
                            <td class="text-number"><%= totals.getCollectedTax() %></td>
                            <td class="text-number"><%= totals.getCollectedSanctions() %></td>
                            <td class="text-number"><%= totals.getCollectedInterest() %></td>
                            <td class="text-number"><%= totals.getCollectedAmount() %></td>
                            <td class="text-number"><%= totals.getResidual() %></td>
                            <td class="text-number">
                                <% if (totals.hasAveragePercentage()) { %>
                                    <%= totals.getAveragePercentage() %>% <small>(media)</small>
                                <% } else { %>
                                    -
                                <% } %>
                            </td>
                            <td></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <% } %>

        <% TotalsData overallTotals = pageData.getOverallTotals(); %>

        <div class="tab-ruoli-group overall-totals-group">
            <div class="tab-ruoli-title">
                <i class="bi bi-calculator-fill"></i>
                <span>TOTALI GENERALI</span>
            </div>

            <div class="tab-ruoli-container">
                <table class="table table-bordered table-sm table-ruoli">
                    <thead>
                        <tr>
                            <th colspan="5">TOTALI COMPLESSIVI</th>
                            <th colspan="4" class="table-warning">TOTALI RUOLI COATTIVI</th>
                            <th colspan="4" class="table-secondary">IMPORTI RISCOSSI</th>
                            <th rowspan="2">RESIDUI RUOLI<br />DA RISCUOTERE</th>
                            <th rowspan="2">MEDIA % RISCOSSO</th>
                        </tr>
                        <tr>
                            <th colspan="5">TUTTE LE ENTRATE</th>
                            <th>IMPOSTA</th>
                            <th>SANZIONI</th>
                            <th>INTERESSI</th>
                            <th>IMPORTO RUOLO</th>
                            <th>IMPOSTA</th>
                            <th>SANZIONI</th>
                            <th>INTERESSI</th>
                            <th>IMPORTO RISCOSSO</th>
                        </tr>
                    </thead>

                    <tbody>
                        <tr class="totals-row overall-totals-row">
                            <td colspan="5" class="text-end">TOTALI GENERALI</td>
                            <td class="text-number"><%= overallTotals.getRoleTax() %></td>
                            <td class="text-number"><%= overallTotals.getRoleSanctions() %></td>
                            <td class="text-number"><%= overallTotals.getRoleInterest() %></td>
                            <td class="text-number"><%= overallTotals.getRoleAmount() %></td>
                            <td class="text-number"><%= overallTotals.getCollectedTax() %></td>
                            <td class="text-number"><%= overallTotals.getCollectedSanctions() %></td>
                            <td class="text-number"><%= overallTotals.getCollectedInterest() %></td>
                            <td class="text-number"><%= overallTotals.getCollectedAmount() %></td>
                            <td class="text-number"><%= overallTotals.getResidual() %></td>
                            <td class="text-number">
                                <% if (overallTotals.hasAveragePercentage()) { %>
                                    <%= overallTotals.getAveragePercentage() %>% <small>(media)</small>
                                <% } else { %>
                                    -
                                <% } %>
                            </td>
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
