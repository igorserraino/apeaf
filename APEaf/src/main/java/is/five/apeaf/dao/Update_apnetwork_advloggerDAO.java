package is.five.apeaf.dao;

import java.sql.Timestamp;
import java.time.Instant;

import javax.transaction.Transactional;

import org.hibernate.Session;
import org.hibernate.Transaction;

import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.view.ViewConstants;


public class Update_apnetwork_advloggerDAO {
	
	static String CALL_PROCEDURE = "CALL apnetwork.update_apnetwork_advlogger(?,?,?,?,?)";
	
	@Transactional
	public void insert(UserView ubAP, String ip, String isOK) {
        Session session = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = session.beginTransaction();


        try {

        session.createNativeQuery("CALL apnetwork.update_apnetwork_advlogger(?,?,?,?,?)")
        .setParameter(1, ubAP.getId())
        .setParameter(2, ubAP.getUsername())
        .setParameter(3, isOK != null ? isOK + " " + ViewConstants.REV : ViewConstants.REV)
        .setParameter(4, Timestamp.from(Instant.now()))
        .setParameter(5, ip)
        .executeUpdate();
        
      
        } catch (Exception e) {

            e.printStackTrace();
        } finally {
        	tx.commit();
        	session.close();
        	}

    }
	
	
}
