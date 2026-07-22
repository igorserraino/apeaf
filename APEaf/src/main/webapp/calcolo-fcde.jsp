<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@page import="is.five.apeaf.utils.Utils"%>

<%@ page import="is.five.apeaf.dao.TabParDAO" %>
<%@ page import="is.five.apeaf.dao.model.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>
<%@ page import="is.five.apeaf.dao.*"%>
<%@ page import="is.five.apeaf.dao.model.*"%>
<%@ page import="is.five.apeaf.utils.*" %>

<%@ page import="is.five.apeaf.controller.InsTabRuoliServlet" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.PageData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.GroupData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.RowData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.TotalsData" %>

<%
request.getSession().setAttribute(SessionVariables.CALLER, "calcolo-fcde.jsp");
UserView user = (UserView) request.getSession().getAttribute("ubAP");
if (user == null || !user.getActive()) {
	response.sendRedirect("index.jsp");
	return;
}

AnnoFinanziarioDAO anniDAO = new AnnoFinanziarioDAO();
String id_anno_selezionato = session.getAttribute(SessionVariables.ANNO) != null
		? (String) session.getAttribute(SessionVariables.ANNO)
		: "";
String anno_selezionato = "";

try {
	if (id_anno_selezionato.length() > 0) {
		anno_selezionato = String
				.valueOf(anniDAO.findByID(Integer.parseInt(id_anno_selezionato)).getAnno());
	}
} catch (Exception exc) {
}

if (anno_selezionato == null ||
		anno_selezionato.trim().isEmpty()) {
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


int anno;

try {
    anno = Integer.parseInt(
		anno_selezionato.trim()
    );

} catch (NumberFormatException e) {
%>

<div class="alert alert-danger">
    Anno finanziario non valido:
    <strong><%= anno_selezionato %></strong>
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

String[] valuesRES = { "0", "0", "0", "0", "0" };
String[] valuesFCDE = { "0", "0", "0", "0", "0" };


	InsResiduiAttivi residuiAttivi = InsResiduiAttiviDAO.findByUserAndAnno(user.getId(), anno);

	if (residuiAttivi != null && residuiAttivi.getValue() != null && !residuiAttivi.getValue().trim().isEmpty()) {

		String[] saved = residuiAttivi.getValue().split(";", -1);

		for (int i = 0; i < saved.length && i < valuesRES.length; i++) {

				if (saved[i] != null && !saved[i].trim().isEmpty()) {

					valuesRES[i] = saved[i].trim();
				}
		}
	}

	 InsDatiFCDE datiFCDE =
			 InsDatiFCDEDAO.findByUserAndAnno(
                    user.getId(),
                    Integer.parseInt(anno_selezionato)
            );


    if (datiFCDE != null &&
			datiFCDE.getValue() != null &&
        !datiFCDE.getValue().trim().isEmpty()) {

        String[] saved =
			datiFCDE
                        .getValue()
                        .split(";", -1);

        for (
                int i = 0;
                i < saved.length && i < valuesFCDE.length;
                i++
        ) {

            if (saved[i] != null &&
                !saved[i].trim().isEmpty()) {

		valuesFCDE[i] = saved[i].trim();
            }
        }
    }


    String csvResiduiAttivi =
            residuiAttivi != null &&
            residuiAttivi.getValue() != null
                    ? residuiAttivi.getValue()
                    : "";

    String csvDatiFCDE =
            datiFCDE != null &&
            datiFCDE.getValue() != null
                    ? datiFCDE.getValue()
                    : "";

    BigDecimal totaleResiduiAttivi =
            BigDecimal.ZERO;

    BigDecimal totaleFCDE =
            BigDecimal.ZERO;

    for (int index = 0; index < 5; index++) {

        totaleResiduiAttivi =
                totaleResiduiAttivi.add(
                    CSVUtils.getDecimalValue(
                        csvResiduiAttivi,
                        index
                    )
                );

        totaleFCDE =
                totaleFCDE.add(
                    CSVUtils.getDecimalValue(
                        csvDatiFCDE,
                        index
                    )
                );
    }

    BigDecimal percentualeTotaleAccantonamento =
            totaleResiduiAttivi.compareTo(BigDecimal.ZERO) != 0
                    ? totaleFCDE
                        .multiply(BigDecimal.valueOf(100))
                        .divide(
                            totaleResiduiAttivi,
                            10,
                            RoundingMode.HALF_UP
                        )
                    : BigDecimal.ZERO;
%>


<h3 class="mb-4">
    <i class="bi bi-calculator"></i> CALCOLO % ACCANTONAMENTO FCDE
    <span class="badge bg-primary ms-2"><%= anno_selezionato %></span>

</h3>

<div class="rounded p-4 dati-card valutazione-ruoli-card mt-4">
    <div class="dati-header mb-3">
        <div class="dati-title dati-section-title">
            <i class="bi bi-table"></i>
            <span>DATI COMPUTATI DA INS. RESIDUI ATTIVI E INS. DATI FCDE</span>
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
                    <th scope="col">RESIDUI ATTIVI</th>
                    <th scope="col">FCDE</th>
                    <th scope="col">% ACCANTONAMENTO</th>
                </tr>
            </thead>

            <tbody>

                <tr>
                    <th class="description-cell" scope="row">
                        Accertamenti ICI
                    </th>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(residuiAttivi.getValue(), 0).doubleValue()) %>
                    </td>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(datiFCDE.getValue(), 0).doubleValue()) %>
                    </td>



                    <td class="percentage-cell">
                        <%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 0).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 0).doubleValue()

                        ) %>
                    </td>
                </tr>

				<tr>
                    <th class="description-cell" scope="row">
                        Accertamenti TASI
                    </th>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(residuiAttivi.getValue(), 1).doubleValue()) %>
                    </td>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(datiFCDE.getValue(), 1).doubleValue()) %>
                    </td>



                    <td class="percentage-cell">
                        <%= formatoItaliano3Decimali.format(
			100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 1).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 1).doubleValue()

                        ) %>
                    </td>
                </tr>

				<tr>
                    <th class="description-cell" scope="row">
                        Accertamenti IMU
                    </th>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(residuiAttivi.getValue(), 2).doubleValue()) %>
                    </td>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(datiFCDE.getValue(), 2).doubleValue()) %>
                    </td>



                    <td class="percentage-cell">
                        <%= formatoItaliano3Decimali.format(
			100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 2).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 2).doubleValue()

                        ) %>
                    </td>
                </tr>

				<tr>
                    <th class="description-cell" scope="row">
                        Tassa Rifiuti
                    </th>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(residuiAttivi.getValue(), 3).doubleValue()) %>
                    </td>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(datiFCDE.getValue(), 3).doubleValue()) %>
                    </td>



                    <td class="percentage-cell">
                        <%= formatoItaliano3Decimali.format(
			100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 3).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 3).doubleValue()

                        ) %>
                    </td>
                </tr>

				<tr>
                    <th class="description-cell" scope="row">
                        CDS
                    </th>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(residuiAttivi.getValue(), 4).doubleValue()) %>
                    </td>

                    <td class="number-cell">
                        <%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(datiFCDE.getValue(), 4).doubleValue()) %>
                    </td>



                    <td class="percentage-cell">
                        <%= formatoItaliano3Decimali.format(
			100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 4).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 4).doubleValue()

                        ) %>
                    </td>
                </tr>
                
                <tr><td></td></tr>

                <tr class="totals-row">
                    <th class="total-label" scope="row">
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

 
                </tr>

            </tbody>
        </table>
    </div>
</div>
