package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractUUIDEntity;
import com.walterjwhite.shell.api.enumeration.MountAction;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.*;

@Entity
public class MountCommand extends AbstractUUIDEntity implements MultipleShellCommandable {

  @Column(nullable = false, updatable = false)
  protected String rootPath;

  @ManyToOne(optional = false, cascade = CascadeType.ALL)
  @JoinColumn(nullable = false, updatable = false)
  protected MountPoint mountPoint;

  @OneToMany(mappedBy = "mountCommand", cascade = CascadeType.ALL)
  protected List<MountCommandShellCommand> shellCommands = new ArrayList<>();

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected MountAction mountAction;

  @Column(nullable = false, updatable = false)
  protected int timeout;

  public MountPoint getMountPoint() {
    return mountPoint;
  }

  public void setMountPoint(MountPoint mountPoint) {
    this.mountPoint = mountPoint;
  }

  public List<MountCommandShellCommand> getShellCommands() {
    return shellCommands;
  }

  public void setShellCommands(List<MountCommandShellCommand> shellCommands) {
    this.shellCommands = shellCommands;
  }

  public void addShellCommand(ShellCommand shellCommand) {
    shellCommands.add(
        new MountCommandShellCommand().withShellCommand(shellCommand).withMountCommand(this));
  }

  @Override
  public int getTimeout() {
    return timeout;
  }

  @Override
  public void setTimeout(int timeout) {
    this.timeout = timeout;
  }

  public MountAction getMountAction() {
    return mountAction;
  }

  public void setMountAction(MountAction mountAction) {
    this.mountAction = mountAction;
  }

  public String getRootPath() {
    return rootPath;
  }

  public void setRootPath(String rootPath) {
    this.rootPath = rootPath;
  }

  public MountCommand withMountPoint(MountPoint mountPoint) {
    this.mountPoint = mountPoint;
    return this;
  }

  public MountCommand withMountAction(MountAction mountAction) {
    this.mountAction = mountAction;
    return this;
  }

  public MountCommand withRootPath(final String rootPath) {
    this.rootPath = rootPath;
    return this;
  }

  //  @Override
  //  public boolean equals(Object o) {
  //    if (this == o) return true;
  //    if (o == null || getClass() != o.getClass()) return false;
  //    MountCommand that = (MountCommand) o;
  //    return Objects.equals(rootPath, that.rootPath)
  //        && Objects.equals(mountPoint, that.mountPoint)
  //        && mountAction == that.mountAction;
  //  }
  //
  //  @Override
  //  public int hashCode() {
  //
  //    return Objects.hash(rootPath, mountPoint, mountAction);
  //  }
}
