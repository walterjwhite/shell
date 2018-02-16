package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.time.LocalDateTime;
import java.util.*;
import javax.persistence.*;

@Inheritance(strategy = InheritanceType.JOINED)
@Entity
public class ShellCommand extends AbstractEntity implements EnvironmentAware {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected Node node;

  @Column(nullable = false, updatable = false)
  protected String commandLine;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  /** Specify -1 for long-running, output will be streamed. */
  @Column(updatable = false)
  protected int timeout;

  @OneToMany(cascade = CascadeType.ALL, mappedBy = "shellCommand")
  protected Set<ShellCommandEnvironmentProperty> shellCommandEnvironmentProperties =
      new HashSet<>();

  @Column protected int returnCode;

  @OneToMany(cascade = CascadeType.ALL, mappedBy = "shellCommand")
  protected List<CommandOutput> outputs = new ArrayList<>();

  @OneToMany(cascade = CascadeType.ALL, mappedBy = "shellCommand")
  protected List<CommandError> errors = new ArrayList<>();

  //  public ShellCommand(Node node, String commandLine, int timeout) {
  //    this();
  //    this.node = node;
  //    this.commandLine = commandLine;
  //    this.timeout = timeout;
  //  }
  //
  //  /** Node will be set @ runtime * */
  //  public ShellCommand(String commandLine, int timeout) {
  //    this(null, commandLine, timeout);
  //  }
  //
  //  public ShellCommand(String commandLine) {
  //    this(commandLine, -1);
  //  }

  public ShellCommand() {
    super();
  }

  public Node getNode() {
    return node;
  }

  public void setNode(Node node) {
    this.node = node;
  }

  public LocalDateTime getDateTime() {
    return dateTime;
  }

  public void setDateTime(LocalDateTime dateTime) {
    this.dateTime = dateTime;
  }

  public int getReturnCode() {
    return returnCode;
  }

  public void setReturnCode(int returnCode) {
    this.returnCode = returnCode;
  }

  public List<CommandOutput> getOutputs() {
    return outputs;
  }

  public void setOutputs(List<CommandOutput> outputs) {
    this.outputs = outputs;
  }

  public List<CommandError> getErrors() {
    return errors;
  }

  public void setErrors(List<CommandError> errors) {
    this.errors = errors;
  }

  public int getTimeout() {
    return timeout;
  }

  public void setTimeout(int timeout) {
    this.timeout = timeout;
  }

  public Set<ShellCommandEnvironmentProperty> getShellCommandEnvironmentProperties() {
    return shellCommandEnvironmentProperties;
  }

  public void setShellCommandEnvironmentProperties(
      Set<ShellCommandEnvironmentProperty> shellCommandEnvironmentProperties) {
    this.shellCommandEnvironmentProperties = shellCommandEnvironmentProperties;
  }

  public void setCommandLine(String commandLine) {
    this.commandLine = commandLine;
  }

  public String getCommandLine() {
    return commandLine;
  }

  public ShellCommand withTimeout(int timeout) {
    this.timeout = timeout;
    return this;
  }

  public ShellCommand withCommandLine(final String commandLine) {
    this.commandLine = commandLine;
    return this;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    ShellCommand that = (ShellCommand) o;
    return Objects.equals(node, that.node)
        && Objects.equals(commandLine, that.commandLine)
        && Objects.equals(dateTime, that.dateTime);
  }

  @Override
  public int hashCode() {

    return Objects.hash(node, commandLine, dateTime);
  }

  @Override
  public String toString() {
    return "ShellCommand{"
        + "node="
        + node
        + ", commandLine='"
        + commandLine
        + '\''
        + ", timeout="
        + timeout
        + '}';
  }
}
