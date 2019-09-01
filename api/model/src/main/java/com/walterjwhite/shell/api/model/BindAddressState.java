package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.time.LocalDateTime;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@ToString(doNotUseGetters = true)
@NoArgsConstructor
// @PersistenceCapable
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

  @EqualsAndHashCode.Exclude
  @ManyToOne
  @JoinColumn(updatable = false)
  protected ShellCommand shellCommand;

  //
  //  public BindAddressState(
  //      BindAddress bindAddress, ServiceStatus serviceStatus, ShellCommand shellCommand) {
  //    super();
  //    this.bindAddress = bindAddress;
  //    this.serviceStatus = serviceStatus;
  //    this.shellCommand = shellCommand;
  //  }
}
