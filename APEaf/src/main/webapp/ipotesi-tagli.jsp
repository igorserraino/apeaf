<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>

<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@ page import="is.five.apeaf.dao.model.Tipologia" %>
<%@ page import="is.five.apeaf.dao.model.TabPar" %>

<%@ page import="is.five.apeaf.dao.TabParDAO" %>
<%@ page import="is.five.apeaf.dao.TipologieDAO" %>

<%@ page import="is.five.apeaf.service.ImportiDefinibiliService" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.PageData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.GroupData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.RowData" %>

<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>


<%

/* ============================================================
   CALLER
   ============================================================ */

request.getSession().setAttribute(
    SessionVariables.CALLER,
    "ipotesi-tagli.jsp"
);


/* ============================================================
   USER
   ============================================================ */

UserView user =
    (UserView) request
        .getSession()
        .getAttribute("ubAP");


if (user == null || !user.getActive()) {

    response.sendRedirect("index.jsp");
    return;
}


/* ============================================================
   ANNO SELEZIONATO
   ============================================================ */

String selectedYearId =
    session.getAttribute(SessionVariables.ANNO) != null
        ? String.valueOf(
            session.getAttribute(SessionVariables.ANNO)
          )
        : "";


/* ============================================================
   IMPORTI DEFINIBILI
   ============================================================ */

ImportiDefinibiliService service =
    new ImportiDefinibiliService();


PageData pageData =
    service.load(
        user,
        selectedYearId
    );


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
              me-3">
    </i>

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
   ANNO NUMERICO

   pageData.getSelectedYear() restituisce String.
   ============================================================ */

Integer selectedYear;


try {

    selectedYear =
        Integer.valueOf(
            pageData
                .getSelectedYear()
                .trim()
        );

} catch (Exception e) {

%>


<div class="alert alert-danger">

    <i class="bi bi-exclamation-triangle-fill me-2"></i>

    Anno finanziario non valido:

    <strong>
        <%= pageData.getSelectedYear() %>
    </strong>

</div>


<%

    return;
}


/* ============================================================
   TIPOLOGIE ATTUALMENTE DEFINITE
   ============================================================ */

List<Tipologia> tipologieDefinite =
    TipologieDAO.findByUserAndAnno(
        user.getId(),
        selectedYear
    );


/* ============================================================
   SET CASE-INSENSITIVE DELLE TIPOLOGIE VALIDE
   ============================================================ */

Set<String> tipologieValide =
    new TreeSet<String>(
        String.CASE_INSENSITIVE_ORDER
    );


if (tipologieDefinite != null) {

    for (Tipologia tipologia : tipologieDefinite) {

        if (tipologia == null ||
            tipologia.getValue() == null) {

            continue;
        }


        String nome =
            tipologia
                .getValue()
                .trim();


        if (!nome.isEmpty()) {

            tipologieValide.add(
                nome
            );
        }
    }
}


/* ============================================================
   DIVISIONE GRUPPI

   COERENTI:
       tipologia presente nella configurazione corrente

   NON COERENTI:
       vecchi dati ancora presenti nella tabella ruoli
       ma tipologia non più definita.
   ============================================================ */

List<GroupData> gruppiCoerenti =
    new ArrayList<GroupData>();


List<GroupData> gruppiNonCoerenti =
    new ArrayList<GroupData>();


if (pageData.getGroups() != null) {

    for (GroupData group : pageData.getGroups()) {


        if (group == null) {
            continue;
        }


        String entry =
            group.getEntry() != null
                ? group.getEntry().trim()
                : "";


        if (!entry.isEmpty() &&
            tipologieValide.contains(entry)) {


            gruppiCoerenti.add(
                group
            );


        } else {


            gruppiNonCoerenti.add(
                group
            );

        }
    }
}


boolean hasCoherentGroups =
    !gruppiCoerenti.isEmpty();


boolean hasIncoherentGroups =
    !gruppiNonCoerenti.isEmpty();


/* ============================================================
   PARAMETRI TAGLIO SANZIONI / INTERESSI
   ============================================================ */

List<TabPar> valoriSanzione =
    new ArrayList<TabPar>(
        TabParDAO.findByUserAndType(
            user.getId(),
            TabPar.TYPE_SANZIONE
        )
    );


List<TabPar> valoriInteressi =
    new ArrayList<TabPar>(
        TabParDAO.findByUserAndType(
            user.getId(),
            TabPar.TYPE_INTERESSI
        )
    );


Comparator<TabPar> ordinamentoNumericoAscendente =
    Comparator.comparing(
        TabPar::getValue,
        Comparator.nullsLast(
            Comparator.naturalOrder()
        )
    );


valoriSanzione.sort(
    ordinamentoNumericoAscendente
);


valoriInteressi.sort(
    ordinamentoNumericoAscendente
);


/* ============================================================
   GARANTIAMO ALMENO 3 IPOTESI
   ============================================================ */

while (valoriSanzione.size() < 3) {

    TabPar parametro =
        new TabPar();

    parametro.setValue(
        BigDecimal.ZERO
    );

    parametro.setType(
        TabPar.TYPE_SANZIONE
    );

    valoriSanzione.add(
        parametro
    );
}


while (valoriInteressi.size() < 3) {

    TabPar parametro =
        new TabPar();

    parametro.setValue(
        BigDecimal.ZERO
    );

    parametro.setType(
        TabPar.TYPE_INTERESSI
    );

    valoriInteressi.add(
        parametro
    );
}


/* ============================================================
   FORMATTAZIONE ITALIANA
   ============================================================ */

DecimalFormat formatoItaliano3Decimali =
    new DecimalFormat(
        "#,##0.000",
        DecimalFormatSymbols.getInstance(
            Locale.ITALY
        )
    );

%>



<!-- ============================================================
     TITOLO
     ============================================================ -->

<h3 class="mb-4">

    <i class="bi bi-calculator me-2"></i>

    IPOTESI TAGLI


    <span class="badge bg-primary ms-2">

        <%= pageData.getSelectedYear() %>

    </span>

</h3>



<!-- ============================================================
     WARNING DATI NON COERENTI
     ============================================================ -->

<% if (hasIncoherentGroups) { %>


<div class="alert alert-danger
            d-flex
            align-items-start
            shadow-sm
            mb-4"
     role="alert">


    <i class="bi bi-database-exclamation
              fs-2
              me-3">
    </i>


    <div class="flex-grow-1">


        <div class="fw-bold mb-1">

            Sono presenti dati associati
            a tipologie non più definite.

        </div>


        <div>

            Sono state individuate

            <strong>
                <%= gruppiNonCoerenti.size() %>
            </strong>

            tipologie presenti nei dati storici
            ma non nella configurazione corrente
            dell'anno

            <strong>
                <%= selectedYear %>
            </strong>.

        </div>


        <div class="mt-2">

            Questi dati

            <strong>
                non vengono inclusi nel calcolo
                delle ipotesi di taglio
            </strong>.

            Se sono dati obsoleti,
            chiedere a un amministratore
            di rimuovere i vecchi dati.

        </div>


        <button class="btn
                       btn-outline-danger
                       btn-sm
                       mt-3"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#nonCoherentValuesTagli"
                aria-expanded="false"
                aria-controls="nonCoherentValuesTagli">


            <i class="bi bi-eye-fill me-1"></i>

            Mostra valori non coerenti


            <span class="badge bg-danger ms-1">

                <%= gruppiNonCoerenti.size() %>

            </span>


        </button>


    </div>

</div>


<% } %>



<!-- ============================================================
     DATI COERENTI / IPOTESI TAGLI
     ============================================================ -->

<div class="rounded
            p-4
            dati-card
            ipotesi-tagli-card
            mt-4">


    <div class="dati-header mb-3">


        <div class="dati-title
                    dati-section-title">


            <i class="bi bi-table"></i>


            <span>

                DATI COMPUTATI DA IMPORTI DEFINIBILI

            </span>


        </div>

    </div>



    <% if (!hasCoherentGroups) { %>


        <div class="alert alert-info mb-0">

            <i class="bi bi-info-circle-fill me-2"></i>

            Nessun dato coerente disponibile
            per le tipologie attualmente definite.

        </div>


    <% } else { %>



    <div class="table-responsive">


        <table class="ipotesi-tagli-table"
               aria-label="Ipotesi di taglio su sanzioni e interessi"
               style="max-width:1200px">


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



            <!-- =================================================
                 HEADER
                 ================================================= -->

            <thead>


                <tr>


                    <th class="empty-header"
                        colspan="2">
                    </th>


                    <th class="section-header"
                        colspan="3"
                        scope="colgroup">

                        SANZIONI

                    </th>


                    <th class="spacer-cell">
                    </th>


                    <th class="section-header"
                        colspan="3"
                        scope="colgroup">

                        INTERESSI

                    </th>


                </tr>



                <tr>


                    <th class="empty-header"
                        colspan="2">
                    </th>


                    <th class="hypothesis-header"
                        scope="col">

                        % taglio
                        (1^ ipotesi)

                    </th>


                    <th class="hypothesis-header"
                        scope="col">

                        % taglio
                        (2^ ipotesi)

                    </th>


                    <th class="hypothesis-header"
                        scope="col">

                        % taglio
                        (3^ ipotesi)

                    </th>


                    <th class="spacer-cell">
                    </th>


                    <th class="hypothesis-header"
                        scope="col">

                        % taglio
                        (1^ ipotesi)

                    </th>


                    <th class="hypothesis-header"
                        scope="col">

                        % taglio
                        (2^ ipotesi)

                    </th>


                    <th class="hypothesis-header"
                        scope="col">

                        % taglio
                        (3^ ipotesi)

                    </th>


                </tr>



                <tr>


                    <th class="percentage-header"
                        scope="col">

                        TIPOLOGIA

                    </th>


                    <th class="percentage-header"
                        scope="col"
                        aria-label="Entrata">
                    </th>


                    <th class="percentage-header"
                        scope="col">

                        <%= formatoItaliano3Decimali.format(
                                valoriSanzione
                                    .get(0)
                                    .getValue()
                            ) %>

                    </th>


                    <th class="percentage-header"
                        scope="col">

                        <%= formatoItaliano3Decimali.format(
                                valoriSanzione
                                    .get(1)
                                    .getValue()
                            ) %>

                    </th>


                    <th class="percentage-header"
                        scope="col">

                        <%= formatoItaliano3Decimali.format(
                                valoriSanzione
                                    .get(2)
                                    .getValue()
                            ) %>

                    </th>


                    <th class="spacer-cell">
                    </th>


                    <th class="percentage-header"
                        scope="col">

                        <%= formatoItaliano3Decimali.format(
                                valoriInteressi
                                    .get(0)
                                    .getValue()
                            ) %>

                    </th>


                    <th class="percentage-header"
                        scope="col">

                        <%= formatoItaliano3Decimali.format(
                                valoriInteressi
                                    .get(1)
                                    .getValue()
                            ) %>

                    </th>


                    <th class="percentage-header"
                        scope="col">

                        <%= formatoItaliano3Decimali.format(
                                valoriInteressi
                                    .get(2)
                                    .getValue()
                            ) %>

                    </th>


                </tr>


            </thead>



            <!-- =================================================
                 BODY
                 ================================================= -->

            <tbody>


                <tr class="separator-row"
                    aria-hidden="true">

                    <td colspan="9">
                    </td>

                </tr>



                <%

                /*
                 * TOTALI CALCOLATI ESCLUSIVAMENTE
                 * SUI GRUPPI COERENTI.
                 */

                double totTagliSanzioni1 = 0d;
                double totTagliSanzioni2 = 0d;
                double totTagliSanzioni3 = 0d;

                double totTagliInteressi1 = 0d;
                double totTagliInteressi2 = 0d;
                double totTagliInteressi3 = 0d;



                for (GroupData group :
                        gruppiCoerenti) {


                    double sanzioniResidue =
                        group
                            .getTotalResidualSanctionsBD()
                            .doubleValue();


                    double interessiResidui =
                        group
                            .getTotalResidualInterestBD()
                            .doubleValue();


                    double taglioSanzioni1 =
                        sanzioniResidue *
                        valoriSanzione
                            .get(0)
                            .getValue()
                            .doubleValue()
                        / 100d;


                    double taglioSanzioni2 =
                        sanzioniResidue *
                        valoriSanzione
                            .get(1)
                            .getValue()
                            .doubleValue()
                        / 100d;


                    double taglioSanzioni3 =
                        sanzioniResidue *
                        valoriSanzione
                            .get(2)
                            .getValue()
                            .doubleValue()
                        / 100d;


                    double taglioInteressi1 =
                        interessiResidui *
                        valoriInteressi
                            .get(0)
                            .getValue()
                            .doubleValue()
                        / 100d;


                    double taglioInteressi2 =
                        interessiResidui *
                        valoriInteressi
                            .get(1)
                            .getValue()
                            .doubleValue()
                        / 100d;


                    double taglioInteressi3 =
                        interessiResidui *
                        valoriInteressi
                            .get(2)
                            .getValue()
                            .doubleValue()
                        / 100d;


                    /* =========================================
                       ACCUMULO TOTALI
                       ========================================= */

                    totTagliSanzioni1 +=
                        taglioSanzioni1;

                    totTagliSanzioni2 +=
                        taglioSanzioni2;

                    totTagliSanzioni3 +=
                        taglioSanzioni3;


                    totTagliInteressi1 +=
                        taglioInteressi1;

                    totTagliInteressi2 +=
                        taglioInteressi2;

                    totTagliInteressi3 +=
                        taglioInteressi3;

                %>



                <tr>


                    <td class="description-cell">

                        MINORI RESIDUI ATTIVI

                    </td>


                    <td class="description-cell text-end">

                        <%= group.getEntry() %>

                    </td>


                    <!-- SANZIONI -->

                    <td class="amount-cell">

                        <%= formatoItaliano3Decimali.format(
                                taglioSanzioni1
                            ) %>

                    </td>


                    <td class="amount-cell">

                        <%= formatoItaliano3Decimali.format(
                                taglioSanzioni2
                            ) %>

                    </td>


                    <td class="amount-cell">

                        <%= formatoItaliano3Decimali.format(
                                taglioSanzioni3
                            ) %>

                    </td>


                    <td class="spacer-cell">
                    </td>


                    <!-- INTERESSI -->

                    <td class="amount-cell">

                        <%= formatoItaliano3Decimali.format(
                                taglioInteressi1
                            ) %>

                    </td>


                    <td class="amount-cell">

                        <%= formatoItaliano3Decimali.format(
                                taglioInteressi2
                            ) %>

                    </td>


                    <td class="amount-cell">

                        <%= formatoItaliano3Decimali.format(
                                taglioInteressi3
                            ) %>

                    </td>


                </tr>


                <%

                }

                %>



                <!-- =================================================
                     TOTALI

                     Solo tipologie valide.
                     ================================================= -->

                <tr>


                    <th class="total-label"
                        scope="row">

                        TOTALI TAGLI RESIDUI

                    </th>


                    <td class="total-label">
                    </td>


                    <td class="total-value">

                        <%= formatoItaliano3Decimali.format(
                                totTagliSanzioni1
                            ) %>

                    </td>


                    <td class="total-value">

                        <%= formatoItaliano3Decimali.format(
                                totTagliSanzioni2
                            ) %>

                    </td>


                    <td class="total-value">

                        <%= formatoItaliano3Decimali.format(
                                totTagliSanzioni3
                            ) %>

                    </td>


                    <td class="spacer-cell">
                    </td>


                    <td class="total-value">

                        <%= formatoItaliano3Decimali.format(
                                totTagliInteressi1
                            ) %>

                    </td>


                    <td class="total-value">

                        <%= formatoItaliano3Decimali.format(
                                totTagliInteressi2
                            ) %>

                    </td>


                    <td class="total-value">

                        <%= formatoItaliano3Decimali.format(
                                totTagliInteressi3
                            ) %>

                    </td>


                </tr>


            </tbody>


        </table>


    </div>


    <% } %>


</div>



<!-- ============================================================
     AREA DATI NON COERENTI
     ============================================================ -->

<% if (hasIncoherentGroups) { %>


<div class="collapse mt-4"
     id="nonCoherentValuesTagli">


    <div class="card border-danger">


        <!-- ====================================================
             HEADER
             ==================================================== -->

        <div class="card-header border-danger">


            <div class="d-flex
                        align-items-center
                        justify-content-between">


                <div class="fw-bold text-danger">


                    <i class="bi bi-exclamation-octagon-fill
                              me-2">
                    </i>


                    VALORI NON COERENTI


                </div>


                <span class="badge bg-danger">


                    <%= gruppiNonCoerenti.size() %>


                </span>


            </div>


        </div>



        <div class="card-body">


            <!-- =================================================
                 DESCRIZIONE
                 ================================================= -->

            <div class="alert alert-warning">


                <div class="d-flex align-items-start">


                    <i class="bi bi-info-circle-fill
                              fs-4
                              me-3">
                    </i>


                    <div>


                        <strong>

                            Sono presenti residui relativi
                            a vecchie tipologie.

                        </strong>


                        <br />


                        Le tipologie riportate sotto non sono
                        più presenti nella configurazione

                        <strong>
                            Def. tipologie
                        </strong>

                        per l'anno

                        <strong>
                            <%= selectedYear %>
                        </strong>.


                        <br /><br />


                        I relativi valori

                        <strong>
                            non sono utilizzati nel calcolo
                            delle ipotesi di taglio.
                        </strong>


                        <br />


                        Se questi dati non sono più necessari,

                        <strong>
                            chiedere a un amministratore
                            di rimuovere i vecchi dati.
                        </strong>


                    </div>


                </div>


            </div>



            <!-- =================================================
                 DATI OBSOLETI
                 ================================================= -->

            <%

            for (GroupData group :
                    gruppiNonCoerenti) {

            %>


            <div class="mb-4">


                <div class="d-flex
                            align-items-center
                            mb-2">


                    <span class="badge
                                 bg-danger
                                 me-2">

                        NON COERENTE

                    </span>


                    <strong>

                        Tipologia:

                        <%= group.getEntry() != null
                            ? group.getEntry()
                            : "(vuota)" %>

                    </strong>


                </div>



                <div class="table-responsive">


                    <table class="table
                                  table-bordered
                                  table-hover
                                  table-sm"
                           style="max-width:1000px">


                        <thead class="table-danger">


                            <tr>


                                <th>
                                    TIPOLOGIA OBSOLETA
                                </th>


                                <th>
                                    ANNO RUOLO
                                </th>


                                <th>
                                    NUM. RUOLO
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

                            for (RowData row :
                                    group.getRows()) {

                            %>


                            <tr>


                                <td>


                                    <span class="text-danger
                                                 fw-bold">


                                        <i class="bi
                                                  bi-x-circle-fill
                                                  me-1">
                                        </i>


                                        <%= row.getEntry() %>


                                    </span>


                                </td>


                                <td class="text-center">

                                    <%= row.getRoleYear() %>

                                </td>


                                <td class="text-center">

                                    <%= row.getRoleNumber() %>

                                </td>


                                <td class="text-number">

                                    <%= row.getResidualTax() %>

                                </td>


                                <td class="text-number">

                                    <%= row.getResidualSanctions() %>

                                </td>


                                <td class="text-number">

                                    <%= row.getResidualInterest() %>

                                </td>


                                <td class="text-number fw-bold">

                                    <%= row.getTotal() %>

                                </td>


                            </tr>


                            <% } %>



                            <!-- =================================
                                 TOTALI DATI OBSOLETI
                                 ================================= -->

                            <tr class="table-danger fw-bold">


                                <td colspan="3"
                                    class="text-end">

                                    TOTALE DATI OBSOLETI

                                </td>


                                <td class="text-number">

                                    <%= group.getTotalResidualTax() %>

                                </td>


                                <td class="text-number">

                                    <%= group.getTotalResidualSanctions() %>

                                </td>


                                <td class="text-number">

                                    <%= group.getTotalResidualInterest() %>

                                </td>


                                <td class="text-number">

                                    <%= group.getTotalRoleAmount() %>

                                </td>


                            </tr>


                        </tbody>


                    </table>


                </div>


            </div>


            <% } %>



            <!-- =================================================
                 ADMIN WARNING
                 ================================================= -->

            <div class="alert alert-danger mb-0">


                <i class="bi bi-shield-exclamation me-2"></i>


                <strong>

                    Intervento amministrativo richiesto:

                </strong>


                questi record appartengono a tipologie
                non più definite.

                Chiedere a un amministratore
                di verificarli ed eventualmente
                rimuovere i vecchi dati.


            </div>


        </div>


    </div>


</div>


<% } %>



<!-- ============================================================
     SCROLL AUTOMATICO SU DATI NON COERENTI
     ============================================================ -->

<style>

#nonCoherentValuesTagli {

    scroll-margin-top: 100px;

}

</style>


<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {


        const nonCoherentValues =
            document.getElementById(
                "nonCoherentValuesTagli"
            );


        if (!nonCoherentValues) {

            return;
        }


        /*
         * Bootstrap genera questo evento
         * DOPO aver completato l'apertura
         * del collapse.
         */
        nonCoherentValues.addEventListener(
            "shown.bs.collapse",
            function () {


                nonCoherentValues.scrollIntoView(
                    {
                        behavior: "smooth",
                        block: "start"
                    }
                );


            }
        );

    }
);

</script>