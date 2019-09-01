package com.walterjwhite.modules.shell.guice.query;

import com.walterjwhite.infrastructure.datastore.modules.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.shell.api.enumeration.Protocol;
import com.walterjwhite.shell.api.model.BindAddress;
import com.walterjwhite.shell.api.model.BindAddress_;
import com.walterjwhite.shell.api.model.IPAddress;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

public class FindBindAddressByIPAddressPortAndProtocolQueryBuilder {
  private static Predicate buildPredicate(
      CriteriaBuilder criteriaBuilder,
      CriteriaQueryConfiguration<BindAddress, BindAddress> criteriaQueryConfiguration,
      IPAddress ipAddress,
      int port,
      Protocol protocol) {
    Predicate ipAddressPredicate =
        criteriaBuilder.equal(
            criteriaQueryConfiguration.getRoot().get(BindAddress_.ipAddress), ipAddress);
    Predicate portPredicate =
        criteriaBuilder.equal(criteriaQueryConfiguration.getRoot().get(BindAddress_.port), port);
    Predicate protocolPredicate =
        criteriaBuilder.equal(
            criteriaQueryConfiguration.getRoot().get(BindAddress_.protocol), protocol);

    return criteriaBuilder.and(ipAddressPredicate, portPredicate, protocolPredicate);
  }
}
