package com.walterjwhite.shell.impl.query;

import com.walterjwhite.datastore.query.AbstractSingularQuery;
import com.walterjwhite.shell.api.model.NetworkInterface;
import com.walterjwhite.shell.api.model.Node;
import lombok.Getter;

@Getter
public class FindNetworkInterfaceByInterfaceNameAndNodeQuery
    extends AbstractSingularQuery<NetworkInterface> {
  protected final String interfaceName;
  protected final Node node;

  public FindNetworkInterfaceByInterfaceNameAndNodeQuery(String interfaceName, final Node node) {
    super(NetworkInterface.class, false);
    this.interfaceName = interfaceName;
    this.node = node;
  }
}
