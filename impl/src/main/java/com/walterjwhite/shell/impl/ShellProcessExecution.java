package com.walterjwhite.shell.impl;

import com.walterjwhite.shell.api.model.Chrootable;
import com.walterjwhite.shell.api.model.ShellCommand;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.concurrent.TimeUnit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ShellProcessExecution extends AbstractProcessExecution {
  private static final Logger LOGGER = LoggerFactory.getLogger(ShellProcessExecution.class);

  protected final Process process;

  public ShellProcessExecution(Process process, ShellCommand shellCommand) throws IOException {
    super(
        shellCommand,
        process.getInputStream(),
        process.getErrorStream(),
        process.getOutputStream());
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
  protected void kill() throws IOException {
    super.kill();

    process.destroy();
  }
}
