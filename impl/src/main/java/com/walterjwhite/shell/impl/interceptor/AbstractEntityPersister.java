package com.walterjwhite.shell.impl.interceptor;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.datastore.api.repository.Repository;
import javax.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public abstract class AbstractEntityPersister {
  protected final Repository repository;
  // protected final EntityTransaction entityTransaction;

  // TODO: use JTA
  @Transactional
  public AbstractEntity save(AbstractEntity entity) {
    try {
      // entityTransaction.begin();

      entity = doSave(entity);
      // entityManager.close();
      // entityTransaction.commit();
      return entity;
    } catch (Exception e) {
      // entityTransaction.rollback();
      throw (e);
    }
  }

  protected abstract AbstractEntity doSave(AbstractEntity entity);
}
