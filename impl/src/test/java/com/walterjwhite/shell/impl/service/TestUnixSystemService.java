package com.walterjwhite.shell.impl.service;

import com.walterjwhite.datastore.api.repository.AbstractEntityRepository;
import com.walterjwhite.google.guice.GuiceHelper;
import com.walterjwhite.shell.api.enumeration.ServiceAction;
import com.walterjwhite.shell.api.model.*;
import com.walterjwhite.shell.api.service.SystemServiceService;
import org.junit.Before;
import org.junit.Test;

public class TestUnixSystemService {

  @Before
  public void onBefore() throws Exception {
    GuiceHelper.addModules(new ShellTestModule(getClass()));
    GuiceHelper.setup();
  }

  @Test
  public void testServiceStatus() throws Exception {
    SystemServiceService systemServiceService =
        GuiceHelper.getGuiceApplicationInjector().getInstance(SystemServiceService.class);

    AbstractEntityRepository entityRepository =
        GuiceHelper.getGuiceApplicationInjector().getInstance(AbstractEntityRepository.class);
    Service sshdService = new Service("sshd");
    entityRepository.persist(sshdService);

    final ServiceCommand serviceCommand =
        systemServiceService.execute(
            new ServiceCommand().withService(sshdService).withServiceAction(ServiceAction.Status));
    LOGGER.info("status:" + serviceCommand.getServiceStatus().getService().getName());

    for (final BindAddressState addressState :
        serviceCommand.getServiceStatus().getBindAddressStates()) {
      LOGGER.info(
          "\tlistening on:"
              + addressState.getBindAddress().getIpAddress()
              + ":"
              + addressState.getBindAddress().getPort()
              + "("
              + addressState.getBindAddress().getProtocol()
              + ")");
    }
  }
}
