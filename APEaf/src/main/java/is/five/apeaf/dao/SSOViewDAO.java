package is.five.apeaf.dao;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.query.Query;

import is.five.apeaf.dao.model.SSOView;



public class SSOViewDAO {
	
	private SessionFactory sessionFactory;



	 public SSOViewDAO() {
	    	super();
	    }

		public SSOViewDAO(SessionFactory sessionFactory) {
	        this.sessionFactory = sessionFactory;
	    }
	
		
		public SSOView selectByUsername(String user) {
			Session session = HibernateUtil.getSessionFactory().openSession();

			try {
				String hql = "FROM SSOView WHERE user = :user";
				Query<SSOView> query = session.createQuery(hql, SSOView.class);
				query.setParameter("user", user);
				return query.uniqueResult();

			} catch (Exception e) {

				e.printStackTrace();
			} finally {
				session.close();
			}
			return null;
		}
		
	
	
	

	
	
}
