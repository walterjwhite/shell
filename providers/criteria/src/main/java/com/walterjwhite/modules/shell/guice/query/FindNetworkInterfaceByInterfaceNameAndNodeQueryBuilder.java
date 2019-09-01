package com.walterjwhite.modules.shell.guice.query;

import com.walterjwhite.infrastructure.datastore.modules.criteria.CriteriaQueryConfiguration;
import com.walterjwhite.shell.api.model.NetworkInterface;
import com.walterjwhite.shell.api.model.NetworkInterface_;
import com.walterjwhite.shell.api.model.Node;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;

public class FindNetworkInterfaceByInterfaceNameAndNodeQueryBuilder {
  private static Predicate buildPredicate(
      CriteriaBuilder criteriaBuilder,
      CriteriaQueryConfiguration<NetworkInterface, NetworkInterface> criteriaQueryConfiguration,
      String interfaceName,
      final Node node) {
    Predicate interfaceNamePredicate =
        criteriaBuilder.equal(
            criteriaQueryConfiguration.getRoot().get(NetworkInterface_.interfaceName),
            interfaceName);

    Predicate nodePredicate =
        criteriaBuilder.equal(
            criteriaQueryConfiguration.getRoot().get(NetworkInterface_.node), node);

    return criteriaBuilder.and(interfaceNamePredicate, nodePredicate);
  }
}
