package com.walterjwhite.shell.impl.service;

import com.google.inject.persist.jpa.JpaPersistModule;
import com.walterjwhite.datastore.GoogleGuicePersistModule;
import com.walterjwhite.datastore.criteria.CriteriaBuilderModule;
import com.walterjwhite.google.guice.GuiceHelper;
import com.walterjwhite.shell.api.service.SystemServiceService;
import com.walterjwhite.shell.impl.ShellModule;
import java.io.InputStream;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ShellTest2 {
  private static final Logger LOGGER = LoggerFactory.getLogger(ShellTest2.class);

  protected SystemServiceService systemServiceService;

  @Before
  public void before() throws Exception {
    GuiceHelper.addModules(
        new ShellModule(),
        new GoogleGuicePersistModule(),
        new JpaPersistModule("defaultJPAUnit"),
        new CriteriaBuilderModule());
    GuiceHelper.setup();
    systemServiceService = GuiceHelper.getGuiceInjector().getInstance(SystemServiceService.class);
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
