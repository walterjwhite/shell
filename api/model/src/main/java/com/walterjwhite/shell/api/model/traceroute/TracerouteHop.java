package com.walterjwhite.shell.api.model.traceroute;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.model.IPAddress;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@ToString(doNotUseGetters = true)
@NoArgsConstructor
// @PersistenceCapable
@Entity
public class TracerouteHop extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected TracerouteRequest tracerouteRequest;

  @Column(nullable = false, updatable = false)
  protected int index;

  @EqualsAndHashCode.Exclude
  @Column(updatable = false)
  protected String fqdn;

  @EqualsAndHashCode.Exclude
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected IPAddress ipAddress;

  @OneToMany(mappedBy = "tracerouteHop", cascade = CascadeType.ALL)
  protected List<TracrouteHopResponse> tracrouteHopResponses = new ArrayList<>();

  public TracerouteHop(
      TracerouteRequest tracerouteRequest, int index, String fqdn, IPAddress ipAddress) {
    super();
    this.tracerouteRequest = tracerouteRequest;
    this.index = index;
    this.fqdn = fqdn;
    this.ipAddress = ipAddress;
  }
}
