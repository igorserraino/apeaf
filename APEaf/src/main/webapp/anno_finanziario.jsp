<%@page import="java.util.*"%>
<%@page import="is.five.apeaf.dao.model.*"%>
<%@page import="is.five.apeaf.view.*"%>
<%@page import="is.five.apeaf.dao.*"%>
<%@page import="java.util.*"%>
<%@page import="is.five.apeaf.utils.*"%>
<%@page import="is.five.apeaf.controller.*"%>


<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src="js/annofinanziario.js" ></script>
<style>

td {
vertical-align: middle;}
</style>
<%! int annoCorrente = Calendar.getInstance().get(Calendar.YEAR); %>

</head>


<body>
<%
session.setAttribute("PAGE", "anno_finanziario.jsp");
%>
<%
UserView user = (UserView) request.getSession().getAttribute("ubAP");
if (user == null) {
	response.sendRedirect("index.jsp");
	return;
} else { 


	request.getSession().setAttribute(SessionVariables.CALLER, "anno_finanziario.jsp");
	AnnoFinanziarioDAO dao = new AnnoFinanziarioDAO();
	
		List<AnnoFinanziario> anni = dao.findByIDUser(user.getId());

%>
<div style="overflow:auto" id="toPrint">

<h2>DEFINIZIONE ANNO FINANZIARIO</h2>

<hr />

<img src="<%= IconsConstants.PRINT_ICON %>" class="form-buttons-image" onclick="printpage('toPrint');" alt="print" />
<img class="form-buttons-image" id="save-button" src="<%= IconsConstants.SAVE_ICON %>" onclick="$('#tabelleannuali-form').submit()" alt="save" />
		

<% if (session.getAttribute(AnnoFinanziarioServlet.class.getName())!=null) { %>
<p class="error_paragraph" ><%=session.getAttribute(AnnoFinanziarioServlet.class.getName())%></p>
<% } %>


<form name="tabelleannuali-form" id="tabelleannuali-form" method="post" action="annofinanziario" onsubmit="return validateForm()">
    <input type="hidden" name="insert_nuovo_anno" value="1" />

    <table class="table table-responsive" style="width: 400px;overflow:auto;">
        <thead>
            <tr class="special-table-cell-centered">
                <th>Creazione anno</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>
                    <input class="form-control bg-dark number-comma-input-150" 
                           name="nuovo_anno" 
                           id="nuovo_anno" 
                           required 
                           placeholder="Inserisci l'anno" />
                </td>
            </tr>
        </tbody>
    </table>

    <button type="submit" class="btn btn-primary">Invia</button>
</form>

<hr />



<p class="alert alert-light">ANNI GIA DEFINITI</p>
<ul>
<% 
for (AnnoFinanziario nesimo : anni) { %>
<li><%= nesimo.getAnno() %></li>
<%
}
%>
</ul>
<hr />





<table class="table table-responsive table-bottom-right">
</table>


</form>

</div>

<% }   %>
</body>
</html>