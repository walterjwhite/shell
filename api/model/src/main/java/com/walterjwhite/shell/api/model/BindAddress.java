package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.Protocol;
import java.util.Objects;
import javax.persistence.*;

@Entity
public class BindAddress extends AbstractEntity {
  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected Protocol protocol;

  @Column(nullable = false, updatable = false)
  protected int port;

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected IPAddress ipAddress;

  public BindAddress(Protocol protocol, int port, IPAddress ipAddress) {
    super();
    this.protocol = protocol;
    this.port = port;
    this.ipAddress = ipAddress;
  }

  public BindAddress() {
    super();
  }

  public Protocol getProtocol() {
    return protocol;
  }

  public void setProtocol(Protocol protocol) {
    this.protocol = protocol;
  }

  public int getPort() {
    return port;
  }

  public void setPort(int port) {
    this.port = port;
  }

  public IPAddress getIpAddress() {
    return ipAddress;
  }

  public void setIpAddress(IPAddress ipAddress) {
    this.ipAddress = ipAddress;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    BindAddress that = (BindAddress) o;
    return port == that.port
        && protocol == that.protocol
        && Objects.equals(ipAddress, that.ipAddress);
  }

  @Override
  public int hashCode() {

    return Objects.hash(protocol, port, ipAddress);
  }

  @Override
  public String toString() {
    return "BindAddress{"
        + "protocol="
        + protocol
        + ", port="
        + port
        + ", ipAddress="
        + ipAddress
        + '}';
  }
}
