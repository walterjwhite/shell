package com.walterjwhite.modules.shell.guice;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import com.walterjwhite.datastore.api.repository.Repository;
import com.walterjwhite.shell.impl.interceptor.MergeEntityPersister;
import com.walterjwhite.shell.impl.interceptor.PersistEntityPersister;
import javax.inject.Provider;
import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;

// TODO: while this works with Guice, it does not easily translate to others
// use aspectj here
public class EntityInterceptor implements MethodInterceptor {
  protected final Provider<Repository> repositoryProvider;

  public EntityInterceptor(Provider<Repository> repositoryProvider) {
    this.repositoryProvider = repositoryProvider;
  }

  @Override
  public Object invoke(MethodInvocation methodInvocation) throws Throwable {
    new PersistEntityPersister(repositoryProvider.get())
        .save((AbstractEntity) methodInvocation.getArguments()[0]);

    final Object result = methodInvocation.proceed();
    return new MergeEntityPersister(repositoryProvider.get()).save((AbstractEntity) result);
  }
}
