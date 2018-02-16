package com.walterjwhite.shell.impl.service.unused;

import com.walterjwhite.shell.api.model.IPAddressState;
import com.walterjwhite.shell.api.model.NetworkInterfaceState;
import com.walterjwhite.shell.api.model.Node;
import com.walterjwhite.shell.api.repository.IPAddressRepository;
import com.walterjwhite.shell.api.repository.NetworkInterfaceRepository;
import com.walterjwhite.shell.api.service.unused.NetworkInterfaceService;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Set;
import javax.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DefaultNetworkInterfaceService implements NetworkInterfaceService {
  private static final Logger LOGGER =
      LoggerFactory.getLogger(DefaultNetworkInterfaceService.class);

  protected final NetworkInterfaceRepository networkInterfaceRepository;
  protected final IPAddressRepository ipAddressRepository;
  protected final Node node;

  @Inject
  public DefaultNetworkInterfaceService(
      NetworkInterfaceRepository networkInterfaceRepository,
      IPAddressRepository ipAddressRepository,
      Node node) {
    super();
    this.networkInterfaceRepository = networkInterfaceRepository;
    this.ipAddressRepository = ipAddressRepository;
    this.node = node;
  }

  @Override
  public Set<NetworkInterfaceState> getNetworkInterfaceStatesForNode() throws SocketException {
    final Set<NetworkInterfaceState> networkInterfaceStateSet = new HashSet<>();

    final Enumeration<NetworkInterface> networkInterfaceEnumeration =
        NetworkInterface.getNetworkInterfaces();

    while (networkInterfaceEnumeration.hasMoreElements()) {
      final NetworkInterface networkInterface = networkInterfaceEnumeration.nextElement();

      if (!networkInterface.isLoopback()) {
        final Enumeration<InetAddress> inetAddressEnumeration = networkInterface.getInetAddresses();

        com.walterjwhite.shell.api.model.NetworkInterface networkInterfaceRef =
            networkInterfaceRepository.findByNameAndNodeOrCreate(
                networkInterface.getDisplayName(), node);
        final NetworkInterfaceState networkInterfaceState =
            new NetworkInterfaceState(networkInterfaceRef);
        while (inetAddressEnumeration.hasMoreElements()) {
          final InetAddress inetAddress = inetAddressEnumeration.nextElement();

          if (!inetAddress.isLinkLocalAddress()) {
            LOGGER.debug(
                "inetAddress:("
                    + networkInterface.getDisplayName()
                    + "):"
                    + inetAddress.getHostAddress());

            networkInterfaceState
                .getIpAddressStates()
                .add(
                    new IPAddressState(
                        ipAddressRepository.findByAddressOrCreate(inetAddress.getHostAddress()),
                        networkInterfaceState));
          }
        }

        networkInterfaceStateSet.add(networkInterfaceState);
      }
    }

    return (networkInterfaceStateSet);
  }
}
