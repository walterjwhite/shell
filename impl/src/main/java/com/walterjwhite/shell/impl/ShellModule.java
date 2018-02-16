package com.walterjwhite.shell.impl;

import static com.google.inject.matcher.Matchers.annotatedWith;
import static com.google.inject.matcher.Matchers.any;

import com.google.inject.AbstractModule;
import com.walterjwhite.shell.api.model.Node;
import com.walterjwhite.shell.api.repository.BindAddressRepository;
import com.walterjwhite.shell.api.repository.IPAddressRepository;
import com.walterjwhite.shell.api.repository.MountPointRepository;
import com.walterjwhite.shell.api.repository.ServiceRepository;
import com.walterjwhite.shell.api.service.*;
import com.walterjwhite.shell.api.service.unused.NetworkInterfaceService;
import com.walterjwhite.shell.impl.annotation.EntityEnabled;
import com.walterjwhite.shell.impl.interceptor.EntityInterceptor;
import com.walterjwhite.shell.impl.provider.NodeProvider;
import com.walterjwhite.shell.impl.service.*;
import com.walterjwhite.shell.impl.service.unused.DefaultNetworkInterfaceService;
import javax.persistence.EntityManager;

public class ShellModule extends AbstractModule {
  @Override
  protected void configure() {
    // TODO: interface this
    bind(ShellCommandBuilder.class);

    bind(DigService.class).to(DefaultDigService.class);
    bind(TracerouteService.class).to(DefaultTracerouteService.class);
    //
    // bind(NetworkManagerManagedNetworkInterfacesService.class).to(DefaultNetworkManagerManagedNetworkInterfacesService.class);
    bind(ShellExecutionService.class).to(DefaultShellExecution.class);
    bind(UpowerService.class).to(DefaultUpowerService.class);
    bind(SystemServiceService.class).to(UnixSystemServiceService.class);

    bind(PingService.class).to(DefaultPingService.class);
    bind(NetworkInterfaceService.class).to(DefaultNetworkInterfaceService.class);
    bind(Node.class).toProvider(NodeProvider.class); // .in(Singleton.class);

    bind(ServiceRepository.class);
    bind(IPAddressRepository.class);
    bind(BindAddressRepository.class);
    bind(MountPointRepository.class);

    // register the interceptor to persist commands
    bindInterceptor(
        any(),
        annotatedWith(EntityEnabled.class),
        new EntityInterceptor(getProvider(EntityManager.class)));
  }
}
