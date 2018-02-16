package com.walterjwhite.shell.impl.collector;

import com.google.common.eventbus.EventBus;
import com.walterjwhite.shell.api.service.OutputCollector;

public class EventBusOutputCollector implements OutputCollector {
  protected final EventBus eventBus;

  public EventBusOutputCollector(EventBus eventBus) {
    super();
    this.eventBus = eventBus;
  }

  @Override
  public void onData(String line, boolean isError) {
    eventBus.post(line);
  }
}
