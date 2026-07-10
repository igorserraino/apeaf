<%@page import="is.five.apeaf.utils.*"%>
<%@page import="is.five.apeaf.utils.SessionVariables"%>
<%@ page import="is.five.apeaf.dao.model.*"%>
<%@ page import="is.five.apeaf.dao.TabParDAO"%>
<%@ page import="java.math.BigDecimal"%>
<%@ page import="is.five.apeaf.controller.TabParServlet"%>
<%@ page import="java.util.List" %>

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<style>
input {text-align:right}
</style>

<% 
	request.getSession().setAttribute(SessionVariables.CALLER, "tab-parametri.jsp");

   UserView user = (UserView) request.getSession().getAttribute("ubAP");
   if (user == null || !user.getActive()) {
		response.sendRedirect("index.jsp");
		return;
	}
   List<TabPar> valoriSanzione = TabParDAO.findByUserAndType(

	        user.getId(),

	        TabPar.TYPE_SANZIONE

	    );

	    List<TabPar> valoriInteressi = TabParDAO.findByUserAndType(

	        user.getId(),

	        TabPar.TYPE_INTERESSI

	    );
 
   %>

<h3 class="mb-4">
	<i class="bi bi-sliders"></i> TABELLA PARAMETRI
</h3>

<div class="bg-secondary rounded p-4 mb-4">

	<h5 class="mb-3">

		<i class="bi bi-percent"></i> Parametri abbattimento

	</h5>

	<% if (session.getAttribute(TabParServlet.class.getName()) != null) { %>

	<div class="alert alert-primary">

		<%= session.getAttribute(TabParServlet.class.getName()) %>

	</div>

	<%
            session.removeAttribute(TabParServlet.class.getName());
        %>

	<% } %>

	<form action="TabParServlet" method="post">

		<div class="row mb-3" style="width:400px">

			<div class="col-md-6">

				<label class="form-label"> % Abbattimento sanzione </label> <input
					type="number" class="form-control bg-dark text-white"
					name="abbattimento_sanzione" placeholder=0 min="0"
					max="100" step="1" />

			</div>

			<div class="col-md-6">

				<label class="form-label"> % Abbattimento interessi </label> <input
					type="number" class="form-control bg-dark text-white"
					name="abbattimento_interessi" placeholder=0 
					min="0" max="100" step="1" />

			</div>

		</div>

		<button type="submit" class="btn btn-primary">

			<i class="bi bi-save"></i> Salva parametri

		</button>

	</form>

</div>

<div class="bg-secondary rounded p-4 mt-4" style="width:700px">

    <h5 class="mb-3">
        <i class="bi bi-table"></i>
        Valori memorizzati
    </h5>

    <table class="table table-bordered table-responsive table-sm">
        <thead>
            <tr>
                <th>Tipo</th>
                <th>Valore</th>
                <th>Data creazione</th>
            </tr>
        </thead>
        <tbody>

            <% for (TabPar p : valoriSanzione) { %>
                <tr style="background:#eed7d9">
                    <td>Abbattimento sanzione</td>
                    <td><%= p.getValue() %>%</td>
                    <td style="text-align:right"><%= DateUtils.formatTimestamp(p.getCreationTimestamp()) %></td>
                </tr>
            <% } %>

            <% for (TabPar p : valoriInteressi) { %>
                <tr style="background:#eed2g9">
                    <td>Abbattimento interessi</td>
                    <td><%= p.getValue() %>%</td>
                    <td style="text-align:right"><%= DateUtils.formatTimestamp(p.getCreationTimestamp()) %></td>
                </tr>
            <% } %>

        </tbody>
    </table>

</div>