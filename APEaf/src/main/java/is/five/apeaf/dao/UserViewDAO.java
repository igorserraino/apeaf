package is.five.apeaf.dao;

import java.util.ArrayList;

import org.hibernate.Session;
import org.hibernate.query.Query;

import is.five.apeaf.dao.model.UserView;




public class UserViewDAO {


	public UserView selectByID(Integer id) {
		Session session = HibernateUtil.getSessionFactory().openSession();

		try {
			String hql = "FROM UserView WHERE id = :id";
			Query<UserView> query = session.createQuery(hql, UserView.class);
			query.setParameter("id", id);
			return query.uniqueResult();

		} catch (Exception e) {

			e.printStackTrace();
		} finally {
			session.close();
		}
		return null;
	}
	
	
	public UserView selectByUsername(String username) {
		Session session = HibernateUtil.getSessionFactory().openSession();

		try {
			String hql = "FROM UserView WHERE username = :username";
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
	
	public ArrayList<UserView> selectByALL() {
		Session session = HibernateUtil.getSessionFactory().openSession();

		try {
			String hql = "FROM UserView ORDER BY "
					+ "  CASE "
					+ "    WHEN LOWER(username) LIKE '%five%' THEN 0 "
					+ "    ELSE 1 "
					+ "  END,"
					+ "  username";
			Query<UserView> query = session.createQuery(hql, UserView.class);
			return new ArrayList<UserView>(query.getResultList());

		} catch (Exception e) {

			e.printStackTrace();
		} finally {
			session.close();
		}
		return null;
	}
	
	
	
	
	
	
	
	

	
	
}
