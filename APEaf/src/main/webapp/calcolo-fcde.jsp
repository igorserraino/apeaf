<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>

<%@ page import="is.five.apeaf.dao.AnnoFinanziarioDAO" %>
<%@ page import="is.five.apeaf.dao.InsResiduiAttiviDAO" %>
<%@ page import="is.five.apeaf.dao.InsDatiFCDEDAO" %>
<%@ page import="is.five.apeaf.dao.TipologieDAO" %>

<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%@ page import="is.five.apeaf.dao.model.InsResiduiAttivi" %>
<%@ page import="is.five.apeaf.dao.model.InsDatiFCDE" %>
<%@ page import="is.five.apeaf.dao.model.Tipologia" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.utils.Utils" %>


<%

/* ============================================================
   CALLER
   ============================================================ */

request.getSession().setAttribute(
    SessionVariables.CALLER,
    "calcolo-fcde.jsp"
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
   ANNO FINANZIARIO SELEZIONATO
   ============================================================ */

String idAnnoSelezionato =
    session.getAttribute(SessionVariables.ANNO) != null
        ? String.valueOf(
            session.getAttribute(SessionVariables.ANNO)
          )
        : "";


String annoSelezionato = "";


try {

    if (!idAnnoSelezionato.trim().isEmpty()) {

        AnnoFinanziarioDAO anniDAO =
            new AnnoFinanziarioDAO();


        annoSelezionato =
            String.valueOf(
                anniDAO
                    .findByID(
                        Integer.parseInt(
                            idAnnoSelezionato.trim()
                        )
                    )
                    .getAnno()
            );
    }

} catch (Exception exc) {

    annoSelezionato = "";
}


/* ============================================================
   NESSUN ANNO
   ============================================================ */

if (annoSelezionato == null ||
    annoSelezionato.trim().isEmpty()) {

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

Integer anno;


try {

    anno =
        Integer.valueOf(
            annoSelezionato.trim()
        );

} catch (NumberFormatException exc) {

%>


<div class="alert alert-danger"
     role="alert">

    <i class="bi bi-exclamation-triangle-fill me-2"></i>

    Anno finanziario non valido:

    <strong>
        <%= annoSelezionato %>
    </strong>

</div>


<%

    return;
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
        anno
    );


Set<String> tipologieValide =
    new TreeSet<String>(
        String.CASE_INSENSITIVE_ORDER
    );


if (tipologieDefinite != null) {

    for (Tipologia tipologia :
            tipologieDefinite) {


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
   RECORD DB
   ============================================================ */

InsResiduiAttivi residuiAttivi =
    null;


InsDatiFCDE datiFCDE =
    null;


try {

    residuiAttivi =
        InsResiduiAttiviDAO.findByUserAndAnno(
            user.getId(),
            anno
        );

} catch (Exception exc) {

    residuiAttivi = null;
}


try {

    datiFCDE =
        InsDatiFCDEDAO.findByUserAndAnno(
            user.getId(),
            anno
        );

} catch (Exception exc) {

    datiFCDE = null;
}


/* ============================================================
   MAPPE DATI

   residuiPerTipologia
       -> residui coerenti

   fcdePerTipologia
       -> FCDE coerente

   residuiNonCoerenti
       -> residui appartenenti a tipologie obsolete

   fcdeNonCoerente
       -> FCDE appartenente a tipologie obsolete
   ============================================================ */

Map<String, BigDecimal> residuiPerTipologia =
    new TreeMap<String, BigDecimal>(
        String.CASE_INSENSITIVE_ORDER
    );


Map<String, BigDecimal> fcdePerTipologia =
    new TreeMap<String, BigDecimal>(
        String.CASE_INSENSITIVE_ORDER
    );


Map<String, BigDecimal> residuiNonCoerenti =
    new TreeMap<String, BigDecimal>(
        String.CASE_INSENSITIVE_ORDER
    );


Map<String, BigDecimal> fcdeNonCoerente =
    new TreeMap<String, BigDecimal>(
        String.CASE_INSENSITIVE_ORDER
    );



/* ============================================================
   LETTURA RESIDUI ATTIVI

   Regola:
   - se nel record esiste almeno un "=" => NUOVO FORMATO
   - in nuovo formato ignoriamo completamente i token senza "="
   - valori obsoleti = 0 NON vengono mostrati
   ============================================================ */

if (residuiAttivi != null &&
    residuiAttivi.getValue() != null &&
    !residuiAttivi.getValue().trim().isEmpty()) {


    String rawResidui =
        residuiAttivi
            .getValue()
            .trim();


    String[] tokens =
        rawResidui.split(";", -1);


    boolean nuovoFormatoResidui =
        false;


    for (String token : tokens) {

        if (token != null &&
            token.contains("=")) {

            nuovoFormatoResidui =
                true;

            break;
        }
    }


    /* ========================================================
       NUOVO FORMATO
       ======================================================== */

    if (nuovoFormatoResidui) {


        for (String token : tokens) {


            if (token == null) {
                continue;
            }


            token =
                token.trim();


            if (token.isEmpty()) {
                continue;
            }


            /*
             * Se il record è nuovo, i vecchi campi
             * posizionali vengono ignorati.
             */
            if (!token.contains("=")) {
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


            if (nome.isEmpty()) {
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

                    valore =
                        parsed;
                }

            } catch (Exception exc) {

                valore =
                    BigDecimal.ZERO;
            }


            if (tipologieValide.contains(nome)) {


                residuiPerTipologia.put(
                    nome,
                    valore
                );


            } else {


                /*
                 * Mostriamo come non coerente
                 * solo un dato realmente significativo.
                 */
                if (valore.compareTo(
                        BigDecimal.ZERO) != 0) {


                    residuiNonCoerenti.put(
                        nome,
                        valore
                    );
                }
            }
        }


    } else {


        /* ====================================================
           VECCHIO FORMATO POSIZIONALE PURO
           ==================================================== */

        int legacyPosition =
            0;


        for (String token : tokens) {


            if (legacyPosition >=
                InsResiduiAttivi.TIPOLOGIE.length) {

                break;
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


            if (token == null) {
                continue;
            }


            token =
                token.trim();


            BigDecimal valore =
                BigDecimal.ZERO;


            if (!token.isEmpty()) {

                try {

                    BigDecimal parsed =
                        Utils.parseItalianNumber(
                            token
                        );


                    if (parsed != null) {

                        valore =
                            parsed;
                    }

                } catch (Exception exc) {

                    valore =
                        BigDecimal.ZERO;
                }
            }


            if (tipologieValide.contains(
                    nomeLegacy)) {


                residuiPerTipologia.put(
                    nomeLegacy,
                    valore
                );


            } else {


                /*
                 * Zero legacy non significa
                 * dato storico da bonificare.
                 */
                if (valore.compareTo(
                        BigDecimal.ZERO) != 0) {


                    residuiNonCoerenti.put(
                        nomeLegacy,
                        valore
                    );
                }
            }
        }
    }
}


/* ============================================================
   LETTURA DATI FCDE
   ============================================================ */

if (datiFCDE != null &&
    datiFCDE.getValue() != null &&
    !datiFCDE.getValue().trim().isEmpty()) {


    String[] tokens =
        datiFCDE
            .getValue()
            .split(";", -1);


    int legacyPosition = 0;


    for (String token : tokens) {


        if (token == null) {

            continue;
        }


        token =
            token.trim();


        if (token.isEmpty()) {

            continue;
        }


        /* ====================================================
           NUOVO FORMATO
               IMU=50
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


            if (nome.isEmpty()) {

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


            if (tipologieValide.contains(nome)) {


                fcdePerTipologia.put(
                    nome,
                    valore
                );


            } else {


                fcdeNonCoerente.put(
                    nome,
                    valore
                );

            }


        } else {


            /* =================================================
               VECCHIO FORMATO POSIZIONALE
               ================================================= */

            if (InsDatiFCDE.TIPOLOGIE != null &&
                legacyPosition <
                    InsDatiFCDE.TIPOLOGIE.length) {


                String nomeLegacy =
                    InsDatiFCDE
                        .TIPOLOGIE[legacyPosition];


                if (nomeLegacy != null &&
                    !nomeLegacy.trim().isEmpty()) {


                    nomeLegacy =
                        nomeLegacy.trim();


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

                    } catch (Exception exc) {

                        valore =
                            BigDecimal.ZERO;
                    }


                    if (tipologieValide.contains(
                            nomeLegacy)) {


                        fcdePerTipologia.put(
                            nomeLegacy,
                            valore
                        );


                    } else {


                        fcdeNonCoerente.put(
                            nomeLegacy,
                            valore
                        );

                    }
                }
            }


            legacyPosition++;
        }
    }
}


/* ============================================================
   TOTALI COERENTI
   ============================================================ */

BigDecimal totaleResiduiAttivi =
    BigDecimal.ZERO;


BigDecimal totaleFCDE =
    BigDecimal.ZERO;


for (String tipologia :
        tipologieValide) {


    BigDecimal residuo =
        residuiPerTipologia.get(
            tipologia
        );


    if (residuo == null) {

        residuo =
            BigDecimal.ZERO;
    }


    BigDecimal fcde =
        fcdePerTipologia.get(
            tipologia
        );


    if (fcde == null) {

        fcde =
            BigDecimal.ZERO;
    }


    totaleResiduiAttivi =
        totaleResiduiAttivi.add(
            residuo
        );


    totaleFCDE =
        totaleFCDE.add(
            fcde
        );
}


/* ============================================================
   PERCENTUALE TOTALE
   ============================================================ */

BigDecimal percentualeTotaleAccantonamento =
    BigDecimal.ZERO;


if (totaleResiduiAttivi.compareTo(
        BigDecimal.ZERO) != 0) {


    percentualeTotaleAccantonamento =
        totaleFCDE
            .multiply(
                BigDecimal.valueOf(100)
            )
            .divide(
                totaleResiduiAttivi,
                3,
                RoundingMode.HALF_UP
            );
}


/* ============================================================
   DATI NON COERENTI

   Uniamo i nomi presenti in una delle due sorgenti.
   ============================================================ */

Set<String> nomiNonCoerenti =
    new TreeSet<String>(
        String.CASE_INSENSITIVE_ORDER
    );


nomiNonCoerenti.addAll(
    residuiNonCoerenti.keySet()
);


nomiNonCoerenti.addAll(
    fcdeNonCoerente.keySet()
);


boolean hasIncoherentValues =
    !nomiNonCoerenti.isEmpty();

%>



<!-- ============================================================
     TITOLO
     ============================================================ -->

<h3 class="mb-4">

    <i class="bi bi-calculator me-2"></i>

    CALCOLO % ACCANTONAMENTO FCDE


    <span class="badge bg-primary ms-2">

        <%= annoSelezionato %>

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

            Sono state individuate

            <strong>
                <%= nomiNonCoerenti.size() %>
            </strong>

            tipologie presenti nei dati Residui Attivi
            e/o FCDE ma non nella configurazione corrente
            dell'anno

            <strong>
                <%= anno %>
            </strong>.

        </div>


        <div class="mt-2">

            Questi valori

            <strong>
                non vengono utilizzati nel calcolo
                della percentuale di accantonamento FCDE.
            </strong>

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
                data-bs-target="#nonCoherentValuesCalcoloFcde"
                aria-expanded="false"
                aria-controls="nonCoherentValuesCalcoloFcde">


            <i class="bi bi-eye-fill me-1"></i>

            Mostra valori non coerenti


            <span class="badge bg-danger ms-1">

                <%= nomiNonCoerenti.size() %>

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

                DATI COMPUTATI DA INS. RESIDUI ATTIVI
                E INS. DATI FCDE

            </span>


        </div>


    </div>



    <% if (tipologieValide.isEmpty()) { %>


        <div class="alert alert-info mb-0">

            <i class="bi bi-info-circle-fill me-2"></i>

            Nessuna tipologia definita
            per l'anno <%= anno %>.

        </div>


    <% } else { %>


    <div class="table-responsive">


        <table class="valutazione-ruoli-table"
               aria-label="Confronto tra residui attivi e FCDE"
               style="max-width:1200px;">


            <colgroup>

                <col class="col-tipologia" />

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

                        RESIDUI ATTIVI

                    </th>


                    <th scope="col">

                        FCDE

                    </th>


                    <th scope="col">

                        % ACCANTONAMENTO

                    </th>


                </tr>


            </thead>



            <tbody>


                <%

                for (String tipologia :
                        tipologieValide) {


                    BigDecimal residuo =
                        residuiPerTipologia.get(
                            tipologia
                        );


                    if (residuo == null) {

                        residuo =
                            BigDecimal.ZERO;
                    }


                    BigDecimal fcde =
                        fcdePerTipologia.get(
                            tipologia
                        );


                    if (fcde == null) {

                        fcde =
                            BigDecimal.ZERO;
                    }


                    BigDecimal percentuale =
                        BigDecimal.ZERO;


                    if (residuo.compareTo(
                            BigDecimal.ZERO) != 0) {


                        percentuale =
                            fcde
                                .multiply(
                                    BigDecimal.valueOf(
                                        100
                                    )
                                )
                                .divide(
                                    residuo,
                                    3,
                                    RoundingMode.HALF_UP
                                );
                    }

                %>



                <tr>


                    <!-- TIPOLOGIA -->

                    <th class="description-cell"
                        scope="row">

                        <%= tipologia %>

                    </th>


                    <!-- RESIDUO -->

                    <td class="number-cell">

                        <%= formatoItaliano3Decimali.format(
                                residuo
                            ) %>

                    </td>


                    <!-- FCDE -->

                    <td class="number-cell">

                        <%= formatoItaliano3Decimali.format(
                                fcde
                            ) %>

                    </td>


                    <!-- % -->

                    <td class="percentage-cell">

                        <%= formatoItaliano3Decimali.format(
                                percentuale
                            ) %>%

                    </td>


                </tr>


                <% } %>



                <!-- =============================================
                     SPACER
                     ============================================= -->

                <tr class="table-spacer-row">


                    <td colspan="4"
                        style="
                            height:18px;
                            padding:0;
                            border:none;
                            background:transparent;
                        ">
                    </td>


                </tr>



                <!-- =============================================
                     TOTALI
                     ============================================= -->

                <tr class="totals-row">


                    <th class="total-label"
                        scope="row">

                        TOTALE

                    </th>


                    <td class="total-number">

                        <%= formatoItaliano3Decimali.format(
                                totaleResiduiAttivi
                            ) %>

                    </td>


                    <td class="total-number">

                        <%= formatoItaliano3Decimali.format(
                                totaleFCDE
                            ) %>

                    </td>


                    <td class="total-number
                               percentage-cell">

                        <%= formatoItaliano3Decimali.format(
                                percentualeTotaleAccantonamento
                            ) %>%

                    </td>


                </tr>


            </tbody>


        </table>


    </div>


    <% } %>


</div>



<!-- ============================================================
     DATI NON COERENTI
     ============================================================ -->

<% if (hasIncoherentValues) { %>


<div class="collapse mt-4"
     id="nonCoherentValuesCalcoloFcde">


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

                    <%= nomiNonCoerenti.size() %>

                </span>


            </div>


        </div>



        <div class="card-body">


            <div class="alert alert-warning">


                <div class="d-flex align-items-start">


                    <i class="bi bi-info-circle-fill
                              fs-4
                              me-3">
                    </i>


                    <div>


                        <strong>

                            Sono presenti valori relativi
                            a vecchie tipologie.

                        </strong>


                        <br />


                        Le righe riportate di seguito
                        provengono dai dati

                        <strong>
                            Residui Attivi
                        </strong>

                        e/o

                        <strong>
                            FCDE
                        </strong>

                        ma la relativa tipologia
                        non è più presente nella configurazione

                        <strong>
                            Def. tipologie
                        </strong>

                        per l'anno

                        <strong>
                            <%= anno %>
                        </strong>.


                        <br /><br />


                        Questi dati

                        <strong>
                            non partecipano ai calcoli correnti.
                        </strong>


                        Se non sono più necessari,

                        <strong>
                            chiedere a un amministratore
                            di rimuovere i vecchi dati.
                        </strong>


                    </div>


                </div>


            </div>



            <!-- =================================================
                 TABELLA NON COERENTI
                 ================================================= -->

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

                                RESIDUO ATTIVO

                            </th>


                            <th>

                                FCDE

                            </th>


                            <th>

                                ORIGINE

                            </th>


                        </tr>


                    </thead>



                    <tbody>


                        <%

                        for (String tipologia :
                                nomiNonCoerenti) {


                            BigDecimal residuo =
                                residuiNonCoerenti.get(
                                    tipologia
                                );


                            BigDecimal fcde =
                                fcdeNonCoerente.get(
                                    tipologia
                                );


                            boolean hasResiduo =
                                residuo != null;


                            boolean hasFcde =
                                fcde != null;


                            if (residuo == null) {

                                residuo =
                                    BigDecimal.ZERO;
                            }


                            if (fcde == null) {

                                fcde =
                                    BigDecimal.ZERO;
                            }


                            String origine;


                            if (hasResiduo &&
                                hasFcde) {

                                origine =
                                    "Residui Attivi + FCDE";

                            } else if (hasResiduo) {

                                origine =
                                    "Residui Attivi";

                            } else {

                                origine =
                                    "FCDE";
                            }

                        %>



                        <tr>


                            <td class="text-danger fw-bold">


                                <i class="bi bi-x-circle-fill
                                          me-1">
                                </i>


                                <%= tipologia %>


                            </td>


                            <td class="text-number">


                                <% if (hasResiduo) { %>


                                    <%= formatoItaliano3Decimali.format(
                                            residuo
                                        ) %>


                                <% } else { %>


                                    <span class="text-muted">
                                        -
                                    </span>


                                <% } %>


                            </td>


                            <td class="text-number">


                                <% if (hasFcde) { %>


                                    <%= formatoItaliano3Decimali.format(
                                            fcde
                                        ) %>


                                <% } else { %>


                                    <span class="text-muted">
                                        -
                                    </span>


                                <% } %>


                            </td>


                            <td>


                                <span class="badge bg-danger">

                                    <%= origine %>

                                </span>


                            </td>


                        </tr>


                        <% } %>


                    </tbody>


                </table>


            </div>



            <!-- =================================================
                 WARNING ADMIN
                 ================================================= -->

            <div class="alert alert-danger mb-0">


                <i class="bi bi-shield-exclamation me-2"></i>


                <strong>

                    Intervento amministrativo richiesto:

                </strong>


                questi dati appartengono a tipologie
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
     SCROLL AUTOMATICO
     ============================================================ -->

<style>

#nonCoherentValuesCalcoloFcde {

    scroll-margin-top: 100px;

}

</style>


<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {


        const section =
            document.getElementById(
                "nonCoherentValuesCalcoloFcde"
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