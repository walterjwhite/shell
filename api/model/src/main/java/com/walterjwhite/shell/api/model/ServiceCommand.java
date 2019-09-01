package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.ServiceAction;
import javax.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Data
@ToString(doNotUseGetters = true)
// @PersistenceCapable
@Entity
public class ServiceCommand extends AbstractEntity implements ShellCommandable {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected Service service;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected ServiceAction serviceAction;

  @EqualsAndHashCode.Exclude
  @Column(nullable = false, updatable = false)
  protected int timeout;

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  // TODO: what is the intent here?
  @ManyToOne @JoinColumn @EqualsAndHashCode.Exclude protected ServiceStatus serviceStatus;

  public ServiceCommand withService(Service service) {
    this.service = service;
    return this;
  }

  public ServiceCommand withServiceAction(ServiceAction serviceAction) {
    this.serviceAction = serviceAction;
    return this;
  }
}
