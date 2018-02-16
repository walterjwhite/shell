package com.walterjwhite.shell.api.repository;

import com.google.inject.persist.Transactional;
import com.walterjwhite.datastore.criteria.AbstractRepository;
import com.walterjwhite.datastore.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.shell.api.model.MountPoint;
import com.walterjwhite.shell.api.model.MountPoint_;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

public class MountPointRepository extends AbstractRepository<MountPoint> {

  @Inject
  public MountPointRepository(EntityManager entityManager, CriteriaBuilder criteriaBuilder) {
    super(entityManager, criteriaBuilder, MountPoint.class);
  }

  @Transactional
  public MountPoint findByMountPointOrCreate(final MountPoint mountPoint) {
    final CriteriaQueryConfiguration<MountPoint> serviceCriteriaQueryConfiguration =
        getCriteriaQuery();

    Predicate condition =
        criteriaBuilder.equal(
            serviceCriteriaQueryConfiguration.getRoot().get(MountPoint_.mountPoint),
            mountPoint.getMountPoint());
    serviceCriteriaQueryConfiguration.getCriteriaQuery().where(condition);

    try {
      return (entityManager
          .createQuery(serviceCriteriaQueryConfiguration.getCriteriaQuery())
          .getSingleResult());
    } catch (NoResultException e) {
      entityManager.persist(mountPoint);
      return mountPoint;
    }
  }
}
