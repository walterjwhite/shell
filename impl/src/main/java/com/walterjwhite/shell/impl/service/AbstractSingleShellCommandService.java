package com.walterjwhite.shell.impl.service;

import com.walterjwhite.shell.api.model.ShellCommandable;
import com.walterjwhite.shell.api.service.ShellExecutionService;

public abstract class AbstractSingleShellCommandService<EntityType extends ShellCommandable>
    extends AbstractShellCommandService<EntityType> {

  public AbstractSingleShellCommandService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      int timeout) {
    super(shellCommandBuilder, shellExecutionService, timeout);
  }

  @Override
  protected void doExecute(EntityType entity) throws Exception {
    entity.setShellCommand(
        shellExecutionService.run(
            shellCommandBuilder
                .build()
                .withCommandLine(getCommandLine(entity))
                .withTimeout(getTimeout(entity))));
  }

  protected String getCommandLine(EntityType entity) {
    return null;
  }

  protected int getTimeout(EntityType entity) {
    if (entity.getTimeout() > 0) return entity.getTimeout();

    return timeout;
  }
}
