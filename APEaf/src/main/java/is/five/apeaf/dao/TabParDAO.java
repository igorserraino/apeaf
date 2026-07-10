package is.five.apeaf.dao;

import java.math.BigDecimal;
import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;

import is.five.apeaf.dao.model.TabPar;



public class TabParDAO {

	public static List<TabPar> findByUserAndType(int idUser, int type) {

	    try (Session session = HibernateUtil.getSessionFactory().openSession()) {

	        return session.createQuery(
	                "from TabPar where idUser = :idUser and type = :type order by id desc",
	                TabPar.class)
	                .setParameter("idUser", idUser)
	                .setParameter("type", type)
	                .list();
	    }
	}

    public static List<TabPar> findByUser(int idUser) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    "from TabPar where idUser = :idUser order by type, id",
                    TabPar.class)
                    .setParameter("idUser", idUser)
                    .list();
        }
    }

    public static boolean saveValue(int idUser, int type, BigDecimal value) {

        if (exists(idUser, type, value)) {
            return false;
        }

        Transaction tx = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            tx = session.beginTransaction();

            TabPar tabPar = new TabPar();
            tabPar.setIdUser(idUser);
            tabPar.setType(type);
            tabPar.setValue(value);

            session.persist(tabPar);

            tx.commit();

            return true;

        } catch (Exception e) {

            if (tx != null) {
                tx.rollback();
            }

            throw e;
        }
    }
    
    public static boolean exists(int idUser, int type, BigDecimal value) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Long count = session.createQuery(
                    "select count(t.id) " +
                    "from TabPar t " +
                    "where t.idUser = :idUser " +
                    "and t.type = :type " +
                    "and t.value = :value",
                    Long.class)
                .setParameter("idUser", idUser)
                .setParameter("type", type)
                .setParameter("value", value)
                .uniqueResult();

            return count != null && count > 0;
        }
    }
}