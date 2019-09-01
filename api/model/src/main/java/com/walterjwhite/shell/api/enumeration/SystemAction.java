package com.walterjwhite.shell.api.enumeration;

import lombok.Getter;

@Getter
public enum SystemAction {
  Shutdown(),
  Reboot(),
  Poweroff(),
  PoweroffImmediately("poweroff -f");

  private final String commandLine;

  SystemAction(final String commandLine) {
    this.commandLine = commandLine;
  }

  SystemAction() {
    this.commandLine = name().toLowerCase();
  }
}
