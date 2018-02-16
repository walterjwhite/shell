package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.util.Objects;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;

@Entity
public class MountCommandShellCommand extends AbstractEntity {
  @ManyToOne @JoinColumn protected MountCommand mountCommand;

  @ManyToOne @JoinColumn protected ShellCommand shellCommand;

  public MountCommand getMountCommand() {
    return mountCommand;
  }

  public void setMountCommand(MountCommand mountCommand) {
    this.mountCommand = mountCommand;
  }

  public ShellCommand getShellCommand() {
    return shellCommand;
  }

  public void setShellCommand(ShellCommand shellCommand) {
    this.shellCommand = shellCommand;
  }

  public MountCommandShellCommand withShellCommand(ShellCommand shellCommand) {
    this.shellCommand = shellCommand;
    return this;
  }

  public MountCommandShellCommand withMountCommand(MountCommand mountCommand) {
    this.mountCommand = mountCommand;
    return this;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    MountCommandShellCommand that = (MountCommandShellCommand) o;
    return Objects.equals(mountCommand, that.mountCommand)
        && Objects.equals(shellCommand, that.shellCommand);
  }

  @Override
  public int hashCode() {

    return Objects.hash(mountCommand, shellCommand);
  }
}
