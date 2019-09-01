package com.walterjwhite.shell.impl.service;

import com.walterjwhite.google.guice.GuiceHelper;
import com.walterjwhite.shell.api.enumeration.ServiceAction;
import com.walterjwhite.shell.api.model.Service;
import com.walterjwhite.shell.api.model.ServiceCommand;
import com.walterjwhite.shell.api.repository.ServiceEntityRepository;
import com.walterjwhite.shell.api.service.SystemServiceService;
import java.io.IOException;
import org.junit.Before;
import org.junit.Test;

public class ShellTest {

  protected SystemServiceService systemServiceService;
  protected ServiceEntityRepository serviceRepository;

  @Before
  public void before() throws Exception {
    GuiceHelper.addModules(new ShellTestModule(getClass()));

    GuiceHelper.setup();
    systemServiceService =
        GuiceHelper.getGuiceApplicationInjector().getInstance(SystemServiceService.class);
    serviceRepository =
        GuiceHelper.getGuiceApplicationInjector().getInstance(ServiceEntityRepository.class);
  }

  /**
   * This actually works and can read stdin to start the service as root.
   *
   * @throws IOException
   */
  @Test
  public void testStartingSSH() throws Exception {
    // @AutoCreate
    final Service service = serviceRepository.findByName("sshd");
    final ServiceCommand serviceCommand =
        systemServiceService.execute(
            new ServiceCommand().withService(service).withServiceAction(ServiceAction.Status));

    LOGGER.info(
        "output:"
            + serviceCommand.getServiceStatus().getShellCommand().getOutputs().get(0).getOutput());
    //    LOGGER.info("error:" + serviceStatus.getCommandOutput().getError());
    //    LOGGER.info("return code:" + serviceStatus.getCommandOutput().getReturnCode());
  }
}
