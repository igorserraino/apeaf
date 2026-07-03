package is.five.apeaf.dao;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;

import org.hibernate.query.Query;

import is.five.apeaf.dao.model.UserView;

public class UserDAO {
	
	
	
	 private SessionFactory sessionFactory;
	 
	 

	    public UserDAO() {
		super();
	}

		public UserDAO(SessionFactory sessionFactory) {
	        this.sessionFactory = sessionFactory;
	    }
	    
	    public void save(UserView bean) {
        
	        Session session = HibernateUtil.getSessionFactory().openSession();
	        Transaction transaction = null;
	
	        try {
	            transaction = session.beginTransaction();
	            session.save(bean);
	            transaction.commit();
	        } catch (Exception e) {
	            if (transaction != null) {
	                transaction.rollback();
	            }
	            e.printStackTrace();
	        } finally {
	            session.close();
	        }
	
	        //HibernateUtil.shutdown();
    }


	public UserView findByUsername(String username) {
		Session session = HibernateUtil.getSessionFactory().openSession();

		try {
			String hql = "FROM User WHERE username = :username";
			Query<UserView> query = session.createQuery(hql, UserView.class);
			query.setParameter("username", username);
			return query.uniqueResult();

		} catch (Exception e) {

			e.printStackTrace();
		} finally {
			session.close();
		}
		return null;

	}

}
