package com.walterjwhite.shell.api.model.ping;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.PingResponseType;
import com.walterjwhite.shell.api.model.IPAddress;
import com.walterjwhite.shell.api.model.NetworkDiagnosticTest;
import com.walterjwhite.shell.api.model.ShellCommand;
import com.walterjwhite.shell.api.model.ShellCommandable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import javax.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

/** Instructs a client to ping a target. */
// @PersistenceCapable
@Entity
@Data
@ToString(doNotUseGetters = true)
@NoArgsConstructor
public class PingRequest extends AbstractEntity implements ShellCommandable {
  @ManyToOne @JoinColumn protected NetworkDiagnosticTest networkDiagnosticTest;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  // -c
  @EqualsAndHashCode.Exclude
  @Column(updatable = false)
  protected int count = 10;

  // -W
  @EqualsAndHashCode.Exclude
  @Column(updatable = false)
  protected int timeout = 5;

  // -i
  @EqualsAndHashCode.Exclude
  @Column(updatable = false)
  protected int interval = 1;

  @EqualsAndHashCode.Exclude
  @ManyToOne(cascade = CascadeType.ALL)
  @JoinColumn(nullable = false)
  protected IPAddress ipAddress;

  @EqualsAndHashCode.Exclude
  @Column
  @Enumerated(EnumType.STRING)
  protected PingResponseType pingResponseType;

  @EqualsAndHashCode.Exclude
  @OneToMany(cascade = CascadeType.ALL)
  protected List<PingResponse> pingResponses = new ArrayList<>();

  @EqualsAndHashCode.Exclude
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  public PingRequest(final NetworkDiagnosticTest networkDiagnosticTest) {
    super();
    this.networkDiagnosticTest = networkDiagnosticTest;
    this.count = new Random().nextInt(10);
  }
}
