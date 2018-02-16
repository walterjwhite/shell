package com.walterjwhite.shell.api.model;

// import com.walterjwhite.linux.builder.api.model.configuration.Configurable;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.VFSType;
import java.util.Objects;
import javax.persistence.*;

@Entity
public class MountPoint /* implements Configurable*/ extends AbstractEntity {
  @Column(nullable = false, updatable = false)
  protected String mountPoint;

  @Column protected String device;

  @Column
  @Enumerated(EnumType.STRING)
  protected VFSType vfsType;
  // protected String vfsType;

  @Column protected String options;

  public MountPoint(String mountPoint, String device, VFSType vfsType) {
    this(mountPoint, device, vfsType, "");
  }

  public MountPoint(String mountPoint, String device, VFSType vfsType, String options) {
    this();

    this.mountPoint = mountPoint;
    this.device = device;
    this.vfsType = vfsType;
    this.options = options;
  }

  public MountPoint() {
    super();
  }

  public String getMountPoint() {
    return mountPoint;
  }

  public void setMountPoint(String mountPoint) {
    this.mountPoint = mountPoint;
  }

  public String getDevice() {
    return device;
  }

  public void setDevice(String device) {
    this.device = device;
  }

  public VFSType getVfsType() {
    return vfsType;
  }

  public void setVfsType(VFSType vfsType) {
    this.vfsType = vfsType;
  }

  public String getOptions() {
    return options;
  }

  public void setOptions(String options) {
    this.options = options;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    MountPoint that = (MountPoint) o;
    return Objects.equals(mountPoint, that.mountPoint);
  }

  @Override
  public int hashCode() {

    return Objects.hash(mountPoint);
  }

  @Override
  public String toString() {
    return "MountPoint{"
        + "mountPoint='"
        + mountPoint
        + '\''
        + ", device='"
        + device
        + '\''
        + ", vfsType="
        + vfsType
        + ", options='"
        + options
        + '\''
        + '}';
  }
}
