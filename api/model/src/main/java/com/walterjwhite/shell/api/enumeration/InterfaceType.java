package com.walterjwhite.shell.api.enumeration;

public enum InterfaceType {
  Ethernet("ethernet"),
  Wireless("wifi");

  private String nmcliType;

  InterfaceType(String nmcliType) {
    this.nmcliType = nmcliType;
  }

  public String getNmcliType() {
    return nmcliType;
  }

  public static InterfaceType getByNMCLIType(final String nmcliType) {
    for (InterfaceType interfaceType : values()) {
      if (interfaceType.nmcliType.equals(nmcliType)) {
        return (interfaceType);
      }
    }

    throw new IllegalArgumentException(nmcliType + " was not found / mapped.");
  }
}
