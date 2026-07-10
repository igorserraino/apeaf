package is.five.apeaf.dao;

import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;

import is.five.apeaf.dao.model.InsDatiFCDE;

public class InsDatiFCDEDAO {

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

	        InsDatiFCDE entity = session.createQuery(
	                "FROM InsDatiFCDE " +
	                "WHERE idUser = :idUser " +
	                "AND anno = :anno",
	                InsDatiFCDE.class
	        )
	        .setParameter("idUser", idUser)
	        .setParameter("anno", anno)
	        .setMaxResults(1)
	        .uniqueResult();

	        if (entity == null) {

	            entity = new InsDatiFCDE();

	            entity.setIdUser(idUser);
	            entity.setAnno(anno);
	            entity.setValue(value);

	            session.persist(entity);

	        } else {

	            entity.setValue(value);

	            /*
	             * Force the timestamp update even when the value
	             * is identical to the stored value.
	             */
	            session.createNativeQuery(
	                    "UPDATE `ins-dati-fcde` " +
	                    "SET `value` = :value, " +
	                    "`creationTimestamp` = CURRENT_TIMESTAMP " +
	                    "WHERE `id_user` = :idUser " +
	                    "AND `anno` = :anno"
	            )
	            .setParameter("value", value)
	            .setParameter("idUser", idUser)
	            .setParameter("anno", anno)
	            .executeUpdate();
	        }

	        transaction.commit();

	    } catch (Exception e) {

	        if (transaction != null &&
	            transaction.getStatus().canRollback()) {

	            try {
	                transaction.rollback();
	            } catch (Exception rollbackException) {
	                rollbackException.printStackTrace();
	            }
	        }

	        e.printStackTrace();

	        throw new RuntimeException(
	                "Errore durante il salvataggio dei dati FCDE",
	                e
	        );

	    } finally {

	        if (session != null && session.isOpen()) {
	            session.close();
	        }
	    }
	}


    public static InsDatiFCDE findByUserAndAnno(
            int idUser,
            int anno) {

        try (Session session =
                HibernateUtil
                    .getSessionFactory()
                    .openSession()) {

            List<InsDatiFCDE> records =
                    session.createQuery(
                            "FROM InsDatiFCDE " +
                            "WHERE idUser = :idUser " +
                            "AND anno = :anno",
                            InsDatiFCDE.class
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
                    "DELETE FROM InsDatiFCDE " +
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