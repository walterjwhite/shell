package com.walterjwhite.shell.api.model.ping;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.util.Objects;
import javax.persistence.*;

@Entity
public class PingResponse extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected PingRequest pingRequest;

  @Column(nullable = false, updatable = false)
  protected int index;

  @Column(updatable = false)
  protected int ttl;

  @Column(updatable = false)
  protected double time;

  public PingResponse(PingRequest pingRequest, int index, int ttl, double time) {
    super();
    this.pingRequest = pingRequest;
    this.index = index;
    this.ttl = ttl;
    this.time = time;
  }

  public PingResponse() {
    super();
  }

  public int getTtl() {
    return ttl;
  }

  public void setTtl(int ttl) {
    this.ttl = ttl;
  }

  public double getTime() {
    return time;
  }

  public void setTime(double time) {
    this.time = time;
  }

  public PingRequest getPingRequest() {
    return pingRequest;
  }

  public void setPingRequest(PingRequest pingRequest) {
    this.pingRequest = pingRequest;
  }

  public int getIndex() {
    return index;
  }

  public void setIndex(int index) {
    this.index = index;
  }

  @Override
  public String toString() {
    return "PingResponse{" + "ttl=" + ttl + ", time=" + time + '}';
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    PingResponse that = (PingResponse) o;
    return index == that.index && Objects.equals(pingRequest, that.pingRequest);
  }

  @Override
  public int hashCode() {

    return Objects.hash(pingRequest, index);
  }
}
