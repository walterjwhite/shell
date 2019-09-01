package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.BatteryState;
import java.time.LocalDateTime;
import javax.persistence.*;
import lombok.*;

@Data
@ToString(doNotUseGetters = true)
@AllArgsConstructor
@NoArgsConstructor
// @PersistenceCapable
@Entity
public class BatteryStatus extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected Node node;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  @EqualsAndHashCode.Exclude
  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected BatteryState batteryState;

  @EqualsAndHashCode.Exclude
  @Column(nullable = false, updatable = false)
  protected int batteryChargePercentage;

  @EqualsAndHashCode.Exclude
  @ManyToOne
  @JoinColumn(updatable = false)
  protected ShellCommand shellCommand;

  //  public BatteryStatus(
  //      Node node,
  //      BatteryState batteryState,
  //      int batteryChargePercentage,
  //      ShellCommand shellCommand) {
  //    super();
  //
  //    this.node = node;
  //    this.batteryState = batteryState;
  //    this.batteryChargePercentage = batteryChargePercentage;
  //    this.shellCommand = shellCommand;
  //  }
}
