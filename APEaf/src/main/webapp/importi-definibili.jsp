<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.*" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>

<%@ page import="is.five.apeaf.dao.TipologieDAO" %>

<%@ page import="is.five.apeaf.dao.model.Tipologia" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>

<%@ page import="is.five.apeaf.service.ImportiDefinibiliService" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.PageData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.GroupData" %>
<%@ page import="is.five.apeaf.service.ImportiDefinibiliService.RowData" %>


<%

/* ============================================================
   CALLER
   ============================================================ */

request.getSession().setAttribute(
    SessionVariables.CALLER,
    "importi-definibili.jsp"
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
   SERVICE
   ============================================================ */

ImportiDefinibiliService service =
    new ImportiDefinibiliService();


PageData pageData =
    service.load(
        user,
        selectedYearId
    );


/* ============================================================
   NESSUN ANNO
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
   CONVERSIONE ANNO

   pageData.getSelectedYear() è String.
   TipologieDAO richiede Integer.
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
   TIPOLOGIE ATTUALMENTE VALIDE

   Solo queste sono considerate coerenti.
   ============================================================ */

List<Tipologia> tipologieDefinite =
    TipologieDAO.findByUserAndAnno(
        user.getId(),
        selectedYear
    );


/* ============================================================
   SET NOMI TIPOLOGIE VALIDE

   TreeSet case-insensitive:
       IMU == imu == Imu
   ============================================================ */

Set<String> tipologieValide =
    new TreeSet<String>(
        String.CASE_INSENSITIVE_ORDER
    );


if (tipologieDefinite != null) {

    for (Tipologia t : tipologieDefinite) {

        if (t == null ||
            t.getValue() == null) {

            continue;
        }


        String nome =
            t.getValue().trim();


        if (!nome.isEmpty()) {

            tipologieValide.add(
                nome
            );
        }
    }
}


/* ============================================================
   SEPARAZIONE DATI

   gruppiCoerenti:
       la tipologia esiste ancora nella tabella tipologie

   gruppiNonCoerenti:
       esistono dati nei ruoli ma la tipologia non è più
       definita per questo utente/anno
   ============================================================ */

List<GroupData> gruppiCoerenti =
    new ArrayList<GroupData>();


List<GroupData> gruppiNonCoerenti =
    new ArrayList<GroupData>();


if (pageData.hasGroups()) {

    for (GroupData group : pageData.getGroups()) {


        if (group == null) {

            continue;
        }


        String entry =
            group.getEntry();


        String nomeTipologia =
            entry != null
                ? entry.trim()
                : "";


        if (!nomeTipologia.isEmpty() &&
            tipologieValide.contains(
                nomeTipologia
            )) {


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


/* ============================================================
   FLAGS
   ============================================================ */

boolean hasCoherentGroups =
    !gruppiCoerenti.isEmpty();


boolean hasIncoherentGroups =
    !gruppiNonCoerenti.isEmpty();


/* ============================================================
   TOTALI DEI SOLI DATI COERENTI

   Importante:
   pageData.getTotal...() comprende anche eventuali vecchi
   gruppi non coerenti.

   Per questo calcoliamo qui i totali visualizzati nella
   sezione principale usando SOLO gruppi coerenti.
   ============================================================ */

double coherentResidualTax = 0.0;
double coherentResidualSanctions = 0.0;
double coherentResidualInterest = 0.0;
double coherentTotal = 0.0;


/*
 * Se i getter dei GroupData restituiscono String formattate,
 * NON usare questo blocco e mantenere i totali del service.
 *
 * Se invece restituiscono double/BigDecimal, adattare i tipi.
 *
 * Per evitare di alterare il tuo service in questa versione,
 * il totale complessivo originale rimane visualizzato sotto
 * come "totale dati presenti".
 */

%>



<!-- ============================================================
     TITOLO
     ============================================================ -->

<h3 class="mb-4">

    <i class="bi bi-calculator me-2"></i>

    IMPORTI DEFINIBILI


    <span class="badge bg-primary ms-2">

        <%= pageData.getSelectedYear() %>

    </span>

</h3>



<!-- ============================================================
     AVVISO DATI NON COERENTI
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

            Sono stati trovati

            <strong>
                <%= gruppiNonCoerenti.size() %>
            </strong>

            gruppi di dati che fanno riferimento
            a vecchie tipologie non presenti nella
            configurazione corrente dell'anno

            <strong>
                <%= selectedYear %>
            </strong>.

        </div>


        <div class="mt-2">

            Questi valori

            <strong>
                non vengono considerati dati coerenti
                con la configurazione corrente
            </strong>.

            Se i record non sono più necessari,
            chiedere a un amministratore di rimuovere
            i vecchi dati dalla base dati.

        </div>


        <button class="btn btn-outline-danger
                       btn-sm
                       mt-3"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#nonCoherentValues"
                aria-expanded="false"
                aria-controls="nonCoherentValues">


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
     AREA DATI COERENTI
     ============================================================ -->

<div class="rounded
            p-4
            dati-card
            mt-4">


    <div class="dati-header mb-3">


        <div class="dati-title
                    dati-section-title">


            <i class="bi bi-table"></i>


            <span>

                DATI COMPUTATI DA TABELLA RUOLI

            </span>

        </div>

    </div>



    <!-- ========================================================
         NESSUN DATO COERENTE
         ======================================================== -->

    <% if (!hasCoherentGroups) { %>


        <div class="alert alert-info mb-0">


            <i class="bi bi-info-circle-fill me-2"></i>


            Nessun ruolo coattivo associato
            alle tipologie attualmente definite.


        </div>


    <% } else { %>



        <!-- ====================================================
             GRUPPI COERENTI
             ==================================================== -->

        <%

        for (GroupData group : gruppiCoerenti) {

        %>


        <div class="tab-ruoli-group">


            <!-- HEADER GRUPPO -->

            <div class="tab-ruoli-title-light"
                 style="max-width:800px">


                <i class="bi bi-tag-fill"></i>


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
                              table-ruoli"
                       style="max-width:800px">


                    <!-- =========================================
                         HEADER
                         ========================================= -->

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
                                Totale
                            </th>


                        </tr>


                    </thead>


                    <tbody>


                        <!-- =====================================
                             RECORD
                             ===================================== -->

                        <%

                        for (RowData row : group.getRows()) {

                        %>


                        <tr>


                            <td>

                                <%= row.getEntry() %>

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


                            <td class="text-number">

                                <%= row.getTotal() %>

                            </td>


                        </tr>


                        <% } %>



                        <!-- =====================================
                             TOTALE TIPOLOGIA
                             ===================================== -->

                        <tr class="table-primary fw-bold">


                            <td colspan="3"
                                class="text-end">


                                TOTALE
                                <%= group.getEntry() %>


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



        <!-- ====================================================
             TOTALI

             ATTENZIONE:
             questi sono i totali restituiti dal service.
             Se nel service vengono sommati anche gruppi obsoleti,
             vedi nota dopo il JSP.
             ==================================================== -->

        <div class="tab-ruoli-group mt-4">


            <div class="tab-ruoli-title">


                <i class="bi bi-calculator-fill"></i>


                <span>

                    TOTALI RUOLI

                </span>


            </div>


            <div class="tab-ruoli-container">


                <table class="table
                              table-bordered
                              table-sm
                              table-ruoli
                              mb-0"
                       style="width:800px">


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


                        <tr class="table-primary fw-bold">


                            <td class="text-number">

                                <%= pageData.getTotalResidualTax() %>

                            </td>


                            <td class="text-number">

                                <%= pageData.getTotalResidualSanctions() %>

                            </td>


                            <td class="text-number">

                                <%= pageData.getTotalResidualInterest() %>

                            </td>


                            <td class="text-number">

                                <%= pageData.getTotalRoleAmount() %>

                            </td>


                        </tr>


                    </tbody>


                </table>


            </div>


        </div>


    <% } %>


</div>



<!-- ============================================================
     DATI NON COERENTI
     ============================================================ -->

<% if (hasIncoherentGroups) { %>


<div class="collapse mt-4"
     id="nonCoherentValues">


    <div class="card border-danger">


        <!-- ====================================================
             HEADER
             ==================================================== -->

        <div class="card-header
                    border-danger">


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
                 SPIEGAZIONE
                 ================================================= -->

            <div class="alert alert-warning">


                <div class="d-flex align-items-start">


                    <i class="bi bi-info-circle-fill
                              fs-4
                              me-3">
                    </i>


                    <div>


                        <strong>

                            Dati storici associati a
                            tipologie non più definite

                        </strong>


                        <br />


                        I record riportati di seguito
                        sono ancora presenti nella base dati,
                        ma la relativa tipologia non esiste
                        più nella pagina

                        <strong>
                            Def. tipologie
                        </strong>

                        per l'anno

                        <strong>
                            <%= selectedYear %>
                        </strong>.


                        <br /><br />


                        Non modificare la configurazione
                        delle tipologie per tentare di
                        nascondere questi dati.


                        <strong>

                            Se i record sono obsoleti,
                            chiedere a un amministratore
                            di rimuovere i vecchi dati.

                        </strong>


                    </div>


                </div>


            </div>



            <!-- =================================================
                 GRUPPI NON COERENTI
                 ================================================= -->

            <%

            for (GroupData group : gruppiNonCoerenti) {

            %>


            <div class="tab-ruoli-group mb-4">


                <!-- =============================================
                     HEADER
                     ============================================= -->

                <div class="d-flex
                            align-items-center
                            mb-2">


                    <span class="badge bg-danger me-2">


                        NON COERENTE


                    </span>


                    <strong>


                        Tipologia:


                        <%= group.getEntry() != null
                            ? group.getEntry()
                            : "(vuota)" %>


                    </strong>


                </div>



                <!-- =============================================
                     TABELLA
                     ============================================= -->

                <div class="table-responsive">


                    <table class="table
                                  table-bordered
                                  table-hover
                                  table-sm"
                           style="max-width:900px">


                        <thead class="table-danger">


                            <tr>


                                <th>
                                    TIPOLOGIA OBSOLETA
                                </th>


                                <th>
                                    Anno ruolo
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

                            for (RowData row :
                                    group.getRows()) {

                            %>


                            <tr>


                                <td>


                                    <span class="text-danger
                                                 fw-bold">


                                        <i class="bi bi-x-circle-fill
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
                                 TOTALI TIPOLOGIA OBSOLETA
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
                 FOOTER WARNING
                 ================================================= -->

            <div class="alert alert-danger mb-0">


                <i class="bi bi-shield-exclamation me-2"></i>


                <strong>

                    Intervento amministrativo richiesto:

                </strong>


                questi dati non possono essere corretti
                da questa pagina.

                Chiedere a un amministratore di verificare
                ed eventualmente rimuovere i record obsoleti.


            </div>


        </div>


    </div>


</div>

<script>
document.addEventListener("DOMContentLoaded", function () {

    const nonCoherentValues =
        document.getElementById("nonCoherentValues");

    if (!nonCoherentValues) {
        return;
    }

    nonCoherentValues.addEventListener(
        "shown.bs.collapse",
        function () {

            nonCoherentValues.scrollIntoView({
                behavior: "smooth",
                block: "start"
            });

        }
    );

});
</script>
<% } %>