package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.util.Objects;
import javax.persistence.*;

@Entity
public class ShellCommandEnvironmentProperty extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  @Column(nullable = false, updatable = false)
  protected String key;

  @Column(nullable = false, updatable = false)
  protected String value;

  public ShellCommandEnvironmentProperty(ShellCommand shellCommand, String key, String value) {
    super();

    this.shellCommand = shellCommand;
    this.key = key;
    this.value = value;
  }

  public ShellCommandEnvironmentProperty() {
    super();
  }

  public ShellCommand getShellCommand() {
    return shellCommand;
  }

  public void setShellCommand(ShellCommand shellCommand) {
    this.shellCommand = shellCommand;
  }

  public String getKey() {
    return key;
  }

  public void setKey(String key) {
    this.key = key;
  }

  public String getValue() {
    return value;
  }

  public void setValue(String value) {
    this.value = value;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    ShellCommandEnvironmentProperty that = (ShellCommandEnvironmentProperty) o;
    return Objects.equals(shellCommand, that.shellCommand) && Objects.equals(key, that.key);
  }

  @Override
  public int hashCode() {

    return Objects.hash(shellCommand, key);
  }
}
