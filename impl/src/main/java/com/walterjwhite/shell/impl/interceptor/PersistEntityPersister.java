package com.walterjwhite.shell.impl.interceptor;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.EntityManager;

public class PersistEntityPersister extends AbstractEntityPersister {
  public PersistEntityPersister(EntityManager entityManager) {
    super(entityManager);
  }

  @Override
  protected AbstractEntity doSave(AbstractEntity entity) {
    entityManager.persist(entity);

    return entity;
  }
}
