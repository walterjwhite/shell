package com.walterjwhite.shell.impl.service;

import com.walterjwhite.google.guice.GuiceHelper;
import com.walterjwhite.shell.api.model.NetworkDiagnosticTest;
import com.walterjwhite.shell.api.model.ping.PingRequest;
import com.walterjwhite.shell.api.model.ping.PingResponse;
import com.walterjwhite.shell.api.service.PingService;
import org.junit.Before;
import org.junit.Test;

public class TestPingService {

  @Before
  public void onBefore() throws Exception {
    GuiceHelper.addModules(new ShellTestModule(getClass()));
    GuiceHelper.setup();
  }

  @Test
  public void pingGoogle() throws Exception {
    PingService pingService =
        GuiceHelper.getGuiceApplicationInjector().getInstance(PingService.class);

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
