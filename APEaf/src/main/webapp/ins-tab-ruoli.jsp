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

request.getSession().setAttribute(SessionVariables.CALLER, "ins-tab-ruoli.jsp");

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


    /*
     * Struttura CSV:
     *
     * 0  Entrata
     * 1  Concessionario
     * 2  Data consegna ruolo
     * 3  Anno ruolo coattivo
     * 4  Numero ruolo
     * 5  Imposta ruolo
     * 6  Sanzioni ruolo
     * 7  Interessi ruolo
     * 8  Importo ruolo
     * 9  Imposta riscossa
     * 10 Sanzioni riscosse
     * 11 Interessi riscossi
     * 12 Importo riscosso
     * 13 Residuo
     * 14 Percentuale riscossa
     */

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


    /*
     * Totali generali.
     */
    BigDecimal totaleGeneraleImpostaRuolo =
            BigDecimal.ZERO;

    BigDecimal totaleGeneraleSanzioniRuolo =
            BigDecimal.ZERO;

    BigDecimal totaleGeneraleInteressiRuolo =
            BigDecimal.ZERO;

    BigDecimal totaleGeneraleImportoRuolo =
            BigDecimal.ZERO;


    BigDecimal totaleGeneraleImpostaRiscossa =
            BigDecimal.ZERO;

    BigDecimal totaleGeneraleSanzioniRiscosse =
            BigDecimal.ZERO;

    BigDecimal totaleGeneraleInteressiRiscossi =
            BigDecimal.ZERO;

    BigDecimal totaleGeneraleImportoRiscosso =
            BigDecimal.ZERO;


    BigDecimal totaleGeneraleResidui =
            BigDecimal.ZERO;

    BigDecimal sommaGeneralePercentuali =
            BigDecimal.ZERO;

    int numeroGeneralePercentuali = 0;
%>



<h3 class="mb-4">
	<i class="bi bi-sliders"></i> INSERIMENTO TABELLA RUOLI     
	<span class="badge bg-primary ms-2">
        <%= anno_selezionato %>
    </span> 
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
        String message = (String) session.getAttribute(
                InsTabRuoliServlet.class.getName()
        );

        if (message != null) {
    %>

	<div class="alert alert-info alert-dismissible fade show" role="alert">

		<%= message %>

		<button type="button" class="btn-close" data-bs-dismiss="alert"
			aria-label="Chiudi"></button>

	</div>

	<%
            session.removeAttribute(
                    InsTabRuoliServlet.class.getName()
            );
        }
    %>


	<form id="ruoloForm" action="ins-tab-ruoli" method="post">

		<input type="hidden" name="op" value="save" />


		<div class="table-responsive">

			<table class="table table-bordered table-hover table-sm table-ruoli">

				<thead class="text-center">

					<tr>

						<th rowspan="2" style="width: 100px">Entrata</th>

						<th rowspan="2">Concessionario</th>

						<th rowspan="2">Data consegna ruolo</th>

						<th rowspan="2">Anno ruolo coattivo</th>

						<th rowspan="2">N. ruolo</th>


						<th colspan="4" class="table-warning">TOTALI RUOLI COATTIVI</th>


						<th colspan="4" class="table-secondary">IMPORTI RISCOSSI</th>


						<th rowspan="2">Residui da riscuotere <br /> al 31/12/<%=anno_selezionato %>

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

						<td><select name="entrata"
							class="form-select form-select-sm select-entrata" required>

								<option value="" selected disabled>Seleziona...</option>

								<%
                                    for (String entrata : Entrata.values) {
                                %>

								<option value="<%= entrata %>">
									<%= entrata %>
								</option>

								<%
                                    }
                                %>

						</select></td>


						<td><input type="text" name="concessionario"
							class="form-control form-control-sm" placeholder="Concessionario"
							required /></td>


						<td><input type="date" name="dataConsegnaRuolo"
							class="form-control form-control-sm" style="width: 145px;" /></td>


						<td><input type="number" name="annoRuoloCoattivo"
							class="form-control form-control-sm text-center" min="1900"
							max="2100" step="1" required /></td>


						<td><input type="text" name="numeroRuolo"
							class="form-control form-control-sm text-center" required /></td>


						<td><input type="number" name="impostaRuolo"
							id="impostaRuolo" class="form-control form-control-sm text-end"
							min="0" step="0.01" value="0.00" /></td>


						<td><input type="number" name="sanzioniRuolo"
							id="sanzioniRuolo" class="form-control form-control-sm text-end"
							step="0.01" value="0.00" readonly /></td>


						<td><input type="number" name="interessiRuolo"
							id="interessiRuolo" class="form-control form-control-sm text-end"
							min="0" step="0.01" value="0.00" /></td>


						<td><input type="number" name="importoRuolo"
							id="importoRuolo"
							class="form-control form-control-sm text-end fw-bold" step="0.01"
							value="0.00" readonly /></td>


						<td><input type="number" name="impostaRiscossa"
							id="impostaRiscossa"
							class="form-control form-control-sm text-end" min="0" step="0.01"
							value="0.00" /></td>


						<td><input type="number" name="sanzioniRiscosse"
							id="sanzioniRiscosse"
							class="form-control form-control-sm text-end" step="0.01"
							value="0.00" readonly /></td>


						<td><input type="number" name="interessiRiscossi"
							id="interessiRiscossi"
							class="form-control form-control-sm text-end" min="0" step="0.01"
							value="0.00" /></td>


						<td><input type="number" name="importoRiscosso"
							id="importoRiscosso"
							class="form-control form-control-sm text-end fw-bold" step="0.01"
							value="0.00" readonly /></td>


						<td><input type="number" name="residuoDaRiscuotere"
							id="residuoDaRiscuotere"
							class="form-control form-control-sm text-end fw-bold" step="0.01"
							value="0.00" readonly /></td>


						<td>

							<div class="input-group input-group-sm">

								<input type="number" name="percentualeRiscosso"
									id="percentualeRiscosso" class="form-control text-end fw-bold"
									step="0.01" value="0.00" readonly /> <span
									class="input-group-text"> % </span>

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

			<i class="bi bi-table"></i> <span> RUOLI COATTIVI MEMORIZZATI
			</span>

		</div>

	</div>


	<%
        if (gruppiEntrata.isEmpty()) {
    %>

	<div class="alert alert-info mb-0">Nessun ruolo coattivo
		memorizzato.</div>

	<%
        } else {

            for (
                    Map.Entry<String, List<InsTabRuoli>> gruppoEntry
                            : gruppiEntrata.entrySet()
            ) {

                String entrata = gruppoEntry.getKey();

                List<InsTabRuoli> righe =
                        gruppoEntry.getValue();


                /*
                 * Totali del singolo gruppo Entrata.
                 * Devono essere azzerati all'inizio di ogni gruppo.
                 */
                BigDecimal totaleImpostaRuolo =
                        BigDecimal.ZERO;

                BigDecimal totaleSanzioniRuolo =
                        BigDecimal.ZERO;

                BigDecimal totaleInteressiRuolo =
                        BigDecimal.ZERO;

                BigDecimal totaleImportoRuolo =
                        BigDecimal.ZERO;


                BigDecimal totaleImpostaRiscossa =
                        BigDecimal.ZERO;

                BigDecimal totaleSanzioniRiscosse =
                        BigDecimal.ZERO;

                BigDecimal totaleInteressiRiscossi =
                        BigDecimal.ZERO;

                BigDecimal totaleImportoRiscosso =
                        BigDecimal.ZERO;


                BigDecimal totaleResidui =
                        BigDecimal.ZERO;

                BigDecimal sommaPercentuali =
                        BigDecimal.ZERO;

                int numeroPercentuali = 0;
    %>


	<div class="tab-ruoli-group">

		<div class="tab-ruoli-title">

			<i class="bi bi-cash-coin"></i> <span> Entrata: <%= entrata %>
			</span>

		</div>


		<div class="tab-ruoli-container">

			<table class="table table-bordered table-hover table-sm table-ruoli">

				<thead>

					<tr>

						<th rowspan="2" style="width: 100px">Entrata</th>

						<th rowspan="2">Concessionario</th>

						<th rowspan="2">Data consegna ruolo</th>

						<th rowspan="2">Anno ruolo coattivo</th>

						<th rowspan="2">N. ruolo</th>


						<th colspan="4" class="table-warning">TOTALI RUOLI COATTIVI</th>


						<th colspan="4" class="table-secondary">RISCOSSO</th>


						<th rowspan="2">RESIDUI RUOLI DA RISCUOTERE <br /> al 31/12/<%=anno_selezionato %>

						</th>


						<th rowspan="2">% riscosso</th>


						<th rowspan="2" style="width: 70px;">AZIONI</th>

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

					<%
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


                            /*
                             * Totali del gruppo Entrata.
                             */
                            totaleImpostaRuolo =
                                    totaleImpostaRuolo.add(
                                            impostaRuolo
                                    );

                            totaleSanzioniRuolo =
                                    totaleSanzioniRuolo.add(
                                            sanzioniRuolo
                                    );

                            totaleInteressiRuolo =
                                    totaleInteressiRuolo.add(
                                            interessiRuolo
                                    );

                            totaleImportoRuolo =
                                    totaleImportoRuolo.add(
                                            importoRuolo
                                    );


                            totaleImpostaRiscossa =
                                    totaleImpostaRiscossa.add(
                                            impostaRiscossa
                                    );

                            totaleSanzioniRiscosse =
                                    totaleSanzioniRiscosse.add(
                                            sanzioniRiscosse
                                    );

                            totaleInteressiRiscossi =
                                    totaleInteressiRiscossi.add(
                                            interessiRiscossi
                                    );

                            totaleImportoRiscosso =
                                    totaleImportoRiscosso.add(
                                            importoRiscosso
                                    );


                            totaleResidui =
                                    totaleResidui.add(
                                            residui
                                    );


                            if (!percentualeStored.isEmpty()) {

                                sommaPercentuali =
                                        sommaPercentuali.add(
                                                percentuale
                                        );

                                numeroPercentuali++;
                            }


                            /*
                             * Totali generali.
                             */
                            totaleGeneraleImpostaRuolo =
                                    totaleGeneraleImpostaRuolo.add(
                                            impostaRuolo
                                    );

                            totaleGeneraleSanzioniRuolo =
                                    totaleGeneraleSanzioniRuolo.add(
                                            sanzioniRuolo
                                    );

                            totaleGeneraleInteressiRuolo =
                                    totaleGeneraleInteressiRuolo.add(
                                            interessiRuolo
                                    );

                            totaleGeneraleImportoRuolo =
                                    totaleGeneraleImportoRuolo.add(
                                            importoRuolo
                                    );


                            totaleGeneraleImpostaRiscossa =
                                    totaleGeneraleImpostaRiscossa.add(
                                            impostaRiscossa
                                    );

                            totaleGeneraleSanzioniRiscosse =
                                    totaleGeneraleSanzioniRiscosse.add(
                                            sanzioniRiscosse
                                    );

                            totaleGeneraleInteressiRiscossi =
                                    totaleGeneraleInteressiRiscossi.add(
                                            interessiRiscossi
                                    );

                            totaleGeneraleImportoRiscosso =
                                    totaleGeneraleImportoRiscosso.add(
                                            importoRiscosso
                                    );


                            totaleGeneraleResidui =
                                    totaleGeneraleResidui.add(
                                            residui
                                    );


                            if (!percentualeStored.isEmpty()) {

                                sommaGeneralePercentuali =
                                        sommaGeneralePercentuali.add(
                                                percentuale
                                        );

                                numeroGeneralePercentuali++;
                            }
                    %>


					<tr>

						<td><%= csvValue(
                                        values,
                                        IDX_ENTRATA
                                ) %></td>


						<td><%= csvValue(
                                        values,
                                        IDX_CONCESSIONARIO
                                ) %></td>


						<td class="text-center"><%= csvValue(
                                        values,
                                        IDX_DATA_CONSEGNA
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
                                        impostaRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        sanzioniRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        interessiRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        importoRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        impostaRiscossa
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        sanzioniRiscosse
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        interessiRiscossi
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        importoRiscosso
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        residui
                                ) %></td>


						<td class="text-number">
							<%
                                    if (!percentualeStored.isEmpty()) {
                                %> <%= percentFormat.format(
                                            percentuale
                                    ) %>% <%
                                    } else {
                                %> - <%
                                    }
                                %>

						</td>


						<td class="text-center">

							<form action="ins-tab-ruoli" method="post" class="d-inline"
								onsubmit="return confirm(
                                          'Eliminare questo ruolo?\n' +
                                          'Sarà possibile reinserirlo successivamente.'
                                      );">

								<input type="hidden" name="op" value="DELETE" /> <input
									type="hidden" name="id" value="<%= ruolo.getId() %>" />

								<button type="submit" class="btn btn-sm btn-danger"
									title="Elimina">

									<i class="bi bi-trash-fill"></i>

								</button>

							</form>

						</td>

					</tr>


					<%
                        }


                        BigDecimal mediaPercentuale =
                                BigDecimal.ZERO;

                        if (numeroPercentuali > 0) {

                            mediaPercentuale =
                                    sommaPercentuali.divide(
                                            BigDecimal.valueOf(
                                                    numeroPercentuali
                                            ),
                                            2,
                                            RoundingMode.HALF_UP
                                    );
                        }
                    %>


					<tr class="totals-row">

						<td colspan="4"></td>


						<td>TOTALI RUOLI</td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleImpostaRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleSanzioniRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleInteressiRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleImportoRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleImpostaRiscossa
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleSanzioniRiscosse
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleInteressiRiscossi
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleImportoRiscosso
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleResidui
                                ) %></td>


						<td class="text-number">
							<%
                                    if (numeroPercentuali > 0) {
                                %> <%= percentFormat.format(
                                            mediaPercentuale
                                    ) %>% <small>(media)</small> <%
                                    } else {
                                %> - <%
                                    }
                                %>

						</td>


						<td></td>

					</tr>

				</tbody>

			</table>

		</div>

	</div>


	<%
            }


            /*
             * La media generale va calcolata dopo aver elaborato
             * tutte le righe di tutti i gruppi.
             */
            BigDecimal mediaGeneralePercentuale =
                    BigDecimal.ZERO;

            if (numeroGeneralePercentuali > 0) {

                mediaGeneralePercentuale =
                        sommaGeneralePercentuali.divide(
                                BigDecimal.valueOf(
                                        numeroGeneralePercentuali
                                ),
                                2,
                                RoundingMode.HALF_UP
                        );
            }
    %>


	<div class="tab-ruoli-group overall-totals-group">

		<div class="tab-ruoli-title">

			<i class="bi bi-calculator-fill"></i> <span> TOTALI GENERALI </span>

		</div>


		<div class="tab-ruoli-container">

			<table class="table table-bordered table-sm table-ruoli">

				<thead>

					<tr>

						<th colspan="5">TOTALI COMPLESSIVI</th>


						<th colspan="4" class="table-warning">TOTALI RUOLI COATTIVI</th>


						<th colspan="4" class="table-secondary">IMPORTI RISCOSSI</th>


						<th rowspan="2">RESIDUI RUOLI <br /> DA RISCUOTERE

						</th>


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


						<td class="text-number"><%= moneyFormat.format(
                                        totaleGeneraleImpostaRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleGeneraleSanzioniRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleGeneraleInteressiRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleGeneraleImportoRuolo
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleGeneraleImpostaRiscossa
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleGeneraleSanzioniRiscosse
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleGeneraleInteressiRiscossi
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleGeneraleImportoRiscosso
                                ) %></td>


						<td class="text-number"><%= moneyFormat.format(
                                        totaleGeneraleResidui
                                ) %></td>


						<td class="text-number">
							<%
                                    if (numeroGeneralePercentuali > 0) {
                                %> <%= percentFormat.format(
                                            mediaGeneralePercentuale
                                    ) %>% <small>(media)</small> <%
                                    } else {
                                %> - <%
                                    }
                                %>

						</td>



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