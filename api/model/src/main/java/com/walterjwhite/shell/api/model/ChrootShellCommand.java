package com.walterjwhite.shell.api.model;

import javax.persistence.*;
import lombok.*;

// @EqualsAndHashCode(s)
// @ToString(doNotUseGetters=true,callSuper = true)
// @Data
@ToString(doNotUseGetters = true)
@Getter
@Setter
@NoArgsConstructor
@Entity
// @PersistenceCapable
public class ChrootShellCommand extends ShellCommand implements Chrootable {
  @Column protected String chrootPath;

  public ChrootShellCommand withChrootPath(final String chrootPath) {
    this.chrootPath = chrootPath;
    return this;
  }
}
