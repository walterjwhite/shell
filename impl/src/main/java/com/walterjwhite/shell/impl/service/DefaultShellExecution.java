package com.walterjwhite.shell.impl.service;

import com.walterjwhite.datastore.api.repository.Repository;
import com.walterjwhite.interruptable.Interruptable;
import com.walterjwhite.interruptable.annotation.InterruptableService;
import com.walterjwhite.property.impl.annotation.Property;
import com.walterjwhite.shell.api.model.*;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.impl.ShellProcessExecution;
import com.walterjwhite.shell.impl.annotation.EntityEnabled;
import com.walterjwhite.shell.impl.property.InterruptGracePeriodUnits;
import com.walterjwhite.shell.impl.property.InterruptGracePeriodValue;
import com.walterjwhite.shell.impl.util.ShellExecutionUtil;
import java.io.IOException;
import java.time.temporal.ChronoUnit;
import javax.inject.Inject;
import javax.inject.Provider;

@InterruptableService
public class DefaultShellExecution implements ShellExecutionService, Interruptable {
  protected final Provider<Repository> repositoryProvider;
  protected boolean shutdown;

  protected final ChronoUnit interruptGracePeriodUnits;
  protected final long interruptGracePeriodValue;

  @Inject
  public DefaultShellExecution(
      Provider<Repository> repositoryProvider,
      @Property(InterruptGracePeriodUnits.class) ChronoUnit interruptGracePeriodUnits,
      @Property(InterruptGracePeriodValue.class) long interruptGracePeriodValue) {
    super();
    this.repositoryProvider = repositoryProvider;

    this.interruptGracePeriodUnits = interruptGracePeriodUnits;
    this.interruptGracePeriodValue = interruptGracePeriodValue;
  }

  @EntityEnabled
  @Override
  public ShellCommand run(ShellCommand shellCommand) throws Exception {
    checkIfShutdown();

    //    shellCommand.setNode(nodeProvider.get());
    ShellExecutionUtil.setEnvironmentalProperties(shellCommand);

    doRun(shellCommand);
    return shellCommand;
  }

  protected void checkIfShutdown() {
    if (shutdown) throw new IllegalStateException("Service is shutting down");
  }

  protected void doRun(ShellCommand shellCommand) throws IOException, InterruptedException {
    new ShellProcessExecution(
            setupProcess(shellCommand),
            shellCommand,
            interruptGracePeriodUnits,
            interruptGracePeriodValue)
        .run();
  }

  protected Process setupProcess(ShellCommand shellCommand) throws IOException {
    if (shellCommand instanceof Chrootable) {
      if (shellCommand instanceof FreeBSDJailShellCommand)
        return doFreeBSDJailChrootProcess(shellCommand);

      return (doChrootProcess(shellCommand));
    }
    return (ShellExecutionUtil.doNonChrootProcess(shellCommand));
  }

  protected Process doFreeBSDJailChrootProcess(ShellCommand shellCommand) throws IOException {
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

  @Override
  public void interrupt() {
    shutdown = true;
  }
}
