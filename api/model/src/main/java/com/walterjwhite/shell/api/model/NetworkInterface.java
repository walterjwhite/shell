package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.util.Objects;
import javax.persistence.*;

/** temporary class until the system configuration classes are moved in. */
@Entity
public class NetworkInterface extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected Node node;

  @Column(nullable = false, updatable = false)
  protected String interfaceName;

  /** All of the digRequestIPAddresses assigned to this interface */
  //  @OneToMany(cascade = CascadeType.ALL)
  //  @JoinTable
  //  protected Set<IPAddress> digRequestIPAddresses = new HashSet<>();

  public NetworkInterface(Node node, String interfaceName) {
    super();
    this.node = node;
    this.interfaceName = interfaceName;
  }

  public NetworkInterface() {
    super();
  }

  public Node getNode() {
    return node;
  }

  public void setNode(Node node) {
    this.node = node;
  }

  public String getInterfaceName() {
    return interfaceName;
  }

  public void setInterfaceName(String interfaceName) {
    this.interfaceName = interfaceName;
  }
  //
  //  public Set<IPAddress> getDigRequestIPAddresses() {
  //    return digRequestIPAddresses;
  //  }
  //
  //  public void setDigRequestIPAddresses(Set<IPAddress> digRequestIPAddresses) {
  //    this.digRequestIPAddresses = digRequestIPAddresses;
  //  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    NetworkInterface that = (NetworkInterface) o;
    return Objects.equals(node, that.node) && Objects.equals(interfaceName, that.interfaceName);
  }

  @Override
  public int hashCode() {

    return Objects.hash(node, interfaceName);
  }
}
