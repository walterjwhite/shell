// package com.walterjwhite.shell.impl.service;
//
// import com.google.common.eventbus.EventBus;
// import com.walterjwhite.shell.api.enumeration.Protocol;
// import com.walterjwhite.shell.api.model.*;
// import com.walterjwhite.shell.api.repository.BindAddressRepository;
// import com.walterjwhite.shell.api.repository.IPAddressRepository;
// import com.walterjwhite.shell.api.service.ShellExecutionService;
// import java.util.HashSet;
// import java.util.Set;
// import java.util.regex.Matcher;
// import java.util.regex.Pattern;
// import javax.inject.Inject;
// import org.slf4j.Logger;
// import org.slf4j.LoggerFactory;
//
// public class DefaultNetworkService implements NetworkService {
//  private static final Logger LOGGER = LoggerFactory.getLogger(DefaultNetworkService.class);
//
//  protected final EventBus eventBus;
//  protected final ShellExecutionService shellExecutionService;
//  protected final IPAddressRepository ipAddressRepository;
//  protected final BindAddressRepository bindAddressRepository;
//
//  @Inject
//  public DefaultNetworkService(
//      EventBus eventBus,
//      ShellExecutionService shellExecutionService,
//      IPAddressRepository ipAddressRepository,
//      BindAddressRepository bindAddressRepository) {
//    super();
//    this.eventBus = eventBus;
//    this.shellExecutionService = shellExecutionService;
//    this.ipAddressRepository = ipAddressRepository;
//    this.bindAddressRepository = bindAddressRepository;
//  }
//
//  @Override
//  public Set<BindAddress> getBindAddressesForService(Service service) throws Exception {
//    final Set<BindAddress> bindAddresses = new HashSet<>();
//
//    ShellCommand shellCommand =
//        new ShellCommand().withCommandLine("sudo netstat -lapn").withTimeout(5);
//    // TODO: make this a service
//    //final CommandExecutionResult shellCommand = null;
//    shellExecutionService.run(shellCommand);
//    //        CommandExecutionUtil.run(applicationEventPublisher, shellCommand);
//
//    final String pattern =
//
// "^(tcp|tcp6|udp|udp6).*[\\W]{1,}([\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3})[:]{1,3}([\\d]{1,5}|\\*)[\\W]{1,}([\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3})[:]{1,3}([\\d]{1,5}|\\*).*[\\W]{1,}([\\d]{1,})/("
//            + service.getName()
//            + ").*";
//
//    LOGGER.debug("pattern:" + pattern);
//
//    final Pattern processBindAddressPattern = Pattern.compile(pattern);
//    for (final CommandOutput commandOutput : shellCommand.getOutputs()) {
//      final Matcher processBindAddressMatcher =
//          processBindAddressPattern.matcher(commandOutput.getOutput());
//
//      if (processBindAddressMatcher.matches()) {
//        LOGGER.debug("matcher(1):" + processBindAddressMatcher.group(1)); //protocol
//        LOGGER.debug("matcher(2):" + processBindAddressMatcher.group(2)); //local IPv4 ipAddress
//
//        LOGGER.debug("matcher(3):" + processBindAddressMatcher.group(3)); //local port
//        LOGGER.debug("matcher(4):" + processBindAddressMatcher.group(4)); //remote IPv4 ipAddress
//        LOGGER.debug("matcher(5):" + processBindAddressMatcher.group(5)); //remote port
//
//        LOGGER.debug("matcher(6):" + processBindAddressMatcher.group(6)); //process id (pid)
//        LOGGER.debug("matcher(6):" + processBindAddressMatcher.group(7)); //process name
//
//        bindAddresses.add(
//            bindAddressRepository.findByIPAddressPortAndProtocolOrCreate(
//                ipAddressRepository.findByAddressOrCreate(processBindAddressMatcher.group(2)),
//                Integer.valueOf(processBindAddressMatcher.group(3)),
//                Protocol.getFromNetstatProtocol(processBindAddressMatcher.group(1))));
//      } else {
//        //LOGGER.debug("line:" + line);
//      }
//    }
//
//    return (bindAddresses);
//  }
//
//  @Override
//  public Set<String> getManagedInterfaces() throws Exception {
//    final Set<String> interfaces = new HashSet<>();
//
//    ShellCommand shellCommand = new ShellCommand().withCommandLine("nmcli d").withTimeout(10);
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
// }
