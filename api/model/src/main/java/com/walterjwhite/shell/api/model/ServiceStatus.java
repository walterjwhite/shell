package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.ServiceState;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;
import javax.persistence.*;

@Entity
public class ServiceStatus extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected Service service;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected ServiceState state;

  @OneToMany(cascade = CascadeType.ALL, mappedBy = "serviceStatus")
  protected Set<BindAddressState> bindAddressStates = new HashSet<>();

  @ManyToOne(optional = false)
  @JoinColumn(updatable = false)
  protected ShellCommand shellCommand;

  public ServiceStatus(
      Service service,
      ServiceState state,
      Set<BindAddressState> addresses,
      ShellCommand shellCommand) {
    super();

    this.service = service;
    this.state = state;
    this.shellCommand = shellCommand;

    if (addresses != null && !addresses.isEmpty()) {
      for (BindAddressState bindAddressState : addresses) {
        bindAddressState.setServiceStatus(this);
      }
    }
  }

  public Service getService() {
    return service;
  }

  public void setService(Service service) {
    this.service = service;
  }

  public LocalDateTime getDateTime() {
    return dateTime;
  }

  public void setDateTime(LocalDateTime dateTime) {
    this.dateTime = dateTime;
  }

  public ServiceStatus() {
    super();
  }

  public ServiceState getState() {
    return state;
  }

  public void setState(ServiceState state) {
    this.state = state;
  }

  public Set<BindAddressState> getBindAddressStates() {
    return bindAddressStates;
  }

  public void setBindAddressStates(Set<BindAddressState> bindAddressStates) {
    this.bindAddressStates = bindAddressStates;
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
    ServiceStatus that = (ServiceStatus) o;
    return Objects.equals(service, that.service) && Objects.equals(dateTime, that.dateTime);
  }

  @Override
  public int hashCode() {

    return Objects.hash(service, dateTime);
  }
}
