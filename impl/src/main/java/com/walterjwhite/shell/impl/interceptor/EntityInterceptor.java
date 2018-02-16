package com.walterjwhite.shell.impl.interceptor;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.inject.Provider;
import javax.persistence.EntityManager;
import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;

public class EntityInterceptor implements MethodInterceptor {
  protected final Provider<EntityManager> entityManagerProvider;

  public EntityInterceptor(Provider<EntityManager> entityManagerProvider) {
    this.entityManagerProvider = entityManagerProvider;
  }

  @Override
  public Object invoke(MethodInvocation methodInvocation) throws Throwable {
    new PersistEntityPersister(entityManagerProvider.get())
        .save((AbstractEntity) methodInvocation.getArguments()[0]);

    final Object result = methodInvocation.proceed();
    return new MergeEntityPersister(entityManagerProvider.get()).save((AbstractEntity) result);
  }
}
