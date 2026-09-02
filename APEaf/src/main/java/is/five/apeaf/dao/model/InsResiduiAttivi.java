package is.five.apeaf.dao.model;


import java.sql.Timestamp;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "`ins-residui-attivi`")
public class InsResiduiAttivi {
	
	public final static String TIPOLOGIE[] = {"Accertamenti ICI", "Accertamenti TASI", "Accertamenti IMU", "Tassi Rifiuti", "CDS" };


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @Column(name = "anno")
    private int anno;

    public int getAnno() {
		return anno;
	}

	public void setAnno(int anno) {
		this.anno = anno;
	}

	@Column(name = "value")
    private String value;

    @Column(name = "id_user")
    private Integer idUser;

    @Column(
    	    name = "creationTimestamp",
    	    insertable = false,
    	    updatable = false
    	)
    	private Timestamp creationTimestamp;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Integer getIdUser() {
        return idUser;
    }

    public void setIdUser(Integer idUser) {
        this.idUser = idUser;
    }

    public Timestamp getCreationTimestamp() {
        return creationTimestamp;
    }

    public void setCreationTimestamp(Timestamp creationTimestamp) {
        this.creationTimestamp = creationTimestamp;
    }
}
