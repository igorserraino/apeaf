package is.five.apeaf.dao;

import java.util.Collections;
import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;

import is.five.apeaf.dao.model.InsTabRuoli;

public class InsTabRuoliDAO {

    private InsTabRuoliDAO() {
    }

    public static void saveOrUpdateByUserAndAnno(
            InsTabRuoli record) {

        Transaction transaction = null;

        try (Session session =
                HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            InsTabRuoli existing = session.createQuery(
                """
                FROM InsTabRuoli
                WHERE idUser = :idUser
                  AND anno = :anno
                """,
                InsTabRuoli.class
            )
            .setParameter("idUser", record.getIdUser())
            .setParameter("anno", record.getAnno())
            .uniqueResult();

            if (existing == null) {

                session.persist(record);

            } else {

                existing.setValues(record.getValues());

                /*
                 * Non serve chiamare merge/update:
                 * existing è già gestito dalla sessione Hibernate.
                 */
            }

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null) {
                try {
                    transaction.rollback();
                } catch (Exception rollbackException) {
                    rollbackException.printStackTrace();
                }
            }

            throw new RuntimeException(
                "Errore durante il salvataggio della tabella ruoli",
                e
            );
        }
    }

    public static void update(InsTabRuoli record) {

        Transaction transaction = null;

        try (Session session =
                HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(record);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null) {
                try {
                    transaction.rollback();
                } catch (Exception rollbackException) {
                    rollbackException.printStackTrace();
                }
            }

            throw new RuntimeException(
                "Errore durante l'aggiornamento del ruolo coattivo",
                e
            );
        }
    }

    public static void delete(int id, int idUser) {

        Transaction tx = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            tx = session.beginTransaction();

            InsTabRuoli r = session.get(InsTabRuoli.class, id);

            if (r != null && r.getIdUser().equals(idUser)) {
                session.remove(r);
            }

            tx.commit();
        }
    }

    public static InsTabRuoli findById(
            Integer id,
            Integer idUser) {

        try (Session session =
                HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                """
                FROM InsTabRuoli
                WHERE id = :id
                  AND idUser = :idUser
                """,
                InsTabRuoli.class
            )
            .setParameter("id", id)
            .setParameter("idUser", idUser)
            .uniqueResult();

        } catch (Exception e) {
            throw new RuntimeException(
                "Errore durante la ricerca del ruolo coattivo",
                e
            );
        }
    }

    public static List<InsTabRuoli> findByUser(Integer idUser) {

        try (Session session =
                HibernateUtil
                    .getSessionFactory()
                    .openSession()) {

            return session.createQuery(
                    "FROM InsTabRuoli " +
                    "WHERE idUser = :idUser " +
                    "ORDER BY anno ASC",
                    InsTabRuoli.class
                )
                .setParameter("idUser", idUser)
                .getResultList();
        }
    }

    public static List<InsTabRuoli> findByUserAndAnno(
            Integer idUser,
            Integer anno) {

        try (Session session =
                HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                """
                FROM InsTabRuoli
                WHERE idUser = :idUser
                  AND anno = :anno
                ORDER BY id DESC
                """,
                InsTabRuoli.class
            )
            .setParameter("idUser", idUser)
            .setParameter("anno", anno)
            .getResultList();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }
}