package com.walterjwhite.shell.api.model.ping;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.*;
import lombok.*;

@Data
@ToString(doNotUseGetters = true)
@NoArgsConstructor
@AllArgsConstructor
// @PersistenceCapable
@Entity
public class PingResponse extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected PingRequest pingRequest;

  @Column(nullable = false, updatable = false)
  protected int index;

  @EqualsAndHashCode.Exclude
  @Column(updatable = false)
  protected int ttl;

  @EqualsAndHashCode.Exclude
  @Column(updatable = false)
  protected double time;
}
