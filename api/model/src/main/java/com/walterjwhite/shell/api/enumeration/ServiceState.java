package com.walterjwhite.shell.api.enumeration;

public enum ServiceState {
  Started(0),
  DoesNotExist(1),
  Stopped(3),
  Crashed(32);

  private final int returnValue;

  ServiceState(int returnValue) {
    this.returnValue = returnValue;
  }

  public int getReturnValue() {
    return returnValue;
  }

  public static ServiceState getFromReturnValue(final int returnValue) {
    for (ServiceState serviceState : values()) {
      if (serviceState.returnValue == returnValue) {
        return (serviceState);
      }
    }

    throw (new IllegalArgumentException(Integer.toString(returnValue) + " was not found."));
  }
}
