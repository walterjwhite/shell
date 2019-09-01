package com.walterjwhite.shell.impl.util;

import com.walterjwhite.shell.api.model.*;
import java.io.File;
import java.io.IOException;
import java.util.Set;

public class ShellExecutionUtil {
  private ShellExecutionUtil() {}

  public static void setEnvironmentalProperties(ShellCommand shellCommand) {
    if (isEnvironmentAware(shellCommand)) {
      final Set<ShellCommandEnvironmentProperty> shellCommandEnvironmentProperties =
          (shellCommand).getShellCommandEnvironmentProperties();
      if (shellCommandEnvironmentProperties != null
          && !shellCommandEnvironmentProperties.isEmpty()) {
        for (ShellCommandEnvironmentProperty shellCommandEnvironmentProperty :
            shellCommandEnvironmentProperties) {
          set(shellCommandEnvironmentProperty);
        }
      }
    }
  }

  private static void set(ShellCommandEnvironmentProperty shellCommandEnvironmentProperty) {
    System.setProperty(
        shellCommandEnvironmentProperty.getKey(), shellCommandEnvironmentProperty.getValue());
  }

  private static boolean isEnvironmentAware(ShellCommand shellCommand) {
    return shellCommand instanceof EnvironmentAware;
  }

  public static String getChrootCmdLine(final Chrootable chrootable) {
    return ("/bin/chroot " + chrootable.getChrootPath() + " /bin/bash");
  }

  public static String getFreeBSDJailChrootCmdLine(final Chrootable chrootable) {
    return ("ezjail-admin console " + ((FreeBSDJailShellCommand) chrootable).getJailName());
  }

  public static Process doNonChrootProcess(ShellCommand shellCommand) throws IOException {
    if (isEnvironmentAware(shellCommand)) {
      if (shellCommand.getCommandLine().contains("|")) {
        if (shellCommand.getWorkingDirectory() != null)
          return Runtime.getRuntime()
              .exec(
                  new String[] {"/bin/sh", "-c", shellCommand.getCommandLine()},
                  getEnvironmentalProperties((shellCommand).getShellCommandEnvironmentProperties()),
                  new File(shellCommand.getWorkingDirectory()));

        return Runtime.getRuntime()
            .exec(
                new String[] {"/bin/sh", "-c", shellCommand.getCommandLine()},
                getEnvironmentalProperties((shellCommand).getShellCommandEnvironmentProperties()));
      }

      if (shellCommand.getWorkingDirectory() != null)
        return Runtime.getRuntime()
            .exec(
                shellCommand.getCommandLine(),
                getEnvironmentalProperties((shellCommand).getShellCommandEnvironmentProperties()),
                new File(shellCommand.getWorkingDirectory()));

      return Runtime.getRuntime()
          .exec(
              shellCommand.getCommandLine(),
              getEnvironmentalProperties((shellCommand).getShellCommandEnvironmentProperties()));
    }

    if (shellCommand.getCommandLine().contains("|"))
      return (Runtime.getRuntime()
          .exec(new String[] {"/bin/sh", "-c", shellCommand.getCommandLine()}));

    return Runtime.getRuntime().exec(shellCommand.getCommandLine());
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
