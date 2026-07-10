package is.five.apeaf.dao.model;

import java.io.Serializable;
import java.sql.Timestamp;

import javax.persistence.*;


@Entity
@Table(name = "`ins-tab-ruoli`")
public class InsTabRuoli implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "anno", nullable = false)
    private Integer anno;

    @Column(name = "`values`", columnDefinition = "TEXT")
    private String values;

    @Column(name = "id_user", nullable = false)
    private Integer idUser;

    @Column(
        name = "creationTimestamp",
        insertable = false,
        updatable = false
    )
    private Timestamp creationTimestamp;

    public InsTabRuoli() {
    }

    public InsTabRuoli(Integer anno, String values, Integer idUser) {
        this.anno = anno;
        this.values = values;
        this.idUser = idUser;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getAnno() {
        return anno;
    }

    public void setAnno(Integer anno) {
        this.anno = anno;
    }

    public String getValues() {
        return values;
    }

    public void setValues(String values) {
        this.values = values;
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
    
    
    
    
    public String[] getValuesArray() {
        return values == null ? new String[0] : values.split(";", -1);
    }

    public String getEntrata() {
        String[] v = getValuesArray();
        return v.length > 0 ? v[0] : "";
    }

    public String getValue(int index) {
        String[] v = getValuesArray();
        return index < v.length ? v[index] : "";
    }
}