package com.walterjwhite.shell.impl.interceptor;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.EntityManager;

public class MergeEntityPersister extends AbstractEntityPersister {
  public MergeEntityPersister(EntityManager entityManager) {
    super(entityManager);
  }

  @Override
  protected AbstractEntity doSave(AbstractEntity entity) {
    return entityManager.merge(entity);
  }
}
