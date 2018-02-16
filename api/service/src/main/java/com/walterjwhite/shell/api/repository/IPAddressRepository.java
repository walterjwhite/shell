package com.walterjwhite.shell.api.repository;

import com.walterjwhite.datastore.criteria.AbstractRepository;
import com.walterjwhite.datastore.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.shell.api.model.IPAddress;
import com.walterjwhite.shell.api.model.IPAddress_;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

public class IPAddressRepository extends AbstractRepository<IPAddress> {

  @Inject
  public IPAddressRepository(EntityManager entityManager, CriteriaBuilder criteriaBuilder) {
    super(entityManager, criteriaBuilder, IPAddress.class);
  }

  public IPAddress findByAddress(final String address) {
    final CriteriaQueryConfiguration<IPAddress> ipAddressCriteriaQueryConfiguration =
        getCriteriaQuery();

    Predicate condition =
        criteriaBuilder.equal(
            ipAddressCriteriaQueryConfiguration.getRoot().get(IPAddress_.address), address);
    ipAddressCriteriaQueryConfiguration.getCriteriaQuery().where(condition);

    return (entityManager
        .createQuery(ipAddressCriteriaQueryConfiguration.getCriteriaQuery())
        .getSingleResult());
  }

  public IPAddress findByAddressOrCreate(final String address) {
    try {
      return (findByAddress(address));
    } catch (NoResultException e) {
      IPAddress ipAddress = new IPAddress(address);
      entityManager.persist(ipAddress);
      return (ipAddress);
    }
  }
}
