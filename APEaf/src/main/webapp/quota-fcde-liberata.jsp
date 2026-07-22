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
<%@ page import="is.five.apeaf.utils.*" %>

<%@ page import="is.five.apeaf.controller.InsTabRuoliServlet" %> 

<%@ page import="is.five.apeaf.service.ImportiDefinibiliService" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.PageData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.GroupData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.RowData" %>
 

<%
request.getSession().setAttribute(SessionVariables.CALLER, "quota-fcde-liberata.jsp");
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
DecimalFormat formatoItaliano3Decimali = new DecimalFormat("#,##0.000", DecimalFormatSymbols.getInstance(Locale.ITALY));
formatoItaliano3Decimali.setRoundingMode(RoundingMode.HALF_UP);
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



InsDatiFCDE datiFCDE =
		 InsDatiFCDEDAO.findByUserAndAnno(
               user.getId(),
               Integer.parseInt(anno_selezionato)
       );
InsResiduiAttivi residuiAttivi = InsResiduiAttiviDAO.findByUserAndAnno(user.getId(), anno);

List<TabPar> valoriSanzione = new ArrayList<>(
	    TabParDAO.findByUserAndType(
	        user.getId(),
	        TabPar.TYPE_SANZIONE
	    )
	);

	List<TabPar> valoriInteressi = new ArrayList<>(
	    TabParDAO.findByUserAndType(
	        user.getId(),
	        TabPar.TYPE_INTERESSI
	    )
	);

	Comparator<TabPar> ordinamentoNumericoAscendente =
	    Comparator.comparing(
	        TabPar::getValue,
	        Comparator.nullsLast(Comparator.naturalOrder())
	    );

	valoriSanzione.sort(ordinamentoNumericoAscendente);
	valoriInteressi.sort(ordinamentoNumericoAscendente);
	
	

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

	ImportiDefinibiliService service = new ImportiDefinibiliService();
	PageData pageData = service.load(user, id_anno_selezionato);
	
    int i = 0;
    double sanzioniICI1=0, sanzioniICI2=0, sanzioniICI3=0;
    double interessiICI1=0, interessiICI2=0, interessiICI3=0;
    double sanzioniTASI1=0, sanzioniTASI2=0, sanzioniTASI3=0;
    double interessiTASI1=0, interessiTASI2=0, interessiTASI3=0;
    double sanzioniIMU1=0, sanzioniIMU2=0, sanzioniIMU3=0;
    double interessiIMU1=0, interessiIMU2=0, interessiIMU3=0;
    
	for (GroupData group : pageData.getGroups()) { 
		switch (i) {
			case (0): {
				sanzioniICI1 = group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(0).getValue().doubleValue()/100;
				interessiICI1 = group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(0).getValue().doubleValue()/100;
				sanzioniICI2 = group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(1).getValue().doubleValue()/100;
				interessiICI2 = group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(1).getValue().doubleValue()/100;
				sanzioniICI3 = group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(2).getValue().doubleValue()/100;
				interessiICI3 = group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(2).getValue().doubleValue()/100;
				i=i+1;
				break;
			}
			case (1): {
				sanzioniTASI1 = group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(0).getValue().doubleValue()/100;
				interessiTASI1 = group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(0).getValue().doubleValue()/100;
				sanzioniTASI2 = group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(1).getValue().doubleValue()/100;
				interessiTASI2 = group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(1).getValue().doubleValue()/100;
				sanzioniTASI3 = group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(2).getValue().doubleValue()/100;
				interessiTASI3 = group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(2).getValue().doubleValue()/100;
				i=i+1;
				break;
			}
			case (2): {
				sanzioniIMU1 = group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(0).getValue().doubleValue()/100;
				interessiIMU1 = group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(0).getValue().doubleValue()/100;
				sanzioniIMU2 = group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(1).getValue().doubleValue()/100;
				interessiIMU2 = group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(1).getValue().doubleValue()/100;
				sanzioniIMU3 = group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(2).getValue().doubleValue()/100;
				interessiIMU3 = group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(2).getValue().doubleValue()/100;
				i=i+1;
				break;
			}
		}
    }
%>

<h3 class="mb-4">
    <i class="bi bi-calculator"></i> QUOTA FCDE LIBERATA
    <span class="badge bg-primary ms-2"><%= anno_selezionato %></span>
</h3>

<div class="rounded p-4 dati-card quota-fcde-card mt-4">
    <div class="dati-header mb-3">
        <div class="dati-title dati-section-title">
            <i class="bi bi-table"></i>
            <span>DATI COMPUTATI DA CALCOLO FCDE E IPOTESI TAGLI</span>
        </div>
    </div>

    <div class="table-responsive">
        <table class="quota-fcde-table" aria-label="Calcolo della quota FCDE liberata" style="max-width: 1500px">
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
                    <th class="section-header" colspan="3" scope="colgroup">SANZIONI + INTERESSI</th>
                    <th class="spacer-cell"></th>
                    <th class="section-header" colspan="3" scope="colgroup">QUOTA FCDE LIBERATA</th>
                </tr>

                <tr>
                    <th class="percentage-header" scope="col">ENTRATA</th>
                    <th class="percentage-header" scope="col">Quota FCDE  <br />accantonata <br />a consuntivo</th>
                    <th class="percentage-header" scope="col">% FCDE</th>
                    <td class="spacer-cell"></td>
                    <th class="percentage-header" scope="col"><%= formatoItaliano3Decimali.format(valoriSanzione.get(0).getValue()) %></th>
                    <th class="percentage-header" scope="col"><%= formatoItaliano3Decimali.format(valoriSanzione.get(1).getValue()) %></th>
                    <th class="percentage-header" scope="col"><%= formatoItaliano3Decimali.format(valoriSanzione.get(2).getValue()) %></th>
                    <th class="spacer-cell"></th>
                    <th class="percentage-header" scope="col"><%= formatoItaliano3Decimali.format(valoriInteressi.get(0).getValue()) %></th>
                    <th class="percentage-header" scope="col"><%= formatoItaliano3Decimali.format(valoriInteressi.get(1).getValue()) %></th>
                    <th class="percentage-header" scope="col"><%= formatoItaliano3Decimali.format(valoriInteressi.get(2).getValue()) %></th>
                </tr>
            </thead>

            <tbody>
                <tr class="separator-row" aria-hidden="true">
                    <td colspan="11"></td>
                </tr>
 

                <tr>
                    <td class="description-cell">ACCERTAMENTI ICI</td>
                    <td class="description-cell text-end"><%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(datiFCDE.getValue(), 0).doubleValue()) %></td>
                    <td class="description-cell text-end"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 0).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 0).doubleValue()) %></td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 0).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 0).doubleValue() * (CSVUtils.getDecimalValue(residuiAttivi.getValue(), 0).doubleValue() - sanzioniICI1 - interessiICI1) / 100) %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 0).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 0).doubleValue() * (CSVUtils.getDecimalValue(residuiAttivi.getValue(), 0).doubleValue() - sanzioniICI2 - interessiICI2) / 100) %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 0).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 0).doubleValue() * (CSVUtils.getDecimalValue(residuiAttivi.getValue(), 0).doubleValue() - sanzioniICI3 - interessiICI3) / 100) %></td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                </tr>
                
                 <tr>
                    <td class="description-cell">ACCERTAMENTI TASI</td>
                    <td class="description-cell text-end"><%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(datiFCDE.getValue(), 1).doubleValue()) %></td>
                    <td class="description-cell text-end"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 1).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 1).doubleValue())%></td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 1).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 1).doubleValue() * (CSVUtils.getDecimalValue(residuiAttivi.getValue(), 1).doubleValue() - sanzioniTASI1 - interessiTASI1) / 100) %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 1).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 1).doubleValue() * (CSVUtils.getDecimalValue(residuiAttivi.getValue(), 1).doubleValue() - sanzioniTASI2 - interessiTASI2) / 100) %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 1).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 1).doubleValue() * (CSVUtils.getDecimalValue(residuiAttivi.getValue(), 1).doubleValue() - sanzioniTASI3 - interessiTASI3) / 100) %></td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                </tr>
                
                 <tr>
                    <td class="description-cell">ACCERTAMENTI IMU</td>
                    <td class="description-cell text-end"><%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(datiFCDE.getValue(), 2).doubleValue()) %></td>
                    <td class="description-cell text-end"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 2).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 2).doubleValue())%></td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 2).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 2).doubleValue() * (CSVUtils.getDecimalValue(residuiAttivi.getValue(), 2).doubleValue() - sanzioniIMU1 - interessiIMU1) / 100) %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 2).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 2).doubleValue() * (CSVUtils.getDecimalValue(residuiAttivi.getValue(), 2).doubleValue() - sanzioniIMU2 - interessiIMU2) / 100) %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 2).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 2).doubleValue() * (CSVUtils.getDecimalValue(residuiAttivi.getValue(), 2).doubleValue() - sanzioniIMU3 - interessiIMU3) / 100) %></td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                </tr>
                
                 <tr>
                    <td class="description-cell">Tassa Rifiuti</td>
                    <td class="description-cell text-end"><%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(datiFCDE.getValue(), 3).doubleValue()) %></td>
                    <td class="description-cell text-end"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 3).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 3).doubleValue())%></td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                </tr>
                
                 <tr>
                    <td class="description-cell">CDS</td>
                    <td class="description-cell text-end"><%= formatoItaliano3Decimali.format(CSVUtils.getDecimalValue(datiFCDE.getValue(), 4).doubleValue()) %></td>
                    <td class="description-cell text-end"><%= formatoItaliano3Decimali.format(100*CSVUtils.getDecimalValue(datiFCDE.getValue(), 4).doubleValue()/CSVUtils.getDecimalValue(residuiAttivi.getValue(), 4).doubleValue())%></td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                    <td class="amount-cell"> </td>
                </tr>
                
              
            </tbody>
        </table>
    </div>
</div>
