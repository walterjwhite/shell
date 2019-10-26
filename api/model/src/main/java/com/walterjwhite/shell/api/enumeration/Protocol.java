package com.walterjwhite.shell.api.enumeration;

public enum Protocol {
  TCP4("tcp"),
  TCP6("tcp6"),
  UDP4("udp"),
  UDP6("udp6");

  private String netstatProtocol;

  Protocol(String netstatProtocol) {
    this.netstatProtocol = netstatProtocol;
  }

  public String getNetstatProtocol() {
    return netstatProtocol;
  }

  public static Protocol getFromNetstatProtocol(final String netstatProtocol) {
    for (final Protocol protocol : values()) {
      if (protocol.netstatProtocol.equals(netstatProtocol)) {
        return (protocol);
      }
    }

    throw new IllegalArgumentException(netstatProtocol + " was not found/mapped.");
  }
}
