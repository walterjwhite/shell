package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.util.Objects;
import javax.persistence.Column;
import javax.persistence.Entity;

@Entity
public class IPAddress extends AbstractEntity {
  @Column(nullable = false, unique = true, updatable = false)
  protected String address;

  public IPAddress(String address) {
    super();
    this.address = address;
  }

  public IPAddress() {
    super();
  }

  public String getAddress() {
    return address;
  }

  public void setAddress(String address) {
    this.address = address;
  }

  @Override
  public String toString() {
    return "IPAddress{" + "ipAddress='" + address + '\'' + '}';
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    IPAddress ipAddress = (IPAddress) o;
    return Objects.equals(address, ipAddress.address);
  }

  @Override
  public int hashCode() {

    return Objects.hash(address);
  }
}
