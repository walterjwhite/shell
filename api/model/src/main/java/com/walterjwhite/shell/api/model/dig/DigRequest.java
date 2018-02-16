package com.walterjwhite.shell.api.model.dig;

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
public class DigRequest extends AbstractEntity implements ShellCommandable {
  @ManyToOne @JoinColumn protected NetworkDiagnosticTest networkDiagnosticTest;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime requestDateTime = LocalDateTime.now();

  @Column(nullable = false, updatable = false)
  protected int timeout;

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

  public DigRequest() {
    super();
  }

  public NetworkDiagnosticTest getNetworkDiagnosticTest() {
    return networkDiagnosticTest;
  }

  public void setNetworkDiagnosticTest(NetworkDiagnosticTest networkDiagnosticTest) {
    this.networkDiagnosticTest = networkDiagnosticTest;
  }

  public LocalDateTime getRequestDateTime() {
    return requestDateTime;
  }

  public void setRequestDateTime(LocalDateTime requestDateTime) {
    this.requestDateTime = requestDateTime;
  }

  public List<DigRequestIPAddress> getDigRequestIPAddresses() {
    return digRequestIPAddresses;
  }

  public void setDigRequestIPAddresses(List<DigRequestIPAddress> digRequestIPAddresses) {
    this.digRequestIPAddresses = digRequestIPAddresses;
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

  public DigRequest withFQDN(final String fqdn) {
    this.networkDiagnosticTest = new NetworkDiagnosticTest();
    this.networkDiagnosticTest.withFQDN(fqdn);
    //    this.networkDiagnosticTest.withName("dig." + fqdn);
    //    this.networkDiagnosticTest.withDescription("dig." + fqdn);
    return this;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    DigRequest that = (DigRequest) o;
    return Objects.equals(networkDiagnosticTest, that.networkDiagnosticTest)
        && Objects.equals(requestDateTime, that.requestDateTime);
  }

  @Override
  public int hashCode() {

    return Objects.hash(networkDiagnosticTest, requestDateTime);
  }
}
