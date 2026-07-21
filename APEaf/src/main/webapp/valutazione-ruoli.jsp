<%@page import="is.five.apeaf.utils.Utils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>

<%@ page import="is.five.apeaf.dao.TabParDAO" %>
<%@ page import="is.five.apeaf.dao.model.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>
<%@ page import="is.five.apeaf.dao.*"%>
<%@ page import="is.five.apeaf.dao.model.*"%>
<%@ page import="is.five.apeaf.controller.InsTabRuoliServlet" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.PageData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.GroupData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.RowData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.TotalsData" %>

<%
request.getSession().setAttribute(SessionVariables.CALLER, "valutazione-ruoli.jsp");
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
<div
	class="alert alert-warning d-flex align-items-center shadow-sm mb-4"
	role="alert">
	<i class="bi bi-arrow-up-right-circle-fill fs-2 me-3"></i>
	<div>
		<strong>Anno finanziario non selezionato.</strong><br /> Seleziona
		l'anno finanziario dal menu in alto a destra.
	</div>
</div>
<%
return;
}

List<TabPar> valoriSanzione = new ArrayList<>(TabParDAO.findByUserAndType(user.getId(), TabPar.TYPE_SANZIONE));

List<TabPar> valoriInteressi = new ArrayList<>(TabParDAO.findByUserAndType(user.getId(), TabPar.TYPE_INTERESSI));

while (valoriSanzione.size() < 3) {
	TabPar parametro = new TabPar();
	parametro.setValue(BigDecimal.ZERO);
	parametro.setType(TabPar.TYPE_SANZIONE);

	valoriSanzione.add(parametro);
}

while (valoriInteressi.size() < 3) {
	TabPar parametro = new TabPar();
	parametro.setValue(BigDecimal.ZERO);
	parametro.setType(TabPar.TYPE_INTERESSI);

	valoriInteressi.add(parametro);
}

DecimalFormat formatoItaliano3Decimali = new DecimalFormat("#,##0.000", DecimalFormatSymbols.getInstance(Locale.ITALY));
formatoItaliano3Decimali.setRoundingMode(RoundingMode.HALF_UP);

String[] values = { "0", "0", "0", "0", "0" };

	InsResiduiAttivi residuiAttivi = InsResiduiAttiviDAO.findByUserAndAnno(user.getId(), Integer.parseInt(pageData.getSelectedYear()));

	if (residuiAttivi != null && residuiAttivi.getValue() != null && !residuiAttivi.getValue().trim().isEmpty()) {

		String[] saved = residuiAttivi.getValue().split(";", -1);

		for (int i = 0; i < saved.length && i < values.length; i++) {

				if (saved[i] != null && !saved[i].trim().isEmpty()) {

					values[i] = saved[i].trim();
				}
		}
	}

%>


<h3 class="mb-4">
    <i class="bi bi-calculator"></i> CONFRONTO RUOLI E ACCERTAMENTI
    <span class="badge bg-primary ms-2"><%= pageData.getSelectedYear() %></span>

</h3>

<div class="rounded p-4 dati-card valutazione-ruoli-card mt-4">
    <div class="dati-header mb-3">
        <div class="dati-title dati-section-title">
            <i class="bi bi-table"></i>
            <span>DATI COMPUTATI DA RESIDUI ATTIVI E TAB RUOLI</span>
        </div>
    </div>

    <div class="table-responsive">
        <table class="valutazione-ruoli-table"
               aria-label="Confronto tra importi residui a bilancio e totale ruoli" style="max-width: 1200px">
            <colgroup>
                <col class="col-tipologia" />
                <col class="col-valore" />
                <col class="col-valore" />
                <col class="col-valore" />
                <col class="col-valore" />
            </colgroup>

            <thead>
                <tr>
                    <th scope="col">TIPOLOGIA ENTRATA</th>
                    <th scope="col">IMPORTI RESIDUI A<br />BILANCIO</th>
                    <th scope="col">TOTALE RUOLI</th>
                    <th scope="col">DIFFERENZA</th>
                    <th scope="col">% RUOLI SU<br />ACCERTAMENTI</th>
                </tr>
            </thead>

            <tbody>
                <%
                int i = 0;

                BigDecimal totaleResiduiBilancio = BigDecimal.ZERO;
                BigDecimal totaleRuoli = BigDecimal.ZERO;

                for (GroupData group : pageData.getGroups()) {

                    TotalsData totals = group.getTotals();

                    BigDecimal residuoBilancio =
                            i < values.length
                                    ? Utils.parseItalianNumber(values[i])
                                    : BigDecimal.ZERO;

                    BigDecimal totaleRuolo =
                            Utils.parseItalianNumber(
                                    totals.getResidual()
                            );

                    BigDecimal differenza =
                            residuoBilancio.subtract(
                                    totaleRuolo
                            );

                    BigDecimal percentualeRuoli =
                            residuoBilancio.compareTo(BigDecimal.ZERO) != 0
                                    ? totaleRuolo
                                            .multiply(BigDecimal.valueOf(100))
                                            .divide(
                                                residuoBilancio,
                                                10,
                                                RoundingMode.HALF_UP
                                            )
                                    : BigDecimal.ZERO;

                    totaleResiduiBilancio =
                            totaleResiduiBilancio.add(
                                    residuoBilancio
                            );

                    totaleRuoli =
                            totaleRuoli.add(
                                    totaleRuolo
                            );

                    i++;
                %>

                <tr>
                    <th class="description-cell" scope="row">
                        <%= group.getEntry() %>
                    </th>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(residuoBilancio) %>
                    </td>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(totaleRuolo) %>
                    </td>

                    <td class="difference-cell">
                        <span class="difference-content">
                            <span>
                                <%= differenza.signum() < 0
                                        ? "-"
                                        : differenza.signum() > 0
                                            ? "+"
                                            : "" %>
                            </span>
                            <span>
                                <%= formatoItaliano3Decimali.format(
                                        differenza.abs()
                                ) %>
                            </span>
                        </span>
                    </td>

                    <td class="percentage-cell">
                        <%= formatoItaliano3Decimali.format(
                                percentualeRuoli
                        ) %>
                    </td>
                </tr>

                <% } %>

                <%
                BigDecimal differenzaTotale =
                        totaleResiduiBilancio.subtract(
                                totaleRuoli
                        );

                BigDecimal percentualeTotale =
                        totaleResiduiBilancio.compareTo(BigDecimal.ZERO) != 0
                                ? totaleRuoli
                                    .multiply(BigDecimal.valueOf(100))
                                    .divide(
                                        totaleResiduiBilancio,
                                        10,
                                        RoundingMode.HALF_UP
                                    )
                                : BigDecimal.ZERO;
                %>

                <tr>
                    <th class="total-label" scope="row">
                        TOTALE
                    </th>

                    <td class="total-number">
                        <%= formatoItaliano3Decimali.format(
                                totaleResiduiBilancio
                        ) %>
                    </td>

                    <td class="total-number">
                        <%= formatoItaliano3Decimali.format(
                                totaleRuoli
                        ) %>
                    </td>

                    <td class="total-difference">
                        <span class="difference-content">
                            <span>
                                <%= differenzaTotale.signum() < 0
                                        ? "-"
                                        : differenzaTotale.signum() > 0
                                            ? "+"
                                            : "" %>
                            </span>
                            <span>
                                <%= formatoItaliano3Decimali.format(
                                        differenzaTotale.abs()
                                ) %>
                            </span>
                        </span>
                    </td>

                    <td class="total-number">
                        <%= formatoItaliano3Decimali.format(
                                percentualeTotale
                        ) %>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>
