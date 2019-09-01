package com.walterjwhite.shell.impl.service;

import com.walterjwhite.datastore.api.repository.Repository;
import com.walterjwhite.property.impl.annotation.Property;
import com.walterjwhite.shell.api.enumeration.MountAction;
import com.walterjwhite.shell.api.enumeration.VFSType;
import com.walterjwhite.shell.api.model.MountCommand;
import com.walterjwhite.shell.api.model.MountPoint;
import com.walterjwhite.shell.api.service.MountService;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.impl.property.MountTimeout;
import com.walterjwhite.shell.impl.query.FindMountPointByMountPointQuery;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.attribute.PosixFilePermission;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.inject.Inject;
import javax.inject.Provider;

public class DefaultMountService extends AbstractMultipleShellCommandService<MountCommand>
    implements MountService {
  protected final Provider<Repository> repositoryProvider;

  @Inject
  public DefaultMountService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      @Property(MountTimeout.class) int timeout,
      Provider<Repository> repositoryProvider) {
    super(shellCommandBuilder, shellExecutionService, timeout);
    this.repositoryProvider = repositoryProvider;
  }

  @Override
  protected void doBefore(MountCommand mountCommand) {
    super.doBefore(mountCommand);
    mountCommand.setTimeout(timeout);
    mountCommand.setMountPoint(
        repositoryProvider
            .get()
            .query(new FindMountPointByMountPointQuery(mountCommand.getMountPoint())));
  }

  //  protected Supplier<PersistenceOptionConfiguration> getCreateConfiguration(MountCommand
  // mountCommand){
  //    return () -> new PersistenceOptionConfiguration(
  //            PersistenceOption.Create, mountCommand.getMountPoint());
  //  }

  protected void doBeforeEach(MountCommand mountCommand) {

    if (MountAction.Mount.equals(mountCommand.getMountAction())) {
      prepareDevice(mountCommand.getMountPoint());
      prepareTarget(mountCommand.getMountPoint(), mountCommand.getRootPath());
    }
  }

  protected void prepareDevice(MountPoint mountPoint) {
    // do not create "device" mount points for psuedo filesystems that do not have an actual
    // underlying device
    // TODO: this SHOULD *NOT* be hard-coded
    if ("none".equals(mountPoint.getDevice())) return;

    final File deviceFile = new File(getDevice(mountPoint.getDevice()));
    if (!deviceFile.exists()) {
      deviceFile.mkdirs();
    }
  }

  protected void prepareTarget(final MountPoint mountPoint, final String rootPath) {
    final File mountPointFile = new File(rootPath + mountPoint.getMountPoint());

    if (!mountPointFile.exists()) {
      mountPointFile.mkdirs();
    }
  }

  @Override
  protected String[] getCommandLines(MountCommand mountCommand) {
    if (MountAction.Unmount.equals(mountCommand.getMountAction())) {
      if (VFSType.RBIND.equals(mountCommand.getMountPoint().getVfsType())) {
        return new String[] {
          "umount -R " + mountCommand.getRootPath() + mountCommand.getMountPoint().getMountPoint()
        };
      }

      return new String[] {
        "umount " + mountCommand.getRootPath() + mountCommand.getMountPoint().getMountPoint()
      };
    }

    if (MountAction.Mount.equals(mountCommand.getMountAction())) {

      final List<String> commandLines = new ArrayList<>();
      for (final List<String> arguments :
          mountCommand
              .getMountPoint()
              .getVfsType()
              .getArguments(
                  mountCommand.getMountPoint(),
                  getDevice(mountCommand.getMountPoint().getDevice()),
                  mountCommand.getRootPath())) {

        commandLines.add(String.join(" ", arguments.toArray(new String[arguments.size()])));
      }

      return commandLines.toArray(new String[commandLines.size()]);
    }

    throw (new IllegalArgumentException("Remounting is not currently supported."));
  }

  protected String getDevice(final String device) {
    if (System.getProperty("~/") != null && !System.getProperty("~/").isEmpty()) {
      return (device.replace("~/", System.getProperty("~/") + File.separator));
    }

    return (device);
  }

  @Override
  protected void doAfter(MountCommand mountCommand) {
    super.doAfter(mountCommand);

    ensureTmpfsIsGloballyReadableAndWritable(mountCommand);
  }

  protected void ensureTmpfsIsGloballyReadableAndWritable(MountCommand mountCommand) {
    // run this after mounting to ensure it is globally readable/writable
    if (VFSType.TMPFS.equals(mountCommand.getMountPoint().getVfsType())) {
      ensureTmpfsIsGloballyReadableAndWritableCli(mountCommand);
      ensureTmpfsIsGloballyReadableAndWritableNative(mountCommand);
    }
  }

  protected void ensureTmpfsIsGloballyReadableAndWritableNative(MountCommand mountCommand) {
    final Set<PosixFilePermission> permissions = new HashSet<>();
    permissions.add(PosixFilePermission.OWNER_READ);
    permissions.add(PosixFilePermission.OWNER_WRITE);
    permissions.add(PosixFilePermission.OWNER_EXECUTE);

    permissions.add(PosixFilePermission.GROUP_READ);
    permissions.add(PosixFilePermission.GROUP_WRITE);
    permissions.add(PosixFilePermission.GROUP_EXECUTE);

    permissions.add(PosixFilePermission.OTHERS_READ);
    permissions.add(PosixFilePermission.OTHERS_WRITE);
    permissions.add(PosixFilePermission.OTHERS_EXECUTE);
    try {
      Files.setPosixFilePermissions(
          new File(
                  mountCommand.getRootPath()
                      + File.separator
                      + mountCommand.getMountPoint().getMountPoint())
              .toPath(),
          permissions);
    } catch (IOException e) {
      throw (new RuntimeException("Error fixing permissions", e));
    }
  }

  protected void ensureTmpfsIsGloballyReadableAndWritableCli(MountCommand mountCommand) {
    //            commandLines.add(
    //                "chmod 1777 "
    //                    + mountCommand.getRootPath()
    //                    + File.separator
    //                    + mountCommand.getMountPoint().getMountPoint());
  }
}
