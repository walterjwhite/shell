package com.walterjwhite.shell.api.model.traceroute;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.util.Objects;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;

@Entity
public class TracrouteHopResponse extends AbstractEntity {
  @Column(nullable = false, updatable = false)
  protected int index;

  @Column(nullable = false, updatable = false)
  protected double responseTime; // in ms

  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected TracerouteHop tracerouteHop;

  public TracrouteHopResponse(int index, double responseTime, TracerouteHop tracerouteHop) {
    super();
    this.index = index;
    this.responseTime = responseTime;
    this.tracerouteHop = tracerouteHop;
  }

  public TracrouteHopResponse() {
    super();
  }

  public int getIndex() {
    return index;
  }

  public void setIndex(int index) {
    this.index = index;
  }

  public double getResponseTime() {
    return responseTime;
  }

  public void setResponseTime(double responseTime) {
    this.responseTime = responseTime;
  }

  public TracerouteHop getTracerouteHop() {
    return tracerouteHop;
  }

  public void setTracerouteHop(TracerouteHop tracerouteHop) {
    this.tracerouteHop = tracerouteHop;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    TracrouteHopResponse that = (TracrouteHopResponse) o;
    return index == that.index && Objects.equals(tracerouteHop, that.tracerouteHop);
  }

  @Override
  public int hashCode() {

    return Objects.hash(index, tracerouteHop);
  }
}
