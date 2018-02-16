package com.walterjwhite.shell.api.repository;

import com.google.inject.persist.Transactional;
import com.walterjwhite.datastore.criteria.AbstractRepository;
import com.walterjwhite.datastore.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.shell.api.model.NetworkInterface;
import com.walterjwhite.shell.api.model.NetworkInterface_;
import com.walterjwhite.shell.api.model.Node;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

public class NetworkInterfaceRepository extends AbstractRepository<NetworkInterface> {

  @Inject
  public NetworkInterfaceRepository(EntityManager entityManager, CriteriaBuilder criteriaBuilder) {
    super(entityManager, criteriaBuilder, NetworkInterface.class);
  }

  public NetworkInterface findByNameAndNodeOrCreate(final String interfaceName, Node node) {
    try {
      return (findByNameAndNode(interfaceName, node));
    } catch (NoResultException e) {
      return (create(interfaceName, node));
    }
  }

  protected NetworkInterface findByNameAndNode(final String interfaceName, Node node) {
    final CriteriaQueryConfiguration<NetworkInterface> serviceCriteriaQueryConfiguration =
        getCriteriaQuery();

    Predicate condition =
        criteriaBuilder.equal(
            serviceCriteriaQueryConfiguration.getRoot().get(NetworkInterface_.interfaceName),
            interfaceName);
    Predicate condition2 =
        criteriaBuilder.equal(
            serviceCriteriaQueryConfiguration.getRoot().get(NetworkInterface_.node), node);

    serviceCriteriaQueryConfiguration.getCriteriaQuery().where(condition, condition2);

    return (entityManager
        .createQuery(serviceCriteriaQueryConfiguration.getCriteriaQuery())
        .getSingleResult());
  }

  @Transactional
  protected NetworkInterface create(final String interfaceName, Node node) {
    NetworkInterface networkInterface = new NetworkInterface(node, interfaceName);
    return (persist(networkInterface));
  }
}
