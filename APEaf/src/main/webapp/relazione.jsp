<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>

<%@ page import="is.five.apeaf.service.TabRuoliPageService" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.PageData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.GroupData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.RowData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.TotalsData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService" %>
<%@ page import="is.five.apeaf.dao.*" %>
<%@ page import="is.five.apeaf.dao.model.TabPar" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>


<%@ page import="is.five.apeaf.dao.InsResiduiAttiviDAO" %>
<%@ page import="is.five.apeaf.dao.InsDatiFCDEDAO" %>
<%@ page import="is.five.apeaf.dao.TipologieDAO" %>

<%@ page import="is.five.apeaf.dao.model.InsResiduiAttivi" %>
<%@ page import="is.five.apeaf.dao.model.InsDatiFCDE" %>
<%@ page import="is.five.apeaf.dao.model.Tipologia" %>

<%@ page import="is.five.apeaf.utils.Utils" %>

<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.TreeMap" %>
<%@ page import="java.util.TreeSet" %>
<%@ page import="java.util.List" %>

<%@ page import="is.five.apeaf.service.RiflessiBilancioService" %>
<%@ page import="is.five.apeaf.service.ValutazioneGeneraleService" %>

<%
    session.setAttribute("PAGE", "relazione.jsp");


UserView user =
    (UserView) request.getSession().getAttribute("ubAP");

if (user == null || !user.getActive()) {
    response.sendRedirect("index.jsp");
    return;
}

String selectedYearId =
    session.getAttribute(SessionVariables.ANNO) != null
        ? String.valueOf(
            session.getAttribute(SessionVariables.ANNO)
          )
        : "";

TabRuoliPageService tabRuoliService =
    new TabRuoliPageService();

PageData pageData =
    tabRuoliService.load(
        user,
        selectedYearId
    );

if (!pageData.hasSelectedYear()) {
%>

<div class="alert alert-warning shadow-sm mb-4">
    <i class="bi bi-exclamation-triangle-fill me-2"></i>
    <strong>Anno finanziario non selezionato.</strong>
    Seleziona l'anno finanziario dal menu in alto a destra.
</div>

<%
    return;
}
%>

<%
/* ============================================================
   ANNO FINANZIARIO
   ============================================================ */

Integer anno = null;

try {

    if (selectedYearId != null &&
        !selectedYearId.trim().isEmpty()) {

        AnnoFinanziarioDAO annoDAO =
            new AnnoFinanziarioDAO();

        anno =
            annoDAO
                .findByID(
                    Integer.parseInt(
                        selectedYearId.trim()
                    )
                )
                .getAnno();
    }

} catch (Exception e) {

    anno = null;
}
%>

<%
DecimalFormat formatoItaliano2Decimali =
    new DecimalFormat(
        "#,##0.00",
        DecimalFormatSymbols.getInstance(Locale.ITALY)
    );
%>


<%
ImportiDefinibiliService importiDefinibiliService =
    new ImportiDefinibiliService();

ImportiDefinibiliService.PageData importiPageData =
    importiDefinibiliService.load(
        user,
        selectedYearId
    );
%>

<%
/* ============================================================
   PARAMETRI IPOTESI TAGLI
   ============================================================ */

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
%>


<div class="def-agev-page">

    <h3>
                <i class="bi bi-file-earmark-text me-2"></i>
                DEFINIZIONE AGEVOLATA DEI TRIBUTI LOCALI
 	</h3>
                
                
 <div class="alert alert-warning text-center fw-bold"
     role="alert"
     style="font-size:16px; border:2px solid #ff8f00;">
    <i class="bi bi-exclamation-triangle-fill me-2"></i>
    PAGINA STATICA VALORI NON COMPUTATI - BUILD IN PROGRESS
</div>

    <p class="intro-text">
        <strong>COMUNE DI <%= user.getUsername() %></strong><br>
        PROVINCIA DI ______________________________
    </p>

    <p class="intro-text">
        Premesso che la Legge 30 dicembre 2025 n. 199, all'art. 1,
        commi da 102 a 110, ha previsto la possibilità per gli Enti Locali
        di introdurre l'istituto della definizione agevolata, prevedendo
        l'esclusione o la riduzione delle sanzioni e degli interessi;
    </p>

    <p class="intro-text">
        Considerato che la norma suddetta dispone che l'introduzione
        della definizione agevolata deve tenere conto del rispetto degli
        equilibri di bilancio nonché della situazione economico-finanziaria
        dell'Ente;
    </p>

    <p class="intro-text">
        Considerato altresì che l'introduzione della definizione dovrà
        essere effettuata con apposito regolamento da adottare da parte
        del Consiglio Comunale;
    </p>

    <p class="intro-text">
        Ravvisata l'opportunità, nonché la necessità, di formulare
        un'analisi delle varie entrate del Comune al fine di valutare,
        secondo una serie di parametri, l'impatto sugli equilibri di
        bilancio in caso di applicazione della definizione agevolata.
    </p>

    <p class="intro-text">
        In relazione ai dati resi disponibili dall'Ente si formula
        la seguente analisi.
    </p>


    <!-- ============================================================ -->
    <!-- ANALISI CAPACITA' RISCOSSIONE                                -->
    <!-- ============================================================ -->

    <div class="section-title">
        ANALISI DELLA CAPACITA' DI RISCOSSIONE
    </div>

    <p>
        L'analisi si fonda sulle seguenti Entrate.
    </p>

 
 <% if (!pageData.hasGroups()) { %>

    <div class="alert alert-info">
        Nessun ruolo coattivo memorizzato
        per l'anno <%= pageData.getSelectedYear() %>.
    </div>

<% } else { %>

    <%
    for (GroupData group : pageData.getGroups()) {

        TotalsData totals =
            group.getTotals();
    %>

    <!-- ============================================================
         TIPOLOGIA
         ============================================================ -->

    <div class="section-subtitle">
        <i class="bi bi-tags-fill me-2"></i>
        <%= group.getEntry() %>
    </div>

    <div class="table-responsive">

        <table class="data-table table table-bordered table-hover table-sm">

            <thead>

                <tr>

                    <th rowspan="2">
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

                        IMPORTI RISCOSSI

                    </th>


                    <th rowspan="2">
                        RESIDUI RUOLI<br>
                        DA RISCUOTERE<br>
                        al 31/12/<%= pageData.getSelectedYear() %>
                    </th>


                    <th rowspan="2">
                        % riscosso
                    </th>

                </tr>


                <tr>

                    <!-- RUOLO -->

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
                        Importo ruolo
                    </th>


                    <!-- RISCOSSO -->

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
                        Importo riscosso
                    </th>

                </tr>

            </thead>


            <tbody>

                <%
                for (RowData row : group.getRows()) {
                %>

                <tr>

                    <!-- TIPOLOGIA -->

                    <td class="group-name">
                        <%= row.getEntry() %>
                    </td>


                    <!-- CONCESSIONARIO -->

                    <td>
                        <%= row.getConcessionaire() %>
                    </td>


                    <!-- DATA CONSEGNA -->

                    <td class="center">
                        <%= row.getDeliveryDate() %>
                    </td>


                    <!-- ANNO RUOLO -->

                    <td class="center">
                        <%= row.getRoleYear() %>
                    </td>


                    <!-- NUMERO RUOLO -->

                    <td class="center">
                        <%= row.getRoleNumber() %>
                    </td>


                    <!-- =============================================
                         TOTALI RUOLO
                         ============================================= -->

                    <td class="num money-role">
                        <%= row.getRoleTax() %>
                    </td>

                    <td class="num money-role">
                        <%= row.getRoleSanctions() %>
                    </td>

                    <td class="num money-role">
                        <%= row.getRoleInterest() %>
                    </td>

                    <td class="num money-role fw-bold">
                        <%= row.getRoleAmount() %>
                    </td>


                    <!-- =============================================
                         IMPORTI RISCOSSI
                         ============================================= -->

                    <td class="num money-paid">
                        <%= row.getCollectedTax() %>
                    </td>

                    <td class="num money-paid">
                        <%= row.getCollectedSanctions() %>
                    </td>

                    <td class="num money-paid">
                        <%= row.getCollectedInterest() %>
                    </td>

                    <td class="num money-paid fw-bold">
                        <%= row.getCollectedAmount() %>
                    </td>


                    <!-- =============================================
                         RESIDUO
                         ============================================= -->

                    <td class="num residual">
                        <%= row.getResidual() %>
                    </td>


                    <!-- =============================================
                         PERCENTUALE
                         ============================================= -->

                    <td class="num percentage">

                        <% if (row.hasPercentage()) { %>

                            <%= row.getPercentage() %>%

                        <% } else { %>

                            -

                        <% } %>

                    </td>

                </tr>

                <% } %>


                <!-- =================================================
                     TOTALI TIPOLOGIA
                     ================================================= -->

                <tr class="total-row">

                    <td colspan="4">
                    </td>

                    <td>
                        TOTALI RUOLI
                    </td>


                    <!-- RUOLO -->

                    <td class="num">
                        <%= totals.getRoleTax() %>
                    </td>

                    <td class="num">
                        <%= totals.getRoleSanctions() %>
                    </td>

                    <td class="num">
                        <%= totals.getRoleInterest() %>
                    </td>

                    <td class="num">
                        <%= totals.getRoleAmount() %>
                    </td>


                    <!-- RISCOSSO -->

                    <td class="num">
                        <%= totals.getCollectedTax() %>
                    </td>

                    <td class="num">
                        <%= totals.getCollectedSanctions() %>
                    </td>

                    <td class="num">
                        <%= totals.getCollectedInterest() %>
                    </td>

                    <td class="num">
                        <%= totals.getCollectedAmount() %>
                    </td>


                    <!-- RESIDUO -->

                    <td class="num">
                        <%= totals.getResidual() %>
                    </td>


                    <!-- PERCENTUALE -->

                    <td class="num">

                        <% if (totals.hasAveragePercentage()) { %>

                            <%= totals.getAveragePercentage() %>%

                        <% } else { %>

                            -

                        <% } %>

                    </td>

                </tr>

            </tbody>

        </table>

    </div>

    <% } %>
    
        <%
    TotalsData overallTotals =
        pageData.getOverallTotals();
    %>

    <div class="section-subtitle">
        <i class="bi bi-calculator-fill me-2"></i>
        TOTALI RUOLI
    </div>

    <div class="table-responsive">

        <table class="data-table table table-bordered table-sm">

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

                    <th>
                        RESIDUI RUOLI<br>
                        DA RISCUOTERE
                    </th>

                </tr>

            </thead>


            <tbody>

                <tr class="grand-total">

                    <td colspan="5"
                        class="text-end">

                        TOTALI RUOLI

                    </td>


                    <!-- RUOLI -->

                    <td class="num">
                        <%= overallTotals.getRoleTax() %>
                    </td>

                    <td class="num">
                        <%= overallTotals.getRoleSanctions() %>
                    </td>

                    <td class="num">
                        <%= overallTotals.getRoleInterest() %>
                    </td>

                    <td class="num">
                        <%= overallTotals.getRoleAmount() %>
                    </td>


                    <!-- RISCOSSO -->

                    <td class="num">
                        <%= overallTotals.getCollectedTax() %>
                    </td>

                    <td class="num">
                        <%= overallTotals.getCollectedSanctions() %>
                    </td>

                    <td class="num">
                        <%= overallTotals.getCollectedInterest() %>
                    </td>

                    <td class="num">
                        <%= overallTotals.getCollectedAmount() %>
                    </td>


                    <!-- RESIDUO -->

                    <td class="num">
                        <%= overallTotals.getResidual() %>
                    </td>

                </tr>

            </tbody>

        </table>

    </div>

<% } %>


 
<!-- ============================================================
     VALUTAZIONE DELLA CAPACITA' DI RISCOSSIONE
     ============================================================ -->

<div class="riscossione-analysis">

    <div class="riscossione-title">
        VALUTAZIONE DELLA CAPACITÀ DI RISCOSSIONE
    </div>

    <%
    for (GroupData group : pageData.getGroups()) {

        TotalsData totals = group.getTotals();

        /* La tipologia viene mostrata esattamente come definita */
        String entry = group.getEntry();

        String percentage =
            totals.hasAveragePercentage()
                ? totals.getAveragePercentage()
                : "0,00";

        double p = 0;

        try {
            p = Double.parseDouble(
                percentage
                    .replace(".", "")
                    .replace(",", ".")
            );
        } catch (Exception e) {
            p = 0;
        }

        String valutazione = "";
        String valutazioneClass = "";

        if (p < 20) {

            valutazione = "MOLTO SCARSA";
            valutazioneClass = "riscossione-bad";

        } else if (p < 50) {

            valutazione = "SCARSA";
            valutazioneClass = "riscossione-bad";

        } else if (p < 60) {

            valutazione = "SUFFICIENTE";
            valutazioneClass = "riscossione-medium";

        } else {

            valutazione = "OTTIMA";
            valutazioneClass = "riscossione-good";
        }
    %>

        <div class="riscossione-row">

            <strong class="riscossione-entry">
                <%= entry %>
            </strong>

            <span class="riscossione-text">
                — La percentuale di riscossione su un totale complessivo di €
                <%= totals.getRoleAmount() %>
                risulta pari al
            </span>

            <strong class="riscossione-percent">
                <%= percentage %>%;
            </strong>

            <span class="riscossione-text">
                pertanto la valutazione sulla riscossione è
            </span>

            <strong class="<%= valutazioneClass %>">
                <%= valutazione %>.
            </strong>

        </div>

    <% } %>

</div>







   <!-- ============================================================
     IMPORTI SOGGETTI A DEFINIZIONE AGEVOLATA
     ============================================================ -->

<div class="section-title">
    IMPORTI SOGGETTI A DEFINIZIONE AGEVOLATA
</div>

<p>
    Secondo quanto previsto dalla Legge n. 199/2025 è possibile
    applicare la definizione agevolata per le sanzioni e gli
    interessi, lasciando inalterata la quota capitale.
    Pertanto le somme soggette a un possibile beneficio risultano
    dai seguenti prospetti:
</p>


<% if (!importiPageData.hasGroups()) { %>

    <div class="alert alert-info">
        <i class="bi bi-info-circle-fill me-2"></i>
        Nessun importo definibile disponibile per l'anno
        <strong><%= importiPageData.getSelectedYear() %></strong>.
    </div>

<% } else { %>


    <%
    for (ImportiDefinibiliService.GroupData group :
            importiPageData.getGroups()) {
    %>


        <!-- ========================================================
             TIPOLOGIA
             ======================================================== -->

        <div class="section-subtitle">
            <i class="bi bi-tag-fill me-2"></i>
            <%= group.getEntry() %>
        </div>


        <div class="table-responsive">

            <table class="data-table table table-bordered table-hover table-sm"
                   style="max-width:900px">

                <thead>

                    <tr>

                        <th>
                            TIPOLOGIA
                        </th>

                        <th>
                            Anno ruolo coattivo
                        </th>

                        <th>
                            Num. ruolo
                        </th>

                        <th>
                            IMPOSTA RESIDUA
                        </th>

                        <th>
                            SANZIONI RESIDUE
                        </th>

                        <th>
                            INTERESSI RESIDUI
                        </th>

                        <th>
                            TOTALE
                        </th>

                    </tr>

                </thead>


                <tbody>

                    <%
                    for (ImportiDefinibiliService.RowData row :
                            group.getRows()) {
                    %>

                        <tr>

                            <td class="group-name">
                                <%= row.getEntry() %>
                            </td>

                            <td class="center">
                                <%= row.getRoleYear() %>
                            </td>

                            <td class="center">
                                <%= row.getRoleNumber() %>
                            </td>

                            <td class="num">
                                <%= row.getResidualTax() %>
                            </td>

                            <td class="num">
                                <%= row.getResidualSanctions() %>
                            </td>

                            <td class="num">
                                <%= row.getResidualInterest() %>
                            </td>

                            <td class="num residual">
                                <%= row.getTotal() %>
                            </td>

                        </tr>

                    <% } %>


                    <!-- =============================================
                         TOTALE TIPOLOGIA
                         ============================================= -->

                    <tr class="total-row">

                        <td colspan="3"
                            class="text-end">

                            TOTALE <%= group.getEntry() %>

                        </td>

                        <td class="num">
                            <%= group.getTotalResidualTax() %>
                        </td>

                        <td class="num">
                            <%= group.getTotalResidualSanctions() %>
                        </td>

                        <td class="num">
                            <%= group.getTotalResidualInterest() %>
                        </td>

                        <td class="num">
                            <%= group.getTotalRoleAmount() %>
                        </td>

                    </tr>

                </tbody>

            </table>

        </div>

    <% } %>


    <!-- ============================================================
         TOTALI RUOLI
         ============================================================ -->

    <div class="section-subtitle">
        <i class="bi bi-calculator-fill me-2"></i>
        TOTALI RUOLI
    </div>


    <div class="table-responsive">

        <table class="data-table table table-bordered table-sm"
               style="max-width:900px">

            <thead>

                <tr>

                    <th>
                        IMPOSTA RESIDUA
                    </th>

                    <th>
                        SANZIONI RESIDUE
                    </th>

                    <th>
                        INTERESSI RESIDUI
                    </th>

                    <th>
                        IMPORTO RUOLO
                    </th>

                </tr>

            </thead>


            <tbody>

                <tr class="grand-total">

                    <td class="num">
                        <%= importiPageData.getTotalResidualTax() %>
                    </td>

                    <td class="num">
                        <%= importiPageData.getTotalResidualSanctions() %>
                    </td>

                    <td class="num">
                        <%= importiPageData.getTotalResidualInterest() %>
                    </td>

                    <td class="num">
                        <%= importiPageData.getTotalRoleAmount() %>
                    </td>

                </tr>

            </tbody>

        </table>

    </div>

<% } %>



<!-- ============================================================
     VALUTAZIONE IPOTESI TAGLI SANZIONI ED INTERESSI
     ============================================================ -->

<div class="section-title mt-4">
    VALUTAZIONE IPOTESI TAGLI SANZIONI ED INTERESSI
</div>

<p class="mt-3 mb-4">
    Si è proceduto a formulare una proiezione di taglio di
    sanzioni ed interessi basata sui parametri definiti:
</p>


<div class="row g-4">

    <!-- ========================================================
         SANZIONI
         ======================================================== -->

    <div class="col-md-6">

        <table class="table table-bordered table-sm text-center
                      align-middle ipotesi-table">

            <thead>

                <tr>
                    <th colspan="3" class="ipotesi-main-title">
                        % TAGLIO SANZIONI
                    </th>
                </tr>

                <tr>
                    <th>IPOTESI 1</th>
                    <th>IPOTESI 2</th>
                    <th>IPOTESI 3</th>
                </tr>

            </thead>

            <tbody>

                <tr class="ipotesi-values">

                    <% for (int i = 0; i < 3; i++) { %>

                        <td>

                            <% if (valoriSanzione != null &&
                                   i < valoriSanzione.size()) { %>

                                <%= valoriSanzione.get(i).getValue() %>

                            <% } else { %>

                                -

                            <% } %>

                        </td>

                    <% } %>

                </tr>

            </tbody>

        </table>

    </div>


    <!-- ========================================================
         INTERESSI
         ======================================================== -->

    <div class="col-md-6">

        <table class="table table-bordered table-sm text-center
                      align-middle ipotesi-table">

            <thead>

                <tr>
                    <th colspan="3" class="ipotesi-main-title">
                        % TAGLIO INTERESSI
                    </th>
                </tr>

                <tr>
                    <th>IPOTESI 1</th>
                    <th>IPOTESI 2</th>
                    <th>IPOTESI 3</th>
                </tr>

            </thead>

            <tbody>

                <tr class="ipotesi-values">

                    <% for (int i = 0; i < 3; i++) { %>

                        <td>

                            <% if (valoriInteressi != null &&
                                   i < valoriInteressi.size()) { %>

                                <%= valoriInteressi.get(i).getValue() %>

                            <% } else { %>

                                -

                            <% } %>

                        </td>

                    <% } %>

                </tr>

            </tbody>

        </table>

    </div>

</div>


<!-- ============================================================
     PROIEZIONE TAGLI SANZIONI ED INTERESSI
     ============================================================ -->

<p class="mt-4 mb-4">
    Dalle entrate in riscossione si è formulata una prima proiezione
    di tagli come ampiamente illustrato nella tabella che segue:
</p>

<%
/* ============================================================
   VERIFICA PARAMETRI
   ============================================================ */

boolean parametriTagliCompleti =
        valoriSanzione != null
        && valoriSanzione.size() >= 3
        && valoriInteressi != null
        && valoriInteressi.size() >= 3;


/* ============================================================
   TOTALI TAGLI
   ============================================================ */

double totTagliSanzioni1 = 0d;
double totTagliSanzioni2 = 0d;
double totTagliSanzioni3 = 0d;

double totTagliInteressi1 = 0d;
double totTagliInteressi2 = 0d;
double totTagliInteressi3 = 0d;
%>


<% if (!parametriTagliCompleti) { %>

    <!-- ========================================================
         PARAMETRI NON COMPLETI
         ======================================================== -->

    <div class="alert alert-warning">

        <i class="bi bi-exclamation-triangle-fill me-2"></i>

        Per elaborare la proiezione devono essere definiti
        <strong>3 parametri di taglio sanzioni</strong> e
        <strong>3 parametri di taglio interessi</strong>.

    </div>

<% } else if (importiPageData == null || !importiPageData.hasGroups()) { %>

    <!-- ========================================================
         NESSUN DATO
         ======================================================== -->

    <div class="alert alert-info">

        <i class="bi bi-info-circle-fill me-2"></i>

        Nessun importo disponibile per elaborare
        la proiezione dei tagli.

    </div>

<% } else { %>


<div class="table-responsive">

    <table class="tagli-report-table">

        <thead>

            <!-- =================================================
                 SANZIONI / INTERESSI
                 ================================================= -->

            <tr>

                <th   colspan="2"></th>

                <th class="tagli-sanzioni-header" colspan="3">
                    SANZIONI
                </th>

                <th class="tagli-interessi-header" colspan="3">
                    INTERESSI
                </th>

            </tr>


            <!-- =================================================
                 DESCRIZIONE IPOTESI
                 ================================================= -->

            <tr>

                <th class="" colspan="2"></th>

                <th class="tagli-sanzioni-header">
                    % taglio (1^ ipotesi)
                </th>

                <th class="tagli-sanzioni-header">
                    % taglio (2^ ipotesi)
                </th>

                <th class="tagli-sanzioni-header">
                    % taglio (3^ ipotesi)
                </th>


                <th class="tagli-interessi-header">
                    % taglio (1^ ipotesi)
                </th>

                <th class="tagli-interessi-header">
                    % taglio (2^ ipotesi)
                </th>

                <th class="tagli-interessi-header">
                    % taglio (3^ ipotesi)
                </th>

            </tr>


            <!-- =================================================
                 VALORI PARAMETRI
                 ================================================= -->

            <tr>

                <th class=""></th>

                <th class="tagli-tipologia-header">
                    TIPOLOGIA
                </th>


                <!-- SANZIONI -->

                <th class="tagli-sanzioni-header">
                    <%= valoriSanzione.get(0).getValue() %>
                </th>

                <th class="tagli-sanzioni-header">
                    <%= valoriSanzione.get(1).getValue() %>
                </th>

                <th class="tagli-sanzioni-header">
                    <%= valoriSanzione.get(2).getValue() %>
                </th>


                <!-- INTERESSI -->

                <th class="tagli-interessi-header">
                    <%= valoriInteressi.get(0).getValue() %>
                </th>

                <th class="tagli-interessi-header">
                    <%= valoriInteressi.get(1).getValue() %>
                </th>

                <th class="tagli-interessi-header">
                    <%= valoriInteressi.get(2).getValue() %>
                </th>

            </tr>

        </thead>


        <tbody>

        <%
        /* ========================================================
           CICLO TIPOLOGIE

           Usiamo direttamente gli stessi gruppi già caricati
           tramite ImportiDefinibiliService.
           ======================================================== */

        for (ImportiDefinibiliService.GroupData group :
                importiPageData.getGroups()) {


            /* ====================================================
               RESIDUI DELLA TIPOLOGIA
               ==================================================== */

            double sanzioniResidue =
                    group.getTotalResidualSanctionsBD()
                         .doubleValue();

            double interessiResidui =
                    group.getTotalResidualInterestBD()
                         .doubleValue();


            /* ====================================================
               PARAMETRI SANZIONI
               ==================================================== */

            double parametroSanzioni1 =
                    valoriSanzione.get(0)
                                  .getValue()
                                  .doubleValue();

            double parametroSanzioni2 =
                    valoriSanzione.get(1)
                                  .getValue()
                                  .doubleValue();

            double parametroSanzioni3 =
                    valoriSanzione.get(2)
                                  .getValue()
                                  .doubleValue();


            /* ====================================================
               PARAMETRI INTERESSI
               ==================================================== */

            double parametroInteressi1 =
                    valoriInteressi.get(0)
                                   .getValue()
                                   .doubleValue();

            double parametroInteressi2 =
                    valoriInteressi.get(1)
                                   .getValue()
                                   .doubleValue();

            double parametroInteressi3 =
                    valoriInteressi.get(2)
                                   .getValue()
                                   .doubleValue();


            /* ====================================================
               CALCOLO TAGLI SANZIONI
               ==================================================== */

            double taglioSanzioni1 =
                    sanzioniResidue
                    * parametroSanzioni1
                    / 100d;

            double taglioSanzioni2 =
                    sanzioniResidue
                    * parametroSanzioni2
                    / 100d;

            double taglioSanzioni3 =
                    sanzioniResidue
                    * parametroSanzioni3
                    / 100d;


            /* ====================================================
               CALCOLO TAGLI INTERESSI
               ==================================================== */

            double taglioInteressi1 =
                    interessiResidui
                    * parametroInteressi1
                    / 100d;

            double taglioInteressi2 =
                    interessiResidui
                    * parametroInteressi2
                    / 100d;

            double taglioInteressi3 =
                    interessiResidui
                    * parametroInteressi3
                    / 100d;


            /* ====================================================
               TOTALI GENERALI
               ==================================================== */

            totTagliSanzioni1 += taglioSanzioni1;
            totTagliSanzioni2 += taglioSanzioni2;
            totTagliSanzioni3 += taglioSanzioni3;

            totTagliInteressi1 += taglioInteressi1;
            totTagliInteressi2 += taglioInteressi2;
            totTagliInteressi3 += taglioInteressi3;
        %>


            <tr>

                <!-- =============================================
                     DESCRIZIONE
                     ============================================= -->

                <td class="tagli-description">

                    MINORI RESIDUI<br>
                    ATTIVI

                </td>


                <!-- =============================================
                     TIPOLOGIA
                     ============================================= -->

                <td class="tagli-tipologia">

                    <%= group.getEntry() %>

                </td>


                <!-- =============================================
                     SANZIONI
                     ============================================= -->

                <td class="tagli-number tagli-sanzioni">

                    <%= formatoItaliano2Decimali.format(
                            taglioSanzioni1
                        ) %>

                </td>

                <td class="tagli-number tagli-sanzioni">

                    <%= formatoItaliano2Decimali.format(
                            taglioSanzioni2
                        ) %>

                </td>

                <td class="tagli-number tagli-sanzioni">

                    <%= formatoItaliano2Decimali.format(
                            taglioSanzioni3
                        ) %>

                </td>


                <!-- =============================================
                     INTERESSI
                     ============================================= -->

                <td class="tagli-number tagli-interessi">

                    <%= formatoItaliano2Decimali.format(
                            taglioInteressi1
                        ) %>

                </td>

                <td class="tagli-number tagli-interessi">

                    <%= formatoItaliano2Decimali.format(
                            taglioInteressi2
                        ) %>

                </td>

                <td class="tagli-number tagli-interessi">

                    <%= formatoItaliano2Decimali.format(
                            taglioInteressi3
                        ) %>

                </td>

            </tr>

        <%
        }
        %>


            <!-- =================================================
                 TOTALI TAGLI RESIDUI
                 ================================================= -->

            <tr class="tagli-total-row">

                <td></td>

                <td class="tagli-total-label">

                    TOTALI TAGLI<br>
                    RESIDUI

                </td>


                <!-- SANZIONI -->

                <td class="tagli-number tagli-sanzioni">

                    <%= formatoItaliano2Decimali.format(
                            totTagliSanzioni1
                        ) %>

                </td>

                <td class="tagli-number tagli-sanzioni">

                    <%= formatoItaliano2Decimali.format(
                            totTagliSanzioni2
                        ) %>

                </td>

                <td class="tagli-number tagli-sanzioni">

                    <%= formatoItaliano2Decimali.format(
                            totTagliSanzioni3
                        ) %>

                </td>


                <!-- INTERESSI -->

                <td class="tagli-number tagli-interessi">

                    <%= formatoItaliano2Decimali.format(
                            totTagliInteressi1
                        ) %>

                </td>

                <td class="tagli-number tagli-interessi">

                    <%= formatoItaliano2Decimali.format(
                            totTagliInteressi2
                        ) %>

                </td>

                <td class="tagli-number tagli-interessi">

                    <%= formatoItaliano2Decimali.format(
                            totTagliInteressi3
                        ) %>

                </td>

            </tr>

        </tbody>

    </table>

</div>

<%
}
%>


<!-- ============================================================
     CALCOLO % ACCANTONAMENTO FCDE
     ============================================================ -->

<%
/* ============================================================
   TIPOLOGIE DEFINITE PER L'ANNO
   ============================================================ */

List<Tipologia> tipologieFcde =
    TipologieDAO.findByUserAndAnno(
        user.getId(),
        anno
    );

Set<String> tipologieValideFcde =
    new TreeSet<String>(
        String.CASE_INSENSITIVE_ORDER
    );

if (tipologieFcde != null) {

    for (Tipologia tipologia : tipologieFcde) {

        if (tipologia == null ||
            tipologia.getValue() == null) {

            continue;
        }

        String nome =
            tipologia.getValue().trim();

        if (!nome.isEmpty()) {
            tipologieValideFcde.add(nome);
        }
    }
}


/* ============================================================
   LETTURA DATI
   ============================================================ */

InsResiduiAttivi residuiAttiviFcde =
    InsResiduiAttiviDAO.findByUserAndAnno(
        user.getId(),
        anno
    );

InsDatiFCDE datiFcdeReport =
    InsDatiFCDEDAO.findByUserAndAnno(
        user.getId(),
        anno
    );


Map<String, BigDecimal> residuiFcdeMap =
    new TreeMap<String, BigDecimal>(
        String.CASE_INSENSITIVE_ORDER
    );

Map<String, BigDecimal> fcdeReportMap =
    new TreeMap<String, BigDecimal>(
        String.CASE_INSENSITIVE_ORDER
    );


/* ============================================================
   RESIDUI ATTIVI

   Supporta:
   - nuovo formato: ICI=150000;TASI=15000;...
   - vecchio formato posizionale
   ============================================================ */

if (residuiAttiviFcde != null &&
    residuiAttiviFcde.getValue() != null &&
    !residuiAttiviFcde.getValue().trim().isEmpty()) {

    String[] tokens =
        residuiAttiviFcde
            .getValue()
            .trim()
            .split(";", -1);

    boolean nuovoFormato = false;

    for (String token : tokens) {

        if (token != null &&
            token.contains("=")) {

            nuovoFormato = true;
            break;
        }
    }


    /* ========================================================
       NUOVO FORMATO
       ======================================================== */

    if (nuovoFormato) {

        for (String token : tokens) {

            if (token == null) {
                continue;
            }

            token = token.trim();

            if (token.isEmpty() ||
                !token.contains("=")) {

                continue;
            }

            String[] parts =
                token.split("=", 2);

            String nome =
                parts[0] != null
                    ? parts[0].trim()
                    : "";

            String valoreString =
                parts.length > 1 &&
                parts[1] != null
                    ? parts[1].trim()
                    : "0";

            if (nome.isEmpty() ||
                !tipologieValideFcde.contains(nome)) {

                continue;
            }

            BigDecimal valore =
                BigDecimal.ZERO;

            try {

                BigDecimal parsed =
                    Utils.parseItalianNumber(
                        valoreString
                    );

                if (parsed != null) {
                    valore = parsed;
                }

            } catch (Exception e) {
                valore = BigDecimal.ZERO;
            }

            residuiFcdeMap.put(
                nome,
                valore
            );
        }

    } else {

        /* ====================================================
           VECCHIO FORMATO POSIZIONALE
           ==================================================== */

        int posizione = 0;

        for (String token : tokens) {

            if (posizione >=
                InsResiduiAttivi.TIPOLOGIE.length) {

                break;
            }

            String nome =
                InsResiduiAttivi
                    .TIPOLOGIE[posizione];

            posizione++;

            if (nome == null) {
                continue;
            }

            nome = nome.trim();

            if (nome.isEmpty() ||
                !tipologieValideFcde.contains(nome)) {

                continue;
            }

            BigDecimal valore =
                BigDecimal.ZERO;

            try {

                if (token != null &&
                    !token.trim().isEmpty()) {

                    BigDecimal parsed =
                        Utils.parseItalianNumber(
                            token.trim()
                        );

                    if (parsed != null) {
                        valore = parsed;
                    }
                }

            } catch (Exception e) {
                valore = BigDecimal.ZERO;
            }

            residuiFcdeMap.put(
                nome,
                valore
            );
        }
    }
}


/* ============================================================
   DATI FCDE

   Supporta:
   - nuovo formato: ICI=110000;TASI=12000;...
   - vecchio formato posizionale
   ============================================================ */

if (datiFcdeReport != null &&
    datiFcdeReport.getValue() != null &&
    !datiFcdeReport.getValue().trim().isEmpty()) {

    String[] tokens =
        datiFcdeReport
            .getValue()
            .split(";", -1);

    int posizioneLegacy = 0;

    for (String token : tokens) {

        if (token == null) {
            continue;
        }

        token = token.trim();

        if (token.isEmpty()) {
            continue;
        }


        /* ====================================================
           NUOVO FORMATO
           ==================================================== */

        if (token.contains("=")) {

            String[] parts =
                token.split("=", 2);

            String nome =
                parts[0] != null
                    ? parts[0].trim()
                    : "";

            String valoreString =
                parts.length > 1 &&
                parts[1] != null
                    ? parts[1].trim()
                    : "0";

            if (nome.isEmpty() ||
                !tipologieValideFcde.contains(nome)) {

                continue;
            }

            BigDecimal valore =
                BigDecimal.ZERO;

            try {

                BigDecimal parsed =
                    Utils.parseItalianNumber(
                        valoreString
                    );

                if (parsed != null) {
                    valore = parsed;
                }

            } catch (Exception e) {
                valore = BigDecimal.ZERO;
            }

            fcdeReportMap.put(
                nome,
                valore
            );

        } else {

            /* =================================================
               VECCHIO FORMATO
               ================================================= */

            if (InsDatiFCDE.TIPOLOGIE != null &&
                posizioneLegacy <
                    InsDatiFCDE.TIPOLOGIE.length) {

                String nome =
                    InsDatiFCDE
                        .TIPOLOGIE[posizioneLegacy];

                if (nome != null) {

                    nome = nome.trim();

                    if (!nome.isEmpty() &&
                        tipologieValideFcde.contains(nome)) {

                        BigDecimal valore =
                            BigDecimal.ZERO;

                        try {

                            BigDecimal parsed =
                                Utils.parseItalianNumber(
                                    token
                                );

                            if (parsed != null) {
                                valore = parsed;
                            }

                        } catch (Exception e) {
                            valore = BigDecimal.ZERO;
                        }

                        fcdeReportMap.put(
                            nome,
                            valore
                        );
                    }
                }
            }

            posizioneLegacy++;
        }
    }
}


/* ============================================================
   TOTALI
   ============================================================ */

BigDecimal totaleResiduiFcde =
    BigDecimal.ZERO;

BigDecimal totaleFcdeReport =
    BigDecimal.ZERO;
%>


<p class="mt-4 mb-4">
    Si procede ora ad individuare la percentuale media di
    accantonamento ad FCDE per ogni tipologia di Entrata.
</p>


<div class="table-responsive">

    <table class="fcde-report-table">

        <thead>

            <tr>
                <th colspan="4"
                    class="fcde-report-main-title">

                    CALCOLO % ACCANTONAMENTO FCDE

                </th>
            </tr>

            <tr>

                <th>
                    TIPOLOGIA ENTRATA
                </th>

                <th>
                    RESIDUI ATTIVI
                </th>

                <th>
                    FCDE
                </th>

                <th>
                    % ACCANTONAMENTO
                </th>

            </tr>

        </thead>


        <tbody>

        <%
        for (String tipologia :
                tipologieValideFcde) {

            BigDecimal residuo =
                residuiFcdeMap.get(tipologia);

            if (residuo == null) {
                residuo = BigDecimal.ZERO;
            }

            BigDecimal fcde =
                fcdeReportMap.get(tipologia);

            if (fcde == null) {
                fcde = BigDecimal.ZERO;
            }


            /* ====================================================
               % ACCANTONAMENTO = FCDE / RESIDUI * 100
               ==================================================== */

            BigDecimal percentualeAccantonamento =
                BigDecimal.ZERO;

            if (residuo.compareTo(
                    BigDecimal.ZERO) != 0) {

                percentualeAccantonamento =
                    fcde
                        .multiply(
                            BigDecimal.valueOf(100)
                        )
                        .divide(
                            residuo,
                            2,
                            RoundingMode.HALF_UP
                        );
            }


            totaleResiduiFcde =
                totaleResiduiFcde.add(residuo);

            totaleFcdeReport =
                totaleFcdeReport.add(fcde);
        %>

            <tr>

                <td class="fcde-tipologia">
                    <%= tipologia %>
                </td>

                <td class="fcde-number fcde-residui">
                    <%= formatoItaliano2Decimali.format(
                            residuo
                        ) %>
                </td>

                <td class="fcde-number">
                    <%= formatoItaliano2Decimali.format(
                            fcde
                        ) %>
                </td>

                <td class="fcde-number fcde-percentuale">
                    <%= formatoItaliano2Decimali.format(
                            percentualeAccantonamento
                        ) %>
                </td>

            </tr>

        <% } %>


            <!-- =================================================
                 TOTALI
                 ================================================= -->

            <tr class="fcde-total-row">

                <td></td>

                <td class="fcde-number">
                    <%= formatoItaliano2Decimali.format(
                            totaleResiduiFcde
                        ) %>
                </td>

                <td class="fcde-number">
                    <%= formatoItaliano2Decimali.format(
                            totaleFcdeReport
                        ) %>
                </td>

                <td></td>

            </tr>

        </tbody>

    </table>

</div>


 <!-- ============================================================
     QUOTA FCDE LIBERATA
     ============================================================ -->

<p class="mt-4 mb-4">
    In base alla percentuale di abbattimento delle sanzioni ed interessi
    la quota di FCDE liberata in sede di applicazione risulta la seguente:
</p>

<%
/* ============================================================
   TOTALI
   ============================================================ */

BigDecimal totaleFcdeAccantonata =
        BigDecimal.ZERO;

BigDecimal totaleFcdeResidua1 =
        BigDecimal.ZERO;

BigDecimal totaleFcdeResidua2 =
        BigDecimal.ZERO;

BigDecimal totaleFcdeResidua3 =
        BigDecimal.ZERO;

BigDecimal totaleFcdeLiberata1 =
        BigDecimal.ZERO;

BigDecimal totaleFcdeLiberata2 =
        BigDecimal.ZERO;

BigDecimal totaleFcdeLiberata3 =
        BigDecimal.ZERO;


/* ============================================================
   PARAMETRI IPOTESI

   Le tre ipotesi sono quelle già definite in tab-parametri.
   ============================================================ */

BigDecimal parametroSanzione1 =
        valoriSanzione.get(0).getValue();

BigDecimal parametroSanzione2 =
        valoriSanzione.get(1).getValue();

BigDecimal parametroSanzione3 =
        valoriSanzione.get(2).getValue();

BigDecimal parametroInteresse1 =
        valoriInteressi.get(0).getValue();

BigDecimal parametroInteresse2 =
        valoriInteressi.get(1).getValue();

BigDecimal parametroInteresse3 =
        valoriInteressi.get(2).getValue();
%>


<div class="table-responsive">

<table class="fcde-liberata-table">

    <thead>

        <!-- ====================================================
             HEADER SUPERIORE
             ==================================================== -->

        <tr>

            <th class=""
                colspan="3">
            </th>

            <th class="fcde-lib-group-residuo"
                colspan="3">
                SANZIONI+INTERESSI
            </th>

            <th class="fcde-lib-group-liberata"
                colspan="3">
                QUOTA FCDE LIBERATA
            </th>

        </tr>


        <!-- ====================================================
             HEADER COLONNE
             ==================================================== -->

        <tr>

            <th>
                ENTRATA
            </th>

            <th>
                Quota FCDE<br>
                accantonata a<br>
                consuntivo
            </th>

            <th>
                % FCDE
            </th>


            <!-- FCDE DOPO TAGLIO -->

            <th>
                <%= parametroSanzione1 %>
            </th>

            <th>
                <%= parametroSanzione2 %>
            </th>

            <th>
                <%= parametroSanzione3 %>
            </th>


            <!-- FCDE LIBERATA -->

            <th>
                <%= parametroSanzione1 %>
            </th>

            <th>
                <%= parametroSanzione2 %>
            </th>

            <th>
                <%= parametroSanzione3 %>
            </th>

        </tr>

    </thead>


    <tbody>

    <%
    for (ImportiDefinibiliService.GroupData group :
            importiPageData.getGroups()) {

        String tipologia =
                group.getEntry();


        /* ========================================================
           FCDE DELLA TIPOLOGIA
           ======================================================== */

        BigDecimal fcdeAccantonata =
                fcdeReportMap.get(tipologia);

        if (fcdeAccantonata == null) {
            fcdeAccantonata =
                    BigDecimal.ZERO;
        }


        BigDecimal residuoAttivo =
                residuiFcdeMap.get(tipologia);

        if (residuoAttivo == null) {
            residuoAttivo =
                    BigDecimal.ZERO;
        }


        /* ========================================================
           % FCDE

           FCDE / RESIDUI ATTIVI * 100
           ======================================================== */

        BigDecimal percentualeFcde =
                BigDecimal.ZERO;

        if (residuoAttivo.compareTo(
                BigDecimal.ZERO) != 0) {

            percentualeFcde =
                    fcdeAccantonata
                        .multiply(
                            BigDecimal.valueOf(100)
                        )
                        .divide(
                            residuoAttivo,
                            10,
                            RoundingMode.HALF_UP
                        );
        }


        /* ========================================================
           SANZIONI / INTERESSI RESIDUI
           ======================================================== */

        BigDecimal sanzioniResidue =
                group.getTotalResidualSanctionsBD();

        BigDecimal interessiResidui =
                group.getTotalResidualInterestBD();


        /* ========================================================
           TAGLI IPOTESI 1
           ======================================================== */

        BigDecimal taglioSanzioni1BD =
                sanzioniResidue
                    .multiply(parametroSanzione1)
                    .divide(
                        BigDecimal.valueOf(100),
                        10,
                        RoundingMode.HALF_UP
                    );

        BigDecimal taglioInteressi1BD =
                interessiResidui
                    .multiply(parametroInteresse1)
                    .divide(
                        BigDecimal.valueOf(100),
                        10,
                        RoundingMode.HALF_UP
                    );


        /* ========================================================
           TAGLI IPOTESI 2
           ======================================================== */

        BigDecimal taglioSanzioni2BD =
                sanzioniResidue
                    .multiply(parametroSanzione2)
                    .divide(
                        BigDecimal.valueOf(100),
                        10,
                        RoundingMode.HALF_UP
                    );

        BigDecimal taglioInteressi2BD =
                interessiResidui
                    .multiply(parametroInteresse2)
                    .divide(
                        BigDecimal.valueOf(100),
                        10,
                        RoundingMode.HALF_UP
                    );


        /* ========================================================
           TAGLI IPOTESI 3
           ======================================================== */

        BigDecimal taglioSanzioni3BD =
                sanzioniResidue
                    .multiply(parametroSanzione3)
                    .divide(
                        BigDecimal.valueOf(100),
                        10,
                        RoundingMode.HALF_UP
                    );

        BigDecimal taglioInteressi3BD =
                interessiResidui
                    .multiply(parametroInteresse3)
                    .divide(
                        BigDecimal.valueOf(100),
                        10,
                        RoundingMode.HALF_UP
                    );


        /* ========================================================
           TAGLIO COMPLESSIVO SANZIONI + INTERESSI
           ======================================================== */

        BigDecimal taglioTotale1 =
                taglioSanzioni1BD
                    .add(taglioInteressi1BD);

        BigDecimal taglioTotale2 =
                taglioSanzioni2BD
                    .add(taglioInteressi2BD);

        BigDecimal taglioTotale3 =
                taglioSanzioni3BD
                    .add(taglioInteressi3BD);


        /* ========================================================
           QUOTA FCDE LIBERATA

           taglio complessivo * % FCDE
           ======================================================== */

        BigDecimal quotaLiberata1 =
                taglioTotale1
                    .multiply(percentualeFcde)
                    .divide(
                        BigDecimal.valueOf(100),
                        2,
                        RoundingMode.HALF_UP
                    );

        BigDecimal quotaLiberata2 =
                taglioTotale2
                    .multiply(percentualeFcde)
                    .divide(
                        BigDecimal.valueOf(100),
                        2,
                        RoundingMode.HALF_UP
                    );

        BigDecimal quotaLiberata3 =
                taglioTotale3
                    .multiply(percentualeFcde)
                    .divide(
                        BigDecimal.valueOf(100),
                        2,
                        RoundingMode.HALF_UP
                    );


        /* ========================================================
           FCDE RESIDUO DOPO LA LIBERAZIONE
           ======================================================== */

        BigDecimal fcdeResidua1 =
                fcdeAccantonata
                    .subtract(quotaLiberata1);

        BigDecimal fcdeResidua2 =
                fcdeAccantonata
                    .subtract(quotaLiberata2);

        BigDecimal fcdeResidua3 =
                fcdeAccantonata
                    .subtract(quotaLiberata3);


        /* ========================================================
           TOTALI
           ======================================================== */

        totaleFcdeAccantonata =
                totaleFcdeAccantonata
                    .add(fcdeAccantonata);

        totaleFcdeResidua1 =
                totaleFcdeResidua1
                    .add(fcdeResidua1);

        totaleFcdeResidua2 =
                totaleFcdeResidua2
                    .add(fcdeResidua2);

        totaleFcdeResidua3 =
                totaleFcdeResidua3
                    .add(fcdeResidua3);

        totaleFcdeLiberata1 =
                totaleFcdeLiberata1
                    .add(quotaLiberata1);

        totaleFcdeLiberata2 =
                totaleFcdeLiberata2
                    .add(quotaLiberata2);

        totaleFcdeLiberata3 =
                totaleFcdeLiberata3
                    .add(quotaLiberata3);
    %>


        <tr>

            <!-- ENTRATA -->

            <td class="fcde-lib-entry">
                <%= tipologia %>
            </td>


            <!-- FCDE ACCANTONATA -->

            <td class="fcde-lib-number fcde-lib-base">
                <%= formatoItaliano2Decimali.format(
                        fcdeAccantonata
                    ) %>
            </td>


            <!-- % FCDE -->

            <td class="fcde-lib-number fcde-lib-base">

                <%= formatoItaliano2Decimali.format(
                        percentualeFcde
                    ) %>

            </td>


            <!-- =============================================
                 FCDE RESIDUA
                 ============================================= -->

            <td class="fcde-lib-number fcde-lib-base">
                <%= formatoItaliano2Decimali.format(
                        fcdeResidua1
                    ) %>
            </td>

            <td class="fcde-lib-number fcde-lib-base">
                <%= formatoItaliano2Decimali.format(
                        fcdeResidua2
                    ) %>
            </td>

            <td class="fcde-lib-number fcde-lib-base">
                <%= formatoItaliano2Decimali.format(
                        fcdeResidua3
                    ) %>
            </td>


            <!-- =============================================
                 FCDE LIBERATA
                 ============================================= -->

            <td class="fcde-lib-number fcde-lib-liberata">
                <%= formatoItaliano2Decimali.format(
                        quotaLiberata1
                    ) %>
            </td>

            <td class="fcde-lib-number fcde-lib-liberata">
                <%= formatoItaliano2Decimali.format(
                        quotaLiberata2
                    ) %>
            </td>

            <td class="fcde-lib-number fcde-lib-liberata">
                <%= formatoItaliano2Decimali.format(
                        quotaLiberata3
                    ) %>
            </td>

        </tr>

    <%
    }
    %>


        <!-- ====================================================
             TOTALI
             ==================================================== -->

        <tr class="fcde-lib-total">

            <td>
                TOTALI
            </td>

            <td class="fcde-lib-number">
                <%= formatoItaliano2Decimali.format(
                        totaleFcdeAccantonata
                    ) %>
            </td>

            <td class="fcde-lib-number">
                0
            </td>


            <!-- FCDE RESIDUA -->

            <td class="fcde-lib-number">
                <%= formatoItaliano2Decimali.format(
                        totaleFcdeResidua1
                    ) %>
            </td>

            <td class="fcde-lib-number">
                <%= formatoItaliano2Decimali.format(
                        totaleFcdeResidua2
                    ) %>
            </td>

            <td class="fcde-lib-number">
                <%= formatoItaliano2Decimali.format(
                        totaleFcdeResidua3
                    ) %>
            </td>


            <!-- FCDE LIBERATA -->

            <td class="fcde-lib-number fcde-lib-highlight">
                <%= formatoItaliano2Decimali.format(
                        totaleFcdeLiberata1
                    ) %>
            </td>

            <td class="fcde-lib-number fcde-lib-highlight">
                <%= formatoItaliano2Decimali.format(
                        totaleFcdeLiberata2
                    ) %>
            </td>

            <td class="fcde-lib-number fcde-lib-highlight">
                <%= formatoItaliano2Decimali.format(
                        totaleFcdeLiberata3
                    ) %>
            </td>

        </tr>

    </tbody>

</table>

</div>

 




     <%
/* ============================================================
   RIFLESSI SUL BILANCIO
   ============================================================ */

RiflessiBilancioService riflessiBilancioService =
        new RiflessiBilancioService();

RiflessiBilancioService.ViewData riflessiViewData =
        riflessiBilancioService.load(
                user,
                selectedYearId
        );
%>
     

<p class="mt-5 mb-4">
    Considerato che i tagli di sanzioni ed interessi hanno un riflesso
    negativo sul Risultato di Amministrazione, mentre la riduzione del
    FCDE ha un riflesso positivo sul Risultato di Amministrazione,
    di seguito si evidenzia la proiezione dei saldi.
</p>


<%
if (riflessiViewData != null &&
    riflessiViewData.getRows() != null &&
    !riflessiViewData.getRows().isEmpty()) {
%>


<!-- ============================================================
     HEADER IPOTESI
     ============================================================ -->

<div class="riflessi-report-header">

    <table>

        <tr>
            <th colspan="<%= riflessiViewData.getHypothesisLabels().size() %>">
                IPOTESI TAGLIO SANZIONI+INTERESSI
            </th>
        </tr>

        <tr>

            <%
            for (String percentage :
                    riflessiViewData.getHypothesisLabels()) {
            %>

                <td>
                    <%= percentage %>
                </td>

            <% } %>

        </tr>

    </table>

</div>


<!-- ============================================================
     TIPOLOGIE
     ============================================================ -->

<%
for (RiflessiBilancioService.RowData row :
        riflessiViewData.getRows()) {
%>


<div class="riflessi-report-group">

    <table class="riflessi-report-table">


        <!-- ====================================================
             TITOLO TIPOLOGIA
             ==================================================== -->

        <tr>

            <th class="riflessi-entry-title">

                <%= row.getEntry() %>

            </th>

            
            <%
            for (String percentage :
                    riflessiViewData.getHypothesisLabels()) {
            %>

                <td  class="valutazione-report-value">
                    <%= percentage %>
                </td>

            <% } %>

        </tr>


        <!-- ====================================================
             RESIDUI ATTIVI
             ==================================================== -->

        <tr>

            <td class="riflessi-description">
                RESIDUI ATTIVI
            </td>

            <%
            for (String value :
                    row.getResidualValues()) {
            %>

                <td class="riflessi-value">
                    <%= value %>
                </td>

            <% } %>

        </tr>


        <!-- ====================================================
             TAGLIO
             ==================================================== -->

        <tr>

            <td class="riflessi-description">
                TAGLIO
            </td>

            <%
            for (String value :
                    row.getCutValues()) {
            %>

                <td class="riflessi-value">
                    <%= value %>
                </td>

            <% } %>

        </tr>


        <!-- ====================================================
             NUOVI RESIDUI
             ==================================================== -->

        <tr>

            <td class="riflessi-description">
                NUOVI RESIDUI
            </td>

            <%
            for (String value :
                    row.getNewResidualValues()) {
            %>

                <td class="riflessi-value">
                    <%= value %>
                </td>

            <% } %>

        </tr>


        <!-- ====================================================
             MINOR ACCANTONAMENTO FCDE
             ==================================================== -->

        <tr>

            <td class="riflessi-description">
                MINOR ACCANTONAMENTO FCDE
            </td>

            <%
            for (String value :
                    row.getMinorFcdeValues()) {
            %>

                <td class="riflessi-value">
                    <%= value %>
                </td>

            <% } %>

        </tr>


        <!-- ====================================================
             IMPATTO SUL BILANCIO
             ==================================================== -->

        <tr>

            <td class="riflessi-impact-label">
                IMPATTO SUL BILANCIO
            </td>

            <%
            for (String value :
                    row.getBudgetImpactValues()) {
            %>

                <td class="riflessi-impact-value">
                    <%= value %>
                </td>

            <% } %>

        </tr>


    </table>

</div>


<%
}
%>


<%
} else {
%>

<div class="alert alert-info mt-4">

    <i class="bi bi-info-circle-fill me-2"></i>

    Nessun dato disponibile per elaborare
    i riflessi sul bilancio.

</div>

<%
}
%>






<%
/* ============================================================
   VALUTAZIONE GENERALE
   ============================================================ */

ValutazioneGeneraleService valutazioneGeneraleService =
        new ValutazioneGeneraleService();

ValutazioneGeneraleService.ViewData valutazioneViewData =
        valutazioneGeneraleService.load(
                user,
                selectedYearId
        );
%>
   <!-- ============================================================
     VALUTAZIONE GENERALE
     ============================================================ -->

<p class="mt-5 mb-4">
    Come si evince dai dati, al fine di generare un impatto zero sul
    risultato di amministrazione, si propone di abbattere le sanzioni
    e gli interessi come indicato nella tabella riepilogativa di seguito:
</p>


<%
if (valutazioneViewData != null &&
    valutazioneViewData.hasData()) {
%>


<div class="valutazione-report-wrapper">

    <table class="valutazione-report-table"
           aria-label="Valutazione generale degli effetti sul bilancio">


        <!-- ====================================================
             HEADER
             ==================================================== -->

        <thead>

            <tr>

                <th class="">
                </th>

                <th colspan="<%= valutazioneViewData.getHypothesisLabels().size() %>"
                    class="valutazione-report-main-header">

                    % TAGLIO SANZIONI+INTERESSI

                </th>

            </tr>


            <tr>

                <th class="">
                </th>

                <%
                for (String percentage :
                        valutazioneViewData.getHypothesisLabels()) {
                %>

                    <th class="valutazione-report-percent">
                        <%= percentage %>
                    </th>

                <% } %>

            </tr>

        </thead>


        <!-- ====================================================
             BODY
             ==================================================== -->

        <tbody>


            <!-- =================================================
                 TOTALE RESIDUI
                 ================================================= -->

            <tr>

                <th scope="row"
                    class="valutazione-report-label">

                    TOTALE RESIDUI

                </th>

                <%
                for (String value :
                        valutazioneViewData.getTotalResidualValues()) {
                %>

                    <td class="valutazione-report-value">
                        <%= value %>
                    </td>

                <% } %>

            </tr>


            <!-- =================================================
                 TOTALE TAGLI
                 ================================================= -->

            <tr>

                <th scope="row"
                    class="valutazione-report-label">

                    TOTALE TAGLI

                </th>

                <%
                for (String value :
                        valutazioneViewData.getTotalCutValues()) {
                %>

                    <td class="valutazione-report-value">
                        <%= value %>
                    </td>

                <% } %>

            </tr>


            <!-- =================================================
                 RESIDUI AL NETTO
                 ================================================= -->

            <tr>

                <th scope="row"
                    class="valutazione-report-label">

                    RESIDUI AL NETTO

                </th>

                <%
                for (String value :
                        valutazioneViewData.getNetResidualValues()) {
                %>

                    <td class="valutazione-report-value">
                        <%= value %>
                    </td>

                <% } %>

            </tr>


            <!-- =================================================
                 MINOR ACCANTONAMENTO FCDE
                 ================================================= -->

            <tr>

                <th scope="row"
                    class="valutazione-report-label">

                    MINOR ACCANTONAMENTO FCDE

                </th>

                <%
                for (String value :
                        valutazioneViewData.getMinorFcdeValues()) {
                %>

                    <td class="valutazione-report-value">
                        <%= value %>
                    </td>

                <% } %>

            </tr>


            <!-- =================================================
                 RISULTATO FINALE
                 ================================================= -->

            <tr class="valutazione-report-result-row">

                <th class="valutazione-report-result-label">
                </th>

                <%
                for (String value :
                        valutazioneViewData.getTotalValues()) {

                    String sign = "+";

                    String absoluteValue =
                            value != null
                                ? value.trim()
                                : "0";

                    if (absoluteValue.startsWith("-")) {

                        sign = "-";

                        absoluteValue =
                                absoluteValue
                                    .substring(1)
                                    .trim();

                    } else if (absoluteValue.startsWith("+")) {

                        sign = "+";

                        absoluteValue =
                                absoluteValue
                                    .substring(1)
                                    .trim();
                    }

                    String resultClass =
                            "+".equals(sign)
                                ? "valutazione-report-positive"
                                : "valutazione-report-negative";
                %>

                    <td class="<%= resultClass %>">

                        <span class="valutazione-report-sign">
                            <%= sign %>
                        </span>

                        <span class="valutazione-report-result-value">
                            <%= absoluteValue %>
                        </span>

                    </td>

                <% } %>

            </tr>


        </tbody>

    </table>

</div>


<%
} else {
%>

<div class="alert alert-info mt-4">

    <i class="bi bi-info-circle-fill me-2"></i>

    Nessun dato disponibile per elaborare
    la valutazione generale.

</div>

<%
}
%>





<!-- ============================================================
     CONSIDERAZIONI FINALI
     ============================================================ -->

<div class="considerazioni-finali">

    <p class="considerazioni-title">
        Considerazioni finali.
    </p>


    <p class="mt-4">
        Dall'esame della consistenza dei ruoli rispetto ai residui
        conservati a bilancio è emerso che
    </p>


    <div class="considerazioni-punti">

        <div>
            a) è necessario ridurre i residui attivi in quanto risultano
            inferiori alle somme a ruolo ancora da incassare;
        </div>

        <div>
            b) i residui attivi risultano coerenti con le somme a ruolo
            ancora da incassare;
        </div>

        <div>
            c) le somme a ruolo risultano più consistenti dei residui attivi
            conservati pertanto si ritiene la situazione positiva.
        </div>

    </div>


    <p class="mt-4 mb-3">
        Dall'esame della velocità di riscossione delle somme a ruolo
        è emerso che
    </p>


    <!-- ========================================================
         VELOCITA' DI RISCOSSIONE
         ======================================================== -->

    <div class="considerazioni-riscossione">

        <%
        for (TabRuoliPageService.GroupData group :
                pageData.getGroups()) {

            TabRuoliPageService.TotalsData totals =
                    group.getTotals();

            String tipologia =
                    group.getEntry();

            String percentage =
                    totals.hasAveragePercentage()
                        ? totals.getAveragePercentage()
                        : "0,00";


            /* ====================================================
               CONVERSIONE PERCENTUALE
               ==================================================== */

            double p = 0d;

            try {

                p = Double.parseDouble(
                        percentage
                            .replace(".", "")
                            .replace(",", ".")
                );

            } catch (Exception e) {

                p = 0d;
            }


            /* ====================================================
               VALUTAZIONE

               Stessa logica utilizzata nella precedente sezione.
               ==================================================== */

            String valutazione;

            String valutazioneClass;

            if (p < 20) {

                valutazione = "MOLTO SCARSA";
                valutazioneClass = "considerazioni-bad";

            } else if (p < 50) {

                valutazione = "SCARSA";
                valutazioneClass = "considerazioni-bad";

            } else if (p < 60) {

                valutazione = "SUFFICIENTE";
                valutazioneClass = "considerazioni-medium";

            } else {

                valutazione = "OTTIMA";
                valutazioneClass = "considerazioni-good";
            }
        %>


            <div class="considerazioni-riga">

                <div class="considerazioni-prefix">
                    per i ruoli
                </div>

                <div class="considerazioni-tipologia">
                    <%= tipologia %>
                </div>

                <div class="considerazioni-descrizione">
                    la percentuale media di riscossione risulta pari al
                </div>

                <div class="considerazioni-percentuale">
                    <%= percentage %>%
                </div>

                <div class="considerazioni-considerata">
                    ed è considerata
                </div>

                <div class="considerazioni-valutazione <%= valutazioneClass %>">
                    <%= valutazione %>
                </div>

            </div>


        <%
        }
        %>

    </div>

</div>







    <!-- ============================================================ -->
    <!-- RISULTATO AMMINISTRAZIONE                                    -->
    <!-- ============================================================ -->

    <div class="section-subtitle">
        COMPOSIZIONE DEL RISULTATO DI AMMINISTRAZIONE
    </div>

    <p>
        Preso atto dei dati relativi al risultato di Amministrazione
        che presenta le seguenti grandezze:
    </p>

    <table class="data-table admin-table">
        <tbody>

            <tr>
                <td colspan="2"><strong>Parte accantonata (3)</strong></td>
            </tr>

            <tr>
                <td>Fondo crediti di dubbia esigibilità al 31/12/.... (4)</td>
                <td class="num">0,00</td>
            </tr>

            <tr>
                <td>
                    Accantonamento residui perenti al 31/12/....
                    (solo per le regioni) (5)
                </td>
                <td class="num">0,00</td>
            </tr>

            <tr>
                <td>Fondo anticipazioni liquidità</td>
                <td class="num">0,00</td>
            </tr>

            <tr>
                <td>Fondo perdite società partecipate</td>
                <td class="num">0,00</td>
            </tr>

            <tr>
                <td>Fondo contenzioso</td>
                <td class="num">0,00</td>
            </tr>

            <tr>
                <td>Altri accantonamenti</td>
                <td class="num">0,00</td>
            </tr>

            <tr class="total-row">
                <td>Totale parte accantonata (B)</td>
                <td class="num">0,00</td>
            </tr>


            <tr>
                <td colspan="2"><strong>Parte vincolata</strong></td>
            </tr>

            <tr>
                <td>Vincoli derivanti da leggi e dai principi contabili</td>
                <td class="num">0,00</td>
            </tr>

            <tr>
                <td>Vincoli derivanti da trasferimenti</td>
                <td class="num">0,00</td>
            </tr>

            <tr>
                <td>Vincoli derivanti dalla contrazione di mutui</td>
                <td class="num">0,00</td>
            </tr>

            <tr>
                <td>Vincoli formalmente attribuiti dall'ente</td>
                <td class="num">0,00</td>
            </tr>

            <tr>
                <td>Altri vincoli</td>
                <td class="num">0,00</td>
            </tr>

            <tr class="total-row">
                <td>Totale parte vincolata (C)</td>
                <td class="num">0,00</td>
            </tr>

            <tr>
                <td>Totale parte destinata agli investimenti (D)</td>
                <td class="num">0,00</td>
            </tr>

            <tr class="grand-total">
                <td>Totale parte disponibile (E = A - B - C - D)</td>
                <td class="num">0,00</td>
            </tr>

        </tbody>
    </table>


    <!-- ============================================================ -->
    <!-- PROPOSTA                                                     -->
    <!-- ============================================================ -->

    <div class="final-box">

        <h4 style="margin-top:0">
            PROPOSTA DI DEFINIZIONE AGEVOLATA
        </h4>

        <p>
            Visti tutti i dati sopra esposti si suggerisce il taglio
            di sanzioni ed interessi nella seguente misura:
        </p>

        <table class="data-table" style="max-width:600px">
            <thead>
                <tr>
                    <th>% TAGLIO SANZIONI</th>
                    <th>% TAGLIO INTERESSI</th>
                </tr>
            </thead>

            <tbody>
                <tr>
                    <td class="center"><strong>________ %</strong></td>
                    <td class="center"><strong>________ %</strong></td>
                </tr>
            </tbody>
        </table>

        <p>
            La riduzione dell'ammontare dei residui attivi per la somma
            di € ____________________, che sommata alla riduzione
            dell'accantonamento a FCDE per la somma di
            € ____________________ consentirebbe di impattare minimamente
            sul risultato di amministrazione.
        </p>

        <p>
            Tale scelta porterebbe alle seguenti azioni positive:
        </p>

        <ul>
            <li>incoraggiare il contribuente a saldare il debito;</li>
            <li>accelerare la riscossione di residui attivi;</li>
            <li>migliorare la liquidità dell'Ente;</li>
            <li>migliorare l'indice di ritardo nei pagamenti;</li>
            <li>
                liberare risorse riducendo in modo proporzionale il FCDE.
            </li>
        </ul>

    </div>


    <!-- ============================================================ -->
    <!-- PARERE                                                       -->
    <!-- ============================================================ -->

    <div class="section-title">
        PARERE DELL'ORGANO DI REVISIONE
    </div>

    <p>
        Visto l'art. 239 comma 1 lett. b) del D.Lgs. n. 267/2000,
        che prevede che l'organo di revisione esprima il parere sulle
        proposte di regolamento di applicazione dei tributi locali;
    </p>

    <p>
        _______________________________________________________________
    </p>

    <p>
        _______________________________________________________________
    </p>

    <p>
        _______________________________________________________________
    </p>

    <div style="margin-top:45px; text-align:right">
        <strong>L'ORGANO DI REVISIONE</strong><br><br>
        ______________________________
    </div>

</div>