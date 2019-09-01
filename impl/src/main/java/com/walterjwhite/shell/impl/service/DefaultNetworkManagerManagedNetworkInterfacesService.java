package com.walterjwhite.shell.impl.service;

import com.google.common.eventbus.EventBus;
import com.walterjwhite.datastore.api.repository.Repository;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import javax.inject.Inject;
import javax.inject.Provider;

public
class DefaultNetworkManagerManagedNetworkInterfacesService /*implements NetworkManagerManagedNetworkInterfacesService*/ {

  protected final EventBus eventBus;
  protected final ShellExecutionService shellExecutionService;
  protected final Provider<Repository> repositoryProvider;

  @Inject
  public DefaultNetworkManagerManagedNetworkInterfacesService(
      EventBus eventBus,
      ShellExecutionService shellExecutionService,
      Provider<Repository> repositoryProvider) {
    super();
    this.eventBus = eventBus;
    this.shellExecutionService = shellExecutionService;
    this.repositoryProvider = repositoryProvider;
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
  //
  //    final Pattern nmcliPattern = Pattern.compile(pattern);
  //    for (final CommandOutput commandOutput : shellCommand.getOutputs()) {
  //      final Matcher nmcliMatcher = nmcliPattern.matcher(commandOutput.getOutput());
  //
  //      if (nmcliMatcher.matches()) {
  //
  //        interfaces.add(nmcliMatcher.group(1));
  //
  //      } else {
  //      }
  //    }
  //
  //    return (interfaces);
  //  }
}
