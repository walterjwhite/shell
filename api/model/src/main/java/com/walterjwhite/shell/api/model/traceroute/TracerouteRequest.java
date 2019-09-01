package com.walterjwhite.shell.api.model.traceroute;

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

@Data
@ToString(doNotUseGetters = true)
@NoArgsConstructor
// @PersistenceCapable
@Entity
public class TracerouteRequest extends AbstractEntity implements ShellCommandable {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected NetworkDiagnosticTest networkDiagnosticTest;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  @EqualsAndHashCode.Exclude
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  @EqualsAndHashCode.Exclude @Column protected boolean ipv4 = true;

  @EqualsAndHashCode.Exclude @Column protected int queriesPerHop = -1;

  @EqualsAndHashCode.Exclude @Column protected int maxHops = -1;

  @EqualsAndHashCode.Exclude @Column protected boolean noFragment;
  @EqualsAndHashCode.Exclude @Column protected int timeout;

  @OneToMany(mappedBy = "tracerouteRequest", cascade = CascadeType.ALL)
  protected List<TracerouteHop> tracerouteHops = new ArrayList<>();

  public TracerouteRequest(NetworkDiagnosticTest networkDiagnosticTest) {
    super();
    this.networkDiagnosticTest = networkDiagnosticTest;
  }
}
