package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.*;
import lombok.*;

@Data
@ToString(doNotUseGetters = true)
@NoArgsConstructor
@AllArgsConstructor
// @PersistenceCapable
@Entity
public class CommandOutput extends AbstractEntity {
  @ToString.Exclude
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  @Column(nullable = false, updatable = false)
  protected int index;

  @EqualsAndHashCode.Exclude
  @Lob
  @Column(updatable = false)
  protected String output;
}
