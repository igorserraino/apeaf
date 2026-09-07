<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="is.five.apeaf.utils.Utils" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>

<%@ page import="is.five.apeaf.dao.*" %>
<%@ page import="is.five.apeaf.dao.model.*" %>

<%@ page import="is.five.apeaf.service.TabRuoliPageService" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.PageData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.GroupData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.RowData" %>
<%@ page import="is.five.apeaf.service.TabRuoliPageService.TotalsData" %>

<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>


<%

/* ============================================================
   CALLER
   ============================================================ */

request.getSession().setAttribute(
    SessionVariables.CALLER,
    "valutazione-ruoli.jsp"
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
   ANNO
   ============================================================ */

String selectedYearId =
    session.getAttribute(SessionVariables.ANNO) != null
        ? String.valueOf(
            session.getAttribute(SessionVariables.ANNO)
          )
        : "";


TabRuoliPageService service =
    new TabRuoliPageService();


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
   PARAMETRI SANZIONI / INTERESSI

   Manteniamo la tua logica esistente.
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
   FORMATTAZIONE
   ============================================================ */

DecimalFormat formatoItaliano3Decimali =
    new DecimalFormat(
        "#,##0.000",
        DecimalFormatSymbols.getInstance(
            Locale.ITALY
        )
    );

formatoItaliano3Decimali.setRoundingMode(
    RoundingMode.HALF_UP
);


/* ============================================================
   TIPOLOGIE ATTUALMENTE DEFINITE
   ============================================================ */

List<Tipologia> tipologieDefinite =
    TipologieDAO.findByUserAndAnno(
        user.getId(),
        selectedYear
    );


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
RESIDUI ATTIVI
============================================================ */

Map<String, BigDecimal> residuiPerTipologia =
 new TreeMap<String, BigDecimal>(
     String.CASE_INSENSITIVE_ORDER
 );

Map<String, BigDecimal> residuiNonCoerenti =
 new TreeMap<String, BigDecimal>(
     String.CASE_INSENSITIVE_ORDER
 );


InsResiduiAttivi residuiAttivi =
 InsResiduiAttiviDAO.findByUserAndAnno(
     user.getId(),
     selectedYear
 );


if (residuiAttivi != null &&
 residuiAttivi.getValue() != null &&
 !residuiAttivi.getValue().trim().isEmpty()) {


 String rawValue =
     residuiAttivi
         .getValue()
         .trim();


 String[] saved =
     rawValue.split(";", -1);


 /* ========================================================
    Se esiste ALMENO un campo nome=valore,
    il record viene considerato nel NUOVO FORMATO.

    In questo caso eventuali vecchi campi posizionali
    vengono completamente ignorati.
    ======================================================== */

 boolean nuovoFormato = false;


 for (String token : saved) {

     if (token != null &&
         token.contains("=")) {

         nuovoFormato = true;
         break;
     }
 }


 /* ========================================================
    NUOVO FORMATO:

        ICI=150000;IMU=50000;TARI=80000

    ======================================================== */

 if (nuovoFormato) {


     for (String token : saved) {


         if (token == null) {
             continue;
         }


         token = token.trim();


         if (token.isEmpty()) {
             continue;
         }


         /*
          * IMPORTANTISSIMO:
          *
          * Se il record è nel nuovo formato,
          * ignoriamo completamente i token che
          * non contengono "=".
          *
          * Questo elimina i residui posizionali
          * lasciati da vecchie versioni.
          */
         if (!token.contains("=")) {
             continue;
         }


         String[] parts =
             token.split("=", 2);


         String nomeTipologia =
             parts[0] != null
                 ? parts[0].trim()
                 : "";


         String valoreString =
             parts.length > 1 &&
             parts[1] != null
                 ? parts[1].trim()
                 : "0";


         if (nomeTipologia.isEmpty()) {
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

         } catch (Exception exc) {

             valore =
                 BigDecimal.ZERO;
         }


         /* ================================================
            TIPOLOGIA VALIDA
            ================================================ */

         if (tipologieValide.contains(
                 nomeTipologia)) {


             residuiPerTipologia.put(
                 nomeTipologia,
                 valore
             );


         } else {


             /*
              * Una tipologia non più definita viene
              * segnalata SOLO se contiene effettivamente
              * un valore diverso da zero.
              *
              * Un vecchio "XYZ=0" non rappresenta
              * un dato significativo da bonificare.
              */
             if (valore.compareTo(
                     BigDecimal.ZERO) != 0) {


                 residuiNonCoerenti.put(
                     nomeTipologia,
                     valore
                 );
             }
         }
     }


 } else {


     /* ====================================================
        VECCHIO FORMATO POSIZIONALE PURO

            100;200;300;400;500

        Questo ramo viene usato SOLO quando nell'intero
        record non esiste neppure un "=".
        ==================================================== */

     int legacyPosition = 0;


     for (String token : saved) {


         if (legacyPosition >=
                 InsResiduiAttivi.TIPOLOGIE.length) {

             break;
         }


         if (token == null) {

             legacyPosition++;
             continue;
         }


         token = token.trim();


         BigDecimal valoreLegacy =
             BigDecimal.ZERO;


         if (!token.isEmpty()) {

             try {

                 BigDecimal parsed =
                     Utils.parseItalianNumber(
                         token
                     );


                 if (parsed != null) {
                     valoreLegacy = parsed;
                 }

             } catch (Exception exc) {

                 valoreLegacy =
                     BigDecimal.ZERO;
             }
         }


         String nomeLegacy =
             InsResiduiAttivi
                 .TIPOLOGIE[legacyPosition];


         legacyPosition++;


         if (nomeLegacy == null ||
             nomeLegacy.trim().isEmpty()) {

             continue;
         }


         nomeLegacy =
             nomeLegacy.trim();


         /* ================================================
            VECCHIA TIPOLOGIA ANCORA VALIDA
            ================================================ */

         if (tipologieValide.contains(
                 nomeLegacy)) {


             residuiPerTipologia.put(
                 nomeLegacy,
                 valoreLegacy
             );


         } else {


             /*
              * Non mostriamo come "dato obsoleto"
              * un semplice zero del vecchio array.
              */
             if (valoreLegacy.compareTo(
                     BigDecimal.ZERO) != 0) {


                 residuiNonCoerenti.put(
                     nomeLegacy,
                     valoreLegacy
                 );
             }
         }
     }
 }
}


/* ============================================================
   DIVISIONE RUOLI COERENTI / NON COERENTI
   ============================================================ */

List<GroupData> gruppiCoerenti =
    new ArrayList<GroupData>();


List<GroupData> gruppiNonCoerenti =
    new ArrayList<GroupData>();


if (pageData.getGroups() != null) {

    for (GroupData group :
            pageData.getGroups()) {


        if (group == null) {

            continue;
        }


        String nome =
            group.getEntry() != null
                ? group.getEntry().trim()
                : "";


        if (!nome.isEmpty() &&
            tipologieValide.contains(nome)) {


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


boolean hasIncoherentGroups =
    !gruppiNonCoerenti.isEmpty();


boolean hasIncoherentResiduals =
    !residuiNonCoerenti.isEmpty();


boolean hasIncoherentValues =
    hasIncoherentGroups ||
    hasIncoherentResiduals;


int numeroNonCoerenti =
    gruppiNonCoerenti.size()
    +
    residuiNonCoerenti.size();

%>



<!-- ============================================================
     TITOLO
     ============================================================ -->

<h3 class="mb-4">

    <i class="bi bi-calculator me-2"></i>

    CONFRONTO RUOLI E ACCERTAMENTI


    <span class="badge bg-primary ms-2">

        <%= pageData.getSelectedYear() %>

    </span>

</h3>



<!-- ============================================================
     WARNING DATI NON COERENTI
     ============================================================ -->

<% if (hasIncoherentValues) { %>


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

            Sono stati individuati dati storici
            che non corrispondono alle tipologie
            attualmente configurate per l'anno

            <strong>
                <%= selectedYear %>
            </strong>.

        </div>


        <div class="mt-2">

            Questi valori

            <strong>
                non vengono utilizzati nel confronto corrente.
            </strong>

            Chiedere a un amministratore
            di verificare ed eventualmente
            rimuovere i vecchi dati.

        </div>


        <button class="btn
                       btn-outline-danger
                       btn-sm
                       mt-3"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#nonCoherentValuesValutazione"
                aria-expanded="false"
                aria-controls="nonCoherentValuesValutazione">


            <i class="bi bi-eye-fill me-1"></i>

            Mostra valori non coerenti


            <span class="badge bg-danger ms-1">

                <%= numeroNonCoerenti %>

            </span>


        </button>


    </div>

</div>


<% } %>



<!-- ============================================================
     TABELLA PRINCIPALE
     ============================================================ -->

<div class="rounded
            p-4
            dati-card
            valutazione-ruoli-card
            mt-4">


    <div class="dati-header mb-3">


        <div class="dati-title
                    dati-section-title">


            <i class="bi bi-table"></i>


            <span>

                DATI COMPUTATI DA RESIDUI ATTIVI E TAB RUOLI

            </span>


        </div>


    </div>


    <% if (gruppiCoerenti.isEmpty()) { %>


        <div class="alert alert-info mb-0">

            Nessun ruolo associato
            alle tipologie attualmente definite.

        </div>


    <% } else { %>


    <div class="table-responsive">


        <table class="valutazione-ruoli-table"
               aria-label="Confronto tra importi residui a bilancio e totale ruoli"
               style="max-width:1200px">


            <colgroup>

                <col class="col-tipologia" />

                <col class="col-valore" />

                <col class="col-valore" />

                <col class="col-valore" />

                <col class="col-valore" />

            </colgroup>



            <thead>


                <tr>


                    <th scope="col">

                        TIPOLOGIA ENTRATA

                    </th>


                    <th scope="col">

                        IMPORTI RESIDUI A

                        <br />

                        BILANCIO

                    </th>


                    <th scope="col">

                        TOTALE RUOLI

                    </th>


                    <th scope="col">

                        DIFFERENZA

                    </th>


                    <th scope="col">

                        % RUOLI SU

                        <br />

                        ACCERTAMENTI

                    </th>


                </tr>


            </thead>



            <tbody>


                <%

                BigDecimal totaleResiduiBilancio =
                    BigDecimal.ZERO;


                BigDecimal totaleRuoli =
                    BigDecimal.ZERO;



                for (GroupData group :
                        gruppiCoerenti) {


                    TotalsData totals =
                        group.getTotals();


                    String nomeTipologia =
                        group.getEntry() != null
                            ? group.getEntry().trim()
                            : "";


                    /* =============================================
                       RESIDUO PER NOME TIPOLOGIA

                       NON più tramite indice i.
                       ============================================= */

                    BigDecimal residuoBilancio =
                        residuiPerTipologia.get(
                            nomeTipologia
                        );


                    if (residuoBilancio == null) {

                        residuoBilancio =
                            BigDecimal.ZERO;
                    }


                    BigDecimal totaleRuolo =
                        Utils.parseItalianNumber(
                            totals.getResidual()
                        );


                    if (totaleRuolo == null) {

                        totaleRuolo =
                            BigDecimal.ZERO;
                    }


                    BigDecimal differenza =
                        residuoBilancio.subtract(
                            totaleRuolo
                        );


                    BigDecimal percentualeRuoli =
                        residuoBilancio.compareTo(
                            BigDecimal.ZERO
                        ) != 0

                        ? totaleRuolo
                            .multiply(
                                BigDecimal.valueOf(100)
                            )
                            .divide(
                                residuoBilancio,
                                10,
                                RoundingMode.HALF_UP
                            )

                        : BigDecimal.ZERO;


                    totaleResiduiBilancio =
                        totaleResiduiBilancio.add(
                            residuoBilancio
                        );


                    totaleRuoli =
                        totaleRuoli.add(
                            totaleRuolo
                        );

                %>



                <tr>


                    <th class="description-cell"
                        scope="row">

                        <%= nomeTipologia %>

                    </th>


                    <!-- =========================================
                         RESIDUO BILANCIO
                         ========================================= -->

                    <td class="number-cell">

                        <%= formatoItaliano3Decimali.format(
                                residuoBilancio
                            ) %>

                    </td>


                    <!-- =========================================
                         RUOLI
                         ========================================= -->

                    <td class="number-cell">

                        <%= formatoItaliano3Decimali.format(
                                totaleRuolo
                            ) %>

                    </td>


                    <!-- =========================================
                         DIFFERENZA
                         ========================================= -->

                    <td class="difference-cell">


                        <span class="difference-content">


                            <span>

                                <%= differenza.signum() < 0
                                    ? "-"
                                    : differenza.signum() > 0
                                        ? "+"
                                        : "" %>

                            </span>


                            <span>

                                <%= formatoItaliano3Decimali.format(
                                        differenza.abs()
                                    ) %>

                            </span>


                        </span>


                    </td>


                    <!-- =========================================
                         PERCENTUALE
                         ========================================= -->

                    <td class="percentage-cell">

                        <%= formatoItaliano3Decimali.format(
                                percentualeRuoli
                            ) %>

                    </td>


                </tr>


                <% } %>



                <!-- =============================================
                     TOTALI
                     ============================================= -->

                <%

                BigDecimal differenzaTotale =
                    totaleResiduiBilancio.subtract(
                        totaleRuoli
                    );


                BigDecimal percentualeTotale =
                    totaleResiduiBilancio.compareTo(
                        BigDecimal.ZERO
                    ) != 0

                    ? totaleRuoli
                        .multiply(
                            BigDecimal.valueOf(100)
                        )
                        .divide(
                            totaleResiduiBilancio,
                            10,
                            RoundingMode.HALF_UP
                        )

                    : BigDecimal.ZERO;

                %>


                <tr>

                    <td></td>

                </tr>


                <tr>


                    <th class="total-label"
                        scope="row">

                        TOTALE

                    </th>


                    <td class="total-number">

                        <%= formatoItaliano3Decimali.format(
                                totaleResiduiBilancio
                            ) %>

                    </td>


                    <td class="total-number">

                        <%= formatoItaliano3Decimali.format(
                                totaleRuoli
                            ) %>

                    </td>


                    <td class="total-difference">


                        <span class="difference-content">


                            <span>

                                <%= differenzaTotale.signum() < 0
                                    ? "-"
                                    : differenzaTotale.signum() > 0
                                        ? "+"
                                        : "" %>

                            </span>


                            <span>

                                <%= formatoItaliano3Decimali.format(
                                        differenzaTotale.abs()
                                    ) %>

                            </span>


                        </span>


                    </td>


                    <td class="total-number">

                        <%= formatoItaliano3Decimali.format(
                                percentualeTotale
                            ) %>

                    </td>


                </tr>


            </tbody>


        </table>


    </div>


    <% } %>


</div>



<!-- ============================================================
     VALORI NON COERENTI
     ============================================================ -->

<% if (hasIncoherentValues) { %>


<div class="collapse mt-4"
     id="nonCoherentValuesValutazione">


    <div class="card border-danger">


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

                    <%= numeroNonCoerenti %>

                </span>


            </div>


        </div>



        <div class="card-body">


            <div class="alert alert-warning">


                <i class="bi bi-info-circle-fill me-2"></i>


                I dati riportati in questa sezione
                fanno riferimento a tipologie che
                non risultano più definite per l'anno

                <strong>
                    <%= selectedYear %>
                </strong>.


                <strong>
                    Chiedere a un amministratore
                    di verificare ed eventualmente
                    rimuovere i vecchi dati.
                </strong>


            </div>



            <!-- =================================================
                 RESIDUI ATTIVI NON COERENTI
                 ================================================= -->

            <% if (hasIncoherentResiduals) { %>


            <h6 class="text-danger fw-bold mt-3">

                <i class="bi bi-wallet2 me-2"></i>

                RESIDUI ATTIVI NON COERENTI

            </h6>


            <div class="table-responsive">


                <table class="table
                              table-bordered
                              table-sm
                              table-hover"
                       style="max-width:700px">


                    <thead class="table-danger">


                        <tr>


                            <th>

                                TIPOLOGIA OBSOLETA

                            </th>


                            <th>

                                IMPORTO RESIDUO

                            </th>


                        </tr>


                    </thead>



                    <tbody>


                        <%

                        for (Map.Entry<String, BigDecimal> entry :
                                residuiNonCoerenti.entrySet()) {

                        %>


                        <tr>


                            <td class="text-danger fw-bold">


                                <i class="bi bi-x-circle-fill
                                          me-1">
                                </i>


                                <%= entry.getKey() %>


                            </td>


                            <td class="text-number">


                                <%= formatoItaliano3Decimali.format(
                                        entry.getValue()
                                    ) %>


                            </td>


                        </tr>


                        <% } %>


                    </tbody>


                </table>


            </div>


            <% } %>



            <!-- =================================================
                 RUOLI NON COERENTI
                 ================================================= -->

            <% if (hasIncoherentGroups) { %>


            <h6 class="text-danger fw-bold mt-4">

                <i class="bi bi-cash-coin me-2"></i>

                RUOLI NON COERENTI

            </h6>


            <%

            for (GroupData group :
                    gruppiNonCoerenti) {

            %>


            <div class="mb-4">


                <div class="mb-2">


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



                <div class="table-responsive">


                    <table class="table
                                  table-bordered
                                  table-sm
                                  table-hover"
                           style="max-width:900px">


                        <thead class="table-danger">


                            <tr>


                                <th>

                                    TIPOLOGIA

                                </th>


                                <th>

                                    ANNO RUOLO

                                </th>


                                <th>

                                    NUM. RUOLO

                                </th>


                                <th>

                                    RESIDUO

                                </th>


                            </tr>


                        </thead>



                        <tbody>


                            <%

                            for (RowData row :
                                    group.getRows()) {

                            %>


                            <tr>


                                <td class="text-danger fw-bold">

                                    <%= row.getEntry() %>

                                </td>


                                <td class="text-center">

                                    <%= row.getRoleYear() %>

                                </td>


                                <td class="text-center">

                                    <%= row.getRoleNumber() %>

                                </td>


                                <td class="text-number">

                                    <%= row.getResidual() %>

                                </td>


                            </tr>


                            <% } %>


                        </tbody>


                    </table>


                </div>


            </div>


            <% } %>


            <% } %>



            <div class="alert alert-danger mb-0">


                <i class="bi bi-shield-exclamation me-2"></i>


                <strong>

                    Intervento amministrativo richiesto.

                </strong>


                I valori sopra elencati
                non partecipano ai calcoli correnti.


            </div>


        </div>


    </div>


</div>


<% } %>



<!-- ============================================================
     SCROLL AUTOMATICO
     ============================================================ -->

<style>

#nonCoherentValuesValutazione {

    scroll-margin-top: 100px;

}

</style>


<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {


        const section =
            document.getElementById(
                "nonCoherentValuesValutazione"
            );


        if (!section) {

            return;
        }


        section.addEventListener(
            "shown.bs.collapse",
            function () {


                section.scrollIntoView({
                    behavior: "smooth",
                    block: "start"
                });


            }
        );

    }
);

</script>