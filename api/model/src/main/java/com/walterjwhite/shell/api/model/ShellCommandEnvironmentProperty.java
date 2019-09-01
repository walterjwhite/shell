package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.*;
import lombok.*;

@Data
@ToString(doNotUseGetters = true)
@AllArgsConstructor
@NoArgsConstructor
// @PersistenceCapable
@Entity
public class ShellCommandEnvironmentProperty extends AbstractEntity {
  @ManyToOne(optional = false)
  @JoinColumn(nullable = false, updatable = false)
  protected ShellCommand shellCommand;

  @Column(nullable = false, updatable = false)
  protected String key;

  @EqualsAndHashCode.Exclude
  @Column(nullable = false, updatable = false)
  protected String value;
}
