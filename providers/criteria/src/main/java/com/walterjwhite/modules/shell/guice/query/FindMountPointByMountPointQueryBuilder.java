package com.walterjwhite.modules.shell.guice.query;

import com.walterjwhite.datastore.api.annotation.Supports;
import com.walterjwhite.infrastructure.datastore.modules.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.infrastructure.datastore.modules.criteria.query.JpaCriteriaQueryBuilder;
import com.walterjwhite.shell.api.model.MountPoint;
import com.walterjwhite.shell.api.model.MountPoint_;
import com.walterjwhite.shell.impl.query.FindMountPointByMountPointQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

@Supports(FindMountPointByMountPointQuery.class)
public class FindMountPointByMountPointQueryBuilder
    extends JpaCriteriaQueryBuilder<MountPoint, MountPoint, FindMountPointByMountPointQuery> {

  @Override
  protected Predicate buildPredicate(
      CriteriaBuilder criteriaBuilder,
      CriteriaQueryConfiguration<MountPoint, MountPoint> criteriaQueryConfiguration,
      FindMountPointByMountPointQuery findMountPointByMountPointQuery) {
    return criteriaBuilder.equal(
        criteriaQueryConfiguration.getRoot().get(MountPoint_.mountPoint),
        findMountPointByMountPointQuery.getMountPoint().getMountPoint());
  }
}
