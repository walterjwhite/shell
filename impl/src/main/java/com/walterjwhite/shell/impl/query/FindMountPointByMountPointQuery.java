package com.walterjwhite.shell.impl.query;

import com.walterjwhite.datastore.query.AbstractSingularQuery;
import com.walterjwhite.shell.api.model.MountPoint;
import lombok.Getter;

@Getter
public class FindMountPointByMountPointQuery extends AbstractSingularQuery<MountPoint> {
  protected final MountPoint mountPoint;

  public FindMountPointByMountPointQuery(MountPoint mountPoint) {
    super(MountPoint.class, true);
    this.mountPoint = mountPoint;
  }
}
