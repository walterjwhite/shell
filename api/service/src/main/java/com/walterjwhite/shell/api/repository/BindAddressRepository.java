package com.walterjwhite.shell.api.repository;

import com.walterjwhite.datastore.criteria.AbstractRepository;
import com.walterjwhite.datastore.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.shell.api.enumeration.Protocol;
import com.walterjwhite.shell.api.model.BindAddress;
import com.walterjwhite.shell.api.model.BindAddress_;
import com.walterjwhite.shell.api.model.IPAddress;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

public class BindAddressRepository extends AbstractRepository<BindAddress> {

  @Inject
  public BindAddressRepository(EntityManager entityManager, CriteriaBuilder criteriaBuilder) {
    super(entityManager, criteriaBuilder, BindAddress.class);
  }

  public BindAddress findByIPAddressPortAndProtocolOrCreate(
      final IPAddress ipAddress, final int port, final Protocol protocol) {
    try {
      final CriteriaQueryConfiguration<BindAddress> bindAddressCriteriaConfiguration =
          getCriteriaQuery();

      Predicate ipAddressPredicate =
          criteriaBuilder.equal(
              bindAddressCriteriaConfiguration.getRoot().get(BindAddress_.ipAddress), ipAddress);
      Predicate portPredicate =
          criteriaBuilder.equal(
              bindAddressCriteriaConfiguration.getRoot().get(BindAddress_.port), port);
      Predicate protocolPredicate =
          criteriaBuilder.equal(
              bindAddressCriteriaConfiguration.getRoot().get(BindAddress_.protocol), protocol);

      Predicate where = criteriaBuilder.and(ipAddressPredicate, portPredicate, protocolPredicate);
      bindAddressCriteriaConfiguration.getCriteriaQuery().where(where);

      return (entityManager
          .createQuery(bindAddressCriteriaConfiguration.getCriteriaQuery())
          .getSingleResult());
    } catch (NoResultException e) {
      return (merge(new BindAddress(Protocol.TCP4, Integer.valueOf(port), ipAddress)));
    }
  }
}
