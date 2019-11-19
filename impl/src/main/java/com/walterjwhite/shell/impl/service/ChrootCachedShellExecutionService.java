package com.walterjwhite.shell.impl.service;

import com.walterjwhite.datastore.api.repository.Repository;
import com.walterjwhite.property.impl.annotation.Property;
import com.walterjwhite.shell.api.model.Chrootable;
import com.walterjwhite.shell.api.model.ShellCommand;
import com.walterjwhite.shell.impl.property.InterruptGracePeriodUnits;
import com.walterjwhite.shell.impl.property.InterruptGracePeriodValue;
import java.time.temporal.ChronoUnit;
import javax.inject.Inject;
import javax.inject.Provider;

// TODO: X 1. setup chroot process at start
// TODO: 2. leave chroot process open even as commands complete
// #2 is tricky since we currently explicitly "exit" the chroot to force the process to close
// TODO: 3. close chroot process at end
public class ChrootCachedShellExecutionService extends DefaultShellExecution {

  protected String chrootPath;
  protected transient Process chrootProcess;

  @Inject
  public ChrootCachedShellExecutionService(
      Provider<Repository> repositoryProvider,
      @Property(InterruptGracePeriodUnits.class) ChronoUnit interruptGracePeriodUnits,
      @Property(InterruptGracePeriodValue.class) long interruptGracePeriodValue) {
    super(repositoryProvider, interruptGracePeriodUnits, interruptGracePeriodValue);
  }

  public ShellCommand run(ShellCommand shellCommand) throws Exception {
    if (chrootProcess == null && shellCommand instanceof Chrootable) {
      // if(chrootPath.equals((Chrootable)shellCommand).getChrootPath()) {}
      chrootProcess = setupProcess(shellCommand);
    }

    return null;
  }

  @Override
  public void interrupt() {
    if (chrootProcess != null) {
      // send "exit" to process, then destroy it
      chrootProcess.destroy();
    }

    super.interrupt();
  }
}
