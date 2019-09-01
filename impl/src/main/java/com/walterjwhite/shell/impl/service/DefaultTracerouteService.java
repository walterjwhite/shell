package com.walterjwhite.shell.impl.service;

import com.walterjwhite.datastore.api.repository.Repository;
import com.walterjwhite.property.impl.annotation.Property;
import com.walterjwhite.shell.api.model.CommandOutput;
import com.walterjwhite.shell.api.model.traceroute.TracerouteHop;
import com.walterjwhite.shell.api.model.traceroute.TracerouteRequest;
import com.walterjwhite.shell.api.model.traceroute.TracrouteHopResponse;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.api.service.TracerouteService;
import com.walterjwhite.shell.impl.property.TracerouteTimeout;
import com.walterjwhite.shell.impl.query.FindIPAddressByIPAddressQuery;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.inject.Inject;
import javax.inject.Provider;

public class DefaultTracerouteService extends AbstractSingleShellCommandService<TracerouteRequest>
    implements TracerouteService {
  private static final Pattern TRACEROUTE_OUTPUT_PATTERN =
      Pattern.compile("^([\\d]{1,})  ([\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3})  (.*)$");

  protected final Provider<Repository> repositoryProvider;

  @Inject
  public DefaultTracerouteService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      @Property(TracerouteTimeout.class) int timeout,
      Provider<Repository> repositoryProvider) {
    super(shellCommandBuilder, shellExecutionService, timeout);
    this.repositoryProvider = repositoryProvider;
  }

  protected String getCommandLine(TracerouteRequest tracerouteRequest) {
    final List<String> arguments = new ArrayList<>();
    arguments.add("sudo");
    arguments.add("traceroute");
    arguments.add("-I");

    if (tracerouteRequest.isIpv4()) arguments.add("-4");
    else arguments.add("-6");

    if (tracerouteRequest.getMaxHops() > 0) {
      arguments.add("-m");
      arguments.add(Integer.toString(tracerouteRequest.getMaxHops()));
    }

    if (tracerouteRequest.isNoFragment()) arguments.add("-F");

    if (tracerouteRequest.getQueriesPerHop() > 0) {
      arguments.add("-q");
      arguments.add(Integer.toString(tracerouteRequest.getQueriesPerHop()));
    }

    // do NOT resolve hostnames, adds time to request
    arguments.add("-n");

    arguments.add(tracerouteRequest.getNetworkDiagnosticTest().getFqdn());

    return String.join(" ", arguments.toArray(new String[arguments.size()]));
  }

  protected void doAfter(TracerouteRequest tracerouteRequest) {

    int index = 0;
    for (final CommandOutput commandOutput : tracerouteRequest.getShellCommand().getOutputs()) {
      if (index > 0) {
        final String line = commandOutput.getOutput().trim().replace("ms", "");

        final Matcher matcher = TRACEROUTE_OUTPUT_PATTERN.matcher(line);
        if (matcher.matches()) {
          final TracerouteHop tracerouteHop =
              new TracerouteHop(
                  tracerouteRequest,
                  index,
                  null,
                  repositoryProvider
                      .get()
                      .query(new FindIPAddressByIPAddressQuery(matcher.group(2)) /*,
                          PersistenceOption.Create*/));
          tracerouteRequest.getTracerouteHops().add(tracerouteHop);

          int j = 0;
          for (final String hopTime : matcher.group(3).split("  ")) {
            try {
              tracerouteHop
                  .getTracrouteHopResponses()
                  .add(new TracrouteHopResponse(j, Double.valueOf(hopTime), tracerouteHop));
            } catch (NumberFormatException e) {
              tracerouteHop
                  .getTracrouteHopResponses()
                  .add(new TracrouteHopResponse(j, -1, tracerouteHop));
            }
            j++;
          }
        }

        index++;
      }
    }
  }
}
