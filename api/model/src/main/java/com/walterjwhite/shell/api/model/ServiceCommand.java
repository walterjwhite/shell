package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.ServiceAction;
import javax.persistence.*;

@Entity
public class ServiceCommand extends AbstractEntity implements ShellCommandable {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected Service service;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected ServiceAction serviceAction;

  @Column(nullable = false, updatable = false)
  protected int timeout;

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  protected ServiceStatus serviceStatus;

  public Service getService() {
    return service;
  }

  public void setService(Service service) {
    this.service = service;
  }

  public ServiceAction getServiceAction() {
    return serviceAction;
  }

  public void setServiceAction(ServiceAction serviceAction) {
    this.serviceAction = serviceAction;
  }

  @Override
  public ShellCommand getShellCommand() {
    return shellCommand;
  }

  @Override
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

  public ServiceStatus getServiceStatus() {
    return serviceStatus;
  }

  public void setServiceStatus(ServiceStatus serviceStatus) {
    this.serviceStatus = serviceStatus;
  }

  public ServiceCommand withService(Service service) {
    this.service = service;
    return this;
  }

  public ServiceCommand withServiceAction(ServiceAction serviceAction) {
    this.serviceAction = serviceAction;
    return this;
  }
}
