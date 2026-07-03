<%@page import="is.five.apeaf.utils.SessionVariables"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

   <% 
    		request.getSession().setAttribute(SessionVariables.CALLER, "tab-parametri-riscossione.jsp");
   
   %>
   
<h3 class="mb-4">
    <i class="bi bi-sliders"></i>
    PARAMETRI RISCOSSIONE
</h3>

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
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="20">
                </td>
                <td class="fw-bold">MOLTO SCARSA</td>
            </tr>

            <tr>
                <td>
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="49">
                </td>
                <td class="fw-bold">SCARSA</td>
            </tr>

            <tr>
                <td>
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="50">
                </td>
                <td class="fw-bold">SUFFICIENTE</td>
            </tr>

            <tr>
                <td>
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="59">
                </td>
                <td class="fw-bold">BUONA</td>
            </tr>

            <tr>
                <td>
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="69">
                </td>
                <td class="fw-bold">OTTIMA</td>
            </tr>

        </tbody>
    </table>

</div>