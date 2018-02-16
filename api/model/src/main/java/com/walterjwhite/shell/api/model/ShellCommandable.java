package com.walterjwhite.shell.api.model;

public interface ShellCommandable {
  ShellCommand getShellCommand();

  void setShellCommand(ShellCommand shellCommand);

  int getTimeout();

  void setTimeout(int timeout);
}
