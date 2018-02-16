package com.walterjwhite.shell.api.enumeration;

public enum ServiceAction {
  Start,
  Stop,
  Restart,
  Reload,
  Status;

  public String getCommand() {
    return (toString().toLowerCase());
  }
}
