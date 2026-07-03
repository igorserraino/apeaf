<%@page import="is.five.apeaf.utils.SessionVariables"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

   <% 
	request.getSession().setAttribute(SessionVariables.CALLER, "tab-parametri.jsp");
   
   %>
   
<h3 class="mb-4">
    <i class="bi bi-sliders"></i>
    TABELLA PARAMETRI
</h3>

<div class="table-responsive">

    <table class="table table-bordered align-middle" style="max-width:600px">
        <thead class="table-secondary">
            <tr>
                <th colspan="2">
                    <i class="bi bi-exclamation-triangle"></i>
                    ABBATTIMENTO SANZIONI
                </th>
            </tr>
        </thead>
        <tbody>

            <tr>
                <td>% ABBATTIMENTO SANZIONE</td>
                <td style="width:220px;">
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="50">
                </td>
            </tr>

            <tr>
                <td>% ABBATTIMENTO SANZIONE</td>
                <td>
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="80">
                </td>
            </tr>

            <tr>
                <td>% ABBATTIMENTO SANZIONE</td>
                <td>
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="100">
                </td>
            </tr>

        </tbody>

        <thead class="table-secondary">
            <tr>
                <th colspan="2">
                    <i class="bi bi-percent"></i>
                    ABBATTIMENTO INTERESSI
                </th>
            </tr>
        </thead>

        <tbody>

            <tr>
                <td>% ABBATTIMENTO INTERESSI</td>
                <td>
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="50">
                </td>
            </tr>

            <tr>
                <td>% ABBATTIMENTO INTERESSI</td>
                <td>
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="80">
                </td>
            </tr>

            <tr>
                <td>% ABBATTIMENTO INTERESSI</td>
                <td>
                    <input type="number"
                           min="0"
                           max="100"
                           class="form-control text-center fw-bold"
                           value="100">
                </td>
            </tr>

        </tbody>
    </table>

</div>