package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.time.LocalDateTime;
import java.util.Objects;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;

@Entity
public class BindAddressState extends AbstractEntity {
  @Column(nullable = false, updatable = false)
  protected LocalDateTime currentDateTime = LocalDateTime.now();

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected BindAddress bindAddress;

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ServiceStatus serviceStatus;

  @ManyToOne
  @JoinColumn(updatable = false)
  protected ShellCommand shellCommand;

  public BindAddressState(
      BindAddress bindAddress, ServiceStatus serviceStatus, ShellCommand shellCommand) {
    super();
    this.bindAddress = bindAddress;
    this.serviceStatus = serviceStatus;
    this.shellCommand = shellCommand;
  }

  public BindAddressState() {
    super();
  }

  public LocalDateTime getCurrentDateTime() {
    return currentDateTime;
  }

  public void setCurrentDateTime(LocalDateTime currentDateTime) {
    this.currentDateTime = currentDateTime;
  }

  public BindAddress getBindAddress() {
    return bindAddress;
  }

  public void setBindAddress(BindAddress bindAddress) {
    this.bindAddress = bindAddress;
  }

  public ServiceStatus getServiceStatus() {
    return serviceStatus;
  }

  public void setServiceStatus(ServiceStatus serviceStatus) {
    this.serviceStatus = serviceStatus;
  }

  public ShellCommand getShellCommand() {
    return shellCommand;
  }

  public void setShellCommand(ShellCommand shellCommand) {
    this.shellCommand = shellCommand;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    BindAddressState that = (BindAddressState) o;
    return Objects.equals(currentDateTime, that.currentDateTime)
        && Objects.equals(bindAddress, that.bindAddress)
        && Objects.equals(serviceStatus, that.serviceStatus);
  }

  @Override
  public int hashCode() {

    return Objects.hash(currentDateTime, bindAddress, serviceStatus);
  }
}
