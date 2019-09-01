package com.walterjwhite.shell.impl.query;

import com.walterjwhite.datastore.query.AbstractSingularQuery;
import com.walterjwhite.shell.api.enumeration.Protocol;
import com.walterjwhite.shell.api.model.BindAddress;
import com.walterjwhite.shell.api.model.IPAddress;
import lombok.Getter;

@Getter
public class FindBindAddressByIPAddressPortAndProtocolQuery
    extends AbstractSingularQuery<BindAddress> {
  protected final IPAddress ipAddress;
  protected final int port;
  protected final Protocol protocol;

  public FindBindAddressByIPAddressPortAndProtocolQuery(
      IPAddress ipAddress, int port, Protocol protocol) {
    super(BindAddress.class, false);
    this.ipAddress = ipAddress;
    this.port = port;
    this.protocol = protocol;
  }
}
