package com.walterjwhite.shell.impl;

import com.walterjwhite.shell.api.service.OutputCollector;
import java.util.HashSet;
import java.util.Set;

public class OutputCollectorConfiguration {
  protected final Set<Class<? extends OutputCollector>> outputCollectorClasses = new HashSet<>();

  public Set<Class<? extends OutputCollector>> getOutputCollectorClasses() {
    return outputCollectorClasses;
  }
}
