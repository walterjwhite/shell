package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.time.LocalDateTime;
import java.util.Objects;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;

@Entity
public class IPAddressState extends AbstractEntity {
  @Column(nullable = false, updatable = false)
  protected LocalDateTime currentDateTime = LocalDateTime.now();

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected IPAddress ipAddress;

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected NetworkInterfaceState networkInterfaceState;

  public IPAddressState(IPAddress ipAddress, NetworkInterfaceState networkInterfaceState) {
    super();
    this.ipAddress = ipAddress;
    this.networkInterfaceState = networkInterfaceState;
  }

  public IPAddressState() {
    super();
  }

  public LocalDateTime getCurrentDateTime() {
    return currentDateTime;
  }

  public void setCurrentDateTime(LocalDateTime currentDateTime) {
    this.currentDateTime = currentDateTime;
  }

  public IPAddress getIpAddress() {
    return ipAddress;
  }

  public void setIpAddress(IPAddress ipAddress) {
    this.ipAddress = ipAddress;
  }

  public NetworkInterfaceState getNetworkInterfaceState() {
    return networkInterfaceState;
  }

  public void setNetworkInterfaceState(NetworkInterfaceState networkInterfaceState) {
    this.networkInterfaceState = networkInterfaceState;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    IPAddressState that = (IPAddressState) o;
    return Objects.equals(currentDateTime, that.currentDateTime)
        && Objects.equals(ipAddress, that.ipAddress)
        && Objects.equals(networkInterfaceState, that.networkInterfaceState);
  }

  @Override
  public int hashCode() {

    return Objects.hash(currentDateTime, ipAddress, networkInterfaceState);
  }
}
