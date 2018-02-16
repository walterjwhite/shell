package com.walterjwhite.shell.impl.collector;

import com.google.common.collect.ImmutableSet;
import com.walterjwhite.shell.api.service.OutputCollector;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class InputConsumable implements Runnable {
  private static final Logger LOGGER = LoggerFactory.getLogger(InputConsumable.class);

  protected final InputStream inputStream;
  protected final boolean isError;
  protected final ImmutableSet<OutputCollector> outputCollectors;

  public InputConsumable(InputStream inputStream, final OutputCollector... outputCollectors) {
    this(inputStream, false, outputCollectors);
  }

  public InputConsumable(
      InputStream inputStream, final boolean isError, final OutputCollector... outputCollectors) {
    super();
    this.inputStream = inputStream;
    this.isError = isError;

    this.outputCollectors = ImmutableSet.copyOf(outputCollectors);
  }

  @Override
  public void run() {
    new BufferedReader(new InputStreamReader(inputStream))
        .lines()
        .forEach(lineRead -> consumeOutput(lineRead));
  }

  // TODO: parallelize this
  // TODO: persist the updated data (shell command / output)
  protected void consumeOutput(final String line) {
    outputCollectors.forEach(outputCollector -> outputCollector.onData(line, isError));
  }
}
