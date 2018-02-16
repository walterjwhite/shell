// package com.walterjwhite.shell.api.model;
//
// import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
// import java.util.ArrayList;
// import java.util.List;
// import javax.persistence.*;
//
// @Entity
// public class DigResult extends AbstractEntity<DigRequest> {
//  @Id
//  @OneToOne(mappedBy = "digResult", cascade = CascadeType.ALL)
//  protected DigRequest digRequest;
//
//
//
//  public DigResult(DigRequest digRequest, List<IPAddress> digRequestIPAddresses) {
//    this();
//
//    this.digRequest = digRequest;
//    if (digRequestIPAddresses != null && !digRequestIPAddresses.isEmpty())
// this.digRequestIPAddresses.addAll(digRequestIPAddresses);
//  }
//
//  public DigResult() {
//    super();
//
//    this.digRequestIPAddresses = new ArrayList<>();
//  }
//
//  public DigRequest getDigRequest() {
//    return digRequest;
//  }
//
//  public void setDigRequest(DigRequest digRequest) {
//    this.digRequest = digRequest;
//  }
//
//
//
//  @Override
//  public DigRequest getId() {
//    return digRequest;
//  }
//
//  @Override
//  public void setId(DigRequest id) {
//    this.digRequest = id;
//  }
//
//  @Override
//  public boolean equals(Object o) {
//    if (this == o) return true;
//    if (o == null || getClass() != o.getClass()) return false;
//
//    DigResult digResult = (DigResult) o;
//
//    return digRequest != null
//        ? digRequest.equals(digResult.digRequest)
//        : digResult.digRequest == null;
//  }
//
//  @Override
//  public int hashCode() {
//    return digRequest != null ? digRequest.hashCode() : 0;
//  }
// }
