package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.util.Objects;
import javax.persistence.*;

@Entity
public class Node extends AbstractEntity {
  @Column(unique = true, nullable = false, updatable = false)
  protected String uuid;

  public Node(String uuid) {
    super();
    this.uuid = uuid;
  }

  public Node() {
    super();
  }

  public String getUuid() {
    return uuid;
  }

  public void setUuid(String uuid) {
    this.uuid = uuid;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    Node node = (Node) o;
    return Objects.equals(uuid, node.uuid);
  }

  @Override
  public int hashCode() {

    return Objects.hash(uuid);
  }

  @Override
  public String toString() {
    return getClass().getName() + "{" + "uuid='" + uuid + '\'' + '}';
  }
}
