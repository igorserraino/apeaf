package is.five.apeaf.dao;


import is.five.apeaf.dao.model.UserView;

public class HibernateDAOTest {
    public static void main(String[] args) {
        // Create a new user
        /*User user = new User();
        user.setUsername("testuser");
        user.setPassword("password");

        // Open a session
        Session session = HibernateUtil.getSessionFactory().openSession();
        Transaction transaction = null;

        try {
            // Start a transaction
            transaction = session.beginTransaction();

            // Save the user object
            session.save(user);

            // Commit the transaction
            transaction.commit();
        } catch (Exception e) {
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
        } finally {
            session.close();
        }*/
        
        
        UserViewDAO dao = new UserViewDAO();
        UserView user = dao.selectByUsername("is.ad");
		/*if (user!=null && user.getId()!=0)
			request.getSession().setAttribute("user", user);*/
		
		if (user!=null)
			System.out.println(user);
        

        // Shutdown the session factory
        //HibernateUtil.shutdown();
    }
}
