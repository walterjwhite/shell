package com.walterjwhite.shell.impl.collector;

import com.walterjwhite.shell.api.model.CommandError;
import com.walterjwhite.shell.api.model.CommandOutput;
import com.walterjwhite.shell.api.model.ShellCommand;
import com.walterjwhite.shell.api.service.OutputCollector;

public class ShellCommandOutputCollector implements OutputCollector {
  protected int outputIndex = 0;
  protected int errorIndex = 0;
  protected final ShellCommand shellCommand;

  public ShellCommandOutputCollector(ShellCommand shellCommand) {
    this.shellCommand = shellCommand;
  }

  @Override
  public void onData(String line, boolean isError) {
    if (isError) {
      shellCommand.getErrors().add(new CommandError(shellCommand, errorIndex++, line));
    } else {
      shellCommand.getOutputs().add(new CommandOutput(shellCommand, outputIndex++, line));
    }
  }

  @Override
  public String toString() {
    return getClass().getName()
        + "{"
        + "outputIndex="
        + outputIndex
        + ", errorIndex="
        + errorIndex
        + ", shellCommand="
        + shellCommand.getCommandLine()
        + '}';
  }
}
