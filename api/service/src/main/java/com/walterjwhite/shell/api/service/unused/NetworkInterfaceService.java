package com.walterjwhite.shell.api.service.unused;

import com.walterjwhite.shell.api.model.NetworkInterfaceState;
import java.net.SocketException;
import java.util.Set;

public interface NetworkInterfaceService {
  Set<NetworkInterfaceState> getNetworkInterfaceStatesForNode() throws SocketException;
}
