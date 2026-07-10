package is.five.apeaf.dao.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;



@Entity
@Table(name = "`tab-par`")
public class TabPar implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final int TYPE_SANZIONE = 0;
    public static final int TYPE_INTERESSI = 1;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "value", precision = 10, scale = 0)
    private BigDecimal value = BigDecimal.ZERO;

    @Column(name = "id_user")
    private Integer idUser;

    @Column(name = "type")
    private Integer type;

    @Column(name = "creationTimestamp", insertable = false, updatable = false)
    private Timestamp creationTimestamp;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public BigDecimal getValue() {
        return value;
    }

    public void setValue(BigDecimal value) {
        this.value = value;
    }

    public Integer getIdUser() {
        return idUser;
    }

    public void setIdUser(Integer idUser) {
        this.idUser = idUser;
    }

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public Timestamp getCreationTimestamp() {
        return creationTimestamp;
    }

    public void setCreationTimestamp(Timestamp creationTimestamp) {
        this.creationTimestamp = creationTimestamp;
    }
}