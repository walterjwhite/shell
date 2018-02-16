package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.BatteryState;
import java.time.LocalDateTime;
import java.util.Objects;
import javax.persistence.*;

@Entity
public class BatteryStatus extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected Node node;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected BatteryState batteryState;

  @Column(nullable = false, updatable = false)
  protected int batteryChargePercentage;

  @ManyToOne
  @JoinColumn(updatable = false)
  protected ShellCommand shellCommand;

  public BatteryStatus(
      Node node,
      BatteryState batteryState,
      int batteryChargePercentage,
      ShellCommand shellCommand) {
    super();

    this.node = node;
    this.batteryState = batteryState;
    this.batteryChargePercentage = batteryChargePercentage;
    this.shellCommand = shellCommand;
  }

  public BatteryStatus() {
    super();
  }

  public Node getNode() {
    return node;
  }

  public void setNode(Node node) {
    this.node = node;
  }

  public LocalDateTime getDateTime() {
    return dateTime;
  }

  public void setDateTime(LocalDateTime dateTime) {
    this.dateTime = dateTime;
  }

  public BatteryState getBatteryState() {
    return batteryState;
  }

  public void setBatteryState(BatteryState batteryState) {
    this.batteryState = batteryState;
  }

  public int getBatteryChargePercentage() {
    return batteryChargePercentage;
  }

  public void setBatteryChargePercentage(int batteryChargePercentage) {
    this.batteryChargePercentage = batteryChargePercentage;
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
    BatteryStatus that = (BatteryStatus) o;
    return Objects.equals(node, that.node) && Objects.equals(dateTime, that.dateTime);
  }

  @Override
  public int hashCode() {

    return Objects.hash(node, dateTime);
  }

  @Override
  public String toString() {
    return "BatteryStatus{"
        + "node="
        + node
        + ", dateTime="
        + dateTime
        + ", batteryState="
        + batteryState
        + ", batteryChargePercentage="
        + batteryChargePercentage
        + '}';
  }
}
