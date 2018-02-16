package com.walterjwhite.shell.impl.service;

import com.walterjwhite.shell.api.model.*;
import com.walterjwhite.shell.api.repository.ShellCommandRepository;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.impl.ShellProcessExecution;
import com.walterjwhite.shell.impl.annotation.EntityEnabled;
import com.walterjwhite.shell.impl.util.ShellExecutionUtil;
import java.io.IOException;
import javax.inject.Inject;
import javax.inject.Provider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DefaultShellExecution implements ShellExecutionService {
  private static final Logger LOGGER = LoggerFactory.getLogger(DefaultShellExecution.class);

  protected final Provider<ShellCommandRepository> shellCommandRepositoryProvider;
  //  protected final Provider<Node> nodeProvider;

  @Inject
  public DefaultShellExecution(
      Provider<ShellCommandRepository> shellCommandRepositoryProvider /*,
      Provider<Node> nodeProvider*/) {
    super();
    this.shellCommandRepositoryProvider = shellCommandRepositoryProvider;
    //    this.nodeProvider = nodeProvider;
  }

  @EntityEnabled
  @Override
  public ShellCommand run(ShellCommand shellCommand) throws Exception {
    //    shellCommand.setNode(nodeProvider.get());
    ShellExecutionUtil.setEnvironmentalProperties(shellCommand);

    doRun(shellCommand);
    return shellCommand;
  }

  protected void doRun(ShellCommand shellCommand) throws IOException, InterruptedException {
    new ShellProcessExecution(setupProcess(shellCommand), shellCommand).run();
  }

  protected Process setupProcess(ShellCommand shellCommand) throws IOException {
    if (shellCommand instanceof Chrootable) {
      return (doChrootProcess(shellCommand));
    }
    return (ShellExecutionUtil.doNonChrootProcess(shellCommand));
  }

  protected Process doChrootProcess(ShellCommand shellCommand) throws IOException {
    final Chrootable chrootable = (Chrootable) shellCommand;
    doValidate(shellCommand, chrootable);

    if (shellCommand instanceof EnvironmentAware)
      return (Runtime.getRuntime()
          .exec(
              ShellExecutionUtil.getChrootCmdLine(chrootable),
              ShellExecutionUtil.getEnvironmentalProperties(
                  (shellCommand).getShellCommandEnvironmentProperties())));
    return (Runtime.getRuntime().exec(ShellExecutionUtil.getChrootCmdLine(chrootable)));

    // once chroot process is running, execute actual command ...
  }

  protected void doValidate(final ShellCommand shellCommand, final Chrootable chrootable) {
    if (chrootable.getChrootPath() == null || chrootable.getChrootPath().isEmpty())
      throw (new IllegalStateException(
          "Cannot chroot, chroot path is null:" + shellCommand.getCommandLine()));
  }
}
