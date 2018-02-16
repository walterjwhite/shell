package com.walterjwhite.shell.impl.service;

import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.impl.annotation.EntityEnabled;

public abstract class AbstractShellCommandService<EntityType> {
  protected final ShellCommandBuilder shellCommandBuilder;
  protected final ShellExecutionService shellExecutionService;
  protected final int timeout;

  protected AbstractShellCommandService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      int timeout) {
    this.shellCommandBuilder = shellCommandBuilder;
    this.shellExecutionService = shellExecutionService;
    this.timeout = timeout;
  }

  public EntityType execute(EntityType entity) throws Exception {
    doBefore(entity);

    return doWrappedExecute(entity);
  }

  protected void doBefore(EntityType entity) {}

  protected void doAfter(EntityType entity) {}

  @EntityEnabled
  protected EntityType doWrappedExecute(EntityType entity) throws Exception {
    doExecute(entity);

    doAfter(entity);

    return entity;
  }

  protected abstract void doExecute(EntityType entity) throws Exception;
}
