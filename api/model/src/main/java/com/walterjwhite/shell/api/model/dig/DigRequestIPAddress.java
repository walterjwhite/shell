package com.walterjwhite.shell.api.model.dig;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.model.IPAddress;
import java.time.LocalDateTime;
import java.util.Objects;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;

@Entity
public class DigRequestIPAddress extends AbstractEntity {
  @Column(nullable = false, updatable = false)
  protected LocalDateTime currentDateTime = LocalDateTime.now();

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected IPAddress ipAddress;

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected DigRequest digRequest;

  public DigRequestIPAddress(IPAddress ipAddress, DigRequest digRequest) {
    super();
    this.ipAddress = ipAddress;
    this.digRequest = digRequest;
  }

  public DigRequestIPAddress() {
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

  public DigRequest getDigRequest() {
    return digRequest;
  }

  public void setDigRequest(DigRequest digRequest) {
    this.digRequest = digRequest;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    DigRequestIPAddress that = (DigRequestIPAddress) o;
    return Objects.equals(currentDateTime, that.currentDateTime)
        && Objects.equals(ipAddress, that.ipAddress)
        && Objects.equals(digRequest, that.digRequest);
  }

  @Override
  public int hashCode() {

    return Objects.hash(currentDateTime, ipAddress, digRequest);
  }
}
