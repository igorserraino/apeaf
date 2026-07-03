package is.five.apeaf.dao.model;

import java.sql.Timestamp;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@Entity
@Table(name = "user_view")
public class UserView {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String username;
    
    @JsonIgnore
    private String enc_password;
    
    private Boolean active;
    private int groupId;
    
    private Timestamp creationTimestamp;
    private Timestamp lastAccessTimestamp;
    
    private String applicazioni;
    
    private String partner;
    private String codice_ap;
    

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @JsonIgnore
    public String getPassword() {
        return enc_password;
    }

    public void setPassword(String password) {
        this.enc_password = password;
    }

	public Boolean getActive() {
		return active;
	}

	public int getGroupId() {
		return groupId;
	}

	public Timestamp getCreationTimestamp() {
		return creationTimestamp;
	}

	public Timestamp getLastAccessTimestamp() {
		return lastAccessTimestamp;
	}

	public void setActive(Boolean active) {
		this.active = active;
	}

	public void setGroupId(int groupId) {
		this.groupId = groupId;
	}

	public void setCreationTimestamp(Timestamp creationTimestamp) {
		this.creationTimestamp = creationTimestamp;
	}

	public void setLastAccessTimestamp(Timestamp lastAccessTimestamp) {
		this.lastAccessTimestamp = lastAccessTimestamp;
	}

	@Override
	public String toString() {
		return "User [id=" + id + ", username=" + username +  ", active=" + active
				+ ", groupId=" + groupId + ", creationTimestamp=" + creationTimestamp + ", lastAccessTimestamp="
				+ lastAccessTimestamp + ", applicazioni=" + applicazioni + "]";
	}

	public String getApplicazioni() {
		return applicazioni;
	}

	public void setApplicazioni(String applicazioni) {
		this.applicazioni = applicazioni;
	}

	public String getPartner() {
		return partner;
	}

	public void setPartner(String partner) {
		this.partner = partner;
	}

	public String getCodice_ap() {
		return codice_ap;
	}

	public void setCodice_ap(String codice_ap) {
		this.codice_ap = codice_ap;
	}



	public String toJson() {
	    ObjectMapper objectMapper = new ObjectMapper();
	    try {
	        String json = objectMapper.writeValueAsString(this);
	        return json;
	    } catch (JsonProcessingException e) {
	        e.printStackTrace();
	        return "{}"; // Return empty JSON if serialization fails
	    }
	}
	
	public static UserView fromJson(String jsonString) {
	    ObjectMapper objectMapper = new ObjectMapper();
	    try {
	        return objectMapper.readValue(jsonString, UserView.class);
	    } catch (Exception e) {
	        e.printStackTrace();
	        return null; // Return null if parsing fails
	    }
	}
	
	

}

