<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.utils.*" %>

<%@ page import="is.five.apeaf.controller.InsResiduiAttiviServlet" %>
<%@ page import="is.five.apeaf.dao.*"%>
<%@ page import="is.five.apeaf.dao.model.*"%>


<%
    request.getSession().setAttribute(
            SessionVariables.CALLER,
            "ins-residui-attivi.jsp"
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
     * Valori iniziali di default.
     */
    String[] values = {
        "0",
        "0",
        "0",
        "0",
        "0"
    };


    /*
     * La ricerca ora usa la chiave logica:
     * id_user + anno.
     */
    InsResiduiAttivi residuiAttivi =
            InsResiduiAttiviDAO.findByUserAndAnno(
                    user.getId(),
                    anno
            );


    if (residuiAttivi != null &&
        residuiAttivi.getValue() != null &&
        !residuiAttivi.getValue().trim().isEmpty()) {

        String[] saved =
                residuiAttivi
                        .getValue()
                        .split(";", -1);

        for (
                int i = 0;
                i < saved.length && i < values.length;
                i++
        ) {

            if (saved[i] != null &&
                !saved[i].trim().isEmpty()) {

                values[i] = saved[i].trim();
            }
        }
    }
%>


<h3 class="mb-4">

    <i class="bi bi-sliders"></i>

    RESIDUI ATTIVI 

    <span class="badge bg-primary ms-2">
        <%= anno %>
    </span>

</h3>


<%
    String message =
            (String) session.getAttribute(
                    InsResiduiAttiviServlet.class.getName()
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
                InsResiduiAttiviServlet.class.getName()
        );
    }
%>


<form action="ins-residui-attivi"
      method="post">
 
    <input type="hidden"
           name="anno"
           value="<%= anno %>" />


    <div class="table-responsive">

    <table class="table table-bordered table-hover table-sm table-residui">

            <thead class="table-secondary">

                <tr>

                    <th style="width:300px;">
                        TIPOLOGIA ENTRATA
                    </th>

                    <th style="width:180px;">
                        al 31/12/<%= anno %>
                    </th>

                </tr>

            </thead>


            <tbody>

                <tr>

                    <td class="fw-bold">
                        Accertamenti ICI
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
                        Accertamenti TASI
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
                        Accertamenti IMU
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
                        Tassa Rifiuti
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
                        CDS
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
                
                <tr class="table-primary fw-bold">

                    <td>
                        TOTALE
                    </td>

                    <td class="text-end fs-6">
                        <output id="totaleResiduiAttivi"
                                aria-live="polite">
                            0,00
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

    const valueInputs = document.querySelectorAll(
        'input[name^="risc_"]'
    );

    const totalOutput = document.getElementById(
        "totaleResiduiAttivi"
    );

    const italianNumberFormat = new Intl.NumberFormat(
        "it-IT",
        {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }
    );


    function updateTotal() {

        let total = 0;

        valueInputs.forEach(function (input) {

            const value = Number(input.value);

            if (Number.isFinite(value)) {
                total += value;
            }
        });

        totalOutput.textContent =
            italianNumberFormat.format(total);
    }


    valueInputs.forEach(function (input) {
        input.addEventListener("input", updateTotal);
    });

    updateTotal();
});
</script>
