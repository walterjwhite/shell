package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractUUIDEntity;
import com.walterjwhite.shell.api.enumeration.MountAction;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.*;
import lombok.*;

@ToString(doNotUseGetters = true) // (callSuper = true)
@Getter
@Setter
// @PersistenceCapable
@Entity
public class MountCommand extends AbstractUUIDEntity implements MultipleShellCommandable {

  @Column(nullable = false, updatable = false)
  protected String rootPath;

  @ManyToOne(optional = false, cascade = CascadeType.ALL)
  @JoinColumn(nullable = false, updatable = false)
  protected MountPoint mountPoint;

  @ToString.Exclude
  @OneToMany(mappedBy = "mountCommand", cascade = CascadeType.ALL)
  protected List<MountCommandShellCommand> shellCommands = new ArrayList<>();

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  protected MountAction mountAction;

  @Column(nullable = false, updatable = false)
  protected int timeout;

  public void addShellCommand(ShellCommand shellCommand) {
    shellCommands.add(
        new MountCommandShellCommand().withShellCommand(shellCommand).withMountCommand(this));
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
}
