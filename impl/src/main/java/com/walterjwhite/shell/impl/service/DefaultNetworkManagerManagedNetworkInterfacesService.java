package com.walterjwhite.shell.impl.service;

import com.google.common.eventbus.EventBus;
import com.walterjwhite.shell.api.model.*;
import com.walterjwhite.shell.api.repository.BindAddressRepository;
import com.walterjwhite.shell.api.repository.IPAddressRepository;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import javax.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public
class DefaultNetworkManagerManagedNetworkInterfacesService /*implements NetworkManagerManagedNetworkInterfacesService*/ {
  private static final Logger LOGGER =
      LoggerFactory.getLogger(DefaultNetworkManagerManagedNetworkInterfacesService.class);

  protected final EventBus eventBus;
  protected final ShellExecutionService shellExecutionService;
  protected final IPAddressRepository ipAddressRepository;
  protected final BindAddressRepository bindAddressRepository;

  @Inject
  public DefaultNetworkManagerManagedNetworkInterfacesService(
      EventBus eventBus,
      ShellExecutionService shellExecutionService,
      IPAddressRepository ipAddressRepository,
      BindAddressRepository bindAddressRepository) {
    super();
    this.eventBus = eventBus;
    this.shellExecutionService = shellExecutionService;
    this.ipAddressRepository = ipAddressRepository;
    this.bindAddressRepository = bindAddressRepository;
  }

  //  @Override
  //  public Set<String> getManagedInterfaces() throws Exception {
  //    final Set<String> interfaces = new HashSet<>();
  //
  //    ShellCommand shellCommand = new ShellCommand("nmcli d", 10);
  //    shellExecutionService.run(shellCommand);
  //
  //    final String pattern =
  //
  // "^([\\w]{1,})[\\W]{1,}(ethernet|wifi)[\\W]{1,}(connected|unavailable|disconnected)[\\W]{1,}(.*)$";
  //    LOGGER.debug("pattern:" + pattern);
  //
  //    final Pattern nmcliPattern = Pattern.compile(pattern);
  //    for (final CommandOutput commandOutput : shellCommand.getOutputs()) {
  //      final Matcher nmcliMatcher = nmcliPattern.matcher(commandOutput.getOutput());
  //
  //      if (nmcliMatcher.matches()) {
  //        LOGGER.debug("matches");
  //
  //        interfaces.add(nmcliMatcher.group(1));
  //
  //        LOGGER.debug(nmcliMatcher.group(1));
  //        LOGGER.debug(nmcliMatcher.group(2));
  //        LOGGER.debug(nmcliMatcher.group(3));
  //      } else {
  //        LOGGER.debug("does NOT match:" + commandOutput.getOutput());
  //      }
  //    }
  //
  //    return (interfaces);
  //  }
}
