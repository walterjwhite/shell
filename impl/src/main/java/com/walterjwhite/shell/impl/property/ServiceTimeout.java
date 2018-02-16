package com.walterjwhite.shell.impl.property;

import com.walterjwhite.google.guice.property.property.DefaultValue;
import com.walterjwhite.google.guice.property.property.GuiceProperty;

public interface ServiceTimeout extends GuiceProperty {
  @DefaultValue int Default = 5;
}
