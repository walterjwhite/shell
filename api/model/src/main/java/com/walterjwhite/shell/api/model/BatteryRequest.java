package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.BatteryRequestAction;
import javax.persistence.*;

@Entity
public class BatteryRequest extends AbstractEntity implements ShellCommandable {
  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected BatteryRequestAction action;

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  @ManyToOne
  @JoinColumn(insertable = false)
  protected BatteryStatus batteryStatus;

  @Column(nullable = false, updatable = false)
  protected int timeout;

  public BatteryRequestAction getAction() {
    return action;
  }

  public void setAction(BatteryRequestAction action) {
    this.action = action;
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

  public BatteryStatus getBatteryStatus() {
    return batteryStatus;
  }

  public void setBatteryStatus(BatteryStatus batteryStatus) {
    this.batteryStatus = batteryStatus;
  }
}
