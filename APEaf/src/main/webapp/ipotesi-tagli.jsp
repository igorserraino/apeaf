<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.PageData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.GroupData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.RowData" %>
<%@ page import="is.five.apeaf.dao.TabParDAO" %>
<%@ page import="is.five.apeaf.dao.model.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>

<%
request.getSession().setAttribute(SessionVariables.CALLER, "ipotesi-tagli.jsp");
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

    DecimalFormat formatoItaliano3Decimali = new DecimalFormat(
        "#,##0.000",
        DecimalFormatSymbols.getInstance(Locale.ITALY)
    );

%>

<h3 class="mb-4">
    <i class="bi bi-calculator"></i> IPOTESI TAGLI
    <span class="badge bg-primary ms-2"><%= pageData.getSelectedYear() %></span>
</h3>

<div class="rounded p-4 dati-card ipotesi-tagli-card mt-4">
    <div class="dati-header mb-3">
        <div class="dati-title dati-section-title">
            <i class="bi bi-table"></i>
            <span>DATI COMPUTATI DA IMPORTI DEFINIBILI</span>
        </div>
    </div>

    <div class="table-responsive">
        <table class="ipotesi-tagli-table" aria-label="Ipotesi di taglio su sanzioni e interessi" style="max-width: 1200px">
            <colgroup>
                <col class="col-tipologia" />
                <col class="col-entrata" />
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
                    <th class="empty-header" colspan="2"></th>
                    <th class="section-header" colspan="3" scope="colgroup">SANZIONI</th>
                    <th class="spacer-cell"></th>
                    <th class="section-header" colspan="3" scope="colgroup">INTERESSI</th>
                </tr>
                <tr>
                    <th class="empty-header" colspan="2"></th>
                    <th class="hypothesis-header" scope="col">% taglio (1^ ipotesi)</th>
                    <th class="hypothesis-header" scope="col">% taglio (2^ ipotesi)</th>
                    <th class="hypothesis-header" scope="col">% taglio (3^ ipotesi)</th>
                    <th class="spacer-cell"></th>
                    <th class="hypothesis-header" scope="col">% taglio (1^ ipotesi)</th>
                    <th class="hypothesis-header" scope="col">% taglio (2^ ipotesi)</th>
                    <th class="hypothesis-header" scope="col">% taglio (3^ ipotesi)</th>
                </tr>
                <tr>
                    <th class="percentage-header" scope="col">TIPOLOGIA</th>
                    <th class="percentage-header" scope="col" aria-label="Entrata"></th>
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
                    <td colspan="9"></td>
                </tr>
                
                
                <%
                
                Double totTagliSanzioni1 = 0d;
                Double totTagliSanzioni2 = 0d;
                Double totTagliSanzioni3 = 0d;
                
                Double totTagliInteressi1 = 0d;
                Double totTagliInteressi2 = 0d;
                Double totTagliInteressi3 = 0d;
                
                 for (GroupData group : pageData.getGroups()) { 


                %>

                <tr>
                    <td class="description-cell">MINORI RESIDUI ATTIVI</td>
                    <td class="description-cell text-end"><%= group.getEntry() %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(0).getValue().doubleValue()/100) %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(1).getValue().doubleValue()/100) %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(2).getValue().doubleValue()/100) %></td>
                    <td class="spacer-cell"></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(0).getValue().doubleValue()/100) %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(1).getValue().doubleValue()/100) %></td>
                    <td class="amount-cell"><%= formatoItaliano3Decimali.format(group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(2).getValue().doubleValue()/100) %></td>
                </tr>
                
                <%  
                
                totTagliSanzioni1+=group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(0).getValue().doubleValue()/100;
                totTagliSanzioni2+=group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(1).getValue().doubleValue()/100;
                totTagliSanzioni3+=group.getTotalResidualSanctionsBD().doubleValue()*valoriSanzione.get(2).getValue().doubleValue()/100;
                
                totTagliInteressi1+=group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(0).getValue().doubleValue()/100;
                totTagliInteressi2+=group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(1).getValue().doubleValue()/100;
                totTagliInteressi3+=group.getTotalResidualInterestBD().doubleValue()*valoriInteressi.get(2).getValue().doubleValue()/100;

                		
                }%>

                <tr>
                    <th class="total-label" scope="row">TOTALI TAGLI RESIDUI</th>
                    <td class="total-label"></td>
                    <td class="total-value"><%= formatoItaliano3Decimali.format(totTagliSanzioni1) %></td>
                    <td class="total-value"><%= formatoItaliano3Decimali.format(totTagliSanzioni2) %></td>
                    <td class="total-value"><%= formatoItaliano3Decimali.format(totTagliSanzioni3) %></td>
                    <td class="spacer-cell"></td>
                    <td class="total-value"><%= formatoItaliano3Decimali.format(totTagliInteressi1) %></td>
                    <td class="total-value"><%= formatoItaliano3Decimali.format(totTagliInteressi2) %></td>
                    <td class="total-value"><%= formatoItaliano3Decimali.format(totTagliInteressi3) %></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>
