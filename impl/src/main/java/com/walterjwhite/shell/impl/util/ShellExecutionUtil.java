package com.walterjwhite.shell.impl.util;

import com.walterjwhite.shell.api.model.Chrootable;
import com.walterjwhite.shell.api.model.EnvironmentAware;
import com.walterjwhite.shell.api.model.ShellCommand;
import com.walterjwhite.shell.api.model.ShellCommandEnvironmentProperty;
import java.io.IOException;
import java.util.Set;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ShellExecutionUtil {
  private static final Logger LOGGER = LoggerFactory.getLogger(ShellExecutionUtil.class);

  private ShellExecutionUtil() {}

  public static void setEnvironmentalProperties(ShellCommand shellCommand) {
    if (shellCommand instanceof EnvironmentAware) {
      LOGGER.trace("setting environmental properties:");

      final Set<ShellCommandEnvironmentProperty> shellCommandEnvironmentProperties =
          (shellCommand).getShellCommandEnvironmentProperties();
      if (shellCommandEnvironmentProperties != null
          && !shellCommandEnvironmentProperties.isEmpty()) {
        for (ShellCommandEnvironmentProperty shellCommandEnvironmentProperty :
            shellCommandEnvironmentProperties) {
          LOGGER.trace(
              "setting: "
                  + shellCommandEnvironmentProperty.getKey()
                  + " -> "
                  + shellCommandEnvironmentProperty.getValue());
          System.setProperty(
              shellCommandEnvironmentProperty.getKey(), shellCommandEnvironmentProperty.getValue());
        }
      }
    }
  }

  public static String getChrootCmdLine(final Chrootable chrootable) {
    return ("/bin/chroot " + chrootable.getChrootPath() + " /bin/bash");
  }

  public static Process doNonChrootProcess(ShellCommand shellCommand) throws IOException {
    LOGGER.trace("NOT chrooting process");
    if (shellCommand instanceof EnvironmentAware) {
      if (shellCommand.getCommandLine().contains("|")) {
        return (Runtime.getRuntime()
            .exec(
                new String[] {"/bin/sh", "-c", shellCommand.getCommandLine()},
                getEnvironmentalProperties((shellCommand).getShellCommandEnvironmentProperties())));
      }

      return (Runtime.getRuntime()
          .exec(
              shellCommand.getCommandLine(),
              getEnvironmentalProperties((shellCommand).getShellCommandEnvironmentProperties())));
    }

    if (shellCommand.getCommandLine().contains("|"))
      return (Runtime.getRuntime()
          .exec(new String[] {"/bin/sh", "-c", shellCommand.getCommandLine()}));

    return (Runtime.getRuntime().exec(shellCommand.getCommandLine()));
  }

  public static String[] getEnvironmentalProperties(
      final Set<ShellCommandEnvironmentProperty> shellCommandEvnironmentProperties) {
    if (shellCommandEvnironmentProperties != null && !shellCommandEvnironmentProperties.isEmpty()) {
      final String[] environmentalProperties = new String[shellCommandEvnironmentProperties.size()];
      int i = 0;
      for (ShellCommandEnvironmentProperty shellCommandEnvironmentProperty :
          shellCommandEvnironmentProperties) {
        environmentalProperties[i++] =
            shellCommandEnvironmentProperty.getKey()
                + "="
                + shellCommandEnvironmentProperty.getValue();
      }

      return (environmentalProperties);
    }

    return (null);
  }
}
