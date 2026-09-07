<%@page import="is.five.apeaf.utils.*"%>
<%@page import="is.five.apeaf.utils.SessionVariables"%>
<%@page import="is.five.apeaf.dao.model.*"%>
<%@page import="is.five.apeaf.dao.TipologieDAO"%>
<%@page import="is.five.apeaf.controller.TipologieServlet"%>
<%@page import="java.util.List"%>

<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%

request.getSession().setAttribute(
    SessionVariables.CALLER,
    "def-tipologie.jsp"
);

UserView user =
    (UserView) request.getSession()
                      .getAttribute("ubAP");

if (user == null || !user.getActive()) {

    response.sendRedirect("index.jsp");
    return;
}


/* ==============================
   ANNO
   ============================== */

Integer anno = null;

Object annoObj =
    session.getAttribute("anno_selezionato");

if (annoObj != null) {

    try {

        anno = Integer.valueOf(
            annoObj.toString()
        );

    } catch (Exception e) {

        anno = null;
    }
}


/* ==============================
   RECORDS
   ============================== */

List<Tipologia> tipologie = null;

if (anno != null) {

    tipologie =
        TipologieDAO.findByUserAndAnno(
            user.getId(),
            anno
        );
}


/* ==============================
   MESSAGE
   ============================== */

String message = (String)
    session.getAttribute(
        TipologieServlet.class.getName()
    );

session.removeAttribute(
    TipologieServlet.class.getName()
);

%>


<div class="bg-secondary rounded h-100 p-4"
     style="width:800px;">

    <div class="d-flex justify-content-between
                align-items-center mb-4">

        <div>

            <h5 class="mb-1">

                <i class="bi bi-tags-fill me-2"></i>

                Definizione tipologie

            </h5>

            <% if (anno != null) { %>

                <span class="badge bg-primary">

                    Anno <%= anno %>

                </span>

            <% } %>

        </div>

    </div>


    <% if (message != null) { %>

        <div class="alert alert-primary
                    alert-dismissible fade show"
             role="alert">

            <%= message %>

            <button type="button"
                    class="btn-close"
                    data-bs-dismiss="alert">
            </button>

        </div>

    <% } %>


    <% if (anno == null) { %>

        <div class="alert alert-warning">

            <i class="bi bi-exclamation-triangle-fill me-2"></i>

            Selezionare prima un anno.

        </div>

    <% } else { %>


        <!-- ==========================
             NUOVA TIPOLOGIA
             ========================== -->

        <form action="TipologieServlet"
              method="post"
              class="mb-4">

            <input type="hidden"
                   name="action"
                   value="save">

            <input type="hidden"
                   name="anno"
                   value="<%= anno %>">


            <div class="row align-items-end">

                <div class="col-md-8">

                    <label for="value"
                           class="form-label">

                        Nuova tipologia

                    </label>

                    <input type="text"
                           class="form-control"
                           id="value"
                           name="value"
                           maxlength="45"
                           autocomplete="off"
                           placeholder="Inserire la tipologia..."
                           required  style="text-align:left">

                </div>


                <div class="col-md-4">

                    <button type="submit"
                            class="btn btn-primary w-100">

                        <i class="bi bi-plus-circle me-2"></i>

                        Memorizza tipologia

                    </button>

                </div>

            </div>

        </form>


        <!-- ==========================
             TIPOLOGIE MEMORIZZATE
             ========================== -->

        <div class="table-responsive">

            <table class="table
                          table-bordered
                          table-hover
                          align-middle">

                <thead>

                    <tr>

                        <th style="width:80px;">
                            #
                        </th>

                        <th>
                            Tipologia
                        </th>

                        <th style="width:120px;"
                            class="text-center">
                            Anno
                        </th>

                        <th style="width:180px;"
                            class="text-center">
                            Inserimento
                        </th>

                        <th style="width:90px;"
                            class="text-center">
                        </th>

                    </tr>

                </thead>


                <tbody>

                <%

                if (tipologie == null
                        || tipologie.isEmpty()) {

                %>

                    <tr>

                        <td colspan="5"
                            class="text-center text-muted py-4">

                            <i class="bi bi-info-circle me-2"></i>

                            Nessuna tipologia definita
                            per l'anno <%= anno %>.

                        </td>

                    </tr>

                <%

                } else {

                    int num = 1;

                    for (Tipologia t : tipologie) {

                %>

                    <tr>

                        <td>
                            <%= num++ %>
                        </td>


                        <td>

                            <span class="badge
                                         bg-light
                                         text-dark
                                         fs-6">

                                <%= t.getValue() %>

                            </span>

                        </td>


                        <td class="text-center">

                            <%= t.getAnno() %>

                        </td>


                        <td class="text-center">

                            <%=
                            t.getCreationTimestamp() != null
                            ?
                            Utils.formatTimestamp(
                                t.getCreationTimestamp()
                            )
                            :
                            ""
                            %>

                        </td>


                        <td class="text-center">

                            <form action="TipologieServlet"
                                  method="post"
                                  style="display:inline;"
                                  onsubmit="
                                    return confirm(
                                      'Eliminare la tipologia?'
                                    );
                                  ">

                                <input type="hidden"
                                       name="action"
                                       value="delete">

                                <input type="hidden"
                                       name="id"
                                       value="<%= t.getId() %>">

                                <button type="submit"
                                        class="btn
                                               btn-sm
                                               btn-outline-danger"
                                        title="Elimina">

                                    <i class="bi bi-trash3"></i>

                                </button>

                            </form>

                        </td>

                    </tr>

                <%

                    }
                }

                %>

                </tbody>

            </table>

        </div>


        <div class="mt-3 text-muted">

            <small>

                <i class="bi bi-info-circle me-1"></i>

                Le tipologie definite sono associate
                all'utente corrente e all'anno
                selezionato.

            </small>

        </div>

    <% } %>

</div>