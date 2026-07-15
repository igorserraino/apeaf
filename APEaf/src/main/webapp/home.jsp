<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="is.five.apeaf.dao.model.*"%>

<%@page import="is.five.apeaf.view.ViewConstants"%>
<%@page import="is.five.apeaf.utils.SessionVariables"%>
<%@page import="is.five.apeaf.dao.*"%>
<%@page import="is.five.apeaf.utils.*"%>

<%@page import="java.util.*"%>
<%@page import="is.five.apeaf.view.*"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>APEaf - Five Consulting srl - developed by IS Igor Serraino</title>


   <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <meta content="" name="keywords">
    <meta content="" name="description">

    <!-- Favicon -->
    <link href="img/favicon.ico" rel="icon">

    <!-- Google Web Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600&family=Roboto:wght@500;700&display=swap" rel="stylesheet"> 
    
    <!-- Icon Font Stylesheet -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Libraries Stylesheet -->
    <link href="lib/owlcarousel/assets/owl.carousel.min.css" rel="stylesheet">
    <link href="lib/tempusdominus/css/tempusdominus-bootstrap-4.min.css" rel="stylesheet" />

    <!-- Customized Bootstrap Stylesheet -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- Template Stylesheet -->
    <link href="css/style.css" rel="stylesheet">
    			<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://kit.fontawesome.com/97214dba7e.js" crossorigin="anonymous"></script>
    
    <script>
        $(document).ready(function() {
            $('.load-link').click(function(e) {
                e.preventDefault();
                var url = $(this).data('url');
                
                  $('#main-content').load(url, function(response, status, xhr) {
                    if (status == "error") {
                        $('#main-content').html("<p>Error loading content. Please check the console for more details.</p>");
                    }
                });
            });
        });
    </script>

</head>
<body>

	<%

		
	
	
	UserView user = (UserView) request.getSession().getAttribute("ubAP");
	String queryString = request.getQueryString();

	if (user == null || !user.getActive()) {
			out.println("<h4>SSO LOGIN ERROR!</h4>");
			out.println("<a href=\"/../apnetwork/home\">BACK TO APNETWORK</a>");
			
			} else {
				
				String PAGE = queryString != null ? queryString + ".jsp" : "";
				if (PAGE.contains(".jsp.jsp"))
					PAGE = PAGE.replace(".jsp.jsp", ".jsp");
				if (PAGE.equals(".jsp") || PAGE.equals("null.jsp"))
					PAGE = "";
				if (PAGE.length()>40)
					PAGE="";

	%>


	<%
				AnnoFinanziarioDAO anniDAO = new AnnoFinanziarioDAO();
				String id_anno_selezionato = request.getSession().getAttribute(SessionVariables.ANNO) != null
						? (String) request.getSession().getAttribute(SessionVariables.ANNO)
						: "";
				String anno_selezionato = "";
				
				try {
					if (id_anno_selezionato.length() > 0) {
						anno_selezionato = String
								.valueOf(anniDAO.findByID(Integer.parseInt(id_anno_selezionato)).getAnno());
						request.getSession().setAttribute("anno_selezionato", anno_selezionato);
					}
				} catch (Exception exc) {
				}
				
				
				UserViewDAO userViewDAO = new UserViewDAO();
				String id_user_selezionato = request.getSession().getAttribute(SessionVariables.USER_SEL)!=null?(String)request.getSession().getAttribute(SessionVariables.USER_SEL):"";
    			String userid_user_selezionato = "";
                if (id_user_selezionato.length()>0) {
    				userid_user_selezionato = userViewDAO.selectByID(Integer.parseInt(id_user_selezionato)).getUsername();
    				if (userid_user_selezionato!=null && userid_user_selezionato.trim().length()>3) {
    					((UserView) request.getSession().getAttribute("ubAP")).setId(Integer.parseInt(id_user_selezionato));
    					((UserView) request.getSession().getAttribute("ubAP")).setUsername(userid_user_selezionato);
    				}
    			}
                
	%>

	<!-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->			

    <div class="container-fluid position-relative d-flex p-0">
        <!-- Spinner Start -->
        <div id="spinner" class="show bg-dark position-fixed translate-middle w-100 vh-100 top-50 start-50 d-flex align-items-center justify-content-center">
            <div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status">
                <span class="sr-only">Loading...</span>
            </div>
        </div>
        <!-- Spinner End -->


<!-- Sidebar Start -->
<div class="sidebar pe-3 pb-3">
    <nav class="navbar bg-secondary navbar-dark sidebar-nav">

<!-- HEADER -->
<div class="sidebar-header">

<a href="#"
   class="load-link sidebar-brand"
  data-url="dashboard.jsp">

    <span class="sidebar-avatar">
		<i class="bi bi-book"></i>
    </span>

    <span class="sidebar-brand-info">

        <span class="sidebar-app">
            AP.EAF
        </span>

        <% if (user.getGroupId()==1 || user.getGroupId()==2) { %>
        <span class="sidebar-user">
            <%= userid_user_selezionato!=null&&userid_user_selezionato.length()>0?userid_user_selezionato:user.getUsername() %>
        </span>
        <% } %>

    </span>

</a>

<hr />

    <div class="sidebar-context">



        <div class="sidebar-badge year">
            <i class="bi bi-calendar-event"></i>
            <span>
                <%= anno_selezionato.length()>0
                    ? anno_selezionato
                    : "Anno n.d." %>
            </span>
        </div>

    </div>

</div>

<div class="navbar-nav w-100 sidebar-menu">

    <% if (user.getGroupId()==1 || user.getGroupId()==2) { %>
    <a href="home.jsp?anno_finanziario.jsp"
       class="dropdown-item">
        <i class="bi bi-calendar-check"></i>
        <span>DEF ANNO FINANZIARIO</span>
    </a>
    <hr />
    <% } %>

    <div class="nav-item dropdown show sidebar-group">
        <a href="home.jsp?tab-parametri" class="dropdown-item">
            <i class="bi bi-table"></i>
            <span>tabella parametri</span>
        </a>
        <a href="home.jsp?tab-parametri-riscossione" class="dropdown-item">
            <i class="bi bi-table"></i>
            <span>tabella param. riscossione</span>
        </a> 
    <hr />
    
    <a href="home.jsp?ins-tab-ruoli.jsp" class="dropdown-item">
            <i class="bi bi-pencil-square"></i>
            <span>ins.tab.ruoli</span>
        </a>
        <a href="home.jsp?ins-residui-attivi" class="dropdown-item">
            <i class="bi bi-pencil-square"></i>
            <span>ins.residui.attivi</span>
        </a>
        <a href="home.jsp?ins-dati-fcde" class="dropdown-item">
           <i class="bi bi-pencil-square"></i>
            <span>ins.dati.FCDE</span>
        </a>
        
    
<hr />
    </div>
    
        <div class="nav-item dropdown show sidebar-group">
        <a href="home.jsp?importi-definibili" class="dropdown-item">
			    <i class="bi bi-calculator"></i>
			    <span>Importi definibili</span>
			</a>
        <a href="home.jsp?bip" class="dropdown-item">
			    <i class="bi bi-calculator"></i>
            <span>ipotesi tagli</span>           
        </a> 
        <a href="home.jsp?bip" class="dropdown-item">
			    <i class="bi bi-calculator"></i>
            <span>valutazione ruoli</span>           
        </a> 
        <a href="home.jsp?bip" class="dropdown-item">
			    <i class="bi bi-calculator"></i>
            <span>calcolo FCDE</span>           
        </a> 
        <a href="home.jsp?bip" class="dropdown-item">
			    <i class="bi bi-calculator"></i>
            <span>quota FCDE liberata</span>           
        </a> 
        <a href="home.jsp?bip" class="dropdown-item">
			    <i class="bi bi-calculator"></i>
            <span>riflessi sul bilancio</span>           
        </a> 
        <a href="home.jsp?bip" class="dropdown-item">
			    <i class="bi bi-calculator"></i>
            <span>valutazione generale</span>           
        </a> 
    <hr />
    </div>
    
    
        <div class="nav-item dropdown show sidebar-group">
        <a href="home.jsp?bip" class="dropdown-item">
  			  <i class="bi bi-file-earmark-text"></i>
            <span>relazione</span>
        </a>

    </div>
    
        </div>

    

    <div class="sidebar-logos">
        <a href="/apnetwork/home.jsp?dashboard.jsp">
            <img src="/apnetwork/img/logo_apnetwork.png"
                 class="home-logo-userid" />
        </a>

        <hr />

        <img src="img/logos/gestore.test.five.2023.png"
             class="home-logo-userid" />
    </div>
    </nav>

</div>
</div>
<!-- Sidebar End -->




        <!-- Sidebar End -->


        <!-- Content Start -->
        <div class="content">
        
        
            <!-- Navbar Start -->
            <nav class="navbar navbar-expand bg-secondary navbar-dark sticky-top px-4 py-0">
                <a href="index.html" class="navbar-brand d-flex d-lg-none me-4">
                    <h2 class="text-primary mb-0"><i class="fa fa-user-edit"></i></h2>
                </a>
                <a href="#" class="sidebar-toggler flex-shrink-0">
                    <i class="fa fa-bars"></i>
                </a>
               
                
                
                <div class="navbar-nav align-items-center ms-auto">
                
                
                <% if (user.getGroupId()==1 || user.getGroupId()==2) { %>
 
					
			
                
                
       <!-- USER SEL -->
        <div class="nav-item dropdown">
                        <a href="#" class="nav-link dropdown-toggle" data-bs-toggle="dropdown">
                            <i class="fa fa-user me-lg-2"></i>
                            <span class="d-none d-lg-inline-flex">Opera come...</span>
                        </a>

			<div class="dropdown-menu dropdown-menu-end bg-secondary border-0 rounded-0 rounded-bottom m-0"
							     style="max-height: 400px; overflow-y: auto; min-width: 220px; padding: 5px;"
							     id="userDropdown">
							  
							  <!-- Search input -->
							  <input type="text" class="form-control form-control-sm mb-2" 
							         placeholder="Cerca utente..." 
							         id="userSearch" autocomplete="off">
							
							  <%
							    ArrayList<UserView> data = userViewDAO.selectByALL();
							
							    // Split users into two groups: normal and "five.consulting"
							    ArrayList<UserView> normalUsers = new ArrayList<>();
							    ArrayList<UserView> fiveUsers = new ArrayList<>();
							
							    for (UserView nesimo : data) {
							        if (nesimo.getGroupId() == 2) continue;
							        if (nesimo.getUsername() != null && (nesimo.getUsername().toLowerCase().contains("five.consulting") || nesimo.getUsername().toLowerCase().contains("fiveconsulting")) ) {
							            fiveUsers.add(nesimo);
							        } else {
							            normalUsers.add(nesimo);
							        }
							    }
							
							    // Merge them — normal first, fiveconsulting last
							    normalUsers.addAll(fiveUsers);
							%>
							
							<% for (int i = 0; i < normalUsers.size(); i++) {
								UserView nesimo = normalUsers.get(i);
							%>
							  <a href="#" class="dropdown-item p-1 user-item"
							     style="display: flex; align-items: center; font-size: 14px; line-height: 1.2;"
							     onclick="$('#select_user').val('<%= nesimo.getId() %>');$('#user_form').submit()">
							     
							     <i class="fa-solid fa-id-badge info-icon"></i>

							     
							     <span class="nome_user_active">
							       <%= (id_user_selezionato != null && id_user_selezionato.length() > 0 
							            && Integer.parseInt(id_user_selezionato) == nesimo.getId()) 
							              ? "<i class=\"fa-solid fa-check info-icon\"></i>" + " " : "" %>
							       <%= nesimo.getUsername() %> <%= nesimo.getCodice_ap() %>
							     </span>
							  </a>
							
							  <% if (i < normalUsers.size() - 1) { %>
							    <hr class="dropdown-divider m-1">
							  <% } %>
							<% } %>

				</div>
					
			</div>
			
			<form name="user_form" id="user_form" action="useractive" method="POST">
				<input type="hidden" id="select_user" name="select_user" value="<%= id_user_selezionato %>" />
			</form>
                
                
              	<% } %>




                 <!-- ANNO SEL -->
                    <div class="nav-item dropdown">
                        <a href="#" class="nav-link dropdown-toggle" data-bs-toggle="dropdown">
                            <i class="fa-solid fa-calendar-days"></i>
                            <span class="d-none d-lg-inline-flex">Selezione ANNO</span>
                        </a>
                        
                        <div class="dropdown-menu dropdown-menu-end bg-secondary border-0 rounded-0 rounded-bottom m-0">
                            <%
                            List<AnnoFinanziario> anni = (ArrayList<AnnoFinanziario>)anniDAO.findByIDUser(user.getId()); //STUB
                            for (AnnoFinanziario nesimo : anni) {
                            %>
									<a href="#" class="dropdown-item">
		                                <div class="d-flex align-items-center" onclick="$('#select_anno').val('<%= nesimo.getId() %>');$('#anno_servizio_form').submit()">
		                                <img src="<%= IconsConstants.ANNI_ICON %>" class="select-icons" />
		                                    <div class="ms-21">
		                                        <h6 class="fw-normal_1 mb-0" >
		                                        <%= id_anno_selezionato!=null&&id_anno_selezionato.length()>0?(Integer.parseInt(id_anno_selezionato)==nesimo.getId())?IconsConstants.OK_ICON_SMALL :"":"" %><%= nesimo.getAnno() %></h6>
		                                    </div>
		                                </div>
		                            </a>
		                            <hr class="dropdown-divider">
							<% } %>
                            
                        </div>
                    </div>
                  <!-- END ANNO SEL -->
                  
                  <form name="anno_servizio_form" id="anno_servizio_form" action="SELServiziAnniServlet" method="POST">
					<input type="hidden" id="select_anno" name="select_anno" value="<%= id_anno_selezionato %>" />
					</form>

                 
                 

                </div>
            </nav>
            <!-- Navbar End -->
            
            
            
            
            <!-- Main Content start -->
            <div class="container-fluid pt-4 px-4"  id='main-content' style="margin-bottom:20px">
				<% if (PAGE!=null&&PAGE.length()>0) {
					session.setAttribute(SessionVariables.CALLER, PAGE);
				 %><jsp:include page="<%= PAGE %>"></jsp:include><% } else { %>
				<jsp:include page="dashboard.jsp"></jsp:include>
				<% } %>
				
            </div>
            <!-- Main Content End -->
            

<% } %>


            <!-- Footer Start -->
            <div class="container-fluid pt-4 px-4 footer" >
                <div class="bg-secondary rounded-top p-4">
                    <div class="row">
                        <div class="col-12 col-sm-6 text-center text-sm-start" style="font-size: small; margin-top:20px; border-top: 1px dashed #3e2676">
                          <%= ViewConstants.FOOTER %> 
                        </div>
                        
                    </div>
                </div>
            </div>
            <!-- Footer End -->
            

            
        </div>
        <!-- Content End -->


        <!-- Back to Top -->
        <a href="#" class="btn btn-lg btn-primary btn-lg-square back-to-top"><i class="bi bi-arrow-up"></i></a>
    </div>

    <!-- JavaScript Libraries -->
    <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="lib/chart/chart.min.js"></script>
    <script src="lib/easing/easing.min.js"></script>
    <script src="lib/waypoints/waypoints.min.js"></script>
    <script src="lib/owlcarousel/owl.carousel.min.js"></script>
    <script src="lib/tempusdominus/js/moment.min.js"></script>
    <script src="lib/tempusdominus/js/moment-timezone.min.js"></script>
    <script src="lib/tempusdominus/js/tempusdominus-bootstrap-4.min.js"></script>

    <!-- Template Javascript -->
    <script src="js/main.js"></script>







			
     
   <script>
try {

document.getElementById("userSearch").addEventListener("keyup", function() {
    let filter = this.value.toLowerCase();
    let firstMatch = null;

    document.querySelectorAll("#userDropdown .user-item").forEach(function(item) {
        let text = item.innerText.toLowerCase();
        if (text.includes(filter)) {
            item.style.display = "";
            if (!firstMatch) firstMatch = item;
        } else {
            item.style.display = "none";
        }
    });

    // scroll into view the first found record
    if (firstMatch) {
        firstMatch.scrollIntoView({ block: "nearest" });
    }
});


  window.addEventListener("load", function() {
    try {
      var loader = document.getElementById("loader");
      var content = document.getElementById("content");

      if (loader) loader.style.display = "none";
      if (content) content.style.display = "block";
    } catch (err) {
    }
  });
  
} catch (err) {
}
</script>  
     
     
</body>
</html>