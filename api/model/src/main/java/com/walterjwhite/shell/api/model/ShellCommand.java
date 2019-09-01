package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import java.time.LocalDateTime;
import java.util.*;
import javax.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@ToString(doNotUseGetters = true)
@Inheritance(strategy = InheritanceType.JOINED)
@NoArgsConstructor
// @PersistenceCapable
@Entity
public class ShellCommand extends AbstractEntity implements EnvironmentAware {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected Node node;

  @Lob
  @Column(nullable = false, updatable = false)
  protected String commandLine;

  @Column(updatable = false)
  protected String workingDirectory;

  @Column(nullable = false, updatable = false)
  protected LocalDateTime dateTime = LocalDateTime.now();

  /** Specify -1 for long-running, output will be streamed. */
  @EqualsAndHashCode.Exclude
  @Column(updatable = false)
  protected int timeout;

  @EqualsAndHashCode.Exclude
  @OneToMany(cascade = CascadeType.ALL, mappedBy = "shellCommand")
  protected Set<ShellCommandEnvironmentProperty> shellCommandEnvironmentProperties =
      new HashSet<>();

  @EqualsAndHashCode.Exclude @Column protected int returnCode;

  @EqualsAndHashCode.Exclude
  @OneToMany(cascade = CascadeType.ALL, mappedBy = "shellCommand")
  protected List<CommandOutput> outputs = new ArrayList<>();

  @EqualsAndHashCode.Exclude
  @OneToMany(cascade = CascadeType.ALL, mappedBy = "shellCommand")
  protected List<CommandError> errors = new ArrayList<>();

  public ShellCommand withTimeout(int timeout) {
    this.timeout = timeout;
    return this;
  }

  public ShellCommand withCommandLine(final String commandLine) {
    this.commandLine = commandLine;
    return this;
  }

  public ShellCommand withWorkingDirectory(final String workingDirectory) {
    this.workingDirectory = workingDirectory;
    return this;
  }
}
