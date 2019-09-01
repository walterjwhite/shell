package com.walterjwhite.shell.impl;

import com.walterjwhite.shell.api.model.ChrootShellCommand;
import com.walterjwhite.shell.api.model.Chrootable;
import com.walterjwhite.shell.api.model.ShellCommand;
import java.io.IOException;
import java.nio.charset.Charset;
import java.time.temporal.ChronoUnit;
import java.util.concurrent.TimeUnit;

public class ShellProcessExecution extends AbstractProcessExecution {
  protected final Process process;

  public ShellProcessExecution(
      Process process,
      ShellCommand shellCommand,
      final ChronoUnit interruptGracePeriodUnits,
      final long interruptGracePeriodValue)
      throws IOException {
    super(
        shellCommand,
        process.getInputStream(),
        process.getErrorStream(),
        process.getOutputStream(),
        ChrootShellCommand.class.isInstance(shellCommand),
        interruptGracePeriodUnits,
        interruptGracePeriodValue);
    this.process = process;

    doExecute();
  }

  protected void doExecute() throws IOException {
    if (shellCommand instanceof Chrootable) {
      outputStream.write(shellCommand.getCommandLine().getBytes(Charset.defaultCharset()));
      outputStream.flush();
    }
  }

  @Override
  protected int getReturnCode() throws InterruptedException {
    if (shellCommand.getTimeout() > 0) {
      process.waitFor(shellCommand.getTimeout(), TimeUnit.SECONDS);
      return (process.exitValue());
    }

    return (process.waitFor());
  }

  protected int getTimeout() {
    return (shellCommand.getTimeout());
  }

  @Override
  protected void doSetTimeout(int timeoutInSeconds) {
    // process.waitFor(timeoutInSeconds, TimeUnit.SECONDS);
  }

  @Override
  protected void kill(Exception e) throws IOException, InterruptedException {
    super.kill(e);

    process.destroy();
  }

  public void interrupt() {
    process.destroy();

    super.interrupt();
  }
}
