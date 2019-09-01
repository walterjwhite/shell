package com.walterjwhite.shell.impl.property;

import com.walterjwhite.property.api.annotation.DefaultValue;
import com.walterjwhite.property.api.property.ConfigurableProperty;

public interface ServiceTimeout extends ConfigurableProperty {
  @DefaultValue int Default = 5;
}
