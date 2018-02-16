package com.walterjwhite.shell.api.model.traceroute;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.model.NetworkDiagnosticTest;
import com.walterjwhite.shell.api.model.ShellCommand;
import com.walterjwhite.shell.api.model.ShellCommandable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import javax.persistence.*;

@Entity
public class TracerouteRequest extends AbstractEntity implements ShellCommandable {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected NetworkDiagnosticTest networkDiagnosticTest;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  @Column protected boolean ipv4 = true;

  @Column protected int queriesPerHop = -1;

  @Column protected int maxHops = -1;

  @Column protected boolean noFragment;
  @Column protected int timeout;

  @OneToMany(mappedBy = "tracerouteRequest", cascade = CascadeType.ALL)
  protected List<TracerouteHop> tracerouteHops = new ArrayList<>();

  public TracerouteRequest(NetworkDiagnosticTest networkDiagnosticTest) {
    super();
    this.networkDiagnosticTest = networkDiagnosticTest;
  }

  public TracerouteRequest() {
    super();
  }

  public NetworkDiagnosticTest getNetworkDiagnosticTest() {
    return networkDiagnosticTest;
  }

  public void setNetworkDiagnosticTest(NetworkDiagnosticTest networkDiagnosticTest) {
    this.networkDiagnosticTest = networkDiagnosticTest;
  }

  public boolean isIpv4() {
    return ipv4;
  }

  public void setIpv4(boolean ipv4) {
    this.ipv4 = ipv4;
  }

  public int getQueriesPerHop() {
    return queriesPerHop;
  }

  public void setQueriesPerHop(int queriesPerHop) {
    this.queriesPerHop = queriesPerHop;
  }

  public int getMaxHops() {
    return maxHops;
  }

  public void setMaxHops(int maxHops) {
    this.maxHops = maxHops;
  }

  public boolean isNoFragment() {
    return noFragment;
  }

  public void setNoFragment(boolean noFragment) {
    this.noFragment = noFragment;
  }

  public ShellCommand getShellCommand() {
    return shellCommand;
  }

  public void setShellCommand(ShellCommand shellCommand) {
    this.shellCommand = shellCommand;
  }

  @Override
  public int getTimeout() {
    return timeout;
  }

  @Override
  public void setTimeout(int timeout) {
    this.timeout = timeout;
  }

  public List<TracerouteHop> getTracerouteHops() {
    return tracerouteHops;
  }

  public void setTracerouteHops(List<TracerouteHop> tracerouteHops) {
    this.tracerouteHops = tracerouteHops;
  }

  public LocalDateTime getDateTime() {
    return dateTime;
  }

  public void setDateTime(LocalDateTime dateTime) {
    this.dateTime = dateTime;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    TracerouteRequest that = (TracerouteRequest) o;
    return Objects.equals(networkDiagnosticTest, that.networkDiagnosticTest)
        && Objects.equals(dateTime, that.dateTime);
  }

  @Override
  public int hashCode() {

    return Objects.hash(networkDiagnosticTest, dateTime);
  }
}
