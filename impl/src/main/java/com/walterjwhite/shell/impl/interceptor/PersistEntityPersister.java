package com.walterjwhite.shell.impl.interceptor;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.datastore.api.repository.Repository;

public class PersistEntityPersister extends AbstractEntityPersister {
  public PersistEntityPersister(Repository repository) {
    super(repository);
  }

  @Override
  protected AbstractEntity doSave(AbstractEntity entity) {
    repository.create(entity);

    return entity;
  }
}
