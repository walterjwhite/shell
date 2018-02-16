package com.walterjwhite.shell.api.enumeration;

import com.walterjwhite.shell.api.model.MountPoint;
import java.util.ArrayList;
import java.util.List;

public enum VFSType {
  BIND(null, null) {

    @Override
    protected void addArguments(
        final MountPoint mountPoint, final String device, final List<List<String>> arguments) {
      final List<String> commandArguments = new ArrayList<>();

      commandArguments.add("-o");
      commandArguments.add("bind");
      commandArguments.add(device);

      arguments.add(commandArguments);
    }
  },
  RBIND(null, null) {

    @Override
    protected void addArguments(
        MountPoint mountPoint, final String device, List<List<String>> arguments) {
      final List<String> rbind = new ArrayList<>();

      rbind.add("--rbind");
      rbind.add(device);

      arguments.add(rbind);

      final List<String> rslave = new ArrayList<>();
      rslave.add("--make-rslave");
      arguments.add(rslave);
    }
  },
  _GENERIC_BLOCK(null, null) {

    @Override
    protected void addArguments(
        MountPoint mountPoint, final String device, List<List<String>> arguments) {
      final List<String> commandArguments = new ArrayList<>();

      if (mountPoint.getVfsType().getType() != null) {
        commandArguments.add("-t");
        commandArguments.add(mountPoint.getVfsType().getType());
      }

      commandArguments.add(device);

      if (mountPoint.getOptions() != null && !mountPoint.getOptions().isEmpty()) {
        commandArguments.add("-o");
        commandArguments.add(mountPoint.getOptions());
      }

      arguments.add(commandArguments);
    }
  },
  // while these values may not be used directly in code, keep in mind they may be used later for
  // the FstabModule
  DEVPTS("devpts", RBIND),
  EXT4("ext4", _GENERIC_BLOCK),
  PROC("proc", _GENERIC_BLOCK),

  SYSFS("sysfs", RBIND),
  TMPFS("tmpfs", _GENERIC_BLOCK),
  SWAP("swap", _GENERIC_BLOCK),
  AUTO(null, _GENERIC_BLOCK);

  private final String type;
  private final VFSType parent;

  VFSType(String type, VFSType parent) {
    this.type = type;
    this.parent = parent;
  }

  public String getType() {
    return type;
  }

  public VFSType getParent() {
    return parent;
  }

  protected void addArguments(
      final MountPoint mountPoint, final String device, List<List<String>> arguments) {}

  public List<List<String>> getArguments(
      MountPoint mountPoint, final String device, String rootPath) {
    final List<List<String>> arguments = new ArrayList<>();

    addArguments(mountPoint, device, arguments);
    if (parent != null) {
      parent.addArguments(mountPoint, device, arguments);
    }

    wrapArguments(mountPoint, rootPath, arguments);

    return (arguments);
  }

  protected void wrapArguments(
      MountPoint mountPoint, String rootPath, final List<List<String>> arguments) {
    for (final List<String> commandArguments : arguments) {
      commandArguments.add(0, "mount");
      commandArguments.add(rootPath + mountPoint.getMountPoint());
    }
  }
}
