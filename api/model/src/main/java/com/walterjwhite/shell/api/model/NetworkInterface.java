package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/** temporary class until the system configuration classes are moved in. */
@AllArgsConstructor
@NoArgsConstructor
@Data
@ToString(doNotUseGetters = true)
// @PersistenceCapable
@Entity
public class NetworkInterface extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected Node node;

  @Column(nullable = false, updatable = false)
  protected String interfaceName;

  /** All of the digRequestIPAddresses assigned to this interface */
  //
  //  @JoinTable
  //  protected Set<IPAddress> digRequestIPAddresses = new HashSet<>();
}
