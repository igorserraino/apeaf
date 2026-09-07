<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>

<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@ page import="is.five.apeaf.dao.model.Tipologia" %>

<%@ page import="is.five.apeaf.dao.TipologieDAO" %>

<%@ page import="is.five.apeaf.controller.InsTabRuoliServlet" %>

<%@ page import="is.five.apeaf.service.TabRuoliPageService" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.PageData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.GroupData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.RowData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.TotalsData" %>


<%

/* ============================================================
   CALLER
   ============================================================ */

request.getSession().setAttribute(
    SessionVariables.CALLER,
    "ins-tab-ruoli.jsp"
);


/* ============================================================
   USER
   ============================================================ */

UserView user =
    (UserView) request.getSession().getAttribute("ubAP");

if (user == null || !user.getActive()) {

    response.sendRedirect("index.jsp");
    return;
}


/* ============================================================
   ANNO FINANZIARIO SELEZIONATO
   ============================================================ */

String selectedYearId =
    session.getAttribute(SessionVariables.ANNO) != null
        ? String.valueOf(
            session.getAttribute(SessionVariables.ANNO)
          )
        : "";


/* ============================================================
   PAGE SERVICE
   ============================================================ */

TabRuoliPageService service =
    new TabRuoliPageService();

PageData pageData =
    service.load(
        user,
        selectedYearId
    );


/* ============================================================
   NESSUN ANNO SELEZIONATO
   ============================================================ */

if (!pageData.hasSelectedYear()) {

%>

<div class="alert alert-warning
            d-flex
            align-items-center
            shadow-sm
            mb-4"
     role="alert">

    <i class="bi bi-arrow-up-right-circle-fill
              fs-2
              me-3"></i>

    <div>

        <strong>
            Anno finanziario non selezionato.
        </strong>

        <br />

        Seleziona l'anno finanziario
        dal menu in alto a destra.

    </div>

</div>

<%

    return;
}


/* ============================================================
   TIPOLOGIE

   Le tipologie vengono definite ESCLUSIVAMENTE
   nella pagina "Def. tipologie".

   Qui vengono semplicemente lette per:
       id_user
       anno
   ============================================================ */

		   Integer selectedYear =
		    Integer.valueOf(pageData.getSelectedYear());

		List<Tipologia> tipologie =
		    TipologieDAO.findByUserAndAnno(
		        user.getId(),
		        selectedYear
		    );

boolean hasTipologie =
    tipologie != null &&
    !tipologie.isEmpty();


/* ============================================================
   MESSAGGIO SERVLET
   ============================================================ */

String message =
    (String) session.getAttribute(
        InsTabRuoliServlet.class.getName()
    );

%>


<!-- ============================================================
     TITOLO
     ============================================================ -->

<h3 class="mb-4">

    <i class="bi bi-sliders me-2"></i>

    INSERIMENTO TABELLA RUOLI

    <span class="badge bg-primary ms-2">

        <%= pageData.getSelectedYear() %>

    </span>

</h3>


<!-- ============================================================
     INSERIMENTO
     ============================================================ -->

<div class="bg-secondary rounded p-4">


    <!-- HEADER -->

    <div class="d-flex
                align-items-center
                justify-content-between
                mb-3">

        <h5 class="mb-0">

            <i class="bi bi-cash-coin me-2"></i>

            Nuovo ruolo coattivo

        </h5>


        <button type="submit"
                form="ruoloForm"
                class="btn btn-success btn-sm"
                <%= !hasTipologie
                    ? "disabled"
                    : "" %>>

            <i class="bi bi-floppy-fill me-1"></i>

            Salva

        </button>

    </div>


    <!-- ========================================================
         MESSAGGIO
         ======================================================== -->

    <% if (message != null) { %>

        <div class="alert alert-info
                    alert-dismissible
                    fade show"
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
            InsTabRuoliServlet.class.getName()
        );

    }

    %>


    <!-- ========================================================
         NESSUNA TIPOLOGIA DEFINITA
         ======================================================== -->

    <% if (!hasTipologie) { %>

        <div class="alert alert-warning
                    d-flex
                    align-items-center
                    shadow-sm
                    mb-4">

            <i class="bi bi-exclamation-triangle-fill
                      fs-3
                      me-3"></i>

            <div>

                <strong>
                    Nessuna tipologia definita
                    per l'anno
                    <%= pageData.getSelectedYear() %>.
                </strong>

                <br />

                Per inserire un ruolo è necessario
                definire prima almeno una tipologia
                dalla pagina

                <strong>
                    Def. tipologie
                </strong>.

            </div>

        </div>

    <% } %>


    <!-- ========================================================
         FORM
         ======================================================== -->

    <form id="ruoloForm"
          action="ins-tab-ruoli"
          method="post">

        <input type="hidden"
               name="op"
               value="save" />


        <div class="table-responsive">

            <table class="table
                          table-bordered
                          table-hover
                          table-sm
                          table-ruoli">

                <!-- =================================================
                     HEADER
                     ================================================= -->

                <thead class="text-center">

                    <tr>

                        <th rowspan="2"
                            style="min-width:150px">

                            Tipologia

                        </th>

                        <th rowspan="2"
                            style="min-width:180px">

                            Concessionario

                        </th>

                        <th rowspan="2"
                            style="min-width:150px">

                            Data consegna ruolo

                        </th>

                        <th rowspan="2"
                            style="min-width:120px">

                            Anno ruolo coattivo

                        </th>

                        <th rowspan="2"
                            style="min-width:100px">

                            N. ruolo

                        </th>


                        <th colspan="4"
                            class="table-warning">

                            TOTALI RUOLI COATTIVI

                        </th>


                        <th colspan="4"
                            class="table-secondary">

                            IMPORTI RISCOSSI

                        </th>


                        <th rowspan="2"
                            style="min-width:150px">

                            Residui da riscuotere

                            <br />

                            al 31/12/<%= pageData.getSelectedYear() %>

                        </th>


                        <th rowspan="2"
                            style="min-width:110px">

                            % riscosso

                        </th>

                    </tr>


                    <tr>

                        <th style="min-width:100px">
                            Imposta
                        </th>

                        <th style="min-width:100px">
                            Sanzioni
                        </th>

                        <th style="min-width:100px">
                            Interessi
                        </th>

                        <th style="min-width:110px">
                            Importo ruolo
                        </th>


                        <th style="min-width:100px">
                            Imposta
                        </th>

                        <th style="min-width:100px">
                            Sanzioni
                        </th>

                        <th style="min-width:100px">
                            Interessi
                        </th>

                        <th style="min-width:110px">
                            Importo riscosso
                        </th>

                    </tr>

                </thead>


                <!-- =================================================
                     DATA ENTRY
                     ================================================= -->

                <tbody>

                    <tr>


                        <!-- =========================================
                             TIPOLOGIA
                             Manteniamo name="entrata" per non
                             modificare servlet / CSV / DAO.
                             ========================================= -->

                        <td>

                            <select name="entrata"
                                    id="entrata"
                                    class="form-select
                                           form-select-sm
                                           select-entrata"
                                    required
                                    <%= !hasTipologie
                                        ? "disabled"
                                        : "" %>>

                                <option value=""
                                        selected
                                        disabled>

                                    Seleziona...

                                </option>


                                <% if (hasTipologie) {

                                    for (Tipologia t : tipologie) {

                                        if (t == null ||
                                            t.getValue() == null) {

                                            continue;
                                        }

                                %>

                                    <option value="<%= t.getValue() %>">

                                        <%= t.getValue() %>

                                    </option>

                                <%

                                    }

                                }

                                %>

                            </select>

                        </td>


                        <!-- CONCESSIONARIO -->

                        <td>

                            <input type="text"
                                   name="concessionario"
                                   class="form-control
                                          form-control-sm"
                                   placeholder="Concessionario"
                                   required />

                        </td>


                        <!-- DATA CONSEGNA -->

                        <td>

                            <input type="date"
                                   name="dataConsegnaRuolo"
                                   class="form-control
                                          form-control-sm"
                                   style="width:145px" />

                        </td>


                        <!-- ANNO RUOLO -->

                        <td>

                            <input type="number"
                                   name="annoRuoloCoattivo"
                                   class="form-control
                                          form-control-sm
                                          text-center"
                                   min="1900"
                                   max="2100"
                                   step="1"
                                   required />

                        </td>


                        <!-- NUMERO RUOLO -->

                        <td>

                            <input type="text"
                                   name="numeroRuolo"
                                   class="form-control
                                          form-control-sm
                                          text-center"
                                   required />

                        </td>


                        <!-- =========================================
                             RUOLO - IMPOSTA
                             ========================================= -->

                        <td>

                            <input type="number"
                                   name="impostaRuolo"
                                   id="impostaRuolo"
                                   class="form-control
                                          form-control-sm
                                          text-end"
                                   min="0"
                                   step="0.01"
                                   value="0.00" />

                        </td>


                        <!-- RUOLO - SANZIONI -->

                        <td>

                            <input type="number"
                                   name="sanzioniRuolo"
                                   id="sanzioniRuolo"
                                   class="form-control
                                          form-control-sm
                                          text-end"
                                   step="0.01"
                                   value="0.00"
                                   readonly />

                        </td>


                        <!-- RUOLO - INTERESSI -->

                        <td>

                            <input type="number"
                                   name="interessiRuolo"
                                   id="interessiRuolo"
                                   class="form-control
                                          form-control-sm
                                          text-end"
                                   min="0"
                                   step="0.01"
                                   value="0.00" />

                        </td>


                        <!-- RUOLO - IMPORTO TOTALE -->

                        <td>

                            <input type="number"
                                   name="importoRuolo"
                                   id="importoRuolo"
                                   class="form-control
                                          form-control-sm
                                          text-end
                                          fw-bold"
                                   step="0.01"
                                   value="0.00"
                                   readonly />

                        </td>


                        <!-- =========================================
                             RISCOSSO - IMPOSTA
                             ========================================= -->

                        <td>

                            <input type="number"
                                   name="impostaRiscossa"
                                   id="impostaRiscossa"
                                   class="form-control
                                          form-control-sm
                                          text-end"
                                   min="0"
                                   step="0.01"
                                   value="0.00" />

                        </td>


                        <!-- RISCOSSO - SANZIONI -->

                        <td>

                            <input type="number"
                                   name="sanzioniRiscosse"
                                   id="sanzioniRiscosse"
                                   class="form-control
                                          form-control-sm
                                          text-end"
                                   step="0.01"
                                   value="0.00"
                                   readonly />

                        </td>


                        <!-- RISCOSSO - INTERESSI -->

                        <td>

                            <input type="number"
                                   name="interessiRiscossi"
                                   id="interessiRiscossi"
                                   class="form-control
                                          form-control-sm
                                          text-end"
                                   min="0"
                                   step="0.01"
                                   value="0.00" />

                        </td>


                        <!-- RISCOSSO - TOTALE -->

                        <td>

                            <input type="number"
                                   name="importoRiscosso"
                                   id="importoRiscosso"
                                   class="form-control
                                          form-control-sm
                                          text-end
                                          fw-bold"
                                   step="0.01"
                                   value="0.00"
                                   readonly />

                        </td>


                        <!-- =========================================
                             RESIDUO
                             ========================================= -->

                        <td>

                            <input type="number"
                                   name="residuoDaRiscuotere"
                                   id="residuoDaRiscuotere"
                                   class="form-control
                                          form-control-sm
                                          text-end
                                          fw-bold"
                                   step="0.01"
                                   value="0.00"
                                   readonly />

                        </td>


                        <!-- PERCENTUALE -->

                        <td>

                            <div class="input-group
                                        input-group-sm">

                                <input type="number"
                                       name="percentualeRiscosso"
                                       id="percentualeRiscosso"
                                       class="form-control
                                              text-end
                                              fw-bold"
                                       step="0.01"
                                       value="0.00"
                                       readonly />

                                <span class="input-group-text">
                                    %
                                </span>

                            </div>

                        </td>

                    </tr>

                </tbody>

            </table>

        </div>

    </form>

</div>



<!-- ============================================================
     AREA VISUALIZZAZIONE
     ============================================================ -->

<div class="rounded p-4 dati-card mt-4">

    <div class="dati-header mb-3">

        <div class="dati-title dati-section-title">

            <i class="bi bi-table"></i>

            <span>
                RUOLI COATTIVI MEMORIZZATI
            </span>

        </div>

    </div>


    <!-- ========================================================
         NESSUN RECORD
         ======================================================== -->

    <% if (!pageData.hasGroups()) { %>

        <div class="alert alert-info mb-0">

            Nessun ruolo coattivo memorizzato.

        </div>


    <% } else { %>


        <!-- ====================================================
             GRUPPI PER TIPOLOGIA
             ==================================================== -->

        <%

        for (GroupData group : pageData.getGroups()) {

            TotalsData totals =
                group.getTotals();

        %>


        <div class="tab-ruoli-group">


            <!-- TITOLO GRUPPO -->

            <div class="tab-ruoli-title">

                <i class="bi bi-tags-fill"></i>

                <span>

                    Tipologia:
                    <%= group.getEntry() %>

                </span>

            </div>


            <div class="tab-ruoli-container">

                <table class="table
                              table-bordered
                              table-hover
                              table-sm
                              table-ruoli">


                    <!-- =============================================
                         HEADER
                         ============================================= -->

                    <thead>

                        <tr>

                            <th rowspan="2"
                                style="width:130px">

                                Tipologia

                            </th>

                            <th rowspan="2">
                                Concessionario
                            </th>

                            <th rowspan="2">
                                Data consegna ruolo
                            </th>

                            <th rowspan="2">
                                Anno ruolo coattivo
                            </th>

                            <th rowspan="2">
                                N. ruolo
                            </th>


                            <th colspan="4"
                                class="table-warning">

                                TOTALI RUOLI COATTIVI

                            </th>


                            <th colspan="4"
                                class="table-secondary">

                                RISCOSSO

                            </th>


                            <th rowspan="2">

                                RESIDUI RUOLI
                                DA RISCUOTERE

                                <br />

                                al 31/12/<%= pageData.getSelectedYear() %>

                            </th>


                            <th rowspan="2">
                                % riscosso
                            </th>


                            <th rowspan="2"
                                style="width:70px">

                                AZIONI

                            </th>

                        </tr>


                        <tr>

                            <th>IMPOSTA</th>

                            <th>SANZIONI</th>

                            <th>INTERESSI</th>

                            <th>
                                Importo ruolo
                            </th>


                            <th>IMPOSTA</th>

                            <th>SANZIONI</th>

                            <th>INTERESSI</th>

                            <th>
                                Importo riscosso
                            </th>

                        </tr>

                    </thead>


                    <!-- =============================================
                         RECORD
                         ============================================= -->

                    <tbody>


                        <%

                        for (RowData row : group.getRows()) {

                        %>

                        <tr>


                            <!-- TIPOLOGIA -->

                            <td>

                                <%= row.getEntry() %>

                            </td>


                            <!-- CONCESSIONARIO -->

                            <td>

                                <%= row.getConcessionaire() %>

                            </td>


                            <!-- DATA -->

                            <td class="text-center">

                                <%= row.getDeliveryDate() %>

                            </td>


                            <!-- ANNO -->

                            <td class="text-center">

                                <%= row.getRoleYear() %>

                            </td>


                            <!-- N. RUOLO -->

                            <td class="text-center">

                                <%= row.getRoleNumber() %>

                            </td>


                            <!-- RUOLO -->

                            <td class="text-number">
                                <%= row.getRoleTax() %>
                            </td>

                            <td class="text-number">
                                <%= row.getRoleSanctions() %>
                            </td>

                            <td class="text-number">
                                <%= row.getRoleInterest() %>
                            </td>

                            <td class="text-number">
                                <%= row.getRoleAmount() %>
                            </td>


                            <!-- RISCOSSO -->

                            <td class="text-number">
                                <%= row.getCollectedTax() %>
                            </td>

                            <td class="text-number">
                                <%= row.getCollectedSanctions() %>
                            </td>

                            <td class="text-number">
                                <%= row.getCollectedInterest() %>
                            </td>

                            <td class="text-number">
                                <%= row.getCollectedAmount() %>
                            </td>


                            <!-- RESIDUO -->

                            <td class="text-number">

                                <%= row.getResidual() %>

                            </td>


                            <!-- PERCENTUALE -->

                            <td class="text-number">

                                <% if (row.hasPercentage()) { %>

                                    <%= row.getPercentage() %>%

                                <% } else { %>

                                    -

                                <% } %>

                            </td>


                            <!-- DELETE -->

                            <td class="text-center">

                                <form action="ins-tab-ruoli"
                                      method="post"
                                      class="d-inline"
                                      onsubmit="
                                      return confirm(
                                      'Eliminare questo ruolo?\n' +
                                      'Sarà possibile reinserirlo successivamente.'
                                      );">

                                    <input type="hidden"
                                           name="op"
                                           value="DELETE" />

                                    <input type="hidden"
                                           name="id"
                                           value="<%= row.getId() %>" />


                                    <button type="submit"
                                            class="btn
                                                   btn-sm
                                                   btn-danger"
                                            title="Elimina">

                                        <i class="bi bi-trash-fill"></i>

                                    </button>

                                </form>

                            </td>

                        </tr>

                        <% } %>


                        <!-- =========================================
                             TOTALI GRUPPO
                             ========================================= -->

                        <tr class="totals-row">

                            <td colspan="4">
                            </td>


                            <td>

                                TOTALI TIPOLOGIA

                            </td>


                            <td class="text-number">

                                <%= totals.getRoleTax() %>

                            </td>


                            <td class="text-number">

                                <%= totals.getRoleSanctions() %>

                            </td>


                            <td class="text-number">

                                <%= totals.getRoleInterest() %>

                            </td>


                            <td class="text-number">

                                <%= totals.getRoleAmount() %>

                            </td>


                            <td class="text-number">

                                <%= totals.getCollectedTax() %>

                            </td>


                            <td class="text-number">

                                <%= totals.getCollectedSanctions() %>

                            </td>


                            <td class="text-number">

                                <%= totals.getCollectedInterest() %>

                            </td>


                            <td class="text-number">

                                <%= totals.getCollectedAmount() %>

                            </td>


                            <td class="text-number">

                                <%= totals.getResidual() %>

                            </td>


                            <td class="text-number">

                                <% if (totals.hasAveragePercentage()) { %>

                                    <%= totals.getAveragePercentage() %>%

                                    <small>
                                        (media)
                                    </small>

                                <% } else { %>

                                    -

                                <% } %>

                            </td>


                            <td>
                            </td>

                        </tr>

                    </tbody>

                </table>

            </div>

        </div>


        <% } %>



        <!-- ====================================================
             TOTALI COMPLESSIVI
             ==================================================== -->

        <%

        TotalsData overallTotals =
            pageData.getOverallTotals();

        %>


        <div class="tab-ruoli-group
                    overall-totals-group">


            <div class="tab-ruoli-title">

                <i class="bi bi-calculator-fill"></i>

                <span>
                    TOTALE RUOLI
                </span>

            </div>


            <div class="tab-ruoli-container">

                <table class="table
                              table-bordered
                              table-sm
                              table-ruoli">


                    <thead>

                        <tr>

                            <th colspan="5">

                                TOTALI COMPLESSIVI

                            </th>


                            <th colspan="4"
                                class="table-warning">

                                TOTALI RUOLI COATTIVI

                            </th>


                            <th colspan="4"
                                class="table-secondary">

                                IMPORTI RISCOSSI

                            </th>


                            <th rowspan="2">

                                RESIDUI RUOLI

                                <br />

                                DA RISCUOTERE

                            </th>


                            <th rowspan="2">

                            </th>

                        </tr>


                        <tr>

                            <th colspan="5">

                                TUTTE LE TIPOLOGIE

                            </th>


                            <th>
                                IMPOSTA
                            </th>

                            <th>
                                SANZIONI
                            </th>

                            <th>
                                INTERESSI
                            </th>

                            <th>
                                IMPORTO RUOLO
                            </th>


                            <th>
                                IMPOSTA
                            </th>

                            <th>
                                SANZIONI
                            </th>

                            <th>
                                INTERESSI
                            </th>

                            <th>
                                IMPORTO RISCOSSO
                            </th>

                        </tr>

                    </thead>


                    <tbody>

                        <tr class="totals-row
                                   overall-totals-row">


                            <td colspan="5"
                                class="text-end">

                                TOTALE RUOLI

                            </td>


                            <td class="text-number">

                                <%= overallTotals.getRoleTax() %>

                            </td>


                            <td class="text-number">

                                <%= overallTotals.getRoleSanctions() %>

                            </td>


                            <td class="text-number">

                                <%= overallTotals.getRoleInterest() %>

                            </td>


                            <td class="text-number">

                                <%= overallTotals.getRoleAmount() %>

                            </td>


                            <td class="text-number">

                                <%= overallTotals.getCollectedTax() %>

                            </td>


                            <td class="text-number">

                                <%= overallTotals.getCollectedSanctions() %>

                            </td>


                            <td class="text-number">

                                <%= overallTotals.getCollectedInterest() %>

                            </td>


                            <td class="text-number">

                                <%= overallTotals.getCollectedAmount() %>

                            </td>


                            <td class="text-number">

                                <%= overallTotals.getResidual() %>

                            </td>


                            <td class="text-number">

                                Totale da riscuotere

                            </td>

                        </tr>

                    </tbody>

                </table>

            </div>

        </div>


    <% } %>

</div>



<!-- ============================================================
     CALCOLI
     ============================================================ -->

<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {

        const calculatedFields = [

            "impostaRuolo",

            "interessiRuolo",

            "impostaRiscossa",

            "interessiRiscossi"

        ];


        calculatedFields.forEach(
            function (id) {

                const field =
                    document.getElementById(id);

                if (field) {

                    field.addEventListener(
                        "input",
                        calculateRuolo
                    );

                }

            }
        );


        calculateRuolo();

    }
);



/* ============================================================
   NUMERO DA INPUT
   ============================================================ */

function getNumber(id) {

    const element =
        document.getElementById(id);

    if (!element) {

        return 0;

    }


    const value =
        parseFloat(element.value);


    return Number.isFinite(value)
        ? value
        : 0;

}



/* ============================================================
   SET INPUT NUMERICO
   ============================================================ */

function setNumber(id, value) {

    const element =
        document.getElementById(id);

    if (!element) {

        return;

    }


    const safeValue =
        Number.isFinite(value)
            ? value
            : 0;


    element.value =
        safeValue.toFixed(2);

}



/* ============================================================
   CALCOLO RUOLO
   ============================================================ */

function calculateRuolo() {


    /* RUOLO */

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



    /* RISCOSSO */

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



    /* RESIDUO */

    const residuoDaRiscuotere =
        importoRuolo -
        importoRiscosso;



    /* PERCENTUALE */

    const percentualeRiscosso =
        importoRuolo > 0
            ? (
                importoRiscosso /
                importoRuolo
              ) * 100
            : 0;



    /* OUTPUT */

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