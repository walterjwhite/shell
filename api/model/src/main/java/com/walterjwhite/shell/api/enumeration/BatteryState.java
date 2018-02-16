package com.walterjwhite.shell.api.enumeration;

public enum BatteryState {
  FullyCharged("fully-charged"),
  Charging("charging"),
  Discharging("discharging"),
  None("no battery");

  private final String upowerString;

  BatteryState(String upowerString) {
    this.upowerString = upowerString;
  }

  public static BatteryState getFromUpowerString(final String upowerString) {
    for (BatteryState batteryState : values()) {
      if (batteryState.upowerString.equals(upowerString)) {
        return (batteryState);
      }
    }

    return (None);
  }
}
