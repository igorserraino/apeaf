package is.five.apeaf.dao.model;

import java.sql.Timestamp;
import java.time.LocalDateTime;

import javax.persistence.*;

@Entity
@Table(name = "annofinanziario",
       uniqueConstraints = @UniqueConstraint(name = "idx_anno_finanziario_id_user_anno", columnNames = {"id_user", "anno"}))
public class AnnoFinanziario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private int anno;

    @Column(name = "id_user", nullable = false)
    private int idUser;

    @Column(nullable = true, insertable = false, updatable = true)
    private LocalDateTime timestamp;

    // Constructors
    public AnnoFinanziario() {}

    public AnnoFinanziario(int anno, int idUser) {
        this.anno = anno;
        this.idUser = idUser;
    }

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public int getAnno() { return anno; }
    public void setAnno(int anno) { this.anno = anno; }

    public int getIdUser() { return idUser; }
    public void setIdUser(int idUser) { this.idUser = idUser; }

    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
}

