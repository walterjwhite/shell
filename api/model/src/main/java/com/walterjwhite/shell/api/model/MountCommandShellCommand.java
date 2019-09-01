package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import lombok.Data;
import lombok.ToString;

@Data
@ToString(doNotUseGetters = true)
// @PersistenceCapable
@Entity
public class MountCommandShellCommand extends AbstractEntity {
  @ManyToOne @JoinColumn protected MountCommand mountCommand;

  @ManyToOne @JoinColumn protected ShellCommand shellCommand;

  public MountCommandShellCommand withShellCommand(ShellCommand shellCommand) {
    this.shellCommand = shellCommand;
    return this;
  }

  public MountCommandShellCommand withMountCommand(MountCommand mountCommand) {
    this.mountCommand = mountCommand;
    return this;
  }
}
