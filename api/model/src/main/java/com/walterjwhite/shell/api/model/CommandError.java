package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.util.Objects;
import javax.persistence.*;

@Entity
public class CommandError extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  @Column(nullable = false, updatable = false)
  protected int index;

  @Lob
  @Column(updatable = false)
  protected String output;

  public CommandError(ShellCommand shellCommand, int index, String output) {
    super();

    this.shellCommand = shellCommand;
    this.index = index;
    this.output = output;
  }

  public CommandError() {
    super();
  }

  public ShellCommand getShellCommand() {
    return shellCommand;
  }

  public void setShellCommand(ShellCommand shellCommand) {
    this.shellCommand = shellCommand;
  }

  public int getIndex() {
    return index;
  }

  public void setIndex(int index) {
    this.index = index;
  }

  public String getOutput() {
    return output;
  }

  public void setOutput(String output) {
    this.output = output;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    CommandError that = (CommandError) o;
    return index == that.index && Objects.equals(shellCommand, that.shellCommand);
  }

  @Override
  public int hashCode() {

    return Objects.hash(shellCommand, index);
  }

  @Override
  public String toString() {
    return "CommandError{" + "index=" + index + ", output='" + output + '\'' + '}';
  }
}
