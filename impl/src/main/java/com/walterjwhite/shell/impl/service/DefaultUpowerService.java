package com.walterjwhite.shell.impl.service;

import com.walterjwhite.google.guice.property.property.Property;
import com.walterjwhite.shell.api.enumeration.BatteryState;
import com.walterjwhite.shell.api.model.BatteryRequest;
import com.walterjwhite.shell.api.model.BatteryStatus;
import com.walterjwhite.shell.api.model.Node;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.api.service.UpowerService;
import com.walterjwhite.shell.impl.property.UpowerTimeout;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DefaultUpowerService extends AbstractSingleShellCommandService<BatteryRequest>
    implements UpowerService {
  private static final Logger LOGGER = LoggerFactory.getLogger(DefaultUpowerService.class);

  protected final Node node;

  @Inject
  public DefaultUpowerService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      Node node,
      @Property(UpowerTimeout.class) int timeout) {
    super(shellCommandBuilder, shellExecutionService, timeout);
    this.node = node;
  }

  protected String getCommandLine() {
    return "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
  }

  public void doAfter(BatteryRequest batteryRequest) {
    final Pattern statePattern = Pattern.compile(".*(fully-charged|charging|discharging).*");
    final Pattern percentagePattern = Pattern.compile(".*percentage:[\\W]{1,}([\\d]{1,3})%.*");

    String state = null;
    int percentage = -1;
    for (String line :
        batteryRequest.getShellCommand().getOutputs().get(0).getOutput().split("\n")) {
      if (state != null && percentage > 0) {
        break;
      }

      final Matcher stateMatcher = statePattern.matcher(line);

      if (stateMatcher.matches()) {
        LOGGER.debug("state matches:" + stateMatcher.matches());
        // LOGGER.debug("state matches:" + stateMatcher.group(0));
        LOGGER.debug("state matches:" + stateMatcher.group(1));

        state = stateMatcher.group(1);
        // LOGGER.debug("state matches:" + stateMatcher.group(2));
        continue;
      }

      final Matcher percentageMatcher = percentagePattern.matcher(line);
      if (percentageMatcher.matches()) {
        LOGGER.debug("percentage matches:" + percentageMatcher.matches());
        LOGGER.debug("percentage matches:" + percentageMatcher.group(1));
        percentage = Integer.valueOf(percentageMatcher.group(1));
        continue;
      }
    }

    batteryRequest.setBatteryStatus(
        new BatteryStatus(
            node,
            BatteryState.getFromUpowerString(state),
            Integer.valueOf(percentage),
            batteryRequest.getShellCommand()));
  }
}
