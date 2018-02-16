package com.walterjwhite.shell.api.model.ping;

import java.util.Objects;

public class PingResult {

  public static void main(final String[] arguments) {
    System.out.println(
        71 * 3 + Objects.hashCode("discovercard.com") * 31 + "discovercard.com".hashCode());
  }
}
