package com.walterjwhite.shell.impl.service;

import com.walterjwhite.shell.api.model.ShellCommand;
import com.walterjwhite.shell.impl.ShellProcessExecution;
import java.io.IOException;
import java.nio.charset.Charset;
import java.time.temporal.ChronoUnit;

public class CachedChrootShellProcessExecution extends ShellProcessExecution {
  public CachedChrootShellProcessExecution(
      Process process,
      ShellCommand shellCommand,
      ChronoUnit interruptGracePeriodUnits,
      long interruptGracePeriodValue)
      throws IOException {
    super(process, shellCommand, interruptGracePeriodUnits, interruptGracePeriodValue);
  }

  protected void exitAfterCompletionOfCommand() throws IOException {
    // keep the bash process running?
    outputStream.write("\necho $?\n".getBytes(Charset.defaultCharset()));
    outputStream.flush();
  }
}
