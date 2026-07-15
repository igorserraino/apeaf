<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="is.five.apeaf.utils.*"%>
<%@ page import="is.five.apeaf.utils.SessionVariables"%>

<%@ page import="is.five.apeaf.dao.model.UserView"%>
<%@ page import="is.five.apeaf.dao.model.TabPar"%>
<%@ page import="is.five.apeaf.dao.model.InsTabRuoli"%>
<%@ page import="is.five.apeaf.dao.model.Entrata"%>

<%@ page import="is.five.apeaf.dao.*"%>

<%@ page import="is.five.apeaf.controller.InsTabRuoliServlet"%>

<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.TreeMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Comparator"%>
<%@ page import="java.util.Locale"%>

<%@ page import="java.math.BigDecimal"%>
<%@ page import="java.math.RoundingMode"%>

<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.DecimalFormatSymbols"%>




<%

request.getSession().setAttribute(SessionVariables.CALLER, "importi-definibili.jsp");

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

%>

<%

if (anno_selezionato == null || anno_selezionato.trim().isEmpty()) {

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

<%!


    private String csvValue(String[] values, int index) {

        if (values == null || index < 0 || index >= values.length) {
            return "";
        }

        return values[index] == null
                ? ""
                : values[index].trim();
    }


    private BigDecimal csvDecimal(String[] values, int index) {

        String value = csvValue(values, index);

        if (value.isEmpty()) {
            return BigDecimal.ZERO;
        }

        try {
            value = value
                    .replace("€", "")
                    .replace("%", "")
                    .replace("\u00A0", "")
                    .replace(" ", "");

            /*
             * Gestisce:
             *
             * 6044.00
             * 6044,00
             * 6.044,00
             */
            if (value.contains(",") && value.contains(".")) {

                value = value
                        .replace(".", "")
                        .replace(",", ".");

            } else if (value.contains(",")) {

                value = value.replace(",", ".");
            }

            return new BigDecimal(value);

        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }


    private int csvInteger(String[] values, int index) {

        String value = csvValue(values, index);

        if (value.isEmpty()) {
            return Integer.MAX_VALUE;
        }

        try {
            return Integer.parseInt(value);

        } catch (NumberFormatException e) {
            return Integer.MAX_VALUE;
        }
    }
%>


<%


    List<TabPar> valoriSanzione =
            TabParDAO.findByUserAndType(
                    user.getId(),
                    TabPar.TYPE_SANZIONE 
            );

    List<TabPar> valoriInteressi =
            TabParDAO.findByUserAndType(
                    user.getId(),
                    TabPar.TYPE_INTERESSI
            );
 
    final int IDX_ENTRATA = 0;
    final int IDX_CONCESSIONARIO = 1;
    final int IDX_DATA_CONSEGNA = 2;
    final int IDX_ANNO_RUOLO = 3;
    final int IDX_NUMERO_RUOLO = 4;

    final int IDX_IMPOSTA_RUOLO = 5;
    final int IDX_SANZIONI_RUOLO = 6;
    final int IDX_INTERESSI_RUOLO = 7;
    final int IDX_IMPORTO_RUOLO = 8;

    final int IDX_IMPOSTA_RISCOSSA = 9;
    final int IDX_SANZIONI_RISCOSSE = 10;
    final int IDX_INTERESSI_RISCOSSI = 11;
    final int IDX_IMPORTO_RISCOSSO = 12;

    final int IDX_RESIDUI = 13;
    final int IDX_PERCENTUALE_RISCOSSO = 14;


    DecimalFormatSymbols formatSymbols =
            DecimalFormatSymbols.getInstance(Locale.ITALY);

    DecimalFormat moneyFormat =
            new DecimalFormat("#,##0.00", formatSymbols);

    DecimalFormat percentFormat =
            new DecimalFormat("#,##0.00", formatSymbols);


    List<InsTabRuoli> ruoli =
            InsTabRuoliDAO.findByUserAndAnno(user.getId(), Integer.parseInt(anno_selezionato));


    Map<String, List<InsTabRuoli>> gruppiEntrata =
            new TreeMap<String, List<InsTabRuoli>>(
                    String.CASE_INSENSITIVE_ORDER
            );


    if (ruoli != null) {

        for (InsTabRuoli ruolo : ruoli) {

            String csv = ruolo.getValues() == null
                    ? ""
                    : ruolo.getValues();

            String[] values = csv.split(";", -1);

            String entrata = csvValue(
                    values,
                    IDX_ENTRATA
            );

            if (entrata.isEmpty()) {
                entrata = "ENTRATA NON DEFINITA";
            }

            gruppiEntrata
                    .computeIfAbsent(
                            entrata,
                            key -> new ArrayList<InsTabRuoli>()
                    )
                    .add(ruolo);
        }
    }


    /*
     * Ordinamento di ogni gruppo per anno ruolo crescente.
     */
    for (List<InsTabRuoli> gruppo : gruppiEntrata.values()) {

        gruppo.sort(
                Comparator.comparingInt(
                        ruolo -> {

                            String csv = ruolo.getValues() == null
                                    ? ""
                                    : ruolo.getValues();

                            return csvInteger(
                                    csv.split(";", -1),
                                    IDX_ANNO_RUOLO
                            );
                        }
                )
        );
    }


 
%>



<h3 class="mb-4">
	<i class="bi bi-calculator"></i> IMPORTI DEFINIBILI   
	<span class="badge bg-primary ms-2">
        <%= anno_selezionato %>
    </span> 
</h3>





<!-- AREA VISUALIZZAZIONE -->

<div class="rounded p-4 dati-card mt-4">

	<div class="dati-header mb-3">

		<div class="dati-title dati-section-title">

			<i class="bi bi-table"></i> <span> DATI COMPUTATI DA TABELLA RUOLI
			</span>

		</div>

	</div>


	<%
        if (gruppiEntrata.isEmpty()) {
    %>

	<div class="alert alert-info mb-0">Nessun ruolo coattivo memorizzato.</div>

	<%
        } else {
        	
        	BigDecimal totaleGlobaleImpostaResidua = BigDecimal.ZERO;
        	 BigDecimal totaleGlobaleSanzioniResidue = BigDecimal.ZERO;
        	 BigDecimal totaleGlobaleInteressiResidui = BigDecimal.ZERO;
        	 BigDecimal totaleGlobaleImportoRuolo = BigDecimal.ZERO;

            for (
                    Map.Entry<String, List<InsTabRuoli>> gruppoEntry
                            : gruppiEntrata.entrySet()
            ) {

                String entrata = gruppoEntry.getKey();

                List<InsTabRuoli> righe =
                        gruppoEntry.getValue();

 
    %>


	<div class="tab-ruoli-group" >

		<div class="tab-ruoli-title-light"  style="max-width:800px">

			<i class="bi bi-cash-coin"></i> <span> Entrata: <%= entrata %>
			</span>

		</div>


		<div class="tab-ruoli-container">

			<table class="table table-bordered table-hover table-sm table-ruoli"  style="max-width:800px">

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

					<%
					BigDecimal totaleImpostaResidua = BigDecimal.ZERO;
					BigDecimal totaleSanzioniResidue = BigDecimal.ZERO;
					BigDecimal totaleInteressiResidui = BigDecimal.ZERO;
					BigDecimal totaleImportoRuolo = BigDecimal.ZERO;
					
                        for (InsTabRuoli ruolo : righe) {

                            String csv = ruolo.getValues() == null
                                    ? ""
                                    : ruolo.getValues();

                            String[] values =
                                    csv.split(";", -1);


                            /*
                             * Prima si leggono i valori.
                             */
                            BigDecimal impostaRuolo =
                                    csvDecimal(
                                            values,
                                            IDX_IMPOSTA_RUOLO
                                    );

                            BigDecimal sanzioniRuolo =
                                    csvDecimal(
                                            values,
                                            IDX_SANZIONI_RUOLO
                                    );

                            BigDecimal interessiRuolo =
                                    csvDecimal(
                                            values,
                                            IDX_INTERESSI_RUOLO
                                    );

                            BigDecimal importoRuolo =
                                    csvDecimal(
                                            values,
                                            IDX_IMPORTO_RUOLO
                                    );


                            BigDecimal impostaRiscossa =
                                    csvDecimal(
                                            values,
                                            IDX_IMPOSTA_RISCOSSA
                                    );

                            BigDecimal sanzioniRiscosse =
                                    csvDecimal(
                                            values,
                                            IDX_SANZIONI_RISCOSSE
                                    );

                            BigDecimal interessiRiscossi =
                                    csvDecimal(
                                            values,
                                            IDX_INTERESSI_RISCOSSI
                                    );

                            BigDecimal importoRiscosso =
                                    csvDecimal(
                                            values,
                                            IDX_IMPORTO_RISCOSSO
                                    );


                            BigDecimal residui =
                                    csvDecimal(
                                            values,
                                            IDX_RESIDUI
                                    );


                            String percentualeStored =
                                    csvValue(
                                            values,
                                            IDX_PERCENTUALE_RISCOSSO
                                    );

                            BigDecimal percentuale =
                                    csvDecimal(
                                            values,
                                            IDX_PERCENTUALE_RISCOSSO
                                    );
                            
                            
                            BigDecimal impostaResidua = impostaRuolo.subtract(impostaRiscossa);
                            BigDecimal sanzioniResidue = sanzioniRuolo.subtract(sanzioniRiscosse); 
                            BigDecimal interessiResidui = interessiRuolo.subtract(interessiRiscossi);
                             BigDecimal importoRuoloResiduo = impostaResidua.add(sanzioniResidue).add(interessiResidui);
                             totaleImpostaResidua = totaleImpostaResidua.add(impostaResidua);
                             totaleSanzioniResidue = totaleSanzioniResidue.add(sanzioniResidue);
                             totaleInteressiResidui = totaleInteressiResidui.add(interessiResidui);
                             totaleImportoRuolo = totaleImportoRuolo.add(importoRuoloResiduo);


                           
                    %>


					<tr>

						<td><%= csvValue(
                                        values,
                                        IDX_ENTRATA
                                ) %></td>



						<td class="text-center"><%= csvValue(
                                        values,
                                        IDX_ANNO_RUOLO
                                ) %></td>


						<td class="text-center"><%= csvValue(
                                        values,
                                        IDX_NUMERO_RUOLO
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        impostaRuolo.subtract(impostaRiscossa)
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        sanzioniRuolo.subtract(sanzioniRiscosse)
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        interessiRuolo.subtract(interessiRiscossi)
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
								impostaRuolo.subtract(impostaRiscossa).add(interessiRuolo.subtract(interessiRiscossi)).add(sanzioniRuolo.subtract(sanzioniRiscosse))
                                ) %></td>


						


						

					</tr>


					<%
                        }
                        totaleGlobaleImpostaResidua = totaleGlobaleImpostaResidua.add(totaleImpostaResidua);
                         totaleGlobaleSanzioniResidue = totaleGlobaleSanzioniResidue.add(totaleSanzioniResidue);
                         totaleGlobaleInteressiResidui = totaleGlobaleInteressiResidui.add(totaleInteressiResidui);
                         totaleGlobaleImportoRuolo = totaleGlobaleImportoRuolo.add(totaleImportoRuolo);
 
                    %>

 
					<tr class="table-primary fw-bold">
						<td colspan="3" class="text-end">TOTALE <%= entrata %></td>
						<td class="text-number"><%= moneyFormat.format(totaleImpostaResidua) %></td>
						<td class="text-number"><%= moneyFormat.format(totaleSanzioniResidue) %></td>
						<td class="text-number"><%= moneyFormat.format(totaleInteressiResidui) %></td>
						<td class="text-number"><%= moneyFormat.format(totaleImportoRuolo) %></td>
					 </tr>


				</tbody>

			</table>

		</div>

	</div>


	<%
            }

 
    %>

<div class="tab-ruoli-group mt-4">
<div class="tab-ruoli-title">
    <i class="bi bi-calculator-fill"></i>
    <span>TOTALI RUOLI</span>
</div>
<div class="tab-ruoli-container">
    <table class="table table-bordered table-sm table-ruoli mb-0" STYLE="width:800px">
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
                <td class="text-number"><%= moneyFormat.format(totaleGlobaleImpostaResidua) %></td>
                <td class="text-number"><%= moneyFormat.format(totaleGlobaleSanzioniResidue) %></td>
                <td class="text-number"><%= moneyFormat.format(totaleGlobaleInteressiResidui) %></td>
                <td class="text-number"><%= moneyFormat.format(totaleGlobaleImportoRuolo) %></td>
            </tr>
        </tbody>
    </table>
</div>
   </div>
 
	

	<%
        }
    %>

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
            field.addEventListener(
                "input",
                calculateRuolo
            );
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

    return Number.isFinite(value)
        ? value
        : 0;
}


function setNumber(id, value) {

    const element = document.getElementById(id);

    if (!element) {
        return;
    }

    const safeValue = Number.isFinite(value)
        ? value
        : 0;

    element.value = safeValue.toFixed(2);
}


function calculateRuolo() {

    /*
     * IMPORTI A RUOLO
     */
    const impostaRuolo =
        getNumber("impostaRuolo");

    const interessiRuolo =
        getNumber("interessiRuolo");

    const sanzioniRuolo =
        impostaRuolo * 0.30;

    const importoRuolo =
        impostaRuolo +
        sanzioniRuolo +
        interessiRuolo;


    /*
     * IMPORTI RISCOSSI
     */
    const impostaRiscossa =
        getNumber("impostaRiscossa");

    const interessiRiscossi =
        getNumber("interessiRiscossi");

    const sanzioniRiscosse =
        impostaRiscossa * 0.30;

    const importoRiscosso =
        impostaRiscossa +
        sanzioniRiscosse +
        interessiRiscossi;


    /*
     * RESIDUO E PERCENTUALE
     */
    const residuoDaRiscuotere =
        importoRuolo - importoRiscosso;

    const percentualeRiscosso =
        importoRuolo > 0
            ? (importoRiscosso / importoRuolo) * 100
            : 0;


    /*
     * AGGIORNAMENTO CAMPI
     */
    setNumber(
        "sanzioniRuolo",
        sanzioniRuolo
    );

    setNumber(
        "importoRuolo",
        importoRuolo
    );

    setNumber(
        "sanzioniRiscosse",
        sanzioniRiscosse
    );

    setNumber(
        "importoRiscosso",
        importoRiscosso
    );

    setNumber(
        "residuoDaRiscuotere",
        residuoDaRiscuotere
    );

    setNumber(
        "percentualeRiscosso",
        percentualeRiscosso
    );
}
</script>