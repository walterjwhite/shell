package com.walterjwhite.shell.impl.service;

import com.walterjwhite.shell.api.model.ChrootShellCommand;
import com.walterjwhite.shell.api.model.Node;
import com.walterjwhite.shell.api.model.ShellCommand;
import javax.inject.Inject;
import javax.inject.Provider;

public class ShellCommandBuilder {
  protected final Provider<Node> nodeProvider;

  @Inject
  public ShellCommandBuilder(Provider<Node> nodeProvider) {
    this.nodeProvider = nodeProvider;
  }

  public ShellCommand build() {
    final ShellCommand shellCommand = new ShellCommand();
    shellCommand.setNode(nodeProvider.get());

    return shellCommand;
  }

  public ChrootShellCommand buildChroot() {
    final ChrootShellCommand chrootShellCommand = new ChrootShellCommand();
    chrootShellCommand.setNode(nodeProvider.get());

    return chrootShellCommand;
  }
}
