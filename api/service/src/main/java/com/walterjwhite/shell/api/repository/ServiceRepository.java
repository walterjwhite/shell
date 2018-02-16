package com.walterjwhite.shell.api.repository;

import com.google.inject.persist.Transactional;
import com.walterjwhite.datastore.criteria.AbstractRepository;
import com.walterjwhite.datastore.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.shell.api.model.Service;
import com.walterjwhite.shell.api.model.Service_;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

public class ServiceRepository extends AbstractRepository<Service> {

  @Inject
  public ServiceRepository(EntityManager entityManager, CriteriaBuilder criteriaBuilder) {
    super(entityManager, criteriaBuilder, Service.class);
  }

  public Service findByName(final String name) {
    final CriteriaQueryConfiguration<Service> serviceCriteriaQueryConfiguration =
        getCriteriaQuery();

    Predicate condition =
        criteriaBuilder.equal(serviceCriteriaQueryConfiguration.getRoot().get(Service_.name), name);
    serviceCriteriaQueryConfiguration.getCriteriaQuery().where(condition);

    return (entityManager
        .createQuery(serviceCriteriaQueryConfiguration.getCriteriaQuery())
        .getSingleResult());
  }

  @Transactional
  public Service findByNameOrCreate(final String name) {
    try {
      return findByName(name);
    } catch (NoResultException e) {
      final Service service = new Service(name);
      entityManager.persist(service);
      return service;
    }
  }
}
