package com.walterjwhite.shell.unused;

import com.walterjwhite.queue.api.job.AbstractCallableJob;
import com.walterjwhite.shell.api.model.CommandError;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CommandErrorCallableJob extends AbstractCallableJob<CommandError, Void> {
  private static final Logger LOGGER = LoggerFactory.getLogger(CommandErrorCallableJob.class);

  @Override
  public Void call() throws Exception {
    LOGGER.info("received output:" + entity.getOutput());
    return null;
  }

  @Override
  protected boolean isRetryable(Throwable thrown) {
    return false;
  }
}
