package com.walterjwhite.shell.impl.service;

import com.walterjwhite.google.guice.GuiceHelper;
import com.walterjwhite.shell.api.service.SystemServiceService;
import java.io.InputStream;
import org.junit.Before;
import org.junit.Test;

public class ShellTest2 {

  protected SystemServiceService systemServiceService;

  @Before
  public void before() throws Exception {
    GuiceHelper.addModules(new ShellTestModule(getClass()));
    GuiceHelper.setup();
    systemServiceService =
        GuiceHelper.getGuiceApplicationInjector().getInstance(SystemServiceService.class);
  }

  @Test
  public void testShellPipe() throws Exception {
    int read = -1;
    //    final Process process = Runtime.getRuntime().exec("/bin/sh echo -e \"hi\nline 1\nline 2\"
    // | grep \"line\"");
    //    final Process process = Runtime.getRuntime().exec(new String[]{"/bin/sh", "-c", "ls -l|
    // grep foo"});
    final Process process =
        Runtime.getRuntime()
            .exec(new String[] {"/bin/sh", "-c", "echo -e \"hi\nline 1\nline 2\n\"| grep line"});
    //    final Process process = Runtime.getRuntime().exec("/bin/sh -c echo -e \"hi\nline 1\nline
    // 2\n\"| grep line");
    //    final Process process = Runtime.getRuntime().exec(new String[]{"/bin/sh -c echo -e
    // \"hi\nline 1\nline 2\n\"| grep line"});
    LOGGER.info("exit code:" + process.waitFor());
    try (final InputStream inputStream = process.getInputStream()) {
      final StringBuilder buffer = new StringBuilder();
      while ((read = inputStream.read()) != -1) {
        buffer.append((char) read);
      }

      LOGGER.info("read:" + buffer.toString());
    }
  }
}
