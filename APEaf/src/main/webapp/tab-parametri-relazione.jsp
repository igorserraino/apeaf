<%@page import="is.five.apeaf.utils.SessionVariables"%>
<%@page import="is.five.apeaf.dao.model.*"%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>



<%
UserView user = (UserView) request.getSession().getAttribute("ubAP");
String queryString = request.getQueryString();

if (user == null || !user.getActive()) {
	response.sendRedirect("index.jsp");
	return;
}

request.getSession().setAttribute(SessionVariables.CALLER, "tab-parametri-relazione.jsp");
%>

<div class="document-box">

    <div class="text-center fw-bold">COMUNE DI <%= user.getUsername() %></div>
    <div class="text-center fw-bold mb-4">PROVINCIA DI</div>

    <p><strong>Premesso che</strong> la Legge 30 dicembre 2025 n. 199, all'art. 1 commi da 102 a 110 ha previsto la possibilità per gli Enti Locali di introdurre l'istituto della definizione agevolata, prevedendo l'esclusione o la riduzione delle sanzioni e degli interessi;</p>

    <p><strong>Considerato</strong> che la norma suddetta dispone che l'introduzione della definizione agevolata deve tenere conto del rispetto degli equilibri di bilancio nonché della situazione economico finanziaria dell'Ente;</p>

    <p>Considerato altresì che l'introduzione della definizione dovrà essere effettuato con apposito regolamento da adottare da parte del Consiglio Comunale;</p>

    <p>Visto l'art. 239 comma 1 lett. b) del D.Lgs. N. 267/2000, che prevede che l'organo di revisione esprima il parere sulle proposte di regolamento di applicazione dei tributi Locali;</p>

    <p>Ravvisata l'opportunità, nonché la necessità di formulare un'analisi delle varie entrate del Comune al fine di valutare secondo una serie di parametri, l'impatto sugli equilibri di bilancio, in caso di applicazione della definizione agevolata</p>

    <p>In relazione ai dati resi disponibili dall'Ente si formula la seguente analisi</p>

    <div class="text-center my-5">
        <div class="fw-bold">ANALISI DELLA CAPACITA' DI RISCOSSIONE</div>
        <div>L'analisi si fonda sulle seguenti Entrate</div>
    </div>

    <p class="fw-bold">CAPACITA' DI RISCOSSIONE</p>

    <p class="fw-bold mt-4">LA RISCOSSIONE SU UN TOTALE COMPLESSIVO DI €:</p>

    <p class="mt-4">
        Secondo quanto previsto dalla Legge n. 199/2025 è possibile appplicare la definizione agevolata per le sanzioni e gli interessi,
        lasciando inalterata la quota capitale. Pertanto le somme soggette a un possibile beneficio risultano da seguenti prospetti:
    </p>

    <p class="mt-4">
        Si è proceduto a formulare una proiezione di taglio di sanzioni ed interessi basata su tre parametri come segue:
    </p>

    <p class="mt-4">
        Dalle entrate in riscossione si è formulata una prima proiezione di tagli come ampiamente illustrato nella tabella che segue:
    </p>

</div>