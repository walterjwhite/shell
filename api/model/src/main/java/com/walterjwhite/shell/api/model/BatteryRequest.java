package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.BatteryRequestAction;
import javax.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Data
@ToString(doNotUseGetters = true)
// @PersistenceCapable
@Entity
public class BatteryRequest extends AbstractEntity implements ShellCommandable {
  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected BatteryRequestAction action;

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  @EqualsAndHashCode.Exclude
  @ManyToOne
  @JoinColumn(insertable = false)
  protected BatteryStatus batteryStatus;

  @EqualsAndHashCode.Exclude
  @Column(nullable = false, updatable = false)
  protected int timeout;
}
