package com.walterjwhite.shell.impl.service;

import com.walterjwhite.property.impl.annotation.Property;
import com.walterjwhite.shell.api.enumeration.BatteryState;
import com.walterjwhite.shell.api.model.BatteryRequest;
import com.walterjwhite.shell.api.model.BatteryStatus;
import com.walterjwhite.shell.api.model.Node;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.api.service.UpowerService;
import com.walterjwhite.shell.impl.property.UpowerTimeout;
import java.time.LocalDateTime;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.inject.Inject;

public class DefaultUpowerService extends AbstractSingleShellCommandService<BatteryRequest>
    implements UpowerService {
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
        state = stateMatcher.group(1);
        continue;
      }

      final Matcher percentageMatcher = percentagePattern.matcher(line);
      if (percentageMatcher.matches()) {
        percentage = Integer.valueOf(percentageMatcher.group(1));
        continue;
      }
    }

    batteryRequest.setBatteryStatus(
        new BatteryStatus(
            node,
            LocalDateTime.now(),
            BatteryState.getFromUpowerString(state),
            Integer.valueOf(percentage),
            batteryRequest.getShellCommand()));
  }
}
