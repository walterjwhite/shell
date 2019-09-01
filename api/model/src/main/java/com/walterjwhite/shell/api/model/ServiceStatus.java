package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.ServiceState;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import javax.persistence.*;
import lombok.*;

@Data
@ToString(doNotUseGetters = true)
@NoArgsConstructor
@AllArgsConstructor
// @PersistenceCapable
@Entity
public class ServiceStatus extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected Service service;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  @EqualsAndHashCode.Exclude
  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected ServiceState state;

  @EqualsAndHashCode.Exclude
  @OneToMany(cascade = CascadeType.ALL, mappedBy = "serviceStatus")
  protected Set<BindAddressState> bindAddressStates = new HashSet<>();

  @EqualsAndHashCode.Exclude
  @ManyToOne(optional = false)
  @JoinColumn(updatable = false)
  protected ShellCommand shellCommand;

  public ServiceStatus(
      Service service,
      ServiceState state,
      Set<BindAddressState> addresses,
      ShellCommand shellCommand) {
    super();
  }
}
