package com.walterjwhite.shell.impl.property;

import com.walterjwhite.property.api.annotation.DefaultValue;
import com.walterjwhite.property.api.property.ConfigurableProperty;
import java.time.temporal.ChronoUnit;

public interface InterruptGracePeriodUnits extends ConfigurableProperty {
  @DefaultValue ChronoUnit Default = ChronoUnit.SECONDS;
}
