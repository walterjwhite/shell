package com.walterjwhite.shell.api.model.traceroute;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.model.IPAddress;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import javax.persistence.*;

@Entity
public class TracerouteHop extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected TracerouteRequest tracerouteRequest;

  @Column(nullable = false, updatable = false)
  protected int index;

  @Column(updatable = false)
  protected String fqdn;

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

  public TracerouteHop() {
    super();
  }

  public int getIndex() {
    return index;
  }

  public void setIndex(int index) {
    this.index = index;
  }

  public String getFqdn() {
    return fqdn;
  }

  public void setFqdn(String fqdn) {
    this.fqdn = fqdn;
  }

  public IPAddress getIpAddress() {
    return ipAddress;
  }

  public void setIpAddress(IPAddress ipAddress) {
    this.ipAddress = ipAddress;
  }

  public List<TracrouteHopResponse> getTracrouteHopResponses() {
    return tracrouteHopResponses;
  }

  public void setTracrouteHopResponses(List<TracrouteHopResponse> tracrouteHopResponses) {
    this.tracrouteHopResponses = tracrouteHopResponses;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    TracerouteHop that = (TracerouteHop) o;
    return index == that.index && Objects.equals(tracerouteRequest, that.tracerouteRequest);
  }

  @Override
  public int hashCode() {

    return Objects.hash(tracerouteRequest, index);
  }
}
