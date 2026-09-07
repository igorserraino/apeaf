<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.utils.*" %>

<%@ page import="java.util.*" %>

<%@ page import="is.five.apeaf.controller.InsDatiFCDEServlet" %>

<%@ page import="is.five.apeaf.dao.*" %>
<%@ page import="is.five.apeaf.dao.model.*" %>


<%

/* ============================================================
   CALLER
   ============================================================ */

request.getSession().setAttribute(
    SessionVariables.CALLER,
    "ins-dati-fcde.jsp"
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
   ANNO FINANZIARIO
   ============================================================ */

AnnoFinanziarioDAO anniDAO =
    new AnnoFinanziarioDAO();


String id_anno_selezionato =
    session.getAttribute(SessionVariables.ANNO) != null
        ? String.valueOf(
            session.getAttribute(SessionVariables.ANNO)
          )
        : "";


String anno_selezionato = "";


try {

    if (!id_anno_selezionato.trim().isEmpty()) {

        anno_selezionato =
            String.valueOf(
                anniDAO
                    .findByID(
                        Integer.parseInt(
                            id_anno_selezionato
                        )
                    )
                    .getAnno()
            );
    }

} catch (Exception exc) {

    anno_selezionato = "";
}


/* ============================================================
   NESSUN ANNO
   ============================================================ */

if (anno_selezionato == null ||
    anno_selezionato.trim().isEmpty()) {

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
   ============================================================ */

int anno;


try {

    anno =
        Integer.parseInt(
            anno_selezionato.trim()
        );

} catch (NumberFormatException e) {

%>

<div class="alert alert-danger">

    Anno finanziario non valido:

    <strong>
        <%= anno_selezionato %>
    </strong>

</div>

<%

    return;
}


/* ============================================================
   TIPOLOGIE DEFINITE

   Nessuna tipologia viene definita in questa pagina.

   Vengono lette esclusivamente dalla tabella tipologie
   utilizzando:
       id_user
       anno
   ============================================================ */

List<Tipologia> tipologie =
    TipologieDAO.findByUserAndAnno(
        user.getId(),
        anno
    );


boolean hasTipologie =
    tipologie != null &&
    !tipologie.isEmpty();


/* ============================================================
   VALORI FCDE MEMORIZZATI

   Mappa:
       nome tipologia -> valore FCDE

   Formato nuovo:
       IMU=100;TARI=200;ALTRO=300
   ============================================================ */

Map<String, String> valoriSalvati =
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


    int legacyPosition = 0;


    for (String token : saved) {


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

           IMU=100
           TARI=250
           Canone patrimoniale=500
           ==================================================== */

        if (token.contains("=")) {


            String[] parts =
                token.split("=", 2);


            String nomeTipologia =
                parts[0].trim();


            String valore =
                parts.length > 1
                    ? parts[1].trim()
                    : "0";


            if (valore.isEmpty()) {

                valore = "0";
            }


            if (!nomeTipologia.isEmpty()) {

                valoriSalvati.put(
                    nomeTipologia,
                    valore
                );
            }


        } else {


            /* =================================================
               COMPATIBILITA' VECCHI RECORD

               Vecchio formato:
                   10;20;30;40;50

               Viene associato temporaneamente alle vecchie
               InsDatiFCDE.TIPOLOGIE[].

               Questa parte può essere eliminata quando tutti
               i record saranno stati risalvati nel nuovo formato.
               ================================================= */

            if (InsDatiFCDE.TIPOLOGIE != null &&
                legacyPosition <
                    InsDatiFCDE.TIPOLOGIE.length) {


                String legacyTipologia =
                    InsDatiFCDE
                        .TIPOLOGIE[legacyPosition];


                if (legacyTipologia != null &&
                    !legacyTipologia.trim().isEmpty()) {


                    valoriSalvati.put(
                        legacyTipologia.trim(),
                        token
                    );
                }
            }


            legacyPosition++;
        }
    }
}


/* ============================================================
   MESSAGGIO
   ============================================================ */

String message =
    (String) session.getAttribute(
        InsDatiFCDEServlet.class.getName()
    );

%>



<!-- ============================================================
     TITOLO
     ============================================================ -->

<h3 class="mb-4">

    <i class="bi bi-sliders me-2"></i>

    INSERIMENTO DATI FCDE

    <span class="badge bg-primary ms-2">

        <%= anno %>

    </span>

</h3>



<!-- ============================================================
     MESSAGGIO SERVLET
     ============================================================ -->

<% if (message != null) { %>


<div class="alert alert-primary
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
        InsDatiFCDEServlet.class.getName()
    );

}

%>



<!-- ============================================================
     NESSUNA TIPOLOGIA
     ============================================================ -->

<% if (!hasTipologie) { %>


<div class="alert alert-warning
            d-flex
            align-items-center
            shadow-sm
            mb-4">

    <i class="bi bi-exclamation-triangle-fill
              fs-3
              me-3">
    </i>


    <div>

        <strong>

            Nessuna tipologia definita
            per l'anno <%= anno %>.

        </strong>

        <br />

        Per inserire i dati FCDE
        è necessario definire prima almeno
        una tipologia dalla pagina

        <strong>
            Def. tipologie
        </strong>.

    </div>

</div>


<% } %>



<!-- ============================================================
     FORM FCDE
     ============================================================ -->

<form action="ins-dati-fcde"
      method="post">


    <input type="hidden"
           name="anno"
           value="<%= anno %>" />


    <div class="table-responsive">


        <table class="table
                      table-bordered
                      table-hover
                      table-sm
                      table-residui">


            <!-- =================================================
                 HEADER
                 ================================================= -->

            <thead class="table-secondary">

                <tr>

                    <th style="width:300px;">

                        TIPOLOGIA ENTRATA

                    </th>


                    <th style="width:180px;">

                        QUOTA FCDE ACCANTONATA
                        A CONSUNTIVO

                    </th>

                </tr>

            </thead>


            <tbody>


                <!-- =============================================
                     TIPOLOGIE DINAMICHE
                     ============================================= -->

                <%

                if (hasTipologie) {


                    for (Tipologia tipologia : tipologie) {


                        if (tipologia == null ||
                            tipologia.getValue() == null ||
                            tipologia
                                .getValue()
                                .trim()
                                .isEmpty()) {

                            continue;
                        }


                        String nomeTipologia =
                            tipologia
                                .getValue()
                                .trim();


                        String valore =
                            valoriSalvati.get(
                                nomeTipologia
                            );


                        if (valore == null ||
                            valore.trim().isEmpty()) {

                            valore = "0";
                        }

                %>


                <tr>


                    <!-- =========================================
                         TIPOLOGIA

                         Hidden perché non è modificabile qui.
                         ========================================= -->

                    <td class="fw-bold">


                        <input type="hidden"
                               name="nuova_tipologia[]"
                               value="<%= nomeTipologia %>" />


                        <div class="d-flex
                                    align-items-center">


                            <i class="bi bi-tag-fill
                                      me-2
                                      text-primary">
                            </i>


                            <span>

                                <%= nomeTipologia %>

                            </span>

                        </div>

                    </td>


                    <!-- =========================================
                         VALORE FCDE
                         ========================================= -->

                    <td>


                        <input type="number"
                               name="nuova_tipologia_valore[]"
                               class="form-control
                                      form-control-sm
                                      bg-dark
                                      text-white
                                      valore-fcde"
                               value="<%= valore %>"
                               min="0"
                               step="any"
                               required />

                    </td>


                </tr>


                <%

                    }

                }

                %>



                <!-- =============================================
                     TOTALE
                     ============================================= -->

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



    <!-- ========================================================
         SALVA
         ======================================================== -->

    <button type="submit"
            class="btn btn-primary btn-sm mt-2"
            <%= !hasTipologie
                ? "disabled"
                : "" %>>


        <i class="bi bi-floppy-fill me-1"></i>

        Salva valori

    </button>


</form>



<!-- ============================================================
     JAVASCRIPT
     ============================================================ -->

<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {


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


        /* =====================================================
           CALCOLO TOTALE FCDE
           ===================================================== */

        function updateTotalFCDE() {


            let total = 0;


            document
                .querySelectorAll(
                    ".valore-fcde"
                )
                .forEach(
                    function(input) {


                        const value =
                            Number(
                                input.value
                            );


                        if (Number.isFinite(value)) {

                            total += value;
                        }

                    }
                );


            if (totalOutput) {

                totalOutput.textContent =
                    italianNumberFormat.format(
                        total
                    );
            }
        }


        /* =====================================================
           LISTENER
           ===================================================== */

        document
            .querySelectorAll(
                ".valore-fcde"
            )
            .forEach(
                function(input) {


                    input.addEventListener(
                        "input",
                        updateTotalFCDE
                    );

                }
            );


        updateTotalFCDE();

    }
);

</script>