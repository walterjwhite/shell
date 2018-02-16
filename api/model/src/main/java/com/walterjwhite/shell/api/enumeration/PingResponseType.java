package com.walterjwhite.shell.api.enumeration;

public enum PingResponseType {
  NoResponse(1),
  UnknownHost(2),
  UnreachableNetwork(255),
  Other(-1),
  Good(0);

  private final int returnCode;

  PingResponseType(int returnCode) {
    this.returnCode = returnCode;
  }

  public int getReturnCode() {
    return returnCode;
  }
}
