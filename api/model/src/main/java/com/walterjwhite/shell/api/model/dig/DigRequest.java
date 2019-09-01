package com.walterjwhite.shell.api.model.dig;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.model.NetworkDiagnosticTest;
import com.walterjwhite.shell.api.model.ShellCommand;
import com.walterjwhite.shell.api.model.ShellCommandable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

// @PersistenceCapable
@Entity
@Data
@ToString(doNotUseGetters = true)
@NoArgsConstructor
public class DigRequest extends AbstractEntity implements ShellCommandable {
  @ManyToOne @JoinColumn protected NetworkDiagnosticTest networkDiagnosticTest;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime requestDateTime = LocalDateTime.now();

  @EqualsAndHashCode.Exclude
  @Column(nullable = false, updatable = false)
  protected int timeout;

  @EqualsAndHashCode.Exclude
  @ManyToOne
  @JoinColumn(updatable = false)
  protected ShellCommand shellCommand;

  // TODO: capture status here
  //  @Column
  //  protected String status;

  @OneToMany(cascade = CascadeType.ALL)
  @JoinTable
  protected List<DigRequestIPAddress> digRequestIPAddresses = new ArrayList<>();

  public DigRequest(NetworkDiagnosticTest networkDiagnosticTest) {
    super();
    this.networkDiagnosticTest = networkDiagnosticTest;
  }
}
