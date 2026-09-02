package is.five.apeaf.dao;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;

import is.five.apeaf.dao.model.InsDatiFCDE;
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
    
    
    public static List<String> findTipologieByUserAndAnno(
            int idUser,
            int anno) {

        List<String> tipologie = new ArrayList<>();

        /*
         * 1. Tipologie standard definite nel bean
         */
        Collections.addAll(
                tipologie,
                InsResiduiAttivi.TIPOLOGIE
        );


        /*
         * 2. Tipologie aggiuntive lette dal DB
         */
        InsResiduiAttivi entity =
                findByUserAndAnno(
                        idUser,
                        anno
                );

        if (entity == null ||
            entity.getValue() == null ||
            entity.getValue().trim().isEmpty()) {

            return tipologie;
        }


        String[] tokens =
                entity.getValue().split(";", -1);


        for (String token : tokens) {

            if (token == null) {
                continue;
            }

            token = token.trim();

            if (token.isEmpty()) {
                continue;
            }


            /*
             * Solo le voci custom hanno il formato:
             *
             * nome=valore
             */
            int pos = token.indexOf('=');

            if (pos <= 0) {
                continue;
            }


            String nomeTipologia =
                    token.substring(0, pos).trim();

            if (!nomeTipologia.isEmpty() &&
                !tipologie.contains(nomeTipologia)) {

                tipologie.add(nomeTipologia);
            }
        }


        return tipologie;
    }
    
}