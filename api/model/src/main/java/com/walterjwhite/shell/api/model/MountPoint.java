package com.walterjwhite.shell.api.model;

// import com.walterjwhite.linux.builder.api.model.configuration.Configurable;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.shell.api.enumeration.VFSType;
import javax.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@ToString(doNotUseGetters = true)
@NoArgsConstructor
// @PersistenceCapable
@Entity
public class MountPoint /* implements Configurable*/ extends AbstractEntity {
  @Column(nullable = false, updatable = false)
  protected String mountPoint;

  @EqualsAndHashCode.Exclude @Column protected String device;

  @EqualsAndHashCode.Exclude
  @Column
  @Enumerated(EnumType.STRING)
  protected VFSType vfsType;
  // protected String vfsType;

  @EqualsAndHashCode.Exclude @Column protected String options;

  public MountPoint(String mountPoint, String device, VFSType vfsType) {
    this(mountPoint, device, vfsType, "");
  }
}
