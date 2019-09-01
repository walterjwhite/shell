package com.walterjwhite.shell.impl.interceptor;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.datastore.api.repository.Repository;

public class MergeEntityPersister extends AbstractEntityPersister {
  public MergeEntityPersister(Repository repository) {
    super(repository);
  }

  @Override
  protected AbstractEntity doSave(AbstractEntity entity) {
    return repository.create(
        entity); // in JPA, this must be merge, otherwise, the operation will fail.
  }
}
