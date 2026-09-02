<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.utils.*" %>
<%@ page import="java.util.*" %>
<%@ page import="is.five.apeaf.controller.InsDatiFCDEServlet" %>
<%@ page import="is.five.apeaf.dao.*"%>
<%@ page import="is.five.apeaf.dao.model.*"%>


<%
    request.getSession().setAttribute(
            SessionVariables.CALLER,
            "ins-dati-fcde.jsp"
    );

    UserView user =
            (UserView) request
                    .getSession()
                    .getAttribute("ubAP");

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


    
    /*
     * Valori standard.
     */
    String[] values = {
        "0",
        "0",
        "0",
        "0",
        "0"
    };

    /*
     * Tipologie aggiuntive salvate come:
     *
     * Nome tipologia=valore
     */
    Map<String, String> tipologieAggiuntive =
            new LinkedHashMap<String, String>();


    InsDatiFCDE datiFCDE =
            InsDatiFCDEDAO.findByUserAndAnno(
                    user.getId(),
                    anno
            );


    if (datiFCDE != null &&
        datiFCDE.getValue() != null &&
        !datiFCDE.getValue().trim().isEmpty()) {

        String[] saved =
                datiFCDE
                    .getValue()
                    .split(";", -1);

        int posizioneFissa = 0;

        for (String token : saved) {

            if (token == null) {
                continue;
            }

            token = token.trim();

            if (token.isEmpty()) {
                continue;
            }


            /*
             * Campo dinamico:
             *
             * Canone=100
             * Recupero evasione=250
             */
            if (token.contains("=")) {

                String[] parts =
                        token.split("=", 2);

                String tipologia =
                        parts[0].trim();

                String valore =
                        parts.length > 1
                        ? parts[1].trim()
                        : "0";

                if (!tipologia.isEmpty()) {

                    if (valore.isEmpty()) {
                        valore = "0";
                    }

                    tipologieAggiuntive.put(
                            tipologia,
                            valore
                    );
                }

            } else {

                /*
                 * I primi 5 valori sono posizionali:
                 *
                 * ICI
                 * TASI
                 * IMU
                 * TARI
                 * CDS
                 */
                if (posizioneFissa < values.length) {

                    values[posizioneFissa] =
                            token;

                    posizioneFissa++;
                }
            }
        }
    }
%>



<h3 class="mb-4">

    <i class="bi bi-sliders"></i>

    INSERIMENTO DATI FCDE

    <span class="badge bg-primary ms-2">
        <%= anno %>
    </span>

</h3>


<%
    String message =
            (String) session.getAttribute(
			InsDatiFCDEServlet.class.getName()
            );

    if (message != null) {
%>

    <div class="alert alert-primary alert-dismissible fade show"
         role="alert">

        <%= message %>

        <button type="button"
                class="btn-close"
                data-bs-dismiss="alert"
                aria-label="Chiudi">
        </button>

    </div>

<%
        session.removeAttribute(
			InsDatiFCDEServlet.class.getName()
        );
    }
%>




<form action="ins-dati-fcde"
      method="post">

    <input type="hidden"
           name="anno"
           value="<%= anno %>" />


    <div class="table-responsive">

    <table class="table table-bordered table-hover table-sm table-residui">

            <thead class="table-secondary">

                <tr>

                    <th colspan=2 style="width:480px">
                        QUOTA FCDE ACCANTONATA A CONSUNTIVO
                    </th>

                </tr>

            </thead>


            <tbody>

                <tr>

                    <td class="fw-bold" style="width:300px">
                         <%= InsDatiFCDE.TIPOLOGIE[0] %>
                    </td>

                    <td>

                       <input type="number"
						       name="risc_0"
                           class="form-control form-control-sm bg-dark text-white"
						       value="<%= values[0] %>"
						       min="0"
						       step="any"
						       required />

                    </td>

                </tr>


                <tr>

                    <td class="fw-bold">
                         <%= InsDatiFCDE.TIPOLOGIE[1] %>
                    </td>

                    <td>

                        <input type="number"
                               name="risc_1"
                           class="form-control form-control-sm bg-dark text-white"
                            value="<%= values[1] %>" min="0"
						       step="any"
						       required />

                    </td>

                </tr>


                <tr>

                    <td class="fw-bold">
                         <%= InsDatiFCDE.TIPOLOGIE[2] %>
                    </td>

                    <td>

                        <input type="number"
                               name="risc_2"
                           class="form-control form-control-sm bg-dark text-white"
                               value="<%= values[2] %>" min="0"
						       step="any"
						       required />

                    </td>

                </tr>


                <tr>

                    <td class="fw-bold">
                         <%= InsDatiFCDE.TIPOLOGIE[3] %>
                    </td>

                    <td>

                        <input type="number"
                               name="risc_3"
                           class="form-control form-control-sm bg-dark text-white"
                               value="<%= values[3] %>" min="0"
						       step="any"
						       required />

                    </td>

                </tr>


                <tr>

                    <td class="fw-bold">
                         <%= InsDatiFCDE.TIPOLOGIE[4] %>
                    </td>

                    <td>

                        <input type="number"
                               name="risc_4"
                           class="form-control form-control-sm bg-dark text-white"
                               value="<%= values[4] %>" min="0"
						       step="any"
						       required />

                    </td>

                </tr>
                
                <%
				    for (Map.Entry<String, String> entry :
				            tipologieAggiuntive.entrySet()) {
				%>
				
				<tr class="dynamic-tipologia">
				
				    <td class="fw-bold">
				
				        <div class="input-group input-group-sm">
				
				            <input type="text" readonly
				                   name="nuova_tipologia[]"
				                   class="form-control"
				                   value="<%= entry.getKey() %>"
				                   required style="text-align:left"/>

				        </div>
				
				    </td>
				
				    <td>
				    
	     <div class="input-group input-group-sm">
				    
				
				        <input type="number" readonly
				               name="nuova_tipologia_valore[]"
				               class="form-control form-control-sm bg-dark text-white valore-dinamico"
				               value="<%= entry.getValue() %>"
				               min="0"
				               step="any"
				               required />
				               
				                <button type="button"
				                    class="btn btn-outline-danger"
				                    onclick="rimuoviTipologia(this)">
				
				                <i class="bi bi-trash"></i>
				
				            </button>
				
									        </div>
				
				    </td>
				
				</tr>
				
				<%
				    }
				%>


			<tr id="rowAggiungiTipologia">
			
			    <td colspan="2">
			
			        <button type="button"
			                class="btn btn-outline-primary btn-sm"
			                onclick="aggiungiTipologia()">
			
			            <i class="bi bi-plus-circle me-1"></i>
			
			            Aggiungi tipologia
			
			        </button>
			
			    </td>
			
			</tr>

                <tr class="table-primary fw-bold">

                    <td>
                        TOTALE FCDE
                    </td>

                    <td class="text-end fs-6">
                        <output id="totaleFCDE"
                                aria-live="polite">
                            0,000
                        </output>
                    </td>

                </tr>

            </tbody>

        </table>

    </div>


    <button type="submit"

            class="btn btn-primary btn-sm mt-2">

        <i class="bi bi-floppy-fill me-1"></i>

        Salva valori

    </button>


</form>




<script>

document.addEventListener("DOMContentLoaded", function () {

    const totalOutput =
            document.getElementById(
                "totaleFCDE"
            );

    const italianNumberFormat =
            new Intl.NumberFormat(
                "it-IT",
                {
                    minimumFractionDigits: 3,
                    maximumFractionDigits: 3
                }
            );


    window.updateTotalFCDE = function () {

        let total = 0;


        /*
         * Campi standard:
         *
         * risc_0 ... risc_4
         */
        document
            .querySelectorAll(
                'input[name^="risc_"]'
            )
            .forEach(function (input) {

                const value =
                        Number(input.value);

                if (Number.isFinite(value)) {
                    total += value;
                }
            });


        /*
         * Campi aggiuntivi.
         */
        document
            .querySelectorAll(
                ".valore-dinamico"
            )
            .forEach(function (input) {

                const value =
                        Number(input.value);

                if (Number.isFinite(value)) {
                    total += value;
                }
            });


        totalOutput.textContent =
                italianNumberFormat.format(
                    total
                );
    };


    /*
     * Listener sui campi standard.
     */
    document
        .querySelectorAll(
            'input[name^="risc_"]'
        )
        .forEach(function (input) {

            input.addEventListener(
                "input",
                updateTotalFCDE
            );
        });


    /*
     * Listener sui campi dinamici
     * caricati dal DB.
     */
    document
        .querySelectorAll(
            ".valore-dinamico"
        )
        .forEach(function (input) {

            input.addEventListener(
                "input",
                updateTotalFCDE
            );
        });


    updateTotalFCDE();
});


function aggiungiTipologia() {

    const tbody =
            document.querySelector(
                ".table-residui tbody"
            );

    const rowAggiungi =
            document.getElementById(
                "rowAggiungiTipologia"
            );


    const tr =
            document.createElement("tr");

    tr.className =
            "dynamic-tipologia";


    tr.innerHTML = `

        <td class="fw-bold">

            <div class="input-group input-group-sm">

                <input
                    type="text"
                    name="nuova_tipologia[]"
                    class="form-control"
                    placeholder="Nuova tipologia FCDE"
                    required />

                <button
                    type="button"
                    class="btn btn-outline-danger"
                    onclick="rimuoviTipologia(this)">

                    <i class="bi bi-trash"></i>

                </button>

            </div>

        </td>

        <td>

            <input
                type="number"
                name="nuova_tipologia_valore[]"
                class="form-control form-control-sm bg-dark text-white valore-dinamico"
                value="0"
                min="0"
                step="any"
                required />

        </td>
    `;


    tbody.insertBefore(
        tr,
        rowAggiungi
    );


    const input =
            tr.querySelector(
                ".valore-dinamico"
            );

    input.addEventListener(
        "input",
        updateTotalFCDE
    );


    updateTotalFCDE();
}


function rimuoviTipologia(button) {

    const row =
            button.closest("tr");

    if (row) {
        row.remove();
    }

    updateTotalFCDE();
}

</script>
