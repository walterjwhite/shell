package com.walterjwhite.modules.shell.guice.query;

import com.walterjwhite.infrastructure.datastore.modules.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.infrastructure.datastore.modules.criteria.query.JpaCriteriaQueryBuilder;
import com.walterjwhite.shell.api.model.Service;
import com.walterjwhite.shell.api.model.Service_;
import com.walterjwhite.shell.impl.query.FindServiceByNameQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

public class FindServiceByNameCriteriaQueryBuilder
    extends JpaCriteriaQueryBuilder<Service, Service, FindServiceByNameQuery> {

  @Override
  protected Predicate buildPredicate(
      CriteriaBuilder criteriaBuilder,
      CriteriaQueryConfiguration<Service, Service> criteriaQueryConfiguration,
      FindServiceByNameQuery findServiceByNameQuery) {
    return criteriaBuilder.equal(
        criteriaQueryConfiguration.getRoot().get(Service_.name), findServiceByNameQuery.getName());
  }
}
