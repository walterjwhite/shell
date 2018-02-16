package com.walterjwhite.shell.impl.provider;

import com.walterjwhite.shell.impl.OutputCollectorConfiguration;
import javax.inject.Provider;

// TODO: how to implement this
public class OutputCollectorConfigurationProvider
    implements Provider<OutputCollectorConfiguration> {
  protected final OutputCollectorConfiguration outputCollectorConfiguration;

  public OutputCollectorConfigurationProvider() {
    //        outputCollectorConfiguration = new OutputCollectorConfiguration();
    //        outputCollectorConfiguration.getOutputCollectorClasses().add(new
    // ShellCommandOutputCollector(shellCommand),
    //                new LoggerOutputCollector(getClass(), shellCommand.getCommandLine())
    outputCollectorConfiguration = null;
  }

  @Override
  public OutputCollectorConfiguration get() {
    return outputCollectorConfiguration;
  }
}
