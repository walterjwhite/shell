package com.walterjwhite.shell.impl.service;

import com.google.inject.persist.jpa.JpaPersistModule;
import com.walterjwhite.datastore.GoogleGuicePersistModule;
import com.walterjwhite.datastore.criteria.CriteriaBuilderModule;
import com.walterjwhite.google.guice.GuiceHelper;
import com.walterjwhite.google.guice.property.test.GuiceTestModule;
import com.walterjwhite.google.guice.property.test.PropertyValuePair;
import com.walterjwhite.shell.api.model.NetworkDiagnosticTest;
import com.walterjwhite.shell.api.model.ping.PingRequest;
import com.walterjwhite.shell.api.model.ping.PingResponse;
import com.walterjwhite.shell.api.property.NodeId;
import com.walterjwhite.shell.api.service.PingService;
import com.walterjwhite.shell.impl.ShellModule;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestPingService {
  private static final Logger LOGGER = LoggerFactory.getLogger(TestPingService.class);

  @Before
  public void onBefore() throws Exception {
    GuiceHelper.addModules(
        new ShellModule(),
        new GoogleGuicePersistModule(),
        new JpaPersistModule("defaultJPAUnit"),
        new CriteriaBuilderModule(),
        new GuiceTestModule(new PropertyValuePair(NodeId.class, "testing")));
    GuiceHelper.setup();
  }

  @Test
  public void pingGoogle() throws Exception {
    PingService pingService = GuiceHelper.getGuiceInjector().getInstance(PingService.class);

    final PingRequest pingRequest =
        new PingRequest(new NetworkDiagnosticTest("google.com", "google.com"));
    pingService.execute(pingRequest);
    LOGGER.info("ping:" + pingRequest.getPingResponseType());
    LOGGER.info("ping:" + pingRequest.getIpAddress());

    LOGGER.info("ping response: " + pingRequest.getPingResponseType());
    for (final PingResponse pingResponse : pingRequest.getPingResponses())
      LOGGER.info(
          "ping response: "
              + pingResponse.getIndex()
              + " "
              + pingResponse.getTime()
              + " "
              + pingResponse.getTtl());
  }
}
