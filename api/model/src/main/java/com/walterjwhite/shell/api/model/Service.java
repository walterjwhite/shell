package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractNamedEntity;
import javax.persistence.Entity;

@Entity
public class Service extends AbstractNamedEntity {
  public Service(String name) {
    super(name);
  }

  public Service() {
    super();
  }

  @Override
  public String toString() {
    return "Service{" + "name='" + name + '\'' + '}';
  }
}
