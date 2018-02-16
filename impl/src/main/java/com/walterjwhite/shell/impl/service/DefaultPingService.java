package com.walterjwhite.shell.impl.service;

import com.walterjwhite.google.guice.property.property.Property;
import com.walterjwhite.shell.api.enumeration.PingResponseType;
import com.walterjwhite.shell.api.model.*;
import com.walterjwhite.shell.api.model.ping.PingRequest;
import com.walterjwhite.shell.api.model.ping.PingResponse;
import com.walterjwhite.shell.api.repository.IPAddressRepository;
import com.walterjwhite.shell.api.service.PingService;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.impl.property.PingTimeout;
import java.util.ArrayList;
import java.util.List;
import javax.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DefaultPingService extends AbstractSingleShellCommandService<PingRequest>
    implements PingService {
  private static final Logger LOGGER = LoggerFactory.getLogger(DefaultPingService.class);

  protected final IPAddressRepository ipAddressRepository;

  @Inject
  public DefaultPingService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      IPAddressRepository ipAddressRepository,
      @Property(PingTimeout.class) int pingTimeout) {
    super(shellCommandBuilder, shellExecutionService, pingTimeout);
    this.ipAddressRepository = ipAddressRepository;
  }

  protected String getCommandLine(PingRequest pingRequest) {
    final List<String> arguments = new ArrayList<>();
    arguments.add("ping");
    if (pingRequest.getCount() > 0) {
      arguments.add("-c");
      arguments.add(Integer.toString(pingRequest.getCount())); // -C
    } else {
      arguments.add("-c");
      arguments.add("1"); // -C
    }

    if (pingRequest.getInterval() > 0) {
      arguments.add("-i");
      arguments.add(Integer.toString(pingRequest.getInterval())); // -C
    }

    if (pingRequest.getTimeout() > 0) {
      arguments.add("-W");
      arguments.add(Integer.toString(pingRequest.getTimeout())); // -W
    }

    arguments.add(pingRequest.getNetworkDiagnosticTest().getFqdn());

    return String.join(" ", arguments);
  }

  protected void doAfter(PingRequest pingRequest) {
    if (pingRequest.getShellCommand().getReturnCode() == 0) {
      for (CommandOutput commandOutput : pingRequest.getShellCommand().getOutputs()) {
        if (commandOutput.getOutput().contains("ping statistics")) {
          final IPAddress ipAddress = getIPAddress(pingRequest.getShellCommand());
          pingRequest.setIpAddress(ipAddress);
          pingRequest.setPingResponseType(PingResponseType.Good);
          pingRequest
              .getPingResponses()
              .addAll(getPingStatistics(pingRequest, pingRequest.getShellCommand()));
          // return ((PingRequest) repository.merge(pingRequest));
          return;
        }
      }

      throw (new RuntimeException("Unexpected output, did NOT find ping statistics header"));
    } else if (pingRequest.getShellCommand().getReturnCode() == 2) {
      pingRequest.setPingResponseType(PingResponseType.UnknownHost);
      //      return ((PingRequest) repository.merge(pingRequest));
      return;
    } else if (pingRequest.getShellCommand().getReturnCode() == 1) {

      pingRequest.setPingResponseType(PingResponseType.NoResponse);
      //      return ((PingRequest) repository.merge(pingRequest));
      return;
    } else {
      LOGGER.warn("return code:" + pingRequest.getShellCommand().getReturnCode());

      pingRequest.setPingResponseType(PingResponseType.Other);
      //      return ((PingRequest) repository.merge(pingRequest));
      // throw (new RuntimeException("Something bad happened."));
      // return(new PingResponse());

      return;
    }
  }

  protected IPAddress getIPAddress(final ShellCommand shellCommand) {
    return (ipAddressRepository.findByAddressOrCreate(getIPAddressFromPingOutput(shellCommand)));
  }

  private static String getIPAddressFromPingOutput(ShellCommand shellCommand) {
    return shellCommand
        .getOutputs()
        .get(0)
        .getOutput()
        .split(" ")[2]
        .replace("(", "")
        .replace(")", "");
  }

  private static final List<PingResponse> getPingStatistics(
      final PingRequest pingRequest, final ShellCommand shellCommand) {
    final List<PingResponse> pingResponses = new ArrayList<>();

    for (int i = 1; i < shellCommand.getOutputs().size(); i++) {
      if (shellCommand.getOutputs().get(i).getOutput().contains("ping statistics")) {
        break;
      }
      if (shellCommand.getOutputs().get(i).getOutput() == null
          || shellCommand.getOutputs().get(i).getOutput().trim().isEmpty()) {
        break;
      }

      LOGGER.info("line:" + shellCommand.getOutputs().get(i).getOutput());
      final String[] splitLine = shellCommand.getOutputs().get(i).getOutput().split(" ");
      final int ttl = Integer.valueOf(splitLine[6].replace("ttl=", ""));
      final double time = Double.valueOf(splitLine[7].replace("time=", ""));

      pingResponses.add(new PingResponse(pingRequest, i - 1, ttl, time));
    }

    return (pingResponses);
  }
}
