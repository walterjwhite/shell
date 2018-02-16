package com.walterjwhite.shell.api.repository;

import com.walterjwhite.datastore.criteria.AbstractRepository;
import com.walterjwhite.shell.api.model.ShellCommand;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.criteria.CriteriaBuilder;

public class ShellCommandRepository extends AbstractRepository<ShellCommand> {

  @Inject
  public ShellCommandRepository(EntityManager entityManager, CriteriaBuilder criteriaBuilder) {
    super(entityManager, criteriaBuilder, ShellCommand.class);
  }
}
