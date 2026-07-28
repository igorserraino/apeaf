<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>
<%
request.getSession().setAttribute(
        SessionVariables.CALLER,
        "valutazione-generale.jsp");

UserView user = (UserView) request.getSession().getAttribute("ubAP");
if (user == null || !user.getActive()) {
    response.sendRedirect("index.jsp");
    return;
}

%>
<%
    NumberFormat currencyFormat =
            NumberFormat.getNumberInstance(Locale.ITALY);

    currencyFormat.setMinimumFractionDigits(2);
    currencyFormat.setMaximumFractionDigits(2);

    /*
     * Replace these example values with values loaded from DAO/bean.
     */

    int[] percentualiTaglio = {50, 80, 100};

    double[] totaleResidui = {
        720000.00,
        720000.00,
        720000.00
    };

    double[] totaleTagli = {
        104056.81,
        166490.90,
        208113.62
    };

    double[] minorAccantonamentoFcde = {
        81404.24,
        128469.89,
        161170.70
    };

    double[] residuiNetti = new double[percentualiTaglio.length];
    double[] riflessiBilancio = new double[percentualiTaglio.length];

    for (int i = 0; i < percentualiTaglio.length; i++) {

        residuiNetti[i] =
                totaleResidui[i] - totaleTagli[i];

        riflessiBilancio[i] =
                minorAccantonamentoFcde[i] - totaleTagli[i];
    }
%>

<div class="page-container">

    <div class="watermark">
        <i class="bi bi-tools"></i>
        <span>IN LAVORAZIONE DATI STATICI</span>
    </div>

<div class="rounded p-4 dati-card valutazione-generale-card">
<h3 class="mb-4">
    <i class="bi bi-calculator"></i> VALUTAZIONE GENERALE
</h3>
    <div class="dati-header">
        <div class="dati-title dati-section-title">
            <i class="bi bi-calculator-fill"></i>
            <span>DATI COMPUTATI DA </span>
        </div>
    </div>

    <div class="valutazione-generale-table-wrapper">

        <table class="valutazione-generale-table" style="max-width:1200px">

            <thead>

                <tr>
                    <th class="valutazione-generale-empty-header"></th>

                    <th
                        colspan="<%= percentualiTaglio.length %>"
                        class="valutazione-generale-main-header">

                        <i class="bi bi-percent"></i>
                        TAGLIO SANZIONI + INTERESSI

                    </th>
                </tr>

                <tr>
                    <th class="valutazione-generale-row-header"></th>

                    <% for (int percentuale : percentualiTaglio) { %>

                        <th class="valutazione-generale-percentuale">
                            <%= percentuale %>
                        </th>

                    <% } %>
                </tr>

            </thead>

            <tbody>

                <tr>
                    <th scope="row">
                        TOTALE RESIDUI
                    </th>

                    <% for (double valore : totaleResidui) { %>

                        <td>
                            <%= currencyFormat.format(valore) %>
                        </td>

                    <% } %>
                </tr>

                <tr>
                    <th scope="row">
                        TOTALE TAGLI
                    </th>

                    <% for (double valore : totaleTagli) { %>

                        <td>
                            <%= currencyFormat.format(valore) %>
                        </td>

                    <% } %>
                </tr>

                <tr>
                    <th scope="row">
                        RESIDUI AL NETTO
                    </th>

                    <% for (double valore : residuiNetti) { %>

                        <td>
                            <%= currencyFormat.format(valore) %>
                        </td>

                    <% } %>
                </tr>

                <tr>
                    <th scope="row">
                        MINOR ACCANTONAMENTO FCDE
                    </th>

                    <% for (double valore : minorAccantonamentoFcde) { %>

                        <td>
                            <%= currencyFormat.format(valore) %>
                        </td>

                    <% } %>
                </tr>

                <tr class="valutazione-generale-result-row">

                    <th scope="row">
                        RIFLESSO DI BILANCIO
                    </th>

                    <% for (double valore : riflessiBilancio) { %>

                        <td class="<%= valore < 0
                                ? "valutazione-generale-negative"
                                : "valutazione-generale-positive" %>">

                            <span class="valutazione-generale-sign">
                                <%= valore < 0 ? "-" : "+" %>
                            </span>

                            <span>
                                <%= currencyFormat.format(Math.abs(valore)) %>
                            </span>

                        </td>

                    <% } %>

                </tr>

            </tbody>

        </table>

    </div>

</div>

</div>