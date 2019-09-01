package com.walterjwhite.shell.impl.service;

import com.walterjwhite.datastore.GoogleGuicePersistModule;
import com.walterjwhite.datastore.api.repository.CriteriaBuilderModule;
import com.walterjwhite.google.guice.property.test.GuiceTestModule;
import com.walterjwhite.google.guice.property.test.PropertyValuePair;
import com.walterjwhite.shell.impl.ShellModule;
import org.reflections.Reflections;

public class ShellTestModule extends GuiceTestModule {
  public ShellTestModule(Class testClass, PropertyValuePair... propertyValuePairs) {
    super(testClass, propertyValuePairs);
  }

  public ShellTestModule(
      Class testClass, Reflections reflections, PropertyValuePair... propertyValuePairs) {
    super(testClass, reflections, propertyValuePairs);
  }

  @Override
  protected void configure() {
    super.configure();

    install(new CriteriaBuilderModule());
    install(new GoogleGuicePersistModule(/*propertyManager, reflections*/ ));

    install(new ShellModule());
  }
}
