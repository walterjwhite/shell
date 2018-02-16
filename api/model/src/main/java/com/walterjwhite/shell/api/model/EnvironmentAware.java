package com.walterjwhite.shell.api.model;

import java.util.Set;

public interface EnvironmentAware {
  void setShellCommandEnvironmentProperties(
      final Set<ShellCommandEnvironmentProperty> shellCommandEnvironmentProperties);

  Set<ShellCommandEnvironmentProperty> getShellCommandEnvironmentProperties();
}
