package is.five.apeaf.dao;

import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;

import is.five.apeaf.dao.model.Tipologia;

public class TipologieDAO {

    /**
     * Returns all tipologie for user/year.
     */
    public static List<Tipologia> findByUserAndAnno(
            Integer idUser,
            Integer anno) {

        try (Session session =
                HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    "FROM Tipologia " +
                    "WHERE idUser = :idUser " +
                    "AND anno = :anno " +
                    "ORDER BY value ASC",
                    Tipologia.class)
                .setParameter("idUser", idUser)
                .setParameter("anno", anno)
                .getResultList();
        }
    }


    /**
     * Find one record by id.
     */
    public static Tipologia findById(Integer id) {

        try (Session session =
                HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Tipologia.class, id);
        }
    }


    /**
     * Checks if the same value already exists for user/year.
     */
    public static boolean exists(
            Integer idUser,
            Integer anno,
            String value) {

        try (Session session =
                HibernateUtil.getSessionFactory().openSession()) {

            Long count = session.createQuery(
                    "SELECT COUNT(t.id) " +
                    "FROM Tipologia t " +
                    "WHERE t.idUser = :idUser " +
                    "AND t.anno = :anno " +
                    "AND LOWER(t.value) = LOWER(:value)",
                    Long.class)
                .setParameter("idUser", idUser)
                .setParameter("anno", anno)
                .setParameter("value", value.trim())
                .getSingleResult();

            return count != null && count > 0;
        }
    }


    /**
     * Save a new tipologia.
     */
    public static void save(Tipologia tipologia) {

        Transaction tx = null;

        try (Session session =
                HibernateUtil.getSessionFactory().openSession()) {

            tx = session.beginTransaction();

            session.persist(tipologia);

            tx.commit();

        } catch (Exception e) {

            if (tx != null) {
                tx.rollback();
            }

            throw e;
        }
    }


    /**
     * Convenience method.
     */
    public static boolean save(
            Integer idUser,
            Integer anno,
            String value) {

        if (value == null || value.trim().isEmpty()) {
            return false;
        }

        value = value.trim();

        if (exists(idUser, anno, value)) {
            return false;
        }

        Tipologia t = new Tipologia();

        t.setIdUser(idUser);
        t.setAnno(anno);
        t.setValue(value);

        save(t);

        return true;
    }


    /**
     * Delete, checking ownership.
     */
    public static boolean delete(
            Integer id,
            Integer idUser) {

        Transaction tx = null;

        try (Session session =
                HibernateUtil.getSessionFactory().openSession()) {

            tx = session.beginTransaction();

            Tipologia t = session.createQuery(
                    "FROM Tipologia " +
                    "WHERE id = :id " +
                    "AND idUser = :idUser",
                    Tipologia.class)
                .setParameter("id", id)
                .setParameter("idUser", idUser)
                .uniqueResult();

            if (t == null) {
                tx.rollback();
                return false;
            }

            session.remove(t);

            tx.commit();

            return true;

        } catch (Exception e) {

            if (tx != null) {
                tx.rollback();
            }

            throw e;
        }
    }


    /**
     * Returns a complete HTML SELECT.
     */
    public static String getSelectByUserAndAnno(
            Integer idUser,
            Integer anno,
            String selectName) {

        return getSelectByUserAndAnno(
                idUser,
                anno,
                selectName,
                null);
    }


    /**
     * Returns a complete HTML SELECT and selects the supplied value.
     */
    public static String getSelectByUserAndAnno(
            Integer idUser,
            Integer anno,
            String selectName,
            String selectedValue) {

        List<Tipologia> tipologie =
                findByUserAndAnno(idUser, anno);

        StringBuilder html = new StringBuilder();

        html.append("<select ")
            .append("name=\"")
            .append(escapeHtml(selectName))
            .append("\" ")
            .append("id=\"")
            .append(escapeHtml(selectName))
            .append("\" ")
            .append("class=\"form-select\">");

        html.append(
            "<option value=\"\">-- Seleziona tipologia --</option>"
        );

        for (Tipologia t : tipologie) {

            String value = t.getValue();

            html.append("<option value=\"")
                .append(escapeHtml(value))
                .append("\"");

            if (selectedValue != null
                    && selectedValue.equalsIgnoreCase(value)) {

                html.append(" selected");
            }

            html.append(">");

            html.append(escapeHtml(value));

            html.append("</option>");
        }

        html.append("</select>");

        return html.toString();
    }


    /**
     * Basic HTML escaping.
     */
    private static String escapeHtml(String value) {

        if (value == null) {
            return "";
        }

        return value
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    }
}