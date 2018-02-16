package com.walterjwhite.shell.unused;

import com.google.common.eventbus.Subscribe;
import com.walterjwhite.queue.api.job.AbstractCallableJob;
import com.walterjwhite.shell.api.model.CommandError;
import com.walterjwhite.shell.api.model.CommandOutput;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CommandOutputCallableJob extends AbstractCallableJob<CommandOutput, Void> {
  private static final Logger LOGGER = LoggerFactory.getLogger(CommandOutputCallableJob.class);

  @Subscribe
  public void onCommandOutput(CommandError commandError) {
    LOGGER.error("received output:" + commandError.getOutput());
  }

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
