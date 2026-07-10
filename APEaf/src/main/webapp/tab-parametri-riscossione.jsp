<%@page import="is.five.apeaf.utils.SessionVariables"%>
<%@page import="is.five.apeaf.controller.TabRiscServlet"%>
<%@page import="is.five.apeaf.utils.*"%>
<%@ page import="is.five.apeaf.dao.model.*"%>
<%@ page import="is.five.apeaf.dao.TabRiscDAO"%>
<%@ page import="java.math.BigDecimal"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

   <% 
    		request.getSession().setAttribute(SessionVariables.CALLER, "tab-parametri-riscossione.jsp");
   UserView user = (UserView) request.getSession().getAttribute("ubAP");
   if (user == null || !user.getActive()) {
		response.sendRedirect("index.jsp");
		return;
	}
   
   String[] values = {"20", "49", "50", "59", "69"};


       TabRisc tab = TabRiscDAO.findLatestByUser(user.getId());

       if (tab != null && tab.getValue() != null && !tab.getValue().trim().isEmpty()) {

           String[] saved = tab.getValue().split(";");

           for (int i = 0; i < saved.length && i < values.length; i++) {

               values[i] = saved[i];

           }

       }

   
   %>
   
<h3 class="mb-4">

    <i class="bi bi-sliders"></i>

    PARAMETRI RISCOSSIONE

</h3>

<% if (session.getAttribute(TabRiscServlet.class.getName()) != null) { %>

    <div class="alert alert-primary">

        <%= session.getAttribute(TabRiscServlet.class.getName()) %>

    </div>

<%

    session.removeAttribute(TabRiscServlet.class.getName());

}

%>

<form action="TabRiscServlet" method="post">

    <div class="table-responsive">

        <table class="table table-bordered align-middle text-center" style="max-width:600px">

            <thead class="table-secondary">

                <tr>

                    <th style="width:220px;">VALORE</th>

                    <th>DEFINIZIONE</th>

                </tr>

            </thead>

            <tbody>

                <tr>

                    <td>

                        <input type="number" min="0" max="100"

                               name="risc_0"

                               class="form-control text-center fw-bold"

                               value="<%= values[0] %>">

                    </td>

                    <td class="fw-bold">MOLTO SCARSA</td>

                </tr>

                <tr>

                    <td>

                        <input type="number" min="0" max="100"

                               name="risc_1"

                               class="form-control text-center fw-bold"

                               value="<%= values[1] %>">

                    </td>

                    <td class="fw-bold">SCARSA</td>

                </tr>

                <tr>

                    <td>

                        <input type="number" min="0" max="100"

                               name="risc_2"

                               class="form-control text-center fw-bold"

                               value="<%= values[2] %>">

                    </td>

                    <td class="fw-bold">SUFFICIENTE</td>

                </tr>

                <tr>

                    <td>

                        <input type="number" min="0" max="100"

                               name="risc_3"

                               class="form-control text-center fw-bold"

                               value="<%= values[3] %>">

                    </td>

                    <td class="fw-bold">BUONA</td>

                </tr>

                <tr>

                    <td>

                        <input type="number" min="0" max="100"

                               name="risc_4"

                               class="form-control text-center fw-bold"

                               value="<%= values[4] %>">

                    </td>

                    <td class="fw-bold">OTTIMA</td>

                </tr>

            </tbody>

        </table>

    </div>

    <button type="submit" class="btn btn-primary">

        <i class="bi bi-save"></i>

        Modifica i valori

    </button>

</form>