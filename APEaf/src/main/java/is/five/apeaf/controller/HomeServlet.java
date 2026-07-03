package is.five.apeaf.controller;


import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import is.five.apeaf.dao.model.UserView;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward the request to home.jsp
    	
    	UserView user = (UserView) request.getSession().getAttribute("ubAP");
		if (user==null)
			{ response.sendRedirect("index.jsp"); return; }
    	
        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward the request to home.jsp
    	UserView user = (UserView) request.getSession().getAttribute("ubAP");
		if (user==null)
			{ response.sendRedirect("index.jsp"); return; }
        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }
}

