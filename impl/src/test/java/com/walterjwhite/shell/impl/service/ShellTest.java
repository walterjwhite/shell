package com.walterjwhite.shell.impl.service;

import com.google.inject.persist.jpa.JpaPersistModule;
import com.walterjwhite.datastore.GoogleGuicePersistModule;
import com.walterjwhite.datastore.criteria.CriteriaBuilderModule;
import com.walterjwhite.google.guice.GuiceHelper;
import com.walterjwhite.google.guice.property.test.GuiceTestModule;
import com.walterjwhite.google.guice.property.test.PropertyValuePair;
import com.walterjwhite.shell.api.enumeration.ServiceAction;
import com.walterjwhite.shell.api.model.Service;
import com.walterjwhite.shell.api.model.ServiceCommand;
import com.walterjwhite.shell.api.property.NodeId;
import com.walterjwhite.shell.api.repository.ServiceRepository;
import com.walterjwhite.shell.api.service.SystemServiceService;
import com.walterjwhite.shell.impl.ShellModule;
import java.io.IOException;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ShellTest {
  private static final Logger LOGGER = LoggerFactory.getLogger(ShellTest.class);

  protected SystemServiceService systemServiceService;
  protected ServiceRepository serviceRepository;

  @Before
  public void before() throws Exception {
    GuiceHelper.addModules(
        new ShellModule(),
        new GoogleGuicePersistModule(),
        new JpaPersistModule("defaultJPAUnit"),
        new CriteriaBuilderModule(),
        new GuiceTestModule(new PropertyValuePair(NodeId.class, "test")));
    GuiceHelper.setup();
    systemServiceService = GuiceHelper.getGuiceInjector().getInstance(SystemServiceService.class);
    serviceRepository = GuiceHelper.getGuiceInjector().getInstance(ServiceRepository.class);
  }

  /**
   * This actually works and can read stdin to start the service as root.
   *
   * @throws IOException
   */
  @Test
  public void testStartingSSH() throws Exception {
    final Service service = serviceRepository.findByNameOrCreate("sshd");
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
