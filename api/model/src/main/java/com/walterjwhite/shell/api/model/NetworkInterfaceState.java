package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;
import javax.persistence.*;

@Entity
public class NetworkInterfaceState extends AbstractEntity {
  @ManyToOne(cascade = CascadeType.ALL, optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected NetworkInterface networkInterface;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  @OneToMany(cascade = CascadeType.ALL, mappedBy = "networkInterfaceState")
  protected Set<IPAddressState> ipAddressStates = new HashSet<>();

  public NetworkInterfaceState(NetworkInterface networkInterface) {
    super();
    this.networkInterface = networkInterface;
  }

  public NetworkInterfaceState() {
    super();
  }

  public NetworkInterface getNetworkInterface() {
    return networkInterface;
  }

  public void setNetworkInterface(NetworkInterface networkInterface) {
    this.networkInterface = networkInterface;
  }

  public LocalDateTime getDateTime() {
    return dateTime;
  }

  public void setDateTime(LocalDateTime dateTime) {
    this.dateTime = dateTime;
  }

  public Set<IPAddressState> getIpAddressStates() {
    return ipAddressStates;
  }

  public void setIpAddressStates(Set<IPAddressState> ipAddressStates) {
    this.ipAddressStates = ipAddressStates;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    NetworkInterfaceState that = (NetworkInterfaceState) o;
    return Objects.equals(networkInterface, that.networkInterface)
        && Objects.equals(dateTime, that.dateTime);
  }

  @Override
  public int hashCode() {

    return Objects.hash(networkInterface, dateTime);
  }
}
