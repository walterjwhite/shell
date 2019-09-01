package com.walterjwhite.shell.impl;

import com.walterjwhite.infrastructure.inject.core.helper.ApplicationHelper;
import com.walterjwhite.interruptable.Interruptable;
import com.walterjwhite.interruptable.annotation.InterruptableTask;
import com.walterjwhite.shell.api.model.ShellCommand;
import com.walterjwhite.shell.api.service.OutputCollector;
import com.walterjwhite.shell.impl.collector.InputConsumable;
import com.walterjwhite.shell.impl.collector.LoggerOutputCollector;
import com.walterjwhite.shell.impl.collector.ShellCommandOutputCollector;
import com.walterjwhite.timeout.TimeConstrainedMethodInvocation;
import com.walterjwhite.timeout.annotation.TimeConstrained;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.time.Duration;
import java.time.temporal.ChronoUnit;

public abstract class AbstractProcessExecution
    implements TimeConstrainedMethodInvocation, Interruptable {
  protected final ShellCommand shellCommand;
  protected final Thread inputThread;
  protected final Thread errorThread;
  protected final OutputStream outputStream;
  protected final boolean requiresExplicitExit;
  protected final ChronoUnit interruptGracePeriodUnits;
  protected final long interruptGracePeriodValue;

  protected AbstractProcessExecution(
      ShellCommand shellCommand,
      final InputStream inputStream,
      final InputStream errorStream,
      final OutputStream outputStream,
      boolean requiresExplicitExit,
      ChronoUnit interruptGracePeriodUnits,
      long interruptGracePeriodValue) {
    super();
    this.shellCommand = shellCommand;
    this.outputStream = outputStream;

    this.inputThread = setupMonitoringThread(inputStream, false);
    this.errorThread = setupMonitoringThread(errorStream, true);
    this.requiresExplicitExit = requiresExplicitExit;
    this.interruptGracePeriodUnits = interruptGracePeriodUnits;
    this.interruptGracePeriodValue = interruptGracePeriodValue;
  }

  public Thread setupMonitoringThread(InputStream inputStream, final boolean isError) {
    InputConsumable inputConsumable =
        new InputConsumable(inputStream, isError, getOutputCollectors());

    final Thread inputConsumableThread = new Thread(inputConsumable);
    inputConsumableThread.start();
    return (inputConsumableThread);
  }

  protected OutputCollector[] getOutputCollectors() {
    final OutputCollectorConfiguration outputCollectorConfiguration = null;
    if (outputCollectorConfiguration == null) {
      return registerDefaultOutputCollectors();
    }

    return registerConfiguredOutputCollectors(outputCollectorConfiguration);
  }

  protected OutputCollector[] registerDefaultOutputCollectors() {
    return new OutputCollector[] {
      new ShellCommandOutputCollector(shellCommand),
      new LoggerOutputCollector(getClass(), shellCommand.getCommandLine())
    };
  }

  protected OutputCollector[] registerConfiguredOutputCollectors(
      final OutputCollectorConfiguration outputCollectorConfiguration) {
    final OutputCollector[] outputCollectors =
        new OutputCollector[outputCollectorConfiguration.getOutputCollectorClasses().size()];
    int i = 0;
    for (Class<? extends OutputCollector> outputCollectorClass :
        outputCollectorConfiguration.getOutputCollectorClasses())
      outputCollectors[i++] =
          ApplicationHelper.getApplicationInstance()
              .getInjector()
              .getInstance(outputCollectorClass);

    return (outputCollectors);
  }

  protected void setTimeout() throws Exception {
    final int timeout = getTimeout();
    if (getTimeout() > 0) {

      doSetTimeout(timeout);
    }
  }

  protected abstract void doSetTimeout(int timeoutInSeconds) throws Exception;

  protected abstract int getTimeout();

  protected abstract int getReturnCode() throws InterruptedException, IOException;

  protected void kill(Exception e) throws IOException, InterruptedException {
    outputStream.write(3);
    outputStream.flush();

    Thread.sleep(1000);
  }

  @InterruptableTask
  @TimeConstrained
  public void run() throws IOException, InterruptedException {
    doRun();
    setReturnCode();
    syncInputs();
  }

  public void interrupt() {
    inputThread.interrupt();
    errorThread.interrupt();
  }

  /**
   * Sets the timeout on the run method, if the execution fails to complete within that time, it is
   * interrupted
   */
  public Duration getAllowedExecutionDuration() {
    return Duration.of(getTimeout(), ChronoUnit.SECONDS);
  }

  protected void doRun() throws IOException, InterruptedException {
    try {
      setTimeout();

      if (requiresExplicitExit) exitAfterCompletionOfCommand();

    } catch (IOException e) {
      if (exitedButNotCleanly(e)) {
        kill(e);
      }
    } catch (Exception e) {
      kill(e);
    }
  }

  protected void exitAfterCompletionOfCommand() throws IOException {
    // if we're running in a chroot (or SSH), type this in
    // whenever the actual command finishes, this will execute and cause the input/error streams
    // to close
    outputStream.write("\nexit\n".getBytes(Charset.defaultCharset()));
    outputStream.flush();
  }

  protected boolean exitedButNotCleanly(Exception e) {
    return !e.getMessage().contains("Stream closed") && !e.getMessage().contains("Broken pipe");
  }

  protected void setReturnCode() {
    try {
      shellCommand.setReturnCode(getReturnCode());
    } catch (Exception e) {
      shellCommand.setReturnCode(-1);
    }
  }

  protected void syncInputs() throws InterruptedException {
    inputThread.join();
    errorThread.join();
  }

  @Override
  public Duration getInterruptGracePeriodTimeout() {
    return Duration.of(interruptGracePeriodValue, interruptGracePeriodUnits);
  }
}
