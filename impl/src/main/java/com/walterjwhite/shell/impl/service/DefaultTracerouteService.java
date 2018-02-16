package com.walterjwhite.shell.impl.service;

import com.walterjwhite.google.guice.property.property.Property;
import com.walterjwhite.shell.api.model.*;
import com.walterjwhite.shell.api.model.traceroute.TracerouteHop;
import com.walterjwhite.shell.api.model.traceroute.TracerouteRequest;
import com.walterjwhite.shell.api.model.traceroute.TracrouteHopResponse;
import com.walterjwhite.shell.api.repository.IPAddressRepository;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.api.service.TracerouteService;
import com.walterjwhite.shell.impl.property.TracerouteTimeout;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DefaultTracerouteService extends AbstractSingleShellCommandService<TracerouteRequest>
    implements TracerouteService {
  private static final Pattern TRACEROUTE_OUTPUT_PATTERN =
      Pattern.compile("^([\\d]{1,})  ([\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3})  (.*)$");
  private static final Logger LOGGER = LoggerFactory.getLogger(DefaultTracerouteService.class);

  protected final IPAddressRepository ipAddressRepository;

  @Inject
  public DefaultTracerouteService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      IPAddressRepository ipAddressRepository,
      @Property(TracerouteTimeout.class) int timeout) {
    super(shellCommandBuilder, shellExecutionService, timeout);

    this.ipAddressRepository = ipAddressRepository;
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
      LOGGER.info("LINE:" + commandOutput.getOutput());
      if (index > 0) {
        LOGGER.info("hop:" + commandOutput.getOutput());

        final String line = commandOutput.getOutput().trim().replace("ms", "");

        final Matcher matcher = TRACEROUTE_OUTPUT_PATTERN.matcher(line);
        if (matcher.matches()) {
          LOGGER.info("matches:" + line);
          LOGGER.info("hop:" + matcher.group(1));
          LOGGER.info("IP:" + matcher.group(2));

          final TracerouteHop tracerouteHop =
              new TracerouteHop(
                  tracerouteRequest,
                  index,
                  null,
                  ipAddressRepository.findByAddressOrCreate(matcher.group(2)));
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
        } else {
          LOGGER.info("!matched:" + commandOutput.getOutput());
        }
      }

      index++;
    }
  }
}
