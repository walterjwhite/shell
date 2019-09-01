// package com.walterjwhite.shell.unused;
//
// import com.google.common.eventbus.Subscribe;
// import com.walterjwhite.queue.api.queuedJob.AbstractCallableJob;
// import com.walterjwhite.shell.api.model.CommandError;
// import com.walterjwhite.shell.api.model.CommandOutput;
//
// public class CommandOutputCallableJob extends AbstractCallableJob<CommandOutput, Void> {
//
//  @Subscribe
//  public void onCommandOutput(CommandError commandError) {}
//
//  @Override
//  public Void call() {
//    return null;
//  }
//
//  @Override
//  protected boolean isRetryable(Throwable thrown) {
//    return false;
//  }
// }
