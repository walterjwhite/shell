package com.walterjwhite.shell.api.model.traceroute;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import lombok.*;

@Data
@ToString(doNotUseGetters = true)
@NoArgsConstructor
@AllArgsConstructor
// @PersistenceCapable
@Entity
public class TracrouteHopResponse extends AbstractEntity {
  @Column(nullable = false, updatable = false)
  protected int index;

  @EqualsAndHashCode.Exclude
  @Column(nullable = false, updatable = false)
  protected double responseTime; // in ms

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected TracerouteHop tracerouteHop;
}
