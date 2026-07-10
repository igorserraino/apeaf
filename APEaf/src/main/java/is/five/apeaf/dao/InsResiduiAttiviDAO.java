package is.five.apeaf.dao;

import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;

import is.five.apeaf.dao.model.InsResiduiAttivi;

public class InsResiduiAttiviDAO {

	public static void saveOrUpdate(
	        int idUser,
	        int anno,
	        String value) {

	    Session session = null;
	    Transaction transaction = null;

	    try {

	        session = HibernateUtil
	                .getSessionFactory()
	                .openSession();

	        transaction = session.beginTransaction();

	        InsResiduiAttivi entity =
	                session.createQuery(
	                        "FROM InsResiduiAttivi " +
	                        "WHERE idUser = :idUser " +
	                        "AND anno = :anno",
	                        InsResiduiAttivi.class
	                )
	                .setParameter("idUser", idUser)
	                .setParameter("anno", anno)
	                .setMaxResults(1)
	                .uniqueResult();

	        if (entity == null) {

	            entity = new InsResiduiAttivi();

	            entity.setIdUser(idUser);
	            entity.setAnno(anno);
	            entity.setValue(value);

	            session.persist(entity);

	        } else {

	            entity.setValue(value);

	            /*
	             * entity is already managed because it was loaded
	             * in the same Hibernate Session.
	             * merge() is not necessary.
	             */
	        }

	        transaction.commit();

	    } catch (Exception e) {

	        if (transaction != null) {

	            try {

	                if (transaction.getStatus().canRollback()) {
	                    transaction.rollback();
	                }

	            } catch (Exception rollbackException) {
	                rollbackException.printStackTrace();
	            }
	        }

	        e.printStackTrace();

	        throw new RuntimeException(
	                "Errore durante il salvataggio dei residui attivi",
	                e
	        );

	    } finally {

	        if (session != null && session.isOpen()) {
	            session.close();
	        }
	    }
	}


    public static InsResiduiAttivi findByUserAndAnno(
            int idUser,
            int anno) {

        try (Session session =
                HibernateUtil
                    .getSessionFactory()
                    .openSession()) {

            List<InsResiduiAttivi> records =
                    session.createQuery(
                            "FROM InsResiduiAttivi " +
                            "WHERE idUser = :idUser " +
                            "AND anno = :anno",
                            InsResiduiAttivi.class
                    )
                    .setParameter("idUser", idUser)
                    .setParameter("anno", anno)
                    .setMaxResults(1)
                    .getResultList();

            return records.isEmpty()
                    ? null
                    : records.get(0);
        }
    }


    public static void delete(
            int idUser,
            int anno) {

        Transaction transaction = null;

        try (Session session =
                HibernateUtil
                    .getSessionFactory()
                    .openSession()) {

            transaction = session.beginTransaction();

            session.createQuery(
                    "DELETE FROM InsResiduiAttivi " +
                    "WHERE idUser = :idUser " +
                    "AND anno = :anno"
            )
            .setParameter("idUser", idUser)
            .setParameter("anno", anno)
            .executeUpdate();

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null &&
                transaction.getStatus().canRollback()) {

                transaction.rollback();
            }

            throw e;
        }
    }
}