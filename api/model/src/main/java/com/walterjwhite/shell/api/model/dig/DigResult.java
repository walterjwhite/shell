// package com.walterjwhite.shell.api.model;
//
// import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
// import java.util.ArrayList;
// import java.util.List;
// import javax.persistence.*;
// import lombok.Data;
// import lombok.ToString;
//
// @Data
// @ToString(doNotUseGetters=true)
// @PersistenceCapable
// public class DigResult extends AbstractEntity<DigRequest> {
//  @Id
//  @OneToOne(mappedBy = "digResult", cascade = CascadeType.ALL)
//  protected DigRequest digRequest;
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
//  @Override
//  public DigRequest getId() {
//    return digRequest;
//  }
//
//  @Override
//  public void setId(DigRequest id) {
//    this.digRequest = id;
//  }
// }
