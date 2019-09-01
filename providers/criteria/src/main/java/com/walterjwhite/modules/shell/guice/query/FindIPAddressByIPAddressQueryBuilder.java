package com.walterjwhite.modules.shell.guice.query;

import com.walterjwhite.infrastructure.datastore.modules.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.shell.api.model.IPAddress;
import com.walterjwhite.shell.api.model.IPAddress_;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

public class FindIPAddressByIPAddressQueryBuilder {
  private static Predicate buildPredicate(
      CriteriaBuilder criteriaBuilder,
      CriteriaQueryConfiguration<IPAddress, IPAddress> criteriaQueryConfiguration,
      String address) {
    return criteriaBuilder.equal(
        criteriaQueryConfiguration.getRoot().get(IPAddress_.address), address);
  }
}
