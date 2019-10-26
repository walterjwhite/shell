package com.walterjwhite.shell.impl.collector;

import com.walterjwhite.shell.api.service.OutputCollector;
import java.io.IOException;

public class AppendableOutputCollector implements OutputCollector {
  protected final Appendable appendable;

  public AppendableOutputCollector(Appendable appendable) {
    super();
    this.appendable = appendable;
  }

  @Override
  public void onData(String line, boolean isError) {
    try {
      appendable.append(line);
    } catch (IOException e) {
      throw new RuntimeException("Error appending line:", e);
    }
  }
}
