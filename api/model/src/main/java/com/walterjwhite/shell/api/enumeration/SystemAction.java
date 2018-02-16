package com.walterjwhite.shell.api.enumeration;

public enum SystemAction {
  Shutdown("shutdown"),
  Reboot("reboot"),
  Poweroff("poweroff"),
  PoweroffImmediately("poweroff -f");

  private final String commandLine;

  SystemAction(final String commandLine) {
    this.commandLine = commandLine;
  }

  public String getCommandLine() {
    return (commandLine);
  }
}
