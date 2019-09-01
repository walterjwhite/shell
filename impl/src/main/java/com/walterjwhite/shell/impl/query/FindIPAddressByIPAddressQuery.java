package com.walterjwhite.shell.impl.query;

import com.walterjwhite.datastore.query.AbstractSingularQuery;
import com.walterjwhite.shell.api.model.IPAddress;
import lombok.Getter;

@Getter
public class FindIPAddressByIPAddressQuery extends AbstractSingularQuery<IPAddress> {
  protected final String address;

  public FindIPAddressByIPAddressQuery(String address) {
    super(IPAddress.class, false);
    this.address = address;
  }
}
