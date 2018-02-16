package com.walterjwhite.shell.api.model;

import javax.persistence.*;

@Entity
public class ChrootShellCommand extends ShellCommand implements Chrootable {
  @Column protected String chrootPath;

  public ChrootShellCommand() {
    super();
  }

  @Override
  public String getChrootPath() {
    return chrootPath;
  }

  @Override
  public void setChrootPath(String chrootPath) {
    this.chrootPath = chrootPath;
  }

  public ChrootShellCommand withChrootPath(final String chrootPath) {
    this.chrootPath = chrootPath;
    return this;
  }

  @Override
  public String toString() {
    return getClass().getName() + "{" + "chrootPath='" + chrootPath + '\'' + super.toString() + '}';
  }
}
