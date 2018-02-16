package com.walterjwhite.shell.api.model;

public interface MultipleShellCommandable {
  //  List<ShellCommand> getShellCommands();
  //
  //  void setShellCommands(List<ShellCommand> shellCommands);

  void addShellCommand(ShellCommand shellCommand);

  int getTimeout();

  void setTimeout(int timeout);
}
