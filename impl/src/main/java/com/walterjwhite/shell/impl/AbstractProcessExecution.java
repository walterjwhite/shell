package com.walterjwhite.shell.impl;

import com.walterjwhite.google.guice.GuiceHelper;
import com.walterjwhite.shell.api.model.ShellCommand;
import com.walterjwhite.shell.api.service.OutputCollector;
import com.walterjwhite.shell.impl.collector.InputConsumable;
import com.walterjwhite.shell.impl.collector.LoggerOutputCollector;
import com.walterjwhite.shell.impl.collector.ShellCommandOutputCollector;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractProcessExecution {
  private static final Logger LOGGER = LoggerFactory.getLogger(AbstractProcessExecution.class);

  protected final transient ScheduledExecutorService interrupterExecutorService =
      Executors.newScheduledThreadPool(1);

  protected final ShellCommand shellCommand;
  protected final Thread inputThread;
  protected final Thread errorThread;
  protected final OutputStream outputStream;

  protected ScheduledFuture interrupter;

  protected AbstractProcessExecution(
      ShellCommand shellCommand,
      final InputStream inputStream,
      final InputStream errorStream,
      final OutputStream outputStream) {
    super();
    this.shellCommand = shellCommand;
    this.outputStream = outputStream;

    this.inputThread = setupMonitoringThread(inputStream, false);
    this.errorThread = setupMonitoringThread(errorStream, true);
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
      outputCollectors[i++] = GuiceHelper.getGuiceInjector().getInstance(outputCollectorClass);

    return (outputCollectors);
  }

  protected void setTimeout() throws Exception {
    final int timeout = getTimeout();
    if (getTimeout() > 0) {
      interrupter = scheduleInterruption(timeout);

      doSetTimeout(timeout);
    }
  }

  protected abstract void doSetTimeout(int timeoutInSeconds) throws Exception;

  protected abstract int getTimeout();

  protected abstract int getReturnCode() throws InterruptedException, IOException;

  protected void kill() throws IOException {
    try {
      outputStream.write(3);
      outputStream.flush();

      try {
        Thread.sleep(1000);
      } catch (InterruptedException e) {
      }
    } catch (Exception e) {
      LOGGER.warn("Error killing process", e);
    }
  }

  public void run() throws IOException, InterruptedException {
    try {
      setTimeout();

      // if we're running in a chroot (or SSH), type this in
      // whenever the actual command finishes, this will execute and cause the input/error streams
      // to close
      outputStream.write("\nexit\n".getBytes(Charset.defaultCharset()));
      outputStream.flush();

    } catch (IOException e) {
      if (!e.getMessage().contains("Stream closed") && !e.getMessage().contains("Broken pipe")) {
        LOGGER.error("Error exiting cleanly, killing command.", e);
        kill();
      } else {
        LOGGER.debug("Process already exited");
      }
    } catch (Exception e) {
      LOGGER.error("Error exiting cleanly, killing command.", e);
      kill();
    }

    try {
      shellCommand.setReturnCode(getReturnCode());
    } catch (Exception e) {
      shellCommand.setReturnCode(-1);
    }

    inputThread.join();
    errorThread.join();

    cancel();
  }

  protected ScheduledFuture scheduleInterruption(int timeout) {
    return interrupterExecutorService.schedule(new TimeoutRunnable(), timeout, TimeUnit.SECONDS);
  }

  protected boolean cancel() {
    if (interrupter != null) {
      try {
        if (!interrupter.isCancelled() && !interrupter.isDone()) {
          return interrupter.cancel(true);
        }

        return false;
      } catch (Exception e) {
        LOGGER.trace("error cancelling task", e);
        return false;
      }
    }

    // the method did not have an timeout
    return false;
  }

  private class TimeoutRunnable implements Runnable {
    @Override
    public void run() {
      try {
        kill();
      } catch (IOException e) {
        throw (new RuntimeException("Error killing the process", e));
      }
    }
  }
}
