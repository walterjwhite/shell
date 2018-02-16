package com.walterjwhite.shell.impl.interceptor;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;

public abstract class AbstractEntityPersister {
  protected final EntityManager entityManager;
  protected final EntityTransaction entityTransaction;

  public AbstractEntityPersister(EntityManager entityManager) {
    this.entityManager = entityManager;
    this.entityTransaction = entityManager.getTransaction();
  }

  public AbstractEntity save(AbstractEntity entity) {
    try {
      entityTransaction.begin();

      entity = doSave(entity);
      // entityManager.close();
      entityTransaction.commit();
      return entity;
    } catch (Exception e) {
      entityTransaction.rollback();
      throw (e);
    }
  }

  protected abstract AbstractEntity doSave(AbstractEntity entity);
}
