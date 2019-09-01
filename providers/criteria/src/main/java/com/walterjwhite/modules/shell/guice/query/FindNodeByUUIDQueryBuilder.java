package com.walterjwhite.modules.shell.guice.query;

import com.walterjwhite.datastore.api.annotation.Supports;
import com.walterjwhite.infrastructure.datastore.modules.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.infrastructure.datastore.modules.criteria.query.JpaCriteriaQueryBuilder;
import com.walterjwhite.shell.api.model.Node;
import com.walterjwhite.shell.api.model.Node_;
import com.walterjwhite.shell.impl.query.FindNodeByUUIDQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

@Supports(FindNodeByUUIDQuery.class)
public class FindNodeByUUIDQueryBuilder
    extends JpaCriteriaQueryBuilder<Node, Node, FindNodeByUUIDQuery> {
  protected Predicate buildPredicate(
      CriteriaBuilder criteriaBuilder,
      CriteriaQueryConfiguration<Node, Node> criteriaQueryConfiguration,
      FindNodeByUUIDQuery findNodeByUUIDQuery) {
    return criteriaBuilder.equal(
        criteriaQueryConfiguration.getRoot().get(Node_.uuid), findNodeByUUIDQuery.getUuid());
  }
}
