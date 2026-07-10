package is.five.apeaf.dao;


import org.hibernate.Session;
import org.hibernate.Transaction;

import is.five.apeaf.dao.model.TabRisc;



public class TabRiscDAO {

    public static TabRisc findLatestByUser(Integer idUser) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    "FROM TabRisc WHERE idUser = :idUser ORDER BY creationTimestamp DESC, id DESC",
                    TabRisc.class)
                    .setParameter("idUser", idUser)
                    .setMaxResults(1)
                    .uniqueResult();
        }
    }

    public static void saveOrUpdate(
            Integer idUser,
            String csvValue) {

        Session session = null;
        Transaction tx = null;

        try {

            session = HibernateUtil
                    .getSessionFactory()
                    .openSession();

            tx = session.beginTransaction();

            TabRisc tab =
                    session.createQuery(
                            "FROM TabRisc " +
                            "WHERE idUser = :idUser " +
                            "ORDER BY creationTimestamp DESC",
                            TabRisc.class
                    )
                    .setParameter("idUser", idUser)
                    .setMaxResults(1)
                    .uniqueResult();

            if (tab == null) {

                tab = new TabRisc();

                tab.setIdUser(idUser);
                tab.setValue(csvValue);

                session.persist(tab);

            } else {

                session.createNativeQuery(
                        "UPDATE `tab-risc` " +
                        "SET `value` = :value, " +
                        "`creationTimestamp` = CURRENT_TIMESTAMP " +
                        "WHERE `id` = :id"
                )
                .setParameter("value", csvValue)
                .setParameter("id", tab.getId())
                .executeUpdate();
            }

            tx.commit();

        } catch (Exception e) {

            if (tx != null) {

                try {

                    if (tx.getStatus().canRollback()) {
                        tx.rollback();
                    }

                } catch (Exception rollbackException) {
                    rollbackException.printStackTrace();
                }
            }

            e.printStackTrace();

            throw new RuntimeException(
                    "Errore durante il salvataggio dei parametri riscossione",
                    e
            );

        } finally {

            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }
}
