package com.walterjwhite.shell.impl.service;

import com.walterjwhite.datastore.api.repository.Repository;
import com.walterjwhite.property.impl.annotation.Property;
import com.walterjwhite.shell.api.model.*;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.api.service.SystemServiceService;
import com.walterjwhite.shell.impl.property.ServiceTimeout;
import javax.inject.Inject;
import javax.inject.Provider;

public class UnixSystemServiceService extends AbstractSingleShellCommandService<ServiceCommand>
    implements SystemServiceService {

  //  protected final Repository Repository;
  protected final Provider<Repository> repositoryProvider;

  @Inject
  public UnixSystemServiceService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      @Property(ServiceTimeout.class) int timeout,
      Provider<Repository> repositoryProvider) {
    super(shellCommandBuilder, shellExecutionService, timeout);
    this.repositoryProvider = repositoryProvider;
  }

  protected String getCommandLine(ServiceCommand serviceCommand) {
    return "sudo service "
        + serviceCommand.getService().getName()
        + " "
        + serviceCommand.getServiceAction().getCommand();
  }

  protected void doAfter(ServiceCommand serviceCommand) {
    //    serviceCommand.setServiceStatus(new ServiceStatus(
    //            service,
    //            ServiceState.getFromReturnValue(shellCommand.getReturnCode()),
    //            getBindAddresses(service),
    //            shellCommand)));
  }

  //  // TODO: get the bind digRequestIPAddresses
  //  // ss -nlp4 | grep unbound | awk {'print$5'}
  //  protected Set<BindAddressState> getBindAddresses(Service service) throws Exception {
  //    ShellCommand shellCommand =
  //        new ShellCommand("sudo ss -nlp4 | grep " + service.getName() + " | awk {'print$5'} ",
  // 10);
  //    shellExecutionService.run(shellCommand);
  //
  //    final Set<BindAddressState> bindAddresses = new HashSet<>();
  //    for (CommandOutput commandOutput : shellCommand.getOutputs()) {
  //      final String ip = commandOutput.getOutput().split(":")[0];
  //      final String port = commandOutput.getOutput().split(":")[1];
  //
  //      bindAddresses.add(
  //          new BindAddressState(
  //              bindAddressRepository.findByIPAddressPortAndProtocolOrCreate(
  //                  ipAddressRepository.findByAddressOrCreate(ip),
  //                  Integer.valueOf(port),
  //                  Protocol.TCP4),
  //              null,
  //              shellCommand));
  //    }
  //
  //    return (bindAddresses);
  //  }
  //
  //  @Override
  //  public Set<BindAddress> getBindAddressesForService(Service service) throws Exception {
  //    final Set<BindAddress> bindAddresses = new HashSet<>();
  //
  //    ShellCommand shellCommand = new ShellCommand("sudo netstat -lapn", 5);
  //    // TODO: make this a service
  //    //final CommandExecutionResult shellCommand = null;
  //    shellExecutionService.run(shellCommand);
  //    //        CommandExecutionUtil.run(applicationEventPublisher, shellCommand);
  //
  //    final String pattern =
  //
  // "^(tcp|tcp6|udp|udp6).*[\\W]{1,}([\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3})[:]{1,3}([\\d]{1,5}|\\*)[\\W]{1,}([\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3})[:]{1,3}([\\d]{1,5}|\\*).*[\\W]{1,}([\\d]{1,})/("
  //                    + service.getName()
  //                    + ").*";
  //
  //    LOGGER.debug("pattern:" + pattern);
  //
  //    final Pattern processBindAddressPattern = Pattern.compile(pattern);
  //    for (final CommandOutput commandOutput : shellCommand.getOutputs()) {
  //      final Matcher processBindAddressMatcher =
  //              processBindAddressPattern.matcher(commandOutput.getOutput());
  //
  //      if (processBindAddressMatcher.matches()) {
  //        LOGGER.debug("matcher(1):" + processBindAddressMatcher.group(1)); //protocol
  //        LOGGER.debug("matcher(2):" + processBindAddressMatcher.group(2)); //local IPv4 ipAddress
  //
  //        LOGGER.debug("matcher(3):" + processBindAddressMatcher.group(3)); //local port
  //        LOGGER.debug("matcher(4):" + processBindAddressMatcher.group(4)); //remote IPv4
  // ipAddress
  //        LOGGER.debug("matcher(5):" + processBindAddressMatcher.group(5)); //remote port
  //
  //        LOGGER.debug("matcher(6):" + processBindAddressMatcher.group(6)); //process id (pid)
  //        LOGGER.debug("matcher(6):" + processBindAddressMatcher.group(7)); //process name
  //
  //        bindAddresses.add(
  //                bindAddressRepository.findByIPAddressPortAndProtocolOrCreate(
  //
  // ipAddressRepository.findByAddressOrCreate(processBindAddressMatcher.group(2)),
  //                        Integer.valueOf(processBindAddressMatcher.group(3)),
  //                        Protocol.getFromNetstatProtocol(processBindAddressMatcher.group(1))));
  //      } else {
  //        //LOGGER.debug("line:" + line);
  //      }
  //    }
  //
  //    return (bindAddresses);
  //  }
}
