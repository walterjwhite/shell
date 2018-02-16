package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractNamedEntity;
import java.util.Objects;
import javax.persistence.Column;
import javax.persistence.Entity;

@Entity
public class NetworkDiagnosticTest extends AbstractNamedEntity {
  @Column(nullable = false, unique = true)
  protected String fqdn;

  public NetworkDiagnosticTest() {
    super();
  }

  public NetworkDiagnosticTest(String name, String fqdn) {
    super(name);
    this.fqdn = fqdn;
  }

  public NetworkDiagnosticTest(String name, String description, String fqdn) {
    super(name, description);
    this.fqdn = fqdn;
  }

  public String getFqdn() {
    return fqdn;
  }

  public void setFqdn(String fqdn) {
    this.fqdn = fqdn;
  }

  public NetworkDiagnosticTest withFQDN(final String fqdn) {
    this.fqdn = fqdn;
    return this;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    if (!super.equals(o)) return false;
    NetworkDiagnosticTest that = (NetworkDiagnosticTest) o;
    return Objects.equals(fqdn, that.fqdn);
  }

  @Override
  public int hashCode() {

    return Objects.hash(super.hashCode(), fqdn);
  }
}
