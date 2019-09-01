package com.walterjwhite.shell.impl.service;

import com.walterjwhite.datastore.api.repository.Repository;
import com.walterjwhite.property.impl.annotation.Property;
import com.walterjwhite.shell.api.enumeration.PingResponseType;
import com.walterjwhite.shell.api.model.CommandOutput;
import com.walterjwhite.shell.api.model.IPAddress;
import com.walterjwhite.shell.api.model.ShellCommand;
import com.walterjwhite.shell.api.model.ping.PingRequest;
import com.walterjwhite.shell.api.model.ping.PingResponse;
import com.walterjwhite.shell.api.service.PingService;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.impl.property.PingTimeout;
import com.walterjwhite.shell.impl.query.FindIPAddressByIPAddressQuery;
import java.util.ArrayList;
import java.util.List;
import javax.inject.Inject;
import javax.inject.Provider;

public class DefaultPingService extends AbstractSingleShellCommandService<PingRequest>
    implements PingService {
  protected final Provider<Repository> repositoryProvider;

  @Inject
  public DefaultPingService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      Provider<Repository> repositoryProvider,
      @Property(PingTimeout.class) int pingTimeout) {
    super(shellCommandBuilder, shellExecutionService, pingTimeout);
    this.repositoryProvider = repositoryProvider;
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
      handleOther(pingRequest);
      //      return ((PingRequest) repository.merge(pingRequest));
      // throw (new RuntimeException("Something bad happened."));
      // return(new PingResponse());

      return;
    }
  }

  protected void handleOther(PingRequest pingRequest) {
    pingRequest.setPingResponseType(PingResponseType.Other);
  }

  protected IPAddress getIPAddress(final ShellCommand shellCommand) {
    return (repositoryProvider
        .get()
        .query(new FindIPAddressByIPAddressQuery(getIPAddressFromPingOutput(shellCommand)) /*,
            PersistenceOption.Create*/));
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

      final String[] splitLine = shellCommand.getOutputs().get(i).getOutput().split(" ");
      final int ttl = Integer.valueOf(splitLine[6].replace("ttl=", ""));
      final double time = Double.valueOf(splitLine[7].replace("time=", ""));

      pingResponses.add(new PingResponse(pingRequest, i - 1, ttl, time));
    }

    return (pingResponses);
  }
}
