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
import java.util.Objects;
import java.util.Random;
import javax.persistence.*;

/** Instructs a client to ping a target. */
@Entity
public class PingRequest extends AbstractEntity implements ShellCommandable {
  @ManyToOne @JoinColumn protected NetworkDiagnosticTest networkDiagnosticTest;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  // -c
  @Column(updatable = false)
  protected int count = 10;

  // -W
  @Column(updatable = false)
  protected int timeout = 5;

  // -i
  @Column(updatable = false)
  protected int interval = 1;

  @ManyToOne(cascade = CascadeType.ALL)
  @JoinColumn(nullable = false)
  protected IPAddress ipAddress;

  @Column
  @Enumerated(EnumType.STRING)
  protected PingResponseType pingResponseType;

  @OneToMany(cascade = CascadeType.ALL)
  protected List<PingResponse> pingResponses = new ArrayList<>();

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  public PingRequest(final NetworkDiagnosticTest networkDiagnosticTest) {
    super();
    this.networkDiagnosticTest = networkDiagnosticTest;
    this.count = new Random().nextInt(10);
  }

  public PingRequest() {
    super();
  }

  public NetworkDiagnosticTest getNetworkDiagnosticTest() {
    return networkDiagnosticTest;
  }

  public void setNetworkDiagnosticTest(NetworkDiagnosticTest networkDiagnosticTest) {
    this.networkDiagnosticTest = networkDiagnosticTest;
  }

  public LocalDateTime getDateTime() {
    return dateTime;
  }

  public void setDateTime(LocalDateTime dateTime) {
    this.dateTime = dateTime;
  }

  public int getCount() {
    return count;
  }

  public void setCount(int count) {
    this.count = count;
  }

  public int getTimeout() {
    return timeout;
  }

  public void setTimeout(int timeout) {
    this.timeout = timeout;
  }

  public int getInterval() {
    return interval;
  }

  public void setInterval(int interval) {
    this.interval = interval;
  }

  public IPAddress getIpAddress() {
    return ipAddress;
  }

  public void setIpAddress(IPAddress ipAddress) {
    this.ipAddress = ipAddress;
  }

  public PingResponseType getPingResponseType() {
    return pingResponseType;
  }

  public void setPingResponseType(PingResponseType pingResponseType) {
    this.pingResponseType = pingResponseType;
  }

  public List<PingResponse> getPingResponses() {
    return pingResponses;
  }

  public void setPingResponses(List<PingResponse> pingResponses) {
    this.pingResponses = pingResponses;
  }

  public ShellCommand getShellCommand() {
    return shellCommand;
  }

  public void setShellCommand(ShellCommand shellCommand) {
    this.shellCommand = shellCommand;
  }

  @Override
  public String toString() {
    return "PingRequest{"
        + ", count="
        + count
        + ", timeout="
        + timeout
        + ", interval="
        + interval
        + '}';
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    PingRequest that = (PingRequest) o;
    return Objects.equals(networkDiagnosticTest, that.networkDiagnosticTest)
        && Objects.equals(dateTime, that.dateTime);
  }

  @Override
  public int hashCode() {

    return Objects.hash(networkDiagnosticTest, dateTime);
  }
}
