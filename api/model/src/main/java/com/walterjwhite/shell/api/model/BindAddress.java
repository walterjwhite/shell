package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.Protocol;
import javax.persistence.*;
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
public class BindAddress extends AbstractEntity {
  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected Protocol protocol;

  @Column(nullable = false, updatable = false)
  protected int port;

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected IPAddress ipAddress;
}
