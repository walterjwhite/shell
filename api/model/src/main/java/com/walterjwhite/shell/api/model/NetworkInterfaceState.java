package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
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
public class NetworkInterfaceState extends AbstractEntity {
  @ManyToOne(cascade = CascadeType.ALL, optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected NetworkInterface networkInterface;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  @EqualsAndHashCode.Exclude
  @OneToMany(cascade = CascadeType.ALL, mappedBy = "networkInterfaceState")
  protected Set<IPAddressState> ipAddressStates = new HashSet<>();
}
