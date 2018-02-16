package com.walterjwhite.shell.api.service;

import com.walterjwhite.shell.api.model.ShellCommand;

public interface ShellExecutionService {
  ShellCommand run(ShellCommand shellCommand) throws Exception;
}
