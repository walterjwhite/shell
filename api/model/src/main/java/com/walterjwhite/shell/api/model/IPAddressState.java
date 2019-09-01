package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.time.LocalDateTime;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@ToString(doNotUseGetters = true)
@AllArgsConstructor
@NoArgsConstructor
// @PersistenceCapable
@Entity
public class IPAddressState extends AbstractEntity {
  @Column(nullable = false, updatable = false)
  protected LocalDateTime currentDateTime = LocalDateTime.now();

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected IPAddress ipAddress;

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected NetworkInterfaceState networkInterfaceState;
}
