package is.five.apeaf.dao.model;

import java.sql.Timestamp;
import java.time.Instant;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "anagrafiche")
public class Anagrafiche {
	
	public final static String[] TIPO_AFF_GESTORE = {"appalto", "concessione"};
	public final static String[] NATURA_SOC_GESTORE = {"societ&agrave; privata", "societ&agrave; in-house", "societ&agrave; mista"};

	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
	
	private int cat;
	
	public int getCat() {
		return cat;
	}

	public void setCat(int cat) {
		this.cat = cat;
	}

	private int idservizio;
	private int idanno;
	private String value;
	private int iduser;
		
	private Timestamp creationTimestamp = Timestamp.from(Instant.now());

	public int getId() {
		return id;
	}

	public int getIdservizio() {
		return idservizio;
	}

	public int getIdanno() {
		return idanno;
	}

	public String getValue() {
		return value;
	}

	public int getIduser() {
		return iduser;
	}

	public Timestamp getCreationTimestamp() {
		return creationTimestamp;
	}

	public void setId(int id) {
		this.id = id;
	}

	public void setIdservizio(int idservizio) {
		this.idservizio = idservizio;
	}

	public void setIdanno(int idanno) {
		this.idanno = idanno;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public void setIduser(int iduser) {
		this.iduser = iduser;
	}

	public void setCreationTimestamp(Timestamp creationTimestamp) {
		this.creationTimestamp = creationTimestamp;
	}
	
	
	

    public static String getTIPO_AFF_GESTORE(String index) {
    	switch (index) {
	    	case ("1"): {
	    		return TIPO_AFF_GESTORE[0];
	    	}
	    	case ("2"): {
	    		return TIPO_AFF_GESTORE[01];
	    	}
	    	default: {
	    		return "n.d.";
	    	}
    	}
    }
    
    public static String getNATURA_AFF_GESTORE(String index) {
    	switch (index) {
	    	case ("1"): {
	    		return NATURA_SOC_GESTORE[0];
	    	}
	    	case ("2"): {
	    		return NATURA_SOC_GESTORE[1];
	    	}
	    	case ("3"): {
	    		return NATURA_SOC_GESTORE[2];
	    	}
	    	default: {
	    		return "n.d.";
	    	}
    	}
    }
    
    

}
