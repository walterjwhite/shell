package com.walterjwhite.shell.impl.service;

import com.walterjwhite.datastore.api.repository.Repository;
import com.walterjwhite.property.impl.annotation.Property;
import com.walterjwhite.shell.api.model.CommandOutput;
import com.walterjwhite.shell.api.model.dig.DigRequest;
import com.walterjwhite.shell.api.model.dig.DigRequestIPAddress;
import com.walterjwhite.shell.api.service.DigService;
import com.walterjwhite.shell.api.service.ShellExecutionService;
import com.walterjwhite.shell.impl.property.DigTimeout;
import com.walterjwhite.shell.impl.query.FindIPAddressByIPAddressQuery;
import java.time.LocalDateTime;
import javax.inject.Inject;
import javax.inject.Provider;

public class DefaultDigService extends AbstractSingleShellCommandService<DigRequest>
    implements DigService {
  protected final Provider<Repository> repositoryProvider;

  @Inject
  public DefaultDigService(
      ShellCommandBuilder shellCommandBuilder,
      ShellExecutionService shellExecutionService,
      @Property(DigTimeout.class) int timeout,
      Provider<Repository> repositoryProvider) {
    super(shellCommandBuilder, shellExecutionService, timeout);
    this.repositoryProvider = repositoryProvider;
  }

  protected void doAfter(DigRequest digRequest) {
    for (final CommandOutput commandOutput : digRequest.getShellCommand().getOutputs()) {
      digRequest.getDigRequestIPAddresses().add(getIPAddress(commandOutput, digRequest));
    }
  }

  protected DigRequestIPAddress getIPAddress(CommandOutput commandOutput, DigRequest digRequest) {
    return new DigRequestIPAddress(
        LocalDateTime.now(),
        repositoryProvider
            .get()
            .query(new FindIPAddressByIPAddressQuery(commandOutput.getOutput())),
        digRequest);
  }

  protected String getCommandLine(DigRequest digRequest) {
    return "dig -4 +short " + digRequest.getNetworkDiagnosticTest().getFqdn();
  }
}
