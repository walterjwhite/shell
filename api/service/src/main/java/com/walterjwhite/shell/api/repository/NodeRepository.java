package com.walterjwhite.shell.api.repository;

import com.walterjwhite.datastore.criteria.AbstractRepository;
import com.walterjwhite.datastore.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.shell.api.model.Node;
import com.walterjwhite.shell.api.model.Node_;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

public class NodeRepository extends AbstractRepository<Node> {

  @Inject
  public NodeRepository(EntityManager entityManager, CriteriaBuilder criteriaBuilder) {
    super(entityManager, criteriaBuilder, Node.class);
  }

  public Node findByUuid(final String uuid) {
    final CriteriaQueryConfiguration<Node> serviceCriteriaQueryConfiguration = getCriteriaQuery();

    Predicate condition =
        criteriaBuilder.equal(serviceCriteriaQueryConfiguration.getRoot().get(Node_.uuid), uuid);
    serviceCriteriaQueryConfiguration.getCriteriaQuery().where(condition);

    return (entityManager
        .createQuery(serviceCriteriaQueryConfiguration.getCriteriaQuery())
        .getSingleResult());
  }
}
