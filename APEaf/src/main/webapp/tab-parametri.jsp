<%@ page import="is.five.apeaf.utils.*" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.dao.model.*" %>
<%@ page import="is.five.apeaf.dao.TabParDAO" %>
<%@ page import="is.five.apeaf.controller.TabParServlet" %>
<%@ page import="java.util.List" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<style>
    input {
        text-align: right;
    }

    .delete-parameter-button {
        line-height: 1;
    }
</style>

<%
request.getSession().setAttribute(SessionVariables.CALLER, "tab-parametri.jsp");

UserView user = (UserView) request.getSession().getAttribute("ubAP");
if (user == null || !user.getActive()) {
    response.sendRedirect("index.jsp");
    return;
}

List<TabPar> valoriSanzione = TabParDAO.findByUserAndType(
        user.getId(), TabPar.TYPE_SANZIONE);

List<TabPar> valoriInteressi = TabParDAO.findByUserAndType(
        user.getId(), TabPar.TYPE_INTERESSI);

boolean limiteSanzioniRaggiunto =
        valoriSanzione != null && valoriSanzione.size() >= 3;

boolean limiteInteressiRaggiunto =
        valoriInteressi != null && valoriInteressi.size() >= 3;
%>

<h3 class="mb-4">
    <i class="bi bi-sliders"></i> TABELLA PARAMETRI
</h3>

<div class="bg-secondary rounded p-4 mb-4">
    <h5 class="mb-3">
        <i class="bi bi-percent"></i> Parametri abbattimento
    </h5>

    <p class="alert alert-warning mb-4" role="note">
        <i class="bi bi-info-circle-fill me-2"></i>
        È possibile configurare massimo 3 parametri per sanzione e
        3 parametri per interessi.
    </p>

    <% if (session.getAttribute(TabParServlet.class.getName()) != null) { %>
        <div class="alert alert-primary">
            <%= session.getAttribute(TabParServlet.class.getName()) %>
        </div>

        <% session.removeAttribute(TabParServlet.class.getName()); %>
    <% } %>

    <form action="TabParServlet" method="post">
        <div class="row mb-3" style="width:400px">
            <div class="col-md-6">
                <label class="form-label" for="abbattimento_sanzione">
                    % Abbattimento sanzione
                </label>
                <input
                    id="abbattimento_sanzione"
                    type="number"
                    class="form-control bg-dark text-white"
                    name="abbattimento_sanzione"
                    placeholder="0"
                    min="0"
                    max="100"
                    step="1"
                    <%= limiteSanzioniRaggiunto ? "disabled" : "" %> />

                <% if (limiteSanzioniRaggiunto) { %>
                    <div class="form-text text-warning">
                        Limite di 3 parametri raggiunto.
                    </div>
                <% } %>
            </div>

            <div class="col-md-6">
                <label class="form-label" for="abbattimento_interessi">
                    % Abbattimento interessi
                </label>
                <input
                    id="abbattimento_interessi"
                    type="number"
                    class="form-control bg-dark text-white"
                    name="abbattimento_interessi"
                    placeholder="0"
                    min="0"
                    max="100"
                    step="1"
                    <%= limiteInteressiRaggiunto ? "disabled" : "" %> />

                <% if (limiteInteressiRaggiunto) { %>
                    <div class="form-text text-warning">
                        Limite di 3 parametri raggiunto.
                    </div>
                <% } %>
            </div>
        </div>

        <button
            type="submit"
            class="btn btn-primary"
            <%= limiteSanzioniRaggiunto && limiteInteressiRaggiunto
                    ? "disabled"
                    : "" %>>
            <i class="bi bi-save"></i> Salva parametri
        </button>
    </form>
</div>

<div class="bg-secondary rounded p-4 mt-4" style="width:700px">
    <h5 class="mb-3">
        <i class="bi bi-table"></i> Valori memorizzati
    </h5>

    <div class="table-responsive">
        <table class="table table-bordered table-sm align-middle">
            <thead>
                <tr>
                    <th>Tipo</th>
                    <th>Valore</th>
                    <th>Data creazione</th>
                    <th class="text-center" aria-label="Azioni">
                        <i class="bi bi-trash-fill" aria-hidden="true"></i>
                    </th>
                </tr>
            </thead>
            <tbody>
                <% for (TabPar p : valoriSanzione) { %>
                    <tr style="background:#eed7d9">
                        <td>Abbattimento sanzione</td>
                        <td class="text-end"><%= p.getValue() %>%</td>
                        <td class="text-end">
                            <%= DateUtils.formatTimestamp(p.getCreationTimestamp()) %>
                        </td>
                        <td class="text-center">
                            <form
                                action="TabParServlet"
                                method="post"
                                class="d-inline"
                                onsubmit="return confirm('Eliminare questo parametro di abbattimento sanzione?');">
                                <input type="hidden" name="operation" value="delete" />
                                <input type="hidden" name="id" value="<%= p.getId() %>" />
                                <button
                                    type="submit"
                                    class="btn btn-sm btn-outline-danger delete-parameter-button"
                                    title="Elimina parametro"
                                    aria-label="Elimina parametro di abbattimento sanzione">
                                    <i class="bi bi-trash-fill" aria-hidden="true"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                <% } %>

                <tr aria-hidden="true">
                    <td colspan="4" class="border-0 bg-transparent py-2"></td>
                </tr>

                <% for (TabPar p : valoriInteressi) { %>
                    <tr style="background:#d7e7f5">
                        <td>Abbattimento interessi</td>
                        <td class="text-end"><%= p.getValue() %>%</td>
                        <td class="text-end">
                            <%= DateUtils.formatTimestamp(p.getCreationTimestamp()) %>
                        </td>
                        <td class="text-center">
                            <form
                                action="TabParServlet"
                                method="post"
                                class="d-inline"
                                onsubmit="return confirm('Eliminare questo parametro di abbattimento interessi?');">
                                <input type="hidden" name="operation" value="delete" />
                                <input type="hidden" name="id" value="<%= p.getId() %>" />
                                <button
                                    type="submit"
                                    class="btn btn-sm btn-outline-danger delete-parameter-button"
                                    title="Elimina parametro"
                                    aria-label="Elimina parametro di abbattimento interessi">
                                    <i class="bi bi-trash-fill" aria-hidden="true"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>
