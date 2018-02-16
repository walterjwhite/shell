package com.walterjwhite.shell.impl.service;

import com.google.inject.persist.jpa.JpaPersistModule;
import com.walterjwhite.datastore.GoogleGuicePersistModule;
import com.walterjwhite.datastore.criteria.CriteriaBuilderModule;
import com.walterjwhite.datastore.criteria.Repository;
import com.walterjwhite.google.guice.GuiceHelper;
import com.walterjwhite.google.guice.property.test.GuiceTestModule;
import com.walterjwhite.shell.api.enumeration.ServiceAction;
import com.walterjwhite.shell.api.model.*;
import com.walterjwhite.shell.api.service.SystemServiceService;
import com.walterjwhite.shell.impl.ShellModule;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestUnixSystemService {
  private static final Logger LOGGER = LoggerFactory.getLogger(TestUnixSystemService.class);

  @Before
  public void onBefore() throws Exception {
    GuiceHelper.addModules(
        new ShellModule(),
        new GoogleGuicePersistModule(),
        new GuiceTestModule(),
        new JpaPersistModule("defaultJPAUnit"),
        new CriteriaBuilderModule());
    GuiceHelper.setup();
  }

  @Test
  public void testServiceStatus() throws Exception {
    SystemServiceService systemServiceService =
        GuiceHelper.getGuiceInjector().getInstance(SystemServiceService.class);

    Repository repository = GuiceHelper.getGuiceInjector().getInstance(Repository.class);
    Service sshdService = new Service("sshd");
    repository.persist(sshdService);

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
