package com.walterjwhite.shell.impl.query;

import com.walterjwhite.datastore.query.AbstractSingularQuery;
import com.walterjwhite.shell.api.model.Service;
import lombok.Getter;

@Getter
public class FindServiceByNameQuery extends AbstractSingularQuery<Service> {
  protected final String name;

  public FindServiceByNameQuery(String name) {
    super(Service.class, false);
    this.name = name;
  }
}
