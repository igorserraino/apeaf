<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="is.five.apeaf.utils.SessionVariables" %>
<%@ page import="is.five.apeaf.dao.model.UserView" %>


<%
request.getSession().setAttribute(
        SessionVariables.CALLER,
        "riflessi-bilancio.jsp");

UserView user = (UserView) request.getSession().getAttribute("ubAP");
if (user == null || !user.getActive()) {
    response.sendRedirect("index.jsp");
    return;
}

%>
 
<div class="page-container">

    <div class="watermark">
        <i class="bi bi-tools"></i>
        <span>IN LAVORAZIONE DATI STATICI</span>
    </div>

<h3 class="mb-4">
    <i class="bi bi-calculator"></i> RIFLESSI SUL BILANCIO
</h3>

<div class="rounded p-4 dati-card riflessi-bilancio-card mt-4">
    <div class="dati-header mb-3">
        <div class="dati-title dati-section-title">
            <i class="bi bi-table"></i>
            <span>DATI COMPUTATI DA </span>
        </div>
    </div>

    <div class="table-responsive">
        <table class="riflessi-bilancio-table" aria-label="Impatto delle ipotesi di taglio sul bilancio" style="max-width:1200px">
            <colgroup>
                <col class="col-descrizione" />
                <col class="col-importo" />
                <col class="col-importo" />
                <col class="col-importo" />
            </colgroup>

            <thead>
                <tr>
                    <th class="empty-header"></th>
                    <th class="section-header" colspan="3" scope="colgroup">
                        IPOTESI TAGLIO SANZIONI + INTERESSI
                    </th>
                </tr>
                <tr>
                    <th class="empty-header"></th>
                    <th class="percentage-header" scope="col">50</th>
                    <th class="percentage-header" scope="col">80</th>
                    <th class="percentage-header" scope="col">100</th>
                </tr>
            </thead>

            <tbody>
                <tr class="separator-row" aria-hidden="true"><td colspan="4"></td></tr>
                <tr>
                    <th class="group-title" scope="rowgroup">ICI</th>
                    <td class="empty-header" colspan="3"></td>
                </tr>
                <tr>
                    <td class="description-cell">RESIDUI ATTIVI</td>
                    <td class="amount-cell">150.000,00</td>
                    <td class="amount-cell">150.000,00</td>
                    <td class="amount-cell">150.000,00</td>
                </tr>
                <tr>
                    <td class="description-cell">TAGLIO</td>
                    <td class="amount-cell">18.478,56</td>
                    <td class="amount-cell">29.565,69</td>
                    <td class="amount-cell">36.957,11</td>
                </tr>
                <tr>
                    <td class="description-cell">NUOVI RESIDUI</td>
                    <td class="amount-cell">131.521,45</td>
                    <td class="amount-cell">120.434,31</td>
                    <td class="amount-cell">113.042,89</td>
                </tr>
                <tr>
                    <td class="description-cell">MINOR ACCANTONAMENTO FCDE</td>
                    <td class="amount-cell">13.550,94</td>
                    <td class="amount-cell">21.681,50</td>
                    <td class="amount-cell">27.101,88</td>
                </tr>
                <tr>
                    <td class="impact-label">IMPATTO SUL BILANCIO</td>
                    <td class="impact-value">- 4.927,61</td>
                    <td class="impact-value">- 7.884,18</td>
                    <td class="impact-value">- 9.855,23</td>
                </tr>

                <tr class="separator-row" aria-hidden="true"><td colspan="4"></td></tr>
                <tr>
                    <th class="group-title" scope="rowgroup">TASI</th>
                    <td class="empty-header" colspan="3"></td>
                </tr>
                <tr>
                    <td class="description-cell">RESIDUI ATTIVI</td>
                    <td class="amount-cell">15.000,00</td>
                    <td class="amount-cell">15.000,00</td>
                    <td class="amount-cell">15.000,00</td>
                </tr>
                <tr>
                    <td class="description-cell">TAGLIO</td>
                    <td class="amount-cell">2.191,99</td>
                    <td class="amount-cell">3.507,18</td>
                    <td class="amount-cell">4.383,98</td>
                </tr>
                <tr>
                    <td class="description-cell">NUOVI RESIDUI</td>
                    <td class="amount-cell">12.808,01</td>
                    <td class="amount-cell">11.492,82</td>
                    <td class="amount-cell">10.616,02</td>
                </tr>
                <tr>
                    <td class="description-cell">MINOR ACCANTONAMENTO FCDE</td>
                    <td class="amount-cell">1.753,59</td>
                    <td class="amount-cell">2.805,75</td>
                    <td class="amount-cell">3.507,18</td>
                </tr>
                <tr>
                    <td class="impact-label">IMPATTO SUL BILANCIO</td>
                    <td class="impact-value">- 438,40</td>
                    <td class="impact-value">- 701,44</td>
                    <td class="impact-value">- 876,80</td>
                </tr>

                <tr class="separator-row" aria-hidden="true"><td colspan="4"></td></tr>
                <tr>
                    <th class="group-title" scope="rowgroup">IMU</th>
                    <td class="empty-header" colspan="3"></td>
                </tr>
                <tr>
                    <td class="description-cell">RESIDUI ATTIVI</td>
                    <td class="amount-cell">85.000,00</td>
                    <td class="amount-cell">85.000,00</td>
                    <td class="amount-cell">85.000,00</td>
                </tr>
                <tr>
                    <td class="description-cell">TAGLIO</td>
                    <td class="amount-cell">12.668,98</td>
                    <td class="amount-cell">20.270,37</td>
                    <td class="amount-cell">25.337,96</td>
                </tr>
                <tr>
                    <td class="description-cell">NUOVI RESIDUI</td>
                    <td class="amount-cell">72.331,02</td>
                    <td class="amount-cell">64.729,63</td>
                    <td class="amount-cell">59.662,04</td>
                </tr>
                <tr>
                    <td class="description-cell">MINOR ACCANTONAMENTO FCDE</td>
                    <td class="amount-cell">8.942,81</td>
                    <td class="amount-cell">12.531,60</td>
                    <td class="amount-cell">16.247,84</td>
                </tr>
                <tr>
                    <td class="impact-label">IMPATTO SUL BILANCIO</td>
                    <td class="impact-value">- 3.726,17</td>
                    <td class="impact-value">- 7.738,76</td>
                    <td class="impact-value">- 9.090,12</td>
                </tr>

                <tr class="separator-row" aria-hidden="true"><td colspan="4"></td></tr>
                <tr>
                    <th class="group-title" scope="rowgroup">TARI</th>
                    <td class="empty-header" colspan="3"></td>
                </tr>
                <tr>
                    <td class="description-cell">RESIDUI ATTIVI</td>
                    <td class="amount-cell">220.000,00</td>
                    <td class="amount-cell">220.000,00</td>
                    <td class="amount-cell">220.000,00</td>
                </tr>
                <tr>
                    <td class="description-cell">TAGLIO</td>
                    <td class="amount-cell">33.224,66</td>
                    <td class="amount-cell">53.159,45</td>
                    <td class="amount-cell">66.449,31</td>
                </tr>
                <tr>
                    <td class="description-cell">NUOVI RESIDUI</td>
                    <td class="amount-cell">186.775,35</td>
                    <td class="amount-cell">166.840,55</td>
                    <td class="amount-cell">153.550,69</td>
                </tr>
                <tr>
                    <td class="description-cell">MINOR ACCANTONAMENTO FCDE</td>
                    <td class="amount-cell">24.163,39</td>
                    <td class="amount-cell">38.661,42</td>
                    <td class="amount-cell">48.326,77</td>
                </tr>
                <tr>
                    <td class="impact-label">IMPATTO SUL BILANCIO</td>
                    <td class="impact-value">- 9.061,27</td>
                    <td class="impact-value">- 14.498,03</td>
                    <td class="impact-value">- 18.122,54</td>
                </tr>

                <tr class="separator-row" aria-hidden="true"><td colspan="4"></td></tr>
                <tr>
                    <th class="group-title" scope="rowgroup">Sanzioni CDS</th>
                    <td class="empty-header" colspan="3"></td>
                </tr>
                <tr>
                    <td class="description-cell">RESIDUI ATTIVI</td>
                    <td class="amount-cell">250.000,00</td>
                    <td class="amount-cell">250.000,00</td>
                    <td class="amount-cell">250.000,00</td>
                </tr>
                <tr>
                    <td class="description-cell">TAGLIO</td>
                    <td class="amount-cell">37.492,63</td>
                    <td class="amount-cell">59.988,21</td>
                    <td class="amount-cell">74.985,26</td>
                </tr>
                <tr>
                    <td class="description-cell">NUOVI RESIDUI</td>
                    <td class="amount-cell">212.507,37</td>
                    <td class="amount-cell">190.011,79</td>
                    <td class="amount-cell">175.014,74</td>
                </tr>
                <tr>
                    <td class="description-cell">MINOR ACCANTONAMENTO FCDE</td>
                    <td class="amount-cell">32.993,51</td>
                    <td class="amount-cell">52.789,62</td>
                    <td class="amount-cell">65.987,03</td>
                </tr>
                <tr>
                    <td class="impact-label">IMPATTO SUL BILANCIO</td>
                    <td class="impact-value">- 4.499,12</td>
                    <td class="impact-value">- 7.198,58</td>
                    <td class="impact-value">- 8.998,23</td>
                </tr>

                <tr class="separator-row" aria-hidden="true"><td colspan="4"></td></tr>
                <tr>
                    <th class="totals-title" scope="rowgroup">TOTALI</th>
                    <td class="empty-header" colspan="3"></td>
                </tr>
                <tr class="total-row">
                    <td class="description-cell">RESIDUI ATTIVI</td>
                    <td class="amount-cell">720.000,00</td>
                    <td class="amount-cell">720.000,00</td>
                    <td class="amount-cell">720.000,00</td>
                </tr>
                <tr class="total-row">
                    <td class="description-cell">TAGLIO</td>
                    <td class="amount-cell">104.056,81</td>
                    <td class="amount-cell">166.490,90</td>
                    <td class="amount-cell">208.113,62</td>
                </tr>
                <tr class="total-row">
                    <td class="description-cell">NUOVI RESIDUI</td>
                    <td class="amount-cell">615.943,19</td>
                    <td class="amount-cell">553.509,10</td>
                    <td class="amount-cell">511.886,38</td>
                </tr>
                <tr class="total-row">
                    <td class="description-cell">MINOR ACCANTONAMENTO FCDE</td>
                    <td class="amount-cell">81.404,24</td>
                    <td class="amount-cell">128.469,89</td>
                    <td class="amount-cell">161.170,70</td>
                </tr>
                <tr>
                    <td class="impact-label">IMPATTO SUL BILANCIO</td>
                    <td class="impact-value">- 22.652,57</td>
                    <td class="impact-value">- 38.021,00</td>
                    <td class="impact-value">- 46.942,92</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

</div>
