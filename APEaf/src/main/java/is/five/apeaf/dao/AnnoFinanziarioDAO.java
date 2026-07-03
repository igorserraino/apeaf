package is.five.apeaf.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;

import org.hibernate.query.Query;

import is.five.apeaf.dao.model.AnnoFinanziario;


public class AnnoFinanziarioDAO {
	
	
	
	 private SessionFactory sessionFactory;
	 
	 

	    public AnnoFinanziarioDAO() {
		super();
	}

		public AnnoFinanziarioDAO(SessionFactory sessionFactory) {
	        this.sessionFactory = sessionFactory;
	    }
	    
	    public void save(AnnoFinanziario bean) {
        
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


	public AnnoFinanziario findByID(int id) {
		Session session = HibernateUtil.getSessionFactory().openSession();

		try {
			String hql = "FROM AnnoFinanziario WHERE id = :id";
			Query<AnnoFinanziario> query = session.createQuery(hql, AnnoFinanziario.class);
			query.setParameter("id", id);
			return query.uniqueResult();

		} catch (Exception e) {

			e.printStackTrace();
		} finally {
			session.close();
		}
		return null;
	}
	

	
	public List<AnnoFinanziario> findByIDUser(Integer id_user) {
		Session session = HibernateUtil.getSessionFactory().openSession();

		try {
			String hql = "FROM AnnoFinanziario WHERE id_user = :id_user";
			Query<AnnoFinanziario> query = session.createQuery(hql, AnnoFinanziario.class);
			query.setParameter("id_user", id_user);
			return query.getResultList();

		} catch (Exception e) {

			e.printStackTrace();
		} finally {
			session.close();
		}
		return new ArrayList<AnnoFinanziario>();
	}

}
