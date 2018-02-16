package com.walterjwhite.shell.impl.service;

import com.walterjwhite.shell.api.model.MultipleShellCommandable;
import com.walterjwhite.shell.api.service.ShellExecutionService;

public class AbstractMultipleShellCommandService<EntityType extends MultipleShellCommandable>
    extends AbstractShellCommandService<EntityType> {
  public AbstractMultipleShellCommandService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      int timeout) {
    super(shellCommandBuilder, shellExecutionService, timeout);
  }

  @Override
  protected void doExecute(EntityType entity) throws Exception {
    final int commandTimeout = getTimeout(entity);
    for (final String commandLine : getCommandLines(entity)) {
      doBeforeEach(entity);

      entity.addShellCommand(
          shellExecutionService.run(
              shellCommandBuilder
                  .build()
                  .withCommandLine(commandLine)
                  .withTimeout(commandTimeout)));

      doAfterEach(entity);
    }
  }

  protected void doBeforeEach(EntityType entity) {}

  protected void doAfterEach(EntityType entity) {}

  protected String[] getCommandLines(EntityType entity) {
    return null;
  }

  protected int getTimeout(EntityType entity) {
    if (entity.getTimeout() > 0) return entity.getTimeout();

    return timeout;
  }
}
