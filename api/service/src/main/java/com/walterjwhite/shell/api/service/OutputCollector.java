package com.walterjwhite.shell.api.service;

/** Collects output from running a command (stdout, stderr). */
public interface OutputCollector {
  void onData(final String line, final boolean isError);
}
