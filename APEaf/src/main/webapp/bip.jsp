<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<html lang="it">
<%@ page import="is.five.apeaf.dao.model.UserView"%>
<%@ page import="is.five.apeaf.utils.SessionVariables"%>

<%

request.getSession().setAttribute(SessionVariables.CALLER, "bip.jsp");

UserView user = (UserView) request.getSession().getAttribute("ubAP");
if (user == null || !user.getActive()) {
		response.sendRedirect("index.jsp");
		return;
	}

%>

    <link rel="preconnect" href="https://cdn.jsdelivr.net">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/bip.css">

</head>
<body>
<div class="page-shell">
 

    <main id="main-content">
        <section class="status-card" aria-labelledby="page-title">
            <div class="status-icon" aria-hidden="true">
                <i class="bi bi-tools"></i>
            </div>

            <p class="eyebrow">Lavori in corso</p>
            <h1 id="page-title">Sezione in lavorazione</h1>
            <p class="description"> 
                La funzionalità sarà disponibile prossimamente.
            </p>

            <div class="progress-track" role="progressbar" aria-label="Sviluppo in corso"
                 aria-valuetext="Lavori in corso">
                <span></span>
            </div>

            <a class="button" href="${pageContext.request.contextPath}/home.jsp">
                <i class="bi bi-arrow-left" aria-hidden="true"></i>
                Torna alla home
            </a>
        </section>
    </main>
 
</div>

